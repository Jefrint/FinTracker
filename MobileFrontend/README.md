# FinTracker Mobile Frontend

Recommended stack: Flutter.

Flutter is the best fit here if the goal is to build one mobile app for both Android and iOS while sharing the same backend APIs used by the web frontend.

Suggested setup when Flutter SDK is installed:

```powershell
cd MobileFrontend
flutter create .
flutter run
```

Use this folder for the mobile app only. Keep the Spring Boot API in `Backend` and the Next.js web app in `Frontend`.
