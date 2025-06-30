import SwiftUI

// MARK: - Custom Page Transition
struct PageTransition: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 1 : 0)
            .scaleEffect(isActive ? 1 : 0.95)
            .offset(x: isActive ? 0 : 20)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isActive)
    }
}

// MARK: - Slide Up Transition
struct SlideUpTransition: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 1 : 0)
            .offset(y: isActive ? 0 : 50)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isActive)
    }
}

// MARK: - Fade Scale Transition
struct FadeScaleTransition: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 1 : 0)
            .scaleEffect(isActive ? 1 : 0.8)
            .blur(radius: isActive ? 0 : 10)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isActive)
    }
}

// MARK: - Custom Transitions Extension
extension AnyTransition {
    static var slideAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
    
    static var scaleAndFade: AnyTransition {
        .scale(scale: 0.8).combined(with: .opacity)
    }
    
    static var bounceIn: AnyTransition {
        .modifier(
            active: BounceTransitionModifier(scale: 0.3),
            identity: BounceTransitionModifier(scale: 1)
        )
    }
}

struct BounceTransitionModifier: ViewModifier {
    let scale: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(scale == 1 ? 1 : 0)
    }
}

// MARK: - Loading Skeleton Animation
struct SkeletonModifier: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color(UIColor.systemGray5),
                        Color(UIColor.systemGray6),
                        Color(UIColor.systemGray5)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(25))
                .offset(x: isAnimating ? 300 : -300)
                .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
            )
            .onAppear { isAnimating = true }
    }
}

extension View {
    func skeleton() -> some View {
        modifier(SkeletonModifier())
    }
    
    func pageTransition(isActive: Bool) -> some View {
        modifier(PageTransition(isActive: isActive))
    }
    
    func slideUpTransition(isActive: Bool) -> some View {
        modifier(SlideUpTransition(isActive: isActive))
    }
    
    func fadeScaleTransition(isActive: Bool) -> some View {
        modifier(FadeScaleTransition(isActive: isActive))
    }
}

// MARK: - Success Checkmark Animation
struct SuccessCheckmark: View {
    @State private var trimEnd: CGFloat = 0
    @State private var scale: CGFloat = 0
    let size: CGFloat
    let color: Color
    
    init(size: CGFloat = 60, color: Color = DesignSystem.Colors.primaryGreen) {
        self.size = size
        self.color = color
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 3)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: trimEnd)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
            
            Image(systemName: "checkmark")
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(color)
                .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                trimEnd = 1
            }
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.4)) {
                scale = 1
            }
        }
    }
}

// MARK: - Parallax Scroll Effect
struct ParallaxScrollModifier: ViewModifier {
    let geometry: GeometryProxy
    let speed: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(y: geometry.frame(in: .global).minY * speed)
    }
}

extension View {
    func parallaxScroll(geometry: GeometryProxy, speed: CGFloat = 0.5) -> some View {
        modifier(ParallaxScrollModifier(geometry: geometry, speed: speed))
    }
}