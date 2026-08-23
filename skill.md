# InternMe - skill.md

## Project Overview

**Project Name:** InternMe

**Architecture:** Feature-first Clean Architecture

**Framework:** Flutter

**State Management:** GetX

**UI Pattern:** Stateless Widgets + Reactive GetX (`Obx`)

**Backend:** Firebase

**Language:** Dart

**Minimum Flutter Version:** Flutter 3.35+

---

# Core Development Rules

## State Management

- Use **GetX** for all state management.
- Never use Provider, Riverpod, Bloc, Cubit, MobX, or setState() for business logic.
- Use Rx variables with `Obx` for UI updates.
- Keep business logic inside Controllers only.

Example:

```dart
final count = 0.obs;
```

---

## Widgets

- Every screen must be a **StatelessWidget**.
- Never create StatefulWidgets unless absolutely required by Flutter APIs.
- UI should react using GetX reactive variables.

Correct:

```dart
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => Text(controller.title.value)),
    );
  }
}
```

---

## Navigation

Use only GetX navigation.

Examples:

```dart
Get.to(() => HomeScreen());

Get.offAll(() => LoginScreen());

Get.back();

Get.off(() => DashboardScreen());
```

Never use:

```dart
Navigator.push()
Navigator.pop()
```

---

## Dependency Injection

Use Get.put()

Example:

```dart
Get.put(AuthController());

Get.lazyPut(() => InternshipController());

Get.find<AuthController>();
```

---

## Routing

Maintain all routes inside:

```
lib/core/routes/
```

Files:

```
app_pages.dart

app_routes.dart
```

---

## Folder Structure

Use Feature First Architecture.

```
lib/

core/

features/

shared/

services/

data/
```

---

# Complete Folder Structure

```
lib
│
├── core
│   ├── constants
│   ├── theme
│   ├── routes
│   ├── bindings
│   ├── utils
│   └── widgets
│
├── data
│   ├── models
│   ├── repositories
│   └── providers
│
├── services
│   ├── firebase
│   ├── ai
│   ├── storage
│   ├── notification
│   └── location
│
├── shared
│   ├── widgets
│   ├── components
│   └── extensions
│
├── features
│
│   ├── authentication
│   ├── onboarding
│   ├── splash
│   ├── student
│   ├── organization
│   ├── admin
│   ├── ai_detector
│   ├── internship
│   ├── applications
│   ├── profile
│   ├── notifications
│   ├── learning
│   ├── scam_reports
│   ├── bookmarks
│   ├── chatbot
│   └── settings
│
└── main.dart
```

---

# Feature Structure

Every feature should follow:

```
feature/

bindings/

controllers/

models/

repository/

screens/

widgets/
```

Example:

```
student/

bindings/

controllers/

home_controller.dart

screens/

home_screen.dart

widgets/

internship_card.dart
```

---

# Bindings

Every feature must have its own Binding.

Example:

```dart
class HomeBinding extends Bindings {

  @override
  void dependencies() {

    Get.lazyPut<HomeController>(
      () => HomeController(),
    );

  }

}
```

---

# Controller Rules

Controllers contain only:

- Business Logic
- API Calls
- Firebase Calls
- Validation
- Navigation Logic

Never write UI code inside Controllers.

---

# UI Rules

Keep screens clean.

Example:

```
HomeScreen

↓

InternshipCard

↓

TrustScoreWidget

↓

VerifiedBadge

↓

CustomButton
```

Avoid writing 500+ lines inside one screen.

---

# Firebase

Use:

- Firebase Authentication
- Firestore
- Firebase Storage
- Firebase Messaging

Create one service for each Firebase module.

Example:

```
services/

firebase/

auth_service.dart

firestore_service.dart

storage_service.dart

notification_service.dart
```

---

# Repository Pattern

Never call Firebase directly from UI.

Flow:

```
Screen

↓

Controller

↓

Repository

↓

Firebase Service
```

---

# Models

Every Firestore collection must have its own model.

Examples:

```
UserModel

InternshipModel

OrganizationModel

ApplicationModel

ScamReportModel

ReviewModel

NotificationModel
```

Include:

```dart
fromJson()

toJson()

copyWith()
```

---

# Firestore Collections

```
users

organizations

internships

applications

savedInternships

reviews

scamReports

offerLetters

notifications

learningCenter

badges
```

---

# Theme

Create:

```
theme.dart

app_colors.dart

app_text_styles.dart

app_sizes.dart
```

Support:

- Light Mode
- Dark Mode

---

# Reusable Widgets

Create reusable widgets.

Examples:

```
CustomButton

CustomTextField

PrimaryCard

SearchBar

InternshipCard

TrustScoreCard

VerifiedBadge

LoadingWidget

EmptyWidget

ErrorWidget

CustomDialog

BottomSheet

ProfileTile
```

---

# AI Module

Create services.

```
GeminiService

InternshipAnalyzer

OfferLetterAnalyzer

URLSafetyChecker
```

Controllers should never contain AI prompts.

---

# Naming Convention

Screens

```
home_screen.dart

profile_screen.dart
```

Controllers

```
home_controller.dart
```

Bindings

```
home_binding.dart
```

Models

```
internship_model.dart
```

Repositories

```
internship_repository.dart
```

Services

```
firestore_service.dart
```

Widgets

```
internship_card.dart
```

---

# Assets

```
assets/

icons/

images/

animations/

logos/

lottie/
```

---

# Packages

Use only:

```
get

firebase_core

firebase_auth

cloud_firestore

firebase_storage

firebase_messaging

google_sign_in

image_picker

file_picker

cached_network_image

flutter_svg

lottie

intl

uuid

connectivity_plus

url_launcher

permission_handler

geolocator

flutter_local_notifications

google_fonts

dio

http
```

---

# Code Quality

Always:

- Null Safety
- Strong Typing
- Const constructors
- Final variables
- Meaningful names
- Small widgets
- Single Responsibility Principle

---

# Performance

Use:

- Obx()
- Lazy Loading
- Pagination
- Cached Images
- Reusable Widgets
- Firebase Indexes

Avoid unnecessary rebuilds.

---

# Security

Always:

- Firebase Authentication
- Firestore Security Rules
- Input Validation
- Secure Storage
- API Key Protection

---

# App Modules

### Authentication

- Login
- Register
- Forgot Password
- Email Verification

### Student

- Home
- Search
- Internship Details
- Saved
- Applications
- Profile

### AI

- Internship Detector
- URL Scanner
- Offer Letter Verification
- AI Career Assistant

### Organization

- Dashboard
- Post Internship
- Applicants
- Analytics
- Organization Profile

### Admin

- Dashboard
- Verify Organizations
- Manage Internships
- Review Scam Reports
- Manage Users

### Learning

- Courses
- Articles
- Tips

### Notifications

- Application Updates
- Scam Alerts
- Internship Alerts

---

# Development Principles

- Feature-first architecture
- Reusable widgets
- Clean folder structure
- GetX reactive programming
- StatelessWidget-first development
- Repository pattern
- Firebase as backend
- Modular and scalable codebase
- Production-ready architecture
- Consistent UI/UX across all modules