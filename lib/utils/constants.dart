class AppConstants {
  // static const String kBaseUrl = 'https://schoolmanagmentbackend-s15i.onrender.com/api';
  static const String kBaseUrl = 'http://localhost:3000/api';
  static const String cloudinaryPreset = 'school_management';
  static const String cloudinaryCloudName = 'dor0zvihv';
  static const cloudinaryUrl =
      'https://res.cloudinary.com/dor0zvihv/image/upload/';
  static const cloudinaryApiKey = '949159975861895';
  static const cloudinarySecretKey = '4XzXFZJzehyIIAviKEjUZKXoFUQ';
  static String token = 'token';
  static String email = 'email';
  static String password = 'password';
  static String name = 'name';
  static String hasLoggedInOnce = 'hasLoggedInOnce';
  static String myPin = 'myPin';
  static String hasPinSet = 'hasPinSet';

  // TEST
  // static String dojahWidgetId = '681e5664b52cf9b2598f5dc9';
  // static String dojahAppId = "6815f136e6f0f1492e449481";
  // static String dojahPublicKey = "test_pk_faF1cixbN2JDQs7eWHQflkPfh";

  static const String biometricMsgoff = "Biometrics is turned off";
  static const String activateBiometricMsg =
      'Kindly activate biometrics to use this feature.';

  static double pickupRadius = 500;
  static double dropoffRadius = 500;
  static String activeDeliveryId = 'activeDeliveryId';

  // final appId= envVars['appId'];
  // final publicKey = envVars['publicKey'];
}
