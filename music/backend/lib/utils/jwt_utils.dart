import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtUtils {
  static const String _secretKey = 'music_player_secret_key_2024_very_secure';
  static const String _refreshSecretKey = 'music_player_refresh_secret_2024';
  static const int accessTokenExpiresIn = 3600; // 1 hour
  static const int refreshTokenExpiresIn = 604800; // 7 days

  static String generateAccessToken(String userId) {
    final jwt = JWT(
      {
        'userId': userId,
        'type': 'access',
      },
      issuer: 'music_player_backend',
    );

    return jwt.sign(
      SecretKey(_secretKey),
      expiresIn: Duration(seconds: accessTokenExpiresIn),
    );
  }

  static String generateRefreshToken(String userId) {
    final jwt = JWT(
      {
        'userId': userId,
        'type': 'refresh',
      },
      issuer: 'music_player_backend',
    );

    return jwt.sign(
      SecretKey(_refreshSecretKey),
      expiresIn: Duration(seconds: refreshTokenExpiresIn),
    );
  }

  static String? verifyAccessToken(String token) {
    final jwt = JWT.tryVerify(token, SecretKey(_secretKey));
    if (jwt == null) return null;
    
    final payload = jwt.payload as Map<String, dynamic>;
    if (payload['type'] != 'access') return null;
    
    return payload['userId'] as String?;
  }

  static String? verifyRefreshToken(String token) {
    final jwt = JWT.tryVerify(token, SecretKey(_refreshSecretKey));
    if (jwt == null) return null;
    
    final payload = jwt.payload as Map<String, dynamic>;
    if (payload['type'] != 'refresh') return null;
    
    return payload['userId'] as String?;
  }

  static String? extractTokenFromHeader(String? authHeader) {
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return null;
    }
    return authHeader.substring(7);
  }
}
