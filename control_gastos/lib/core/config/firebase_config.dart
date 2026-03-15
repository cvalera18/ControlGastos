// Firebase initialization is handled via google-services.json (Android)
// and GoogleService-Info.plist (iOS).
// Run: flutterfire configure
// to generate lib/firebase_options.dart automatically.

class FirebaseConfig {
  FirebaseConfig._();

  // Firestore settings
  static const bool enablePersistence = true;
  static const int cacheSizeBytes = 104857600; // 100 MB
}
