/// API Constants
class ApiConstants {
  static const String apiVersion = 'v1';
  static const String basePathPrefix = '/api';
  
  // Auth endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  
  // User endpoints
  static const String usersMe = '/users/me';
  static const String usersUpdate = '/users/me';
  
  // Music endpoints
  static const String music = '/music';
  static const String musicUpload = '/music/upload';
  static String musicDetail(String id) => '/music/$id';
  static String musicStream(String id) => '/music/$id/stream';
  static String musicCover(String id) => '/music/$id/cover';
  
  // Playlist endpoints
  static const String playlists = '/playlists';
  static String playlistDetail(String id) => '/playlists/$id';
  static String playlistTracks(String id) => '/playlists/$id/tracks';
  static String playlistTrack(String playlistId, String trackId) => 
      '/playlists/$playlistId/tracks/$trackId';
  
  // Favorite endpoints
  static const String favorites = '/favorites';
  static String favoriteMusic(String musicId) => '/favorites/$musicId';
  static String checkFavorite(String musicId) => '/favorites/check/$musicId';
  
  // History endpoints
  static const String history = '/history';
  static const String historyRecord = '/history/record';
  static const String historyClear = '/history/clear';
  
  // Search endpoints
  static const String search = '/search';
  static const String searchHistory = '/search/history';
  static const String searchHistoryClear = '/search/history/clear';
}

/// App Constants
class AppConstants {
  // Supported audio formats
  static const List<String> supportedAudioFormats = [
    'mp3',
    'flac',
    'wav',
    'aac',
    'm4a',
    'ogg',
  ];
  
  // Max file size (100MB)
  static const int maxFileSize = 100 * 1024 * 1024;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Token expiration
  static const int accessTokenExpiresIn = 3600; // 1 hour
  static const int refreshTokenExpiresIn = 604800; // 7 days
  
  // Search
  static const int maxSearchHistoryItems = 20;
  static const int searchDebounceMs = 300;
  
  // Player
  static const int seekStepSeconds = 10;
  static const double minVolume = 0.0;
  static const double maxVolume = 1.0;
  static const double defaultVolume = 0.7;
}

/// Play modes
enum PlayMode {
  sequence, // 顺序播放
  loop,     // 列表循环
  single,   // 单曲循环
  shuffle,  // 随机播放
}

/// Music quality
enum MusicQuality {
  low,      // 128kbps
  medium,   // 192kbps
  high,     // 320kbps
  lossless, // FLAC
}
