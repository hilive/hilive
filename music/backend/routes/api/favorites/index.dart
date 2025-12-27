import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../lib/services/auth_service.dart';
import '../../../lib/services/favorite_service.dart';
import '../../../lib/utils/response_utils.dart';

Future<Response> onRequest(RequestContext context) async {
  final authService = AuthService();
  final authHeader = context.request.headers['Authorization'];
  final user = authService.getUserFromToken(authHeader);

  if (user == null) {
    return ResponseUtils.unauthorized();
  }

  final favoriteService = FavoriteService();

  switch (context.request.method) {
    case HttpMethod.get:
      final params = context.request.uri.queryParameters;
      final page = int.tryParse(params['page'] ?? '1') ?? 1;
      final pageSize = int.tryParse(params['pageSize'] ?? '20') ?? 20;

      final result = favoriteService.getByUserId(
        user.id,
        page: page,
        pageSize: pageSize,
      );

      return ResponseUtils.paginated(
        items: result.items.map((f) => f.toJson()).toList(),
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

      final musicId = json['musicId'] as String?;
      if (musicId == null) {
        return ResponseUtils.error('缺少 musicId');
      }

      final favorite = favoriteService.add(user.id, musicId);
      if (favorite == null) {
        return ResponseUtils.error('收藏失败，音乐不存在或已收藏');
      }

      return ResponseUtils.created(favorite.toJson());
    
    default:
      return ResponseUtils.error('Method not allowed', statusCode: 405);
  }
}
