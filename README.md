# Sarvam - Farmer's Assistant App

A Flutter application designed specifically for Indian farmers to assess livestock health risks, receive weather advisories, and access educational resources. The app prioritizes accessibility, clarity, and ease of use for users with varying levels of digital literacy.

## Features

### 🎯 Core Features

- **Risk Assessment Dashboard**: Visual risk score gauge with color-coded indicators
- **OTP-based Authentication**: Simple mobile number verification system
- **Weather Advisory**: Real-time weather conditions with actionable farming advice
- **Health Trends**: Visual mortality trends and livestock health monitoring
- **Learning Resources**: Educational videos and articles for farmers

### 🎨 Design Philosophy

- **Clarity First**: Large fonts, high-contrast colors, universally recognized icons
- **Accessibility**: Designed for outdoor use with high contrast modes
- **Trustworthy Aesthetic**: Clean, professional color palette
- **Lightweight**: Optimized for low-end Android devices

### 🎨 UI/UX Highlights

- **Farmer-Centric Design**: Tailored for users with varying digital literacy
- **Outdoor Visibility**: High contrast colors for bright sunlight usage
- **Large Touch Targets**: Prevents accidental taps on mobile devices
- **Intuitive Navigation**: Simple, clear user flows

## Tech Stack

### Frontend

- **Flutter**: Cross-platform mobile development
- **Google Fonts (Poppins)**: Clean, readable typography
- **Syncfusion Flutter Gauges**: Risk score visualization
- **FL Chart**: Health trends line charts
- **Shimmer**: Professional loading states

### Backend (Ready for Integration)

- **Firebase Core**: Authentication and backend services
- **Cloud Firestore**: Real-time database for farm data
- **Firebase Auth**: OTP verification system

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── themes/
│   └── theme.dart           # App-wide theming and colors
├── screens/
│   ├── login_screen.dart    # OTP authentication
│   └── dashboard_screen.dart # Main risk assessment dashboard
├── widgets/
│   └── custom_widgets.dart  # Reusable UI components
└── firebase_options.dart    # Firebase configuration
```

## Setup Instructions

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase project (for backend integration)

### Installation

1. **Clone the repository**:

   ```bash
   git clone <repository-url>
   cd FarmPact
   ```

2. **Install dependencies**:

   ```bash
   flutter pub get
   ```

3. **Firebase Setup** (Optional for demo):

   - Create a Firebase project
   - Configure Android/iOS apps
   - Download and replace `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)
   - Update `firebase_options.dart` with your project configuration

4. **Run the app**:
   ```bash
   flutter run
   ```

## Key Components

### Authentication Flow

- **Login Screen**: Mobile number input with country code selector (+91)
- **OTP Verification**: 6-digit OTP input with verification
- **Error Handling**: User-friendly error messages and validation

### Dashboard Components

#### 1. Risk Score Gauge

- **Visual Impact**: Large, prominent radial gauge
- **Color Coding**:
  - Green (0-30): Low Risk
  - Yellow (31-70): Moderate Risk
  - Red (71-100): High Risk
- **Interactive**: Animated needle pointer and color transitions

#### 2. Weather Advisory Card

- **Weather Icons**: Dynamic icons based on conditions
- **Actionable Advice**: Specific recommendations for current weather
- **Real-time Updates**: Timestamp showing last update

#### 3. Health Trends Chart

- **30-day Mortality Trend**: Line chart with data visualization
- **Professional Styling**: Clean, medical-grade appearance
- **Trend Indicators**: Visual indicators for improving/declining trends

#### 4. Learning Resources

- **Horizontal Scroll**: Easy browsing of educational content
- **Thumbnail Previews**: Visual cards for videos and articles
- **Categorized Content**: Disease prevention, feeding practices, etc.

### Custom Widgets

#### Theme System

- **Consistent Colors**: Earthy green primary color (#2E7D32)
- **Accessibility**: High contrast ratios for outdoor visibility
- **Typography**: Poppins font family with proper weight hierarchy
- **Responsive Design**: Adaptable to different screen sizes

#### Reusable Components

- **CustomCard**: Consistent card styling with optional tap handlers
- **LoadingCard**: Shimmer effect for professional loading states
- **StatusBadge**: Color-coded status indicators
- **WeatherIcon**: Dynamic weather condition icons

## Color Palette

```dart
Primary Green: #2E7D32      // AppBar, buttons, primary actions
Background: #F5F5F5         // Main background, better contrast than white
Card Background: #FFFFFF    // Card surfaces
Primary Text: #212121       // Main text content
Secondary Text: #757575     // Supporting text

Risk Colors:
Low Risk: #4CAF50          // Green for safe conditions
Medium Risk: #FFC107       // Yellow for caution
High Risk: #D32F2F         // Red for danger
```

## Accessibility Features

- **Large Font Sizes**: Minimum 16px for body text, 20px for titles
- **High Contrast**: WCAG AA compliant color combinations
- **Large Touch Targets**: Minimum 56px height for all interactive elements
- **Clear Visual Hierarchy**: Proper heading structure and spacing
- **Icon + Text Labels**: All actions have both visual and text indicators

## Performance Optimizations

- **Lightweight Animations**: Simple, purposeful transitions
- **Optimized Images**: Placeholder handling for network images
- **Efficient Scrolling**: SingleChildScrollView with proper physics
- **Memory Management**: Proper widget disposal and state management

## Future Enhancements

- **Offline Support**: Cache critical data for offline access
- **Multi-language**: Hindi and regional language support
- **Voice Navigation**: Voice commands for hands-free operation
- **Dark Mode**: Low-light usage scenarios
- **Push Notifications**: Critical alerts and reminders

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit changes (`git commit -am 'Add new feature'`)
4. Push to branch (`git push origin feature/new-feature`)
5. Create Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:

- Create an issue in the repository
- Contact the development team
- Check the documentation wiki

---

**Built with ❤️ for Indian Farmers**
# FarmPact
