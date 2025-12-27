import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../lib/services/auth_service.dart';
import '../../../lib/services/playlist_service.dart';
import '../../../lib/utils/response_utils.dart';

Future<Response> onRequest(RequestContext context) async {
  final authService = AuthService();
  final authHeader = context.request.headers['Authorization'];
  final user = authService.getUserFromToken(authHeader);

  if (user == null) {
    return ResponseUtils.unauthorized();
  }

  final playlistService = PlaylistService();

  switch (context.request.method) {
    case HttpMethod.get:
      final params = context.request.uri.queryParameters;
      final page = int.tryParse(params['page'] ?? '1') ?? 1;
      final pageSize = int.tryParse(params['pageSize'] ?? '20') ?? 20;

      final result = playlistService.getByUserId(
        user.id,
        page: page,
        pageSize: pageSize,
      );

      return ResponseUtils.paginated(
        items: result.items.map((p) => p.toJson()).toList(),
        total: result.total,
        page: page,
        pageSize: pageSize,
      );
    
    case HttpMethod.post:
      final body = await context.request.body();
      final Map<String, dynamic> json;
      
      try {
        json = jsonDecode(body) as Map<String, dynamic>;
      } catch (e) {
        return ResponseUtils.error('Invalid JSON body');
      }

      final name = json['name'] as String?;
      if (name == null || name.isEmpty) {
        return ResponseUtils.error('歌单名称不能为空');
      }

      final playlist = playlistService.create(
        name: name,
        description: json['description'] as String?,
        coverUrl: json['coverUrl'] as String?,
        userId: user.id,
        isPublic: json['isPublic'] as bool? ?? false,
      );

      return ResponseUtils.created(playlist.toJson());
    
    default:
      return ResponseUtils.error('Method not allowed', statusCode: 405);
  }
}
