class AppConstants {
  static const String appName = '音乐播放器';
  static const String baseUrl = 'http://127.0.0.1:8080';
  
  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Player
  static const int seekStepSeconds = 10;
  static const double defaultVolume = 0.7;
}
