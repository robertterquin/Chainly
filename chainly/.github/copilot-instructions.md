# Chainly - Copilot Instructions

## Project Overview

Chainly is a Flutter-based mobile application for cyclists to track bike maintenance, schedule service reminders, and monitor maintenance costs. Targets Android, iOS, Web, Windows, macOS, and Linux platforms. Designed for single or multiple bike profiles, offline-first support, and push notifications for reminders. Currently at initial scaffold stage with default counter demo template. Uses Dart SDK ^3.10.4.

## App Architecture

### User Flow & Screens

#### Initial Launch Sequence:

1. **Splash Screen** (2-3s) – Chainly logo, gradient background, app version
2. **Onboarding Slides** (3-4 screens) – Overview of app features: Maintenance Tracking, Reminders, Cost Management, Quick Access
3. **Welcome Screen** – Get Started / Login options
4. **Authentication** – Register, Login, Forgot Password flows

#### Main App (Bottom Navigation - 5 Tabs):

1. **Dashboard (Home)** – Overview of next maintenance, total maintenance costs, quick access
2. **My Bikes** – Manage all bike profiles
3. **Maintenance History** – Timeline of maintenance tasks per bike
4. **Reminders** – Upcoming and overdue maintenance notifications
5. **Cost Summary / Analytics** – Total maintenance cost per bike, charts, optional export

#### Additional Screens:

- **Add/Edit Bike** – Add new bikes or edit existing ones
- **Add/Edit Maintenance** – Add new maintenance tasks or edit existing
- **Calendar View** – Visual monthly overview of maintenance events
- **Profile & Settings** – User preferences, notification settings, app theme
- **Optional Smart Features** – Maintenance predictions, photo upload for tasks

## Recommended Folder Structure

```
lib/
├── main.dart
├── screens/
│   ├── splash/
│   │   ├── splash_screen.dart
│   ├── onboarding/
│   │   ├── onboarding_screen.dart
│   │   ├── widgets/ (onboarding_page.dart, page_indicator.dart)
│   ├── auth/
│   │   ├── welcome_screen.dart
│   │   ├── register_screen.dart
│   │   ├── login_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   ├── widgets/ (auth_button.dart, input_field.dart)
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   ├── widgets/ (next_maintenance_card.dart, total_cost_card.dart, quick_action_buttons.dart)
│   ├── bikes/
│   │   ├── my_bikes_screen.dart
│   │   ├── add_edit_bike_screen.dart
│   │   ├── widgets/ (bike_card.dart, add_bike_button.dart)
│   ├── maintenance/
│   │   ├── maintenance_list_screen.dart
│   │   ├── add_edit_maintenance_screen.dart
│   │   ├── widgets/ (maintenance_tile.dart, filter_chip.dart)
│   ├── reminders/
│   │   ├── reminders_screen.dart
│   │   ├── widgets/ (reminder_tile.dart, snooze_button.dart)
│   ├── analytics/
│   │   ├── cost_summary_screen.dart
│   │   ├── widgets/ (bar_chart.dart, pie_chart.dart)
│   ├── calendar/
│   │   ├── calendar_screen.dart
│   │   ├── widgets/ (calendar_event_marker.dart)
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── widgets/ (profile_header.dart, saved_items_list.dart)
├── models/
│   ├── bike.dart
│   ├── maintenance.dart
│   ├── reminder.dart
│   ├── user.dart
├── services/
│   ├── auth_service.dart
│   ├── local_storage_service.dart
│   ├── notification_service.dart
│   ├── analytics_service.dart
├── widgets/ (shared across app)
│   ├── custom_app_bar.dart
│   ├── custom_bottom_nav.dart
│   ├── loading_indicator.dart
│   ├── search_bar.dart
└── utils/
    ├── constants.dart
    ├── theme.dart (Chainly colors and gradients)
    ├── helpers.dart
    ├── routes.dart (named routes)
```

## Development Commands

```bash
# Run the app
flutter run

# Run on specific device
flutter run -d windows    # or: chrome, macos, linux, android, ios

# Hot reload: Press 'r' in terminal or save files in IDE
# Hot restart: Press 'R' in terminal

# Run tests
flutter test

# Analyze code for issues
flutter analyze

# Update dependencies
flutter pub get
flutter pub upgrade --major-versions
```

## Key Features by Screen

### 1. Splash Screen
- Chainly logo (no text)
- Gradient background (blue/green or orange accent)
- App version display
- Duration: 2-3 seconds

### 2. Onboarding Screens (3-4 slides)
- **Slide 1** – Maintenance Tracking: "Easily log bike maintenance tasks and service history"
- **Slide 2** – Reminders: "Get notifications for upcoming maintenance"
- **Slide 3** – Cost Tracking: "Monitor total maintenance expenses"
- **Optional Slide 4** – Multiple Bikes / Smart Features
- Next/Skip buttons
- Page indicators (••••)

### 3. Welcome Screen
- Logo and app name
- "Get Started" button
- "Already have an account? Login" link

### 4. Authentication Flow

**Register Page:**
- Fields: Full Name, Email, Password, Confirm Password
- Terms & Privacy Policy checkbox
- Register button
- Optional: Continue as Guest

**Login Page:**
- Fields: Email, Password
- Login button
- Forgot Password link
- Create Account link

**Forgot Password Page:**
- Enter email
- Reset link confirmation
- Back to Login link

### 5. Dashboard (Home)
- Next maintenance card (bike, task, due date)
- Total maintenance cost summary
- Quick action buttons: Add Maintenance, View Bikes, Calendar, Analytics
- Notifications preview (overdue tasks)

### 6. My Bikes
- List of bikes (photo, name, type, last service date)
- Add/Edit/Delete bike
- Tap bike → Maintenance List

### 7. Maintenance List
- Timeline/list of maintenance tasks
- Each record: Task name, category, date, cost, notes
- Filter by category, date, or cost
- Add new maintenance button

### 8. Add/Edit Maintenance
- Task name, category (chain, tires, brakes, other)
- Date performed
- Cost
- Notes (optional)
- Reminder toggle + next maintenance date
- Save/Cancel

### 9. Reminders
- List upcoming/overdue reminders
- Toggle to mark done or snooze
- Optional push notifications

### 10. Analytics / Cost Summary
- Total maintenance cost per bike
- Monthly/Yearly charts
- Filter by bike or category
- Optional export (PDF/CSV)

### 11. Calendar View
- Monthly calendar
- Maintenance tasks shown on dates
- Tap date → view or add maintenance
- Color-coded by category or overdue status

### 12. Profile & Settings
- Profile picture, name, email
- Edit Profile
- Saved items (maintenance history, reminders)
- Settings: Notifications, Theme (light/dark), Privacy, Logout, Delete account

### 13. Optional Smart Features
- Photo upload for tasks
- Predictive maintenance reminders
- Multiple bike support
- Offline-first caching

## Patterns & Conventions

- **State Management**: Provider or Riverpod recommended
- **Navigation**: Named routes in `routes.dart`
- **Theming**: Gradient backgrounds, accent colors for Chainly brand
- **Local Storage**: Hive or SQLite for offline support
- **Notifications**: Flutter Local Notifications for reminders
- **Guest Mode**: View content, but require auth for adding tasks or reminders
- **Linting**: `flutter_lints` (`flutter analyze`)

## Testing

Widget tests (`*_test.dart`)

**Test priority:**
1. Onboarding flow
2. Authentication
3. Maintenance CRUD
4. Reminder notifications
5. Multi-bike support
6. Analytics chart rendering
7. Calendar interactions

## Suggested Packages

- `shared_preferences` – Onboarding flags, user prefs
- `provider` / `riverpod` – State management
- `sqflite` / `hive` – Offline storage
- `flutter_local_notifications` – Maintenance reminders
- `smooth_page_indicator` – Onboarding dots
- `cached_network_image` – Bike images
- `image_picker` – Profile & maintenance photos
- `flutter_svg` – App icons/logo
- Optional: `charts_flutter` – Analytics charts
