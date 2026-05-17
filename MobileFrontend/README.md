# FinTracker Mobile Frontend

Flutter mobile app for the FinTracker Spring Boot API.

## What It Includes

- Login and register
- JWT session storage using `shared_preferences`
- Dashboard with net worth
- Asset list and asset creation
- Transaction list and transaction creation
- Profile update and sign out
- Buy/sell based holdings calculation

## API URL

The app automatically uses:

```text
Android emulator: http://10.0.2.2:8081/api
Web/Desktop:       http://localhost:8081/api
```

You can override it:

```cmd
flutter run --dart-define=API_BASE_URL=http://YOUR_IP:8081/api
```

For a real Android phone on the same Wi-Fi, use your computer's LAN IP instead of `localhost`.

## Run Locally

Start PostgreSQL and the backend first:

```cmd
cd C:\Users\jefy0\Desktop\works\FinTracker\Backend
mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=local
```

Then run the mobile app:

```cmd
cd C:\Users\jefy0\Desktop\works\FinTracker\MobileFrontend
flutter pub get
flutter run
```

## Build APK

To build an installable APK, run:

```cmd
cd C:\Users\jefy0\Desktop\works\FinTracker\MobileFrontend
flutter build apk --release
```

After the build completes, the APK is located at:

```text
MobileFrontend\build\app\outputs\flutter-apk\app-release.apk
```

You can also use the debug APK for quick installs:

```cmd
flutter build apk --debug
```

The debug APK appears at:

```text
MobileFrontend\build\app\outputs\flutter-apk\app-debug.apk
```

## Windows Developer Mode

Flutter plugins on Windows need symlink support. If you see:

```text
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

Open:

```cmd
start ms-settings:developers
```

Enable **Developer Mode**, then run:

```cmd
flutter pub get
flutter run
```

## Validate

```cmd
flutter analyze
flutter test
```
