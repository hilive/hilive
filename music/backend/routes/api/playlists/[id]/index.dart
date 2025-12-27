import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/services/auth_service.dart';
import '../../../../lib/services/playlist_service.dart';
import '../../../../lib/utils/response_utils.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final authService = AuthService();
  final authHeader = context.request.headers['Authorization'];
  final user = authService.getUserFromToken(authHeader);

  final playlistService = PlaylistService();

  switch (context.request.method) {
    case HttpMethod.get:
      final playlistWithTracks = playlistService.getWithTracks(id, user?.id);
      if (playlistWithTracks == null) {
        return ResponseUtils.notFound('歌单不存在或无权访问');
      }
      return ResponseUtils.success(playlistWithTracks.toJson());
    
    case HttpMethod.put:
      if (user == null) {
        return ResponseUtils.unauthorized();
      }

      final body = await context.request.body();
      final Map<String, dynamic> json;
      
      try {
        json = jsonDecode(body) as Map<String, dynamic>;
      } catch (e) {
        return ResponseUtils.error('Invalid JSON body');
      }

      final updated = playlistService.update(
        id,
        user.id,
        name: json['name'] as String?,
        description: json['description'] as String?,
        coverUrl: json['coverUrl'] as String?,
        isPublic: json['isPublic'] as bool?,
      );

      if (updated == null) {
        return ResponseUtils.error('更新失败，歌单不存在或无权限');
      }

      return ResponseUtils.success(updated.toJson());
    
    case HttpMethod.delete:
      if (user == null) {
        return ResponseUtils.unauthorized();
      }

      final deleted = playlistService.delete(id, user.id);
      if (!deleted) {
        return ResponseUtils.error('删除失败，歌单不存在或无权限');
      }
      return ResponseUtils.success({'deleted': true});
    
    default:
      return ResponseUtils.error('Method not allowed', statusCode: 405);
  }
}
