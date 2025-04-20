# Karma Farm

Karma Farm is a community-driven mobile app that lets users request and offer help, earning "Karma Points" in the process. Built with React Native, Expo, and Supabase.

<p align="center">
  <img src="./assets/logo.png" alt="Karma Farm Logo" width="200">
</p>

## Features

- **Passwordless Authentication**: Phone number OTP via Supabase Auth with optional email verification
- **Interactive Map**: Shows clustered markers of nearby help requests and offers
- **Feed**: Browse and filter tasks, skillshares, and interests
- **Real-time Chat**: Connect with other users through direct messaging
- **Karma System**: Track and reward helpful actions with Karma Points
- **Profile**: Showcase your skills, reviews, and karma history

## Tech Stack

- **Frontend**: React Native + Expo + TypeScript
- **UI Library**: Tamagui
- **State Management**: Zustand
- **Navigation**: React Navigation v7
- **Backend**: Supabase (Auth, Postgres, Row-Level Security, Realtime)
- **Maps**: react-native-maps with Google Maps SDK

## Quick Start

### Prerequisites

- Node.js (v16+)
- pnpm
- Expo CLI
- A Supabase account

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/karma-farm.git
   cd karma-farm
   ```

2. Install dependencies:
   ```bash
   pnpm install
   ```

3. Create a `.env` file in the root directory with your Supabase credentials:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   ```

4. Set up the Supabase database:
   - Create a new Supabase project
   - Run the schema setup script from `supabase/schema.sql`

5. Start the development server:
   ```bash
   pnpm dev
   ```

## Project Structure

```
karma-farm/
├── app/
│   ├── components/    # Reusable UI components
│   ├── hooks/         # Custom hooks
│   ├── navigation/    # Navigation structure
│   ├── screens/       # Screen components
│   ├── store/         # Zustand state stores
│   └── utils/         # Utility functions
├── assets/            # Images, fonts, etc.
├── lib/               # Core libraries
│   ├── supabase.ts    # Supabase client
│   └── types.ts       # TypeScript types
└── supabase/          # Supabase configuration
    └── schema.sql     # Database schema
```

## Core Components

- **Avatar**: Displays user avatar with badges
- **Badge**: Shows verification status (Tufts, Verified)
- **KarmaCounter**: Displays karma with animation on increment
- **PostCard**: Renders post details in feed
- **MapMarker**: Customizable markers for posts on map
- **RatingStars**: Star rating component
- **DistanceSlider**: Filter posts by distance

## Authentication Flow

1. Phone number validation
2. OTP verification
3. Optional email verification (Badge for Tufts emails)
4. Face verification placeholder (for future integration)

## Data Models

The app uses the following main Postgres tables:
- `users`: User profiles with karma totals
- `posts`: Help requests and offers
- `chats`: Conversation rooms between users
- `messages`: Individual chat messages
- `karma_transactions`: Record of karma transfers
- `reviews`: User ratings and testimonials

## Future Work

- **Push Notifications**: Implement Expo Push for alerts on new messages and nearby posts
- **Onfido Integration**: Complete the face verification flow for enhanced security
- **Stripe Integration**: Add payment escrow for certain types of tasks
- **Community Features**: Groups, teams, and community challenges
- **Analytics Dashboard**: Insights on community impact and karma flow

## Testing

The project includes:
- Unit tests for auth, posts, and karma functionality
- E2E test for the auth flow

Run tests with:
```bash
pnpm test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License. 