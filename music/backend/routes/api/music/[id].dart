import 'package:dart_frog/dart_frog.dart';
import '../../../lib/services/music_service.dart';
import '../../../lib/services/auth_service.dart';
import '../../../lib/utils/response_utils.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final musicService = MusicService();

  switch (context.request.method) {
    case HttpMethod.get:
      final music = musicService.getById(id);
      if (music == null) {
        return ResponseUtils.notFound('音乐不存在');
      }
      return ResponseUtils.success(music.toJson());
    
    case HttpMethod.delete:
      final authService = AuthService();
      final authHeader = context.request.headers['Authorization'];
      final user = authService.getUserFromToken(authHeader);
      
      if (user == null) {
        return ResponseUtils.unauthorized();
      }

      final deleted = musicService.delete(id, user.id);
      if (!deleted) {
        return ResponseUtils.error('删除失败，音乐不存在或无权限');
      }
      return ResponseUtils.success({'deleted': true});
    
    default:
      return ResponseUtils.error('Method not allowed', statusCode: 405);
  }
}
