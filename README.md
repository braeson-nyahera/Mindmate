# MindMate 🧠

**MindMate** is a comprehensive educational platform built with Flutter that connects students with tutors, provides course management, and facilitates collaborative learning through forums and messaging. The app serves as a one-stop solution for academic support and learning management.

## ✨ Features

### 🔐 Authentication & User Management
- **Google Sign-In Integration** - Seamless authentication with Google accounts
- **Firebase Authentication** - Secure user authentication and session management
- **User Profiles** - Personalized profiles with enrollment and appointment tracking

### 📚 Course Management
- **Course Enrollment** - Browse and enroll in available courses
- **Course Details** - Detailed course information with modules and materials
- **Progress Tracking** - Track enrolled courses and learning progress
- **Search Functionality** - Find courses easily with built-in search

### 👨‍🏫 Tutor System
- **Tutor Directory** - Browse available tutors with detailed profiles
- **Tutor Registration** - Register as a tutor to offer services
- **Appointment Booking** - Schedule tutoring sessions with available tutors
- **Appointment Management** - View and manage upcoming appointments

### 💬 Communication & Collaboration
- **Discussion Forums** - Participate in academic discussions and Q&A
- **Real-time Messaging** - Chat functionality for student-tutor communication
- **Notifications** - Stay updated with important announcements and messages

### 🌐 Additional Features
- **Network Connectivity Monitoring** - Automatic detection and handling of network issues
- **Responsive Design** - Optimized for different screen sizes and orientations
- **Material Design 3** - Modern UI following Google's Material Design guidelines
- **Dark/Light Theme Support** - Customizable app appearance

## 🚀 Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile application framework
- **Dart** - Programming language for Flutter development
- **Material Design 3** - Modern UI components and design system

### Backend & Services
- **Firebase Core** - Backend-as-a-Service platform
- **Cloud Firestore** - NoSQL document database for real-time data
- **Firebase Authentication** - User authentication and authorization
- **Firebase Storage** - File storage for images and documents
- **Firebase Messaging** - Push notifications service

### Key Dependencies
- **Google Sign-In** - Google authentication integration
- **Google Fonts** - Custom typography
- **Provider** - State management solution
- **Image Picker** - Image selection from gallery/camera
- **Connectivity Plus** - Network connectivity monitoring
- **Intl** - Internationalization and date formatting
- **RxDart** - Reactive programming utilities

## 📱 Screenshots

| Landing Page | Course List | Tutor Directory | Discussion Forum |
|:------------:|:-----------:|:---------------:|:----------------:|
| Authentication and onboarding | Browse available courses | Find and book tutors | Community discussions |

## 🛠️ Installation & Setup

### Prerequisites
- **Flutter SDK** (^3.6.2)
- **Dart SDK** (included with Flutter)
- **Android Studio** / **VS Code** with Flutter extensions
- **Firebase Project** with the following services enabled:
  - Authentication
  - Firestore Database
  - Cloud Storage
  - Cloud Messaging

### Step 1: Clone the Repository
```bash
git clone https://github.com/braeson-nyahera/Mindmate.git
cd mindmate
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Firebase Configuration
1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable the following services:
   - **Authentication** (Google Sign-In provider)
   - **Firestore Database**
   - **Cloud Storage**
   - **Cloud Messaging**

3. **Android Setup:**
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/google-services.json`

4. **iOS Setup (if targeting iOS):**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Add it to the iOS project in Xcode

### Step 4: Update Firebase Configuration
The app uses Firebase configuration in `lib/firebase_options.dart`. Make sure this file matches your Firebase project settings.

### Step 5: Run the Application
```bash
# Run on connected device or emulator
flutter run

# Build for release
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 🏗️ Project Structure

The codebase has been refactored and organized into a clean, modular architecture that follows Flutter best practices:

```
lib/
├── main.dart                          # App entry point and routing configuration
├── config/                            # Configuration files
│   ├── firebase_options.dart          # Firebase project configuration
│   └── firebase_test.dart             # Firebase connection tests
├── screens/                           # UI screens organized by feature
│   ├── auth/                          # Authentication screens
│   │   ├── landing_page.dart          # Welcome/onboarding screen
│   │   ├── login.dart                 # User login screen
│   │   └── signup_screen.dart         # User registration screen
│   ├── courses/                       # Course management screens
│   │   ├── courses.dart               # Course listing and search
│   │   ├── course_detail.dart         # Individual course details
│   │   ├── course_add.dart            # Add/create new courses
│   │   └── module_detail.dart         # Course module details
│   ├── forum/                         # Discussion forum screens
│   │   ├── forum.dart                 # Discussion forum listing
│   │   └── discussion_detail.dart     # Individual discussion threads
│   ├── main/                          # Core app screens
│   │   ├── home.dart                  # Main dashboard/home screen
│   │   ├── profile.dart               # User profile management
│   │   ├── notifications.dart         # Notification center
│   │   └── notes.dart                 # Notes functionality
│   ├── messaging/                     # Communication screens
│   │   ├── chats.dart                 # Chat interface
│   │   ├── message_list.dart          # Message conversations
│   │   └── message_detail.dart        # Individual message details
│   └── tutors/                        # Tutor system screens
│       ├── tutors.dart                # Tutor directory
│       ├── tutor_details.dart         # Tutor profile details
│       ├── tutor_registration.dart    # Tutor registration form
│       └── appointment.dart           # Appointment booking system
├── services/                          # Business logic and external services
│   ├── authservice.dart               # Authentication service
│   └── google_sign_in.dart            # Google Sign-In integration
├── utils/                             # Utility classes and helpers
│   ├── connectivity_wrapper.dart      # Network connectivity monitoring
│   └── no_network.dart               # No internet connection handler
└── widgets/                           # Reusable UI components
    ├── components.dart                # Common UI components
    ├── bottom_bar.dart               # Bottom navigation bar
    └── top_bar.dart                  # Top navigation bar
```

### 🎯 Architecture Benefits

**📁 Modular Organization:**
- **Feature-based structure** - Related functionality grouped together
- **Clear separation of concerns** - UI, business logic, and utilities separated
- **Scalable architecture** - Easy to add new features and maintain existing ones

**🔧 Maintainability:**
- **Intuitive file organization** - Developers can quickly locate specific functionality
- **Consistent naming conventions** - Clear, descriptive file and folder names
- **Reduced coupling** - Components are loosely coupled and highly cohesive

**🚀 Development Experience:**
- **Faster navigation** - IDE can efficiently index and search organized code
- **Team collaboration** - Multiple developers can work on different features without conflicts
- **Code reusability** - Shared components and services can be easily imported


## 🎯 Usage

### For Students
1. **Sign up/Login** with Google account
2. **Browse Courses** and enroll in subjects of interest
3. **Find Tutors** and book appointments for personalized help
4. **Join Discussions** to ask questions and share knowledge
5. **Track Progress** through your profile dashboard

### For Tutors
1. **Register as a Tutor** with your expertise and availability
2. **Manage Appointments** and view student bookings
3. **Participate in Forums** to help students with questions
4. **Update Profile** with qualifications and subject areas

## 🔧 Configuration

### Environment Variables
The app uses Firebase for backend services. Ensure your `firebase_options.dart` contains the correct configuration for your Firebase project.


## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support and questions:
- **Email**: braebulimo@gmail.com
- **GitHub Issues**: [Create an issue](https://github.com/braeson-nyahera/Mindmate/issues)

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Firebase Team** for the backend services
- **Material Design** for the beautiful UI components
- **Open Source Community** for the various packages used

---

**Built with ❤️**
