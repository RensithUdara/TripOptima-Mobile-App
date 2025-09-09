# TripOptima Mobile App

![TripOptima Logo](assets/images/logo.png)

## 📱 Overview

TripOptima is a comprehensive travel planning and management mobile application built with Flutter. It helps users plan, organize, and optimize their trips with features such as itinerary creation, destination discovery, real-time weather forecasts, route optimization, and expense tracking.

## ✨ Features

### 🧳 Trip Management
- Create and manage multiple trips with detailed itineraries
- Add destinations, accommodations, and activities to your trips
- View trip timelines and schedules
- Get personalized trip recommendations based on preferences

### 🗺️ Exploration
- Discover popular destinations and attractions
- Search for places with advanced filtering options
- Save favorite locations for future trips
- Get route optimization for multiple destinations

### 🌤️ Weather Integration
- Real-time weather forecasts for trip destinations
- 5-day weather predictions
- Weather-based activity recommendations

### 👤 User Profile
- Secure authentication with email/password and Google Sign-in
- Personalized user profiles
- Travel preferences and history
- Favorite destinations management

### 📊 Additional Tools
- Trip expense tracking
- Packing list management
- Travel notes and reminders
- Share trips with friends and family

## 📱 Screenshots

![App Screenshots](assets/images/screenshots.png)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version ^3.5.3)
- Dart SDK (version ^3.0.0)
- Android Studio / VS Code with Flutter plugins
- Firebase account for backend services
- Google Maps API key

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/trip-optima-mobile-app.git
cd trip-optima-mobile-app
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Configure Firebase:**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android and iOS apps in your Firebase project
   - Download the configuration files:
     - `google-services.json` for Android (place in `android/app/`)
     - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
   - Enable Authentication services (Email/Password and Google Sign-in)

4. **Set up Google Maps:**
   - Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Add it to:
     - Android: `android/app/src/main/AndroidManifest.xml`
     - iOS: `ios/Runner/AppDelegate.swift`

5. **Configure environment variables:**
   - Create a `.env` file at the root of the project with:
   ```
   GOOGLE_MAPS_API_KEY=your_api_key_here
   WEATHER_API_KEY=your_weather_api_key_here
   ```

6. **Run the app:**
```bash
flutter run
```

## 🏗️ Project Structure

```
lib/
├── constants/              # App-wide constants and theme configuration
├── models/                 # Data models for the application
│   ├── location_model.dart # Location data structure
│   ├── trip_model.dart     # Trip data structure
│   └── ...                 # Other data models
├── providers/              # State management providers
│   ├── app_providers.dart  # Provider aggregator
│   ├── auth_provider.dart  # Authentication state management
│   ├── location_provider.dart # Location services
│   ├── trip_provider.dart  # Trip data management
│   ├── route_provider.dart # Route calculation and optimization
│   ├── weather_provider.dart # Weather data fetching
│   ├── scoring_provider.dart # Trip scoring algorithm
│   └── ui_provider.dart    # UI state management
├── services/               # Business logic and external service integrations
│   ├── auth_service.dart   # Firebase authentication
│   ├── location_service.dart # Geolocation services
│   ├── weather_service.dart # Weather API integration
│   └── ...                 # Other services
├── utils/                  # Utility functions and helper classes
│   ├── app_preferences.dart # Local storage utilities
│   └── ...                 # Other utilities
├── views/                  # UI screens and components
│   ├── auth/               # Authentication screens
│   ├── explore/            # Location exploration screens
│   ├── home_screen.dart    # Main home screen
│   ├── map/                # Map views
│   ├── notifications/      # Notification screens
│   ├── profile/            # User profile screens
│   ├── splash_screen.dart  # App splash screen
│   └── trips/              # Trip management screens
├── widgets/                # Reusable UI components
│   └── ...                 # Various widgets
├── firebase_options.dart   # Firebase configuration
└── main.dart               # Application entry point
```

## 🔧 Architecture

TripOptima follows a **Provider** pattern for state management with a layered architecture:

- **Presentation Layer** (Views): UI components that display data to the user
- **State Management Layer** (Providers): Manages the application state and business logic
- **Data Layer** (Models & Services): Handles data operations and external API calls

## 📦 Key Dependencies

### State Management
- `provider`: ^6.1.1 - For state management across the app

### Firebase & Authentication
- `firebase_core`: ^2.24.2 - Firebase core functionality
- `firebase_auth`: ^4.15.3 - Authentication services
- `google_sign_in`: ^6.1.6 - Google authentication integration

### Networking & API
- `http`: ^1.1.0 - HTTP client for API calls
- `dio`: ^5.3.3 - Advanced HTTP client with interceptors

### Location & Maps
- `geolocator`: ^10.1.0 - Get device location
- `geocoding`: ^2.1.1 - Convert coordinates to addresses
- `google_maps_flutter`: ^2.5.0 - Display and interact with maps
- `google_place`: ^0.4.7 - Google Places API integration
- `flutter_polyline_points`: ^1.0.0 - Generate polylines for routes

### Data Storage
- `shared_preferences`: ^2.2.2 - Simple key-value storage
- `sqflite`: ^2.3.0 - SQLite database access
- `hive`: ^2.2.3 - NoSQL database solution
- `path_provider`: ^2.1.1 - File system path resolution

### UI Components
- `flutter_spinkit`: ^5.2.0 - Loading indicators
- `cached_network_image`: ^3.3.0 - Image caching
- `shimmer`: ^3.0.0 - Shimmer loading effects
- `lottie`: ^2.7.0 - Lottie animation support

### Weather
- `weather`: ^3.1.1 - Weather data API integration

### Utilities
- `intl`: ^0.18.1 - Internationalization and formatting
- `connectivity_plus`: ^5.0.1 - Network connectivity detection
- `permission_handler`: ^11.0.1 - Handle runtime permissions
- `flutter_dotenv`: ^5.1.0 - Environment variable management
- `url_launcher`: ^6.1.11 - Launch external URLs
- `uuid`: ^4.2.1 - Generate unique IDs

## 📱 Supported Platforms

- Android
- iOS
- Web (experimental)
- macOS (experimental)
- Windows (experimental)

## 🔐 Authentication Flow

1. **User Registration**:
   - Email and password registration
   - Google Sign-in integration
   - Account verification via email

2. **User Login**:
   - Email/password login
   - Social media login
   - Password recovery functionality

## 🌐 API Integrations

- **Firebase**: Authentication, data storage, and cloud functions
- **Google Maps Platform**: Maps, places, and directions
- **Weather API**: Real-time weather forecasts
- **Custom Backend API**: Trip data synchronization

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Credits

- **[Your Name]** - *Initial work* - [YourGitHub](https://github.com/yourgithub)

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev/) - UI framework
- [Firebase](https://firebase.google.com/) - Backend services
- [Google Maps Platform](https://cloud.google.com/maps-platform) - Location services
- [Weather API](https://www.weatherapi.com/) - Weather data
