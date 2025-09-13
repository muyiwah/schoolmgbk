class AppConstants {


  // static const String kBaseUrl = 'http://10.255.18.138:3000/api';
  static const String kBaseUrl = 'http://localhost:3000/api';
  static const String appType = 'mover';

  static String token = 'token';
  static String email = 'email';
  static String password = 'password';
  static String name = 'name';
  static String hasLoggedInOnce = 'hasLoggedInOnce';
  static String myPin = 'myPin';
  static String hasPinSet = 'hasPinSet';

  static String googleAPIKey = 'AIzaSyDpF1z1rLFd8BmLnXJ6QajbxFKETxk0Upw';

  static String oneSignalAppId = '23c0061a-967b-479f-aa6b-ea6958becb39';

  // PRODUCTION
  static String dojahWidgetId = '6887bf0dcc3a4ec28bf9ca97';
  static String dojahAppId = '6815f136e6f0f1492e449481';
  static String dojahPublicKey = 'prod_pk_ZAL4SFYGdqbDrmN1UhlL868mA';

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

const darkMapStyle = [
  {
    "elementType": "geometry",
    "stylers": [
      {"color": "#0f0f0f"},
    ],
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {"visibility": "off"},
    ],
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#6f6f6f"},
    ],
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {"color": "#0f0f0f"},
    ],
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      {"color": "#6f6f6f"},
    ],
  },
  {
    "featureType": "administrative.country",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#8a8a8a"},
    ],
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#9e9e9e"},
    ],
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#6f6f6f"},
    ],
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {"color": "#0d0d0d"},
    ],
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#5a5a5a"},
    ],
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [
      {"color": "#1a1a1a"},
    ],
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      {"color": "#242424"},
    ],
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {"color": "#2a2a2a"},
    ],
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {"color": "#0a0a0a"},
    ],
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#4d4d4d"},
    ],
  },
];

const plainMapStyle = [
  {
    "elementType": "geometry",
    "stylers": [
      {"color": "#f5f5f5"},
    ],
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {"visibility": "off"},
    ],
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#616161"},
    ],
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {"color": "#f5f5f5"},
    ],
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#bdbdbd"},
    ],
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {"color": "#eeeeee"},
    ],
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#757575"},
    ],
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {"color": "#e5e5e5"},
    ],
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#9e9e9e"},
    ],
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {"color": "#ffffff"},
    ],
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#757575"},
    ],
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {"color": "#dadada"},
    ],
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#616161"},
    ],
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#9e9e9e"},
    ],
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {"color": "#e5e5e5"},
    ],
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {"color": "#eeeeee"},
    ],
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {"color": "#c9c9c9"},
    ],
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#9e9e9e"},
    ],
  },
];

const mapStyle1 = [
  {
    "featureType": "landscape",
    "elementType": "geometry.fill",
    "stylers": [
      {"color": "#f1f1f2"},
    ],
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {"color": "#efefef"},
    ],
  },
  {
    "featureType": "water",
    "stylers": [
      {"visibility": "on"},
      {"color": "#eeeeee"},
    ],
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {"color": "#ffffff"},
    ],
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {"color": "#757575"},
    ],
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {"visibility": "on"},
      {"color": "#e5e7ef"},
    ],
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [
      {"visibility": "on"},
      {"color": "#ffffff"},
    ],
  },
  {
    "featureType": "poi",
    "elementType": "labels.icon",
    "stylers": [
      {"visibility": "off"},
    ],
  },
];
