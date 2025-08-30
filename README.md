
# QR Scanner App

## Description

QR Scanner App is a cross-platform mobile application designed to scan QR codes, capture geolocation data, and store the results in a local database. The app allows users to export scanned data as CSV and send it via email. It is ideal for logistics, inventory, or any scenario requiring QR code tracking with location and device information.

## Technologies Used

- **Framework:** Flutter
- **Languages:** Dart
- **Database:** SQLite (via sqflite)
- **QR Scanning:** qr_code_scanner
- **Geolocation:** geolocator
- **Permissions:** permission_handler
- **Email Sending:** flutter_email_sender
- **Device Info:** device_info_plus
- **CSV Export:** csv

## Installation

1. **Clone the repository:**
	```zsh
	git clone <repository-url>
	cd app
	```
2. **Install dependencies:**
	```zsh
	flutter pub get
	```
3. **Configure platforms:**
	- For Android/iOS, ensure you have the required SDKs and emulators installed.
	- For desktop/web, follow [Flutter's official setup guide](https://docs.flutter.dev/get-started/install).

## Running the Project

1. **Set up environment (if needed):**
	- No custom environment variables are required for basic usage.
	- For email functionality, ensure a valid email client is configured on the device.
2. **Run the app:**
	```zsh
	flutter run
	```
	- To run on a specific device:
	  ```zsh
	  flutter run -d <device-id>
	  ```

## Example Usage

Scan a QR code and export the data:

1. Open the app and tap the camera icon to scan a QR code.
2. The scanned data, along with location and device info, will be saved locally.
3. Tap the email icon to export all data as a CSV and send it via email.

**Sample code to scan QR:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
	 builder: (context) => const QRScannerScreen(),
  ),
);
```

## Testing

Widget tests are included in the `test/widget_test.dart` file. To run tests:
```zsh
flutter test
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Credits / Author

- Developed by bemonio
- Contact: bemonio@gmail.com

