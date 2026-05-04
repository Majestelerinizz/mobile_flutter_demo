class AppConstants {
  // App info
  static const String appName = 'AidatPanel';
  static const String appVersion = '0.0.9';

  // Storage keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiryKey = 'token_expiry';
  static const String userKey = 'user';
  static const String languageKey = 'language';
  static const String fcmTokenKey = 'fcm_token';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // Invite code
  static const int inviteCodeExpiryDays = 7;

  // Pagination
  static const int pageSize = 20;

  // Default language
  static const String defaultLanguage = 'tr';
}
