import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../lib/services/auth_service.dart';
import '../../../lib/repositories/user_repository.dart';
import '../../../lib/utils/response_utils.dart';

Future<Response> onRequest(RequestContext context) async {
  final authService = AuthService();
  final authHeader = context.request.headers['Authorization'];
  final user = authService.getUserFromToken(authHeader);

  if (user == null) {
    return ResponseUtils.unauthorized();
  }

  switch (context.request.method) {
    case HttpMethod.get:
      return ResponseUtils.success(user.toPublicJson());
    
    case HttpMethod.put:
      final body = await context.request.body();
      final Map<String, dynamic> json;
      
      try {
        json = jsonDecode(body) as Map<String, dynamic>;
      } catch (e) {
        return ResponseUtils.error('Invalid JSON body');
      }

      final userRepo = UserRepository();
      final updatedUser = userRepo.update(
        user.id,
        username: json['username'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
      );

      if (updatedUser == null) {
        return ResponseUtils.error('更新失败');
      }

      return ResponseUtils.success(updatedUser.toPublicJson());
    
    default:
      return ResponseUtils.error('Method not allowed', statusCode: 405);
  }
}
