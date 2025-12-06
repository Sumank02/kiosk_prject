# Bharat Tele Kiosk (TeleKiosk)

## What is this?
TeleKiosk is a simple kiosk-style app for booking a telemedicine appointment and checking if doctors are currently available. It is designed to run on devices placed in public areas (kiosks) or on a normal phone/computer for demo purposes.

## Who is it for?
- People at a clinic, pharmacy, or help desk who need a quick way to book appointments.
- Demonstrations or assignments where a basic telemedicine flow is needed without complex setup.

## What can you do with it?
- Login to the kiosk with a fixed demo username and password.
- See if doctors are online or offline.
- Book an appointment by entering your name, choosing a date, and selecting an online doctor.

## Before you start (very simple)
- You need internet access.
- For Android builds: Android Studio (or just use an Android device with Developer Mode) is helpful.
- For Windows builds: a Windows PC is enough.

The app is built with Flutter and already includes the necessary project files. If you just want to run it without development tools, see “Quick start (no coding)” below.

## Quick start (no coding)
You have two easy options. Pick the one that suits you:

### Option A — Run on Android (easiest for most people)
1. Copy the project to a computer and open the `android` folder in Android Studio, or connect an Android phone with Developer Mode enabled.
2. Press “Run” in Android Studio to install the app on your device.
3. Open the app on the device.

### Option B — Run on Windows desktop
1. On a Windows 10/11 PC, install Flutter if you don’t have it already (search for “Install Flutter on Windows”).
2. In a terminal, go to the project folder and run:
   - `flutter pub get`
   - `flutter run -d windows`

If you prefer running on a phone emulator, you can also run: `flutter run` with an emulator or device connected.

## Login details (demo)
- Username: `kioskuser`
- Password: `kiosk@123`

After login, you’ll land on the home screen with two actions: Book Appointment and Doctor Status.

## Where does the data come from?
- Doctor availability is read from a sample Firebase Realtime Database. On first launch, the app seeds a few sample doctors (e.g., Dr Alice, Dr Bob, Dr Carol). This is only for demonstration.
- Activity (like button taps or bookings) is logged to a mock backend inside the app (no data leaves your device unless you configure a real server URL).

## Troubleshooting
- Can’t connect or see doctors? Make sure the device has internet access.
- If Firebase is blocked on your network, the doctor list may be empty.
- If the app returns to the login screen by itself, it’s because the kiosk is set to auto‑lock after 2 minutes of no activity.

## Notes on privacy
This demo app does not collect or store personal data on a server by default. Booking actions are mocked locally unless you add a real server address in the app’s settings/code.

## Want to develop further?
If you’re a developer (optional):
- Flutter version: SDK >= 3.3.0
- Run `flutter pub get` to install packages.
- Main entry: `lib/main.dart`
- Key screens: `lib/screens/login_page.dart`, `lib/screens/home_page.dart`, `lib/screens/book_appointment.dart`, `lib/screens/doctor_status.dart`
- Services: `lib/services/backend_service.dart`, `lib/services/websocket_service.dart`

That’s it—you’re ready to try the kiosk app.
