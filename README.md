# FarmPact 🌾

A comprehensive Flutter application designed to empower farmers with modern agricultural tools and livestock management solutions. Built for the Smart India Hackathon (SIH), FarmPact provides real-time livestock monitoring, health analytics, weather advisories, and veterinary consultation services to enhance farm productivity and animal welfare.

## Features

### 🎯 Core Features

- **Livestock Management Dashboard**: Comprehensive livestock tracking and health monitoring
- **Real-time Analytics**: Visual charts and gauges for livestock data analysis
- **Weather Integration**: Location-based weather updates with farming recommendations
- **Veterinary Services**: Connect with local veterinarians and emergency contacts
- **Daily Reporting**: Track daily livestock activities and health metrics
- **Smart Notifications**: Alerts for health issues, weather warnings, and scheduled activities
- **Map Integration**: GPS-enabled location services and area mapping

### 🎨 Design Philosophy

- **User-Centric Design**: Intuitive interface designed for farmers with varying technical backgrounds
- **Outdoor Optimization**: High contrast colors and clear visibility for field use
- **Performance First**: Lightweight and responsive for reliable performance on all devices
- **Data-Driven Insights**: Visual analytics to help farmers make informed decisions

### 📱 Supported Platforms

- **Android**: Full native support with material design
- **iOS**: Cross-platform compatibility
- **Web**: Progressive web app capabilities
- **Windows**: Desktop support for farm office management

## Tech Stack

### Frontend Technologies

- **Flutter 3.0+**: Modern cross-platform framework
- **Provider**: State management for reactive UI
- **Google Maps**: Interactive mapping and location services
- **FL Chart**: Advanced data visualization and analytics
- **Syncfusion Gauges**: Professional gauge widgets for metrics
- **HTTP**: RESTful API integration
- **Geolocator**: GPS and location tracking
- **Image Picker**: Camera and gallery integration
- **Local Notifications**: Push notification system

### Backend & Services

- **SQLite**: Local database for offline functionality
- **Firebase (Optional)**: Cloud services and real-time sync
- **Weather API**: Real-time weather data integration
- **Maps API**: Location and mapping services

## Project Structure

```
lib/
├── main.dart                           # App entry point and initialization
├── models/                            # Data models and structures
│   ├── farmer_model.dart              # Farmer profile data model
│   ├── livestock_model.dart           # Livestock data model
│   └── alert_model.dart               # Alert and notification model
├── providers/                         # State management providers
│   ├── farmer_provider.dart           # Farmer data provider
│   ├── livestock_provider.dart        # Livestock management provider
│   ├── location_provider.dart         # GPS and location provider
│   └── notification_provider.dart     # Notification management
├── screens/                           # UI screens and pages
│   ├── splash_screen.dart             # App launch screen
│   ├── login_screen.dart              # Authentication screen
│   ├── registration_screen.dart       # User registration
│   ├── dashboard_screen.dart          # Main dashboard
│   ├── enhanced_dashboard_screen.dart # Advanced dashboard features
│   ├── livestock_data_entry_screen.dart # Livestock data input
│   ├── livestock_analytics_screen.dart  # Data visualization
│   ├── daily_report_screen.dart       # Daily activity reporting
│   ├── map_view_screen.dart           # Interactive maps
│   ├── veterinarian_contact_screen.dart # Vet services
│   ├── profile_screen.dart            # User profile management
│   └── main_navigation_screen.dart    # Bottom navigation
├── services/                          # Business logic and APIs
│   ├── database_service.dart          # Local database operations
│   ├── location_service.dart          # GPS and mapping services
│   └── notification_service.dart      # Push notifications
├── widgets/                           # Reusable UI components
│   └── custom_widgets.dart            # Custom widgets and components
└── themes/
    └── theme.dart                     # App theming and styling
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
   git clone https://github.com/SIBI-thinker/FarmPact.git
   cd FarmPact
   ```

2. **Install dependencies**:

   ```bash
   flutter pub get
   ```

3. **Configure API Keys** (Optional):

   - Add your Google Maps API key in `android/app/src/main/AndroidManifest.xml`
   - Configure weather API keys in the app settings
   - Set up any required third-party service credentials

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

## Screenshots

*Coming Soon - App screenshots and demo videos will be added here*

## Team

**SIH Team - SIBI-thinker**
- Developed for Smart India Hackathon 2025
- Focus: Agricultural Technology and Livestock Management

## Acknowledgments

- Smart India Hackathon organizers
- Flutter and Dart communities
- Open source contributors
- Agricultural experts and farmers for valuable insights

---

**Built with ❤️ for Farmers Everywhere**

*Empowering Agriculture Through Technology*
