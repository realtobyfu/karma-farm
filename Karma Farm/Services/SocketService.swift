//
//  SocketService.swift
//  Karma Farm
//
//  Created by Claude on 9/15/25.
//

import Foundation
import Network
import Combine

// MARK: - Socket Events
enum SocketEvent: String, CaseIterable {
    case connect = "connect"
    case disconnect = "disconnect"
    case newMessage = "new_message"
    case messageRead = "message_read"
    case typingStart = "typing_start"
    case typingStop = "typing_stop"
    case userPresence = "user_presence"
    case joinChat = "join_chat"
    case leaveChat = "leave_chat"
    case error = "error"
}

// MARK: - Socket Message Models
struct SocketMessage: Codable {
    let event: String
    let data: SocketData?
    let timestamp: Date

    init(event: SocketEvent, data: SocketData? = nil) {
        self.event = event.rawValue
        self.data = data
        self.timestamp = Date()
    }
}

struct SocketData: Codable {
    let chatId: String?
    let userId: String?
    let messageId: String?
    let content: String?
    let isTyping: Bool?
    let isOnline: Bool?
    let message: Message?

    init(chatId: String? = nil, userId: String? = nil, messageId: String? = nil,
         content: String? = nil, isTyping: Bool? = nil, isOnline: Bool? = nil, message: Message? = nil) {
        self.chatId = chatId
        self.userId = userId
        self.messageId = messageId
        self.content = content
        self.isTyping = isTyping
        self.isOnline = isOnline
        self.message = message
    }
}

// MARK: - Connection State
enum SocketConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case failed(Error)

    var isConnected: Bool {
        if case .connected = self {
            return true
        }
        return false
    }

    static func == (lhs: SocketConnectionState, rhs: SocketConnectionState) -> Bool {
        switch (lhs, rhs) {
        case (.disconnected, .disconnected),
             (.connecting, .connecting),
             (.connected, .connected),
             (.reconnecting, .reconnecting):
            return true
        case (.failed, .failed):
            // For failed states, we consider them equal regardless of the error
            return true
        default:
            return false
        }
    }
}

// MARK: - SocketService Actor
@globalActor
actor SocketServiceActor {
    static let shared = SocketServiceActor()
}

@SocketServiceActor
class SocketService: ObservableObject {
    static let shared = SocketService()

    // MARK: - Published Properties
    @MainActor @Published var connectionState: SocketConnectionState = .disconnected
    @MainActor @Published var isConnected: Bool = false

    // MARK: - Private Properties
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "SocketService.NetworkMonitor")

    private var currentUserId: String?
    private var reconnectionAttempts = 0
    private let maxReconnectionAttempts = 5
    private var reconnectionTimer: Timer?

    // Event handlers
    private var messageHandlers: [(String, Message) -> Void] = []
    private var typingHandlers: [(String, String, Bool) -> Void] = []
    private var presenceHandlers: [(String, Bool) -> Void] = []
    private var readReceiptHandlers: [(String, String, String) -> Void] = []

    // MARK: - Initialization
    private init() {
        setupNetworkMonitoring()
    }

    // MARK: - Connection Management
    nonisolated func connect(userId: String) {
        Task { @SocketServiceActor in
            await _connect(userId: userId)
        }
    }

    private func _connect(userId: String) async {
        guard !(await MainActor.run { connectionState == .connected || connectionState == .connecting }) else { return }

        currentUserId = userId
        await updateConnectionState(.connecting)

        guard let url = buildWebSocketURL(userId: userId) else {
            await updateConnectionState(.failed(SocketError.invalidURL))
            return
        }

        // Create URLRequest with authentication headers if needed
        var request = URLRequest(url: url)
        if let idToken = await AuthManager.shared.getIDToken() {
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        }

        urlSession = URLSession(configuration: .default)
        webSocketTask = urlSession?.webSocketTask(with: request)

        webSocketTask?.resume()

        // Start listening for messages
        await startListening()

        // Send connect event
        await sendSocketMessage(SocketMessage(event: .connect, data: SocketData(userId: userId)))

        await updateConnectionState(.connected)
        reconnectionAttempts = 0
    }

    nonisolated func disconnect() {
        Task { @SocketServiceActor in
            await _disconnect()
        }
    }

    private func _disconnect() async {
        reconnectionTimer?.invalidate()
        reconnectionTimer = nil

        if let userId = currentUserId {
            await sendSocketMessage(SocketMessage(event: .disconnect, data: SocketData(userId: userId)))
        }

        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        urlSession?.invalidateAndCancel()
        urlSession = nil

        await updateConnectionState(.disconnected)
        currentUserId = nil
        reconnectionAttempts = 0
    }

    // MARK: - Message Handling
    private func startListening() async {
        guard let webSocketTask = webSocketTask else { return }

        do {
            let message = try await webSocketTask.receive()

            switch message {
            case .string(let text):
                await handleReceivedMessage(text)
            case .data(let data):
                if let text = String(data: data, encoding: .utf8) {
                    await handleReceivedMessage(text)
                }
            @unknown default:
                break
            }

            // Continue listening if still connected
            if await MainActor.run { connectionState.isConnected } {
                await startListening()
            }
        } catch {
            await handleConnectionError(error)
        }
    }

    private func handleReceivedMessage(_ text: String) async {
        guard let data = text.data(using: .utf8) else { return }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601

            let socketMessage = try decoder.decode(SocketMessage.self, from: data)
            await processSocketMessage(socketMessage)
        } catch {
            print("Failed to decode socket message: \(error)")
        }
    }

    private func processSocketMessage(_ message: SocketMessage) async {
        guard let eventType = SocketEvent(rawValue: message.event),
              let data = message.data else { return }

        switch eventType {
        case .newMessage:
            if let chatId = data.chatId, let message = data.message {
                await notifyMessageHandlers(chatId: chatId, message: message)
            }

        case .typingStart, .typingStop:
            if let chatId = data.chatId, let userId = data.userId {
                let isTyping = eventType == .typingStart
                await notifyTypingHandlers(chatId: chatId, userId: userId, isTyping: isTyping)
            }

        case .userPresence:
            if let userId = data.userId, let isOnline = data.isOnline {
                await notifyPresenceHandlers(userId: userId, isOnline: isOnline)
            }

        case .messageRead:
            if let chatId = data.chatId, let userId = data.userId, let messageId = data.messageId {
                await notifyReadReceiptHandlers(chatId: chatId, userId: userId, messageId: messageId)
            }

        case .connect, .disconnect, .joinChat, .leaveChat:
            // These are handled automatically
            break

        case .error:
            if let content = data.content {
                await handleSocketError(content)
            }
        }
    }

    private func sendSocketMessage(_ message: SocketMessage) async {
        guard let webSocketTask = webSocketTask else { return }
        let isConnected = await MainActor.run { connectionState.isConnected }
        guard isConnected else { return }

        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            encoder.dateEncodingStrategy = .iso8601

            let data = try encoder.encode(message)
            let text = String(data: data, encoding: .utf8) ?? ""

            try await webSocketTask.send(.string(text))
        } catch {
            print("Failed to send socket message: \(error)")
        }
    }

    // MARK: - Chat Operations
    nonisolated func joinChat(chatId: String, userId: String) {
        Task { @SocketServiceActor in
            await sendSocketMessage(
                SocketMessage(event: .joinChat, data: SocketData(chatId: chatId, userId: userId))
            )
        }
    }

    nonisolated func leaveChat(chatId: String) {
        Task { @SocketServiceActor in
            await sendSocketMessage(
                SocketMessage(event: .leaveChat, data: SocketData(chatId: chatId))
            )
        }
    }

    nonisolated func sendMessage(chatId: String, userId: String, content: String) {
        Task { @SocketServiceActor in
            await sendSocketMessage(
                SocketMessage(event: .newMessage, data: SocketData(chatId: chatId, userId: userId, content: content))
            )
        }
    }

    nonisolated func updateTypingStatus(chatId: String, userId: String, isTyping: Bool) {
        Task { @SocketServiceActor in
            let event: SocketEvent = isTyping ? .typingStart : .typingStop
            await sendSocketMessage(
                SocketMessage(event: event, data: SocketData(chatId: chatId, userId: userId, isTyping: isTyping))
            )
        }
    }

    nonisolated func markMessageAsRead(chatId: String, userId: String, messageId: String) {
        Task { @SocketServiceActor in
            await sendSocketMessage(
                SocketMessage(event: .messageRead, data: SocketData(chatId: chatId, userId: userId, messageId: messageId))
            )
        }
    }

    // MARK: - Event Handlers
    nonisolated func onNewMessage(handler: @escaping (String, Message) -> Void) {
        Task { @SocketServiceActor in
            messageHandlers.append(handler)
        }
    }

    nonisolated func onTypingUpdate(handler: @escaping (String, String, Bool) -> Void) {
        Task { @SocketServiceActor in
            typingHandlers.append(handler)
        }
    }

    nonisolated func onPresenceUpdate(handler: @escaping (String, Bool) -> Void) {
        Task { @SocketServiceActor in
            presenceHandlers.append(handler)
        }
    }

    nonisolated func onReadUpdate(handler: @escaping (String, String, String) -> Void) {
        Task { @SocketServiceActor in
            readReceiptHandlers.append(handler)
        }
    }

    // MARK: - Handler Notifications
    private func notifyMessageHandlers(chatId: String, message: Message) async {
        for handler in messageHandlers {
            handler(chatId, message)
        }
    }

    private func notifyTypingHandlers(chatId: String, userId: String, isTyping: Bool) async {
        for handler in typingHandlers {
            handler(chatId, userId, isTyping)
        }
    }

    private func notifyPresenceHandlers(userId: String, isOnline: Bool) async {
        for handler in presenceHandlers {
            handler(userId, isOnline)
        }
    }

    private func notifyReadReceiptHandlers(chatId: String, userId: String, messageId: String) async {
        for handler in readReceiptHandlers {
            handler(chatId, userId, messageId)
        }
    }

    // MARK: - Connection State Management
    @MainActor
    private func updateConnectionState(_ newState: SocketConnectionState) {
        connectionState = newState
        isConnected = newState.isConnected
    }

    // MARK: - Error Handling
    private func handleConnectionError(_ error: Error) async {
        print("WebSocket connection error: \(error)")
        await updateConnectionState(.failed(error))

        // Attempt reconnection if we have a user ID
        if let userId = currentUserId, reconnectionAttempts < maxReconnectionAttempts {
            await attemptReconnection(userId: userId)
        }
    }

    private func handleSocketError(_ message: String) async {
        print("Socket error received: \(message)")
    }

    // MARK: - Reconnection Logic
    private func attemptReconnection(userId: String) async {
        guard reconnectionAttempts < maxReconnectionAttempts else {
            print("Max reconnection attempts reached")
            return
        }

        reconnectionAttempts += 1
        await updateConnectionState(.reconnecting)

        // Exponential backoff: 2^attempt seconds
        let delay = min(pow(2.0, Double(reconnectionAttempts)), 30.0)

        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        if case .reconnecting = await MainActor.run { connectionState } {
            await _connect(userId: userId)
        }
    }

    // MARK: - Network Monitoring
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @SocketServiceActor in
                if path.status == .satisfied {
                    // Network is available, attempt reconnection if needed
                    if let self = self, let userId = self.currentUserId,
                       !(await MainActor.run { self.connectionState.isConnected }) && self.reconnectionAttempts > 0 {
                        await self.attemptReconnection(userId: userId)
                    }
                } else {
                    // Network is unavailable
                    await self?.updateConnectionState(.disconnected)
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }

    // MARK: - Utilities
    private func buildWebSocketURL(userId: String) -> URL? {
        var components = URLComponents()
        components.scheme = APIConfig.baseURL.hasPrefix("https") ? "wss" : "ws"
        components.host = URL(string: APIConfig.baseURL)?.host
        components.port = URL(string: APIConfig.baseURL)?.port
        components.path = "/socket"
        components.queryItems = [
            URLQueryItem(name: "userId", value: userId)
        ]
        return components.url
    }

    // MARK: - Public Interface
    nonisolated var isSocketConnected: Bool {
        get async {
            await MainActor.run { connectionState.isConnected }
        }
    }

    deinit {
        monitor.cancel()
        Task { @SocketServiceActor in
            await _disconnect()
        }
    }
}

// MARK: - Socket Errors
enum SocketError: LocalizedError {
    case invalidURL
    case connectionFailed
    case authenticationFailed
    case messageEncodingFailed
    case messageDecodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid WebSocket URL"
        case .connectionFailed:
            return "Failed to connect to WebSocket"
        case .authenticationFailed:
            return "WebSocket authentication failed"
        case .messageEncodingFailed:
            return "Failed to encode socket message"
        case .messageDecodingFailed:
            return "Failed to decode socket message"
        }
    }
}
