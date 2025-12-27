import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/services/auth_service.dart';
import '../../../../lib/services/playlist_service.dart';
import '../../../../lib/utils/response_utils.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final authService = AuthService();
  final authHeader = context.request.headers['Authorization'];
  final user = authService.getUserFromToken(authHeader);

  if (user == null) {
    return ResponseUtils.unauthorized();
  }

  final playlistService = PlaylistService();

  switch (context.request.method) {
    case HttpMethod.post:
      final body = await context.request.body();
      final Map<String, dynamic> json;
      
      try {
        json = jsonDecode(body) as Map<String, dynamic>;
      } catch (e) {
        return ResponseUtils.error('Invalid JSON body');
      }

      final musicId = json['musicId'] as String?;
      if (musicId == null) {
        return ResponseUtils.error('缺少 musicId');
      }

      final added = playlistService.addTrack(
        id,
        musicId,
        user.id,
        position: json['position'] as int?,
      );

      if (!added) {
        return ResponseUtils.error('添加失败，歌单不存在、无权限或歌曲已存在');
      }

      return ResponseUtils.success({'added': true});
    
    case HttpMethod.delete:
      final body = await context.request.body();
      final Map<String, dynamic> json;
      
      try {
        json = jsonDecode(body) as Map<String, dynamic>;
      } catch (e) {
        return ResponseUtils.error('Invalid JSON body');
      }

      final musicId = json['musicId'] as String?;
      if (musicId == null) {
        return ResponseUtils.error('缺少 musicId');
      }

      final removed = playlistService.removeTrack(id, musicId, user.id);
      if (!removed) {
        return ResponseUtils.error('移除失败');
      }

      return ResponseUtils.success({'removed': true});
    
    case HttpMethod.put:
      // Reorder tracks
      final body = await context.request.body();
      final Map<String, dynamic> json;
      
      try {
        json = jsonDecode(body) as Map<String, dynamic>;
      } catch (e) {
        return ResponseUtils.error('Invalid JSON body');
      }

      final musicIds = (json['musicIds'] as List?)?.cast<String>();
      if (musicIds == null) {
        return ResponseUtils.error('缺少 musicIds');
      }

      playlistService.reorderTracks(id, user.id, musicIds);
      return ResponseUtils.success({'reordered': true});
    
    default:
      return ResponseUtils.error('Method not allowed', statusCode: 405);
  }
}
