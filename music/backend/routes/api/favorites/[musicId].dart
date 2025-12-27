import 'package:dart_frog/dart_frog.dart';
import '../../../lib/services/auth_service.dart';
import '../../../lib/services/favorite_service.dart';
import '../../../lib/utils/response_utils.dart';

Future<Response> onRequest(RequestContext context, String musicId) async {
  final authService = AuthService();
  final authHeader = context.request.headers['Authorization'];
  final user = authService.getUserFromToken(authHeader);

  if (user == null) {
    return ResponseUtils.unauthorized();
  }

  final favoriteService = FavoriteService();

  switch (context.request.method) {
    case HttpMethod.get:
      // Check if favorited
      final isFavorite = favoriteService.isFavorite(user.id, musicId);
      return ResponseUtils.success({'isFavorite': isFavorite});
    
    case HttpMethod.delete:
      final removed = favoriteService.remove(user.id, musicId);
      if (!removed) {
        return ResponseUtils.error('取消收藏失败');
      }
      return ResponseUtils.success({'removed': true});
    
    default:
      return ResponseUtils.error('Method not allowed', statusCode: 405);
  }
}
