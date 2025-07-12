# Food Ordering Application

A robust and scalable cross-platform mobile application developed with **Flutter** and **Dart**, designed to facilitate seamless food ordering experiences. This project integrates real-time order management, user authentication, administrative oversight, and in-app communication, leveraging **Firebase Firestore** as the backend service.

---

## Key Features

- **User Authentication:** Secure sign-up and login functionalities using Firebase Authentication.
- **Food Catalog:** Browse a variety of food items with detailed information, including images, pricing, and quantities.
- **Order Management:** Real-time order placement, tracking, and status updates for both users and administrators.
- **Administrative Dashboard:** Comprehensive admin interface for managing orders, updating statuses, and overseeing users.
- **In-App Chat:** Real-time messaging system enabling direct communication between admins and users.
- **Persistent Local Storage:** Utilization of Shared Preferences for efficient local data caching and retrieval.

---

## Technologies & Tools

- **Flutter & Dart:** For cross-platform UI development.
- **Firebase Firestore:** Cloud-hosted NoSQL database for real-time data synchronization.
- **Firebase Authentication:** Secure authentication framework.
- **Shared Preferences:** Lightweight key-value local storage.
- **Provider / StreamBuilder:** Reactive state management and UI updates.

---

## Getting Started

This project is a fully functional Flutter application integrated with Firebase services. It provides a solid foundation for building scalable food ordering apps with real-time features.

Follow the instructions below to set up and run the project locally.

## Prerequisites

- **Flutter SDK:** Install from the [official guide](https://flutter.dev/docs/get-started/install) and verify with `flutter doctor`.
- **Firebase Project:** Create a Firebase project with Firestore and Authentication enabled. Download and add the configuration files:
  - `google-services.json` to `android/app/`
  - `GoogleService-Info.plist` to `ios/Runner/`
- **Development IDE:** Use Android Studio, VS Code, or IntelliJ with Flutter and Dart plugins installed. Ensure you have an emulator or device connected.
-  **API Keys** Stripe Payment Integration:
Replace the Stripe API keys in your code with your own test/live keys for processing payments securely.
Example location in code:
const String stripePublishableKey = 'pk_test_YOUR_OWN_STRIPE_KEY_HERE';
- **Environment Variables / Secrets**
If your project uses environment variables or secret files (e.g., .env or Dart --dart-define), update them with your own credentials.

Avoid committing sensitive keys publicly.

---


### Installation & Setup

1. **Clone the repository**

```bash
git clone https://github.com/EmaPeeva/flutter-fooddelivery-app
```

2. **Navigate to the project directory**

```bash
cd flutter-fooddelivery-app
```

3. **Fetch project dependencies**
```bash
flutter pub get
```

4. **Configure Firebase**
Add your google-services.json file to the android/app/ directory.
Add your GoogleService-Info.plist file to the ios/Runner/ directory.

5. **Run the application**
```bash
flutter run
```
---


### Contribution
Contributions are welcome! Please fork the repository and create a pull request with your proposed changes.

---

#### License
This project is licensed under the MIT License - see the LICENSE file for details.

---

### Contact


