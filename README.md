# Vivu Travel Mobile Application

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)]()

**Vivu Travel** is a comprehensive mobile travel planning and management application built with Flutter, featuring intelligent itinerary management, AI-powered recommendations, and collaborative travel planning capabilities.

## 🚀 Overview

Vivu Travel is an enterprise-grade mobile application that revolutionizes travel planning through advanced technology integration. Built with Clean Architecture principles and modern Flutter development practices, the application provides a seamless experience for creating, managing, and sharing travel itineraries with real-time collaboration features.

### Key Highlights
- **Enterprise Architecture**: Clean Architecture with BLoC pattern and Dependency Injection
- **AI Integration**: Intelligent travel recommendations and automated itinerary generation
- **Real-time Collaboration**: Multi-user itinerary sharing and management
- **Location Services**: Advanced mapping and geolocation capabilities
- **Security**: JWT-based authentication with secure token management

## 🏗️ Architecture

### Clean Architecture Implementation

The application follows **Clean Architecture** principles with clear separation of concerns across three distinct layers:

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│  (UI, BLoC, Widgets, Controllers)   │
├─────────────────────────────────────┤
│       Domain Layer                   │
│  (Entities, Use Cases, Repository)  │
├─────────────────────────────────────┤
│        Data Layer                    │
│  (Models, DataSources, Repository)  │
└─────────────────────────────────────┘
```

#### Layer Responsibilities:

1. **Presentation Layer** (`presentation/`)
   - User interface components and screens
   - BLoC state management implementation
   - Form controllers and validation
   - Event and State definitions

2. **Domain Layer** (`domain/`)
   - Business entities and domain models
   - Use cases containing business logic
   - Repository interfaces (contracts)
   - Framework-independent core logic

3. **Data Layer** (`data/`)
   - JSON serializable data models
   - Remote and local data sources
   - Repository implementations
   - API client configurations

### State Management: BLoC Pattern

Implements `flutter_bloc` for predictable state management:
- **Events**: User actions and system triggers
- **States**: Application state representations
- **Bloc**: Business logic processing and Event → State transformations

### Dependency Injection: GetIt

Utilizes `get_it` for comprehensive dependency management:
- `registerLazySingleton`: Long-lived services and repositories
- `registerFactory`: Short-lived components like BLoCs

## 🎯 Core Features

### 1. Authentication & Security
- ✅ **Multi-factor Authentication**: Email OTP verification system
- ✅ **Secure Login/Registration**: JWT-based authentication with auto-refresh
- ✅ **Password Management**: Forgot password, reset, and change password flows
- ✅ **Secure Storage**: Encrypted credential storage using Flutter Secure Storage
- ✅ **Session Management**: Automatic token refresh and session timeout handling

### 2. Intelligent Schedule Management
- ✅ **Dynamic Itinerary Creation**: AI-powered schedule generation and manual editing
- ✅ **Activity Management**: Comprehensive activity planning with time slots and locations
- ✅ **Location Services**: Check-in/check-out functionality with GPS integration
- ✅ **Collaborative Planning**: Multi-user itinerary sharing and real-time updates
- ✅ **QR Code Integration**: Quick schedule joining via QR code scanning
- ✅ **Role-based Access**: Owner, Editor, and Viewer permission levels
- ✅ **Smart Checklists**: Packing lists and travel essentials management
- ✅ **Media Integration**: Photo and video uploads for activities
- ✅ **Geocoding Services**: Advanced address search using Mapbox APIs
- ✅ **Calendar Integration**: Visual timeline and calendar views
- ✅ **Activity Reordering**: Drag-and-drop activity management

### 3. AI-Powered Travel Assistant
- ✅ **Intelligent Recommendations**: AI chat for personalized travel suggestions
- ✅ **Automated Itinerary Generation**: AI-created schedules based on preferences
- ✅ **Smart Activity Suggestions**: Context-aware activity recommendations
- ✅ **Natural Language Processing**: Conversational AI interface

### 4. Advertisement & Monetization
- ✅ **Content Discovery**: Browse and explore travel advertisements
- ✅ **Partner Management**: Advertisement creation tools for business partners
- ✅ **Package Management**: Subscription and premium package offerings
- ✅ **Payment Integration**: Secure transaction processing and history

### 5. Real-time Communication
- ✅ **Push Notifications**: SignalR-based real-time messaging
- ✅ **Local Notifications**: Offline notification management
- ✅ **Notification Center**: Centralized notification management and read status

### 6. Transaction Management
- ✅ **Transaction History**: Comprehensive payment and purchase tracking
- ✅ **Payment Details**: Detailed transaction information and receipts
- ✅ **Financial Analytics**: Spending insights and travel cost analysis

### 7. User Profile Management
- ✅ **Profile Customization**: Personal information management
- ✅ **Avatar Management**: Profile picture upload and management
- ✅ **Preference Settings**: User preferences and application settings

## 📁 Project Structure

```
lib/
├── core/                          # Core application infrastructure
│   ├── constants/                # Application constants, colors, styles
│   ├── errors/                    # Error handling and exception management
│   ├── network/                   # API client, interceptors, configuration
│   ├── services/                  # SignalR, Local notifications, external services
│   ├── utils/                     # Utility functions and helpers
│   └── widgets/                   # Reusable UI components
│
├── features/                      # Feature-based modules (Clean Architecture)
│   ├── authentication/           # Authentication & Authorization
│   │   ├── data/                 # Data layer implementation
│   │   │   ├── datasources/     # Remote and local data sources
│   │   │   ├── models/          # Data transfer objects (DTOs)
│   │   │   └── repositories/     # Repository implementations
│   │   ├── domain/               # Domain layer (business logic)
│   │   │   ├── entities/        # Business entities
│   │   │   ├── repositories/     # Repository interfaces (contracts)
│   │   │   └── usecases/        # Use cases (business operations)
│   │   └── presentation/         # Presentation layer (UI)
│   │       ├── bloc/            # BLoC state management
│   │       ├── controllers/     # Form controllers and validation
│   │       ├── screens/         # UI screens and pages
│   │       └── widgets/         # Feature-specific widgets
│   │
│   ├── schedule/                 # Schedule & Itinerary Management
│   ├── ai_chat/                  # AI Chat & Recommendations
│   ├── advertisement/            # Advertisement & Monetization
│   ├── notification/             # Notification Management
│   ├── transaction/              # Transaction & Payment Processing
│   ├── user/                     # User Profile Management
│   ├── home/                     # Home Dashboard
│   ├── onboarding/               # User Onboarding Flow
│   └── splash/                   # Application Splash Screen
│
├── injection_container.dart       # Dependency injection configuration
├── main.dart                      # Application entry point
└── routes.dart                    # Application routing configuration

assets/
├── images/                       # Image assets and graphics
└── icons/                        # Icon assets and vector graphics
```

## 🚀 Getting Started

### System Requirements

- **Flutter SDK**: ^3.9.2
- **Dart SDK**: ^3.9.2
- **IDE**: Android Studio / VS Code with Flutter extensions
- **Version Control**: Git
- **Platform Support**: Android (API 21+), iOS (12.0+), Web

### Installation Guide

1. **Clone the Repository**
```bash
git clone <repository-url>
cd vivu_travel_app_fe
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Environment Configuration**

Create a `.env` file in the root directory with the following configuration:
```env
BASE_URL=http://your-api-url:port
WEBSOCKET_URL=http://your-websocket-url:port
MAPBOX_PUBLIC_TOKEN=pk.asaasdasgfgfvidoiojsdfojcojoijoijewqoijweoirfje
MAPBOX_SECRET_KEY=sk.gohjeonvuhspoqwpopoIUjapsfqeionUCPueedsdcsdcsdcdd
```

4. **Run the Application**

```bash
# Android Development
flutter run

# iOS Development
flutter run -d ios

# Web Development
flutter run -d chrome

# Specific Device
flutter run -d <device-id>
```

## 🛠️ Technology Stack

### Core Framework & Architecture
- **`flutter_bloc: ^9.1.1`** - Predictable state management with BLoC pattern
- **`get_it: ^8.0.0`** - Service locator and dependency injection
- **`equatable: ^2.0.5`** - Value equality and comparison utilities
- **`dartz: ^0.10.1`** - Functional programming utilities (Either, Union types)

### Network & API Integration
- **`dio: ^5.7.0`** - Advanced HTTP client with interceptors
- **`internet_connection_checker: ^3.0.1`** - Network connectivity monitoring
- **`signalr_netcore: ^1.4.4`** - Real-time communication hub

### Data Persistence & Security
- **`shared_preferences: ^2.3.2`** - Local key-value storage
- **`flutter_secure_storage: ^9.2.2`** - Encrypted secure storage for sensitive data

### User Interface & Design
- **`google_fonts: ^6.3.2`** - Typography system (Inter font family)
- **`flutter_svg: ^2.0.9`** - Scalable vector graphics support
- **`cached_network_image: ^3.4.1`** - Optimized image loading and caching

### Location & Mapping Services
- **`mapbox_maps_flutter: ^2.11.0`** - Advanced mapping and geospatial features
- **`geolocator: ^14.0.2`** - GPS location services and permissions

### Media & Communication
- **`mobile_scanner: ^7.1.2`** - QR code and barcode scanning
- **`qr_flutter: ^4.1.0`** - QR code generation and display
- **`image_picker: ^1.1.2`** - Camera and gallery image selection
- **`flutter_local_notifications: ^18.0.1`** - Local push notification system
- **`flutter_markdown: ^0.7.4`** - Rich text rendering and markdown support

### Development & Build Tools
- **`build_runner: ^2.9.0`** - Code generation and build automation
- **`json_serializable: ^6.8.0`** - Automatic JSON serialization
- **`flutter_lints: ^6.0.0`** - Code quality and linting rules

## 📝 Development Guidelines & Conventions

### Clean Architecture Principles

1. **Dependency Flow**: Presentation → Domain ← Data
   - Presentation layer depends on Domain layer
   - Data layer depends on Domain layer
   - Domain layer has no external dependencies

2. **Entity vs Model Distinction**
   - **Entity**: Domain layer pure Dart classes without JSON annotations
   - **Model**: Data layer classes with JSON serialization, extending entities

3. **Repository Pattern Implementation**
   - Repository interfaces defined in Domain layer
   - Repository implementations in Data layer
   - Dependency inversion principle maintained

4. **Use Case Design**
   - One use case per business operation
   - Contains pure business logic
   - Accepts repository interfaces, returns Either<Failure, Success>

5. **BLoC State Management**
   - **Events**: User actions and system triggers
   - **States**: UI state representations (loading, success, error)
   - **Bloc**: Business logic processing and state transitions

### Naming Conventions

```
File Naming:
- snake_case.dart (e.g., login_screen.dart, auth_repository.dart)
- Feature files: feature_name_type.dart

Class Naming:
- PascalCase (e.g., LoginScreen, AuthBloc)
- Interfaces: InterfaceName (e.g., AuthRepository)
- Implementations: InterfaceNameImpl (e.g., AuthRepositoryImpl)

Variable Naming:
- camelCase (e.g., isLoading, userProfile)
- Private variables: _variableName

Constants:
- UPPER_SNAKE_CASE (e.g., MAX_RETRY_ATTEMPTS, API_TIMEOUT)
```

### BLoC Implementation Standards

```dart
// Event naming convention: [Feature][Action]Event
class LoginEvent extends Equatable {
  const LoginEvent();
}

// State naming convention: [Feature][StateName]State
class LoginState extends Equatable {
  const LoginState();
}

// Bloc naming convention: [Feature]Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState());
}
```

### Code Generation Commands

Generate models and serializers:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Watch mode for automatic generation:
```bash
flutter pub run build_runner watch
```

## 🧪 Testing & Quality Assurance

### Test Execution
```bash
# Run all tests
flutter test

# Run tests with coverage report
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .

# Check for unused dependencies
flutter pub deps
```

## 🔧 Build & Deployment

### Android Build
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App bundle for Play Store
flutter build appbundle --release
```

### iOS Build
```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release

# Archive for App Store
flutter build ipa --release
```

### Web Build
```bash
# Web build
flutter build web --release

# Web build with base href
flutter build web --base-href /vivu-travel/
```

## 📱 Platform Configuration

### Android Configuration
**File**: `android/app/build.gradle.kts`
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)
- **Compile SDK**: 34
- **Permissions**: Camera, Location, Internet, Network State

### iOS Configuration
**File**: `ios/Runner/Info.plist`
- **Deployment Target**: iOS 12.0+
- **Required Permissions**:
  - Camera access for QR scanning
  - Location services for check-in/out
  - Photo library access for media uploads
  - Push notifications

## 🤝 Contributing Guidelines

### Development Workflow
1. **Fork the repository**
2. **Create feature branch**: `git checkout -b feature/amazing-feature`
3. **Follow coding standards**: Use provided linting rules
4. **Write tests**: Ensure adequate test coverage
5. **Commit changes**: `git commit -m 'feat: add amazing feature'`
6. **Push to branch**: `git push origin feature/amazing-feature`
7. **Create Pull Request**: Provide detailed description

### Code Review Process
- All changes require code review
- Automated tests must pass
- Code coverage must be maintained
- Documentation updates required for new features

## 📄 License & Legal

**Proprietary Software** - All rights reserved by Vivu Travel Company

This software is confidential and proprietary. Unauthorized copying, distribution, or modification is strictly prohibited.

## 📞 Support & Contact

### Technical Support
- **Email**: tech-support@vivutravel.com
- **Documentation**: https://docs.vivutravel.com
- **Issue Tracker**: Internal JIRA system

### Business Inquiries
- **Email**: business@vivutravel.com
- **Website**: https://vivutravel.com
- **Phone**: +1 (555) 123-4567

---

**Developed with ❤️ by the Vivu Travel Engineering Team**

*Last Updated: December 2024*
