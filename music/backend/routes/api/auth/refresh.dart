import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../lib/services/auth_service.dart';
import '../../../lib/utils/response_utils.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return ResponseUtils.error('Method not allowed', statusCode: 405);
  }

  final body = await context.request.body();
  final Map<String, dynamic> json;
  
  try {
    json = jsonDecode(body) as Map<String, dynamic>;
  } catch (e) {
    return ResponseUtils.error('Invalid JSON body');
  }

  final refreshToken = json['refreshToken'] as String?;

  if (refreshToken == null) {
    return ResponseUtils.error('缺少 refreshToken');
  }

  final authService = AuthService();
  final result = authService.refresh(refreshToken);

  if (result.error != null) {
    return ResponseUtils.unauthorized(result.error!);
  }

  return ResponseUtils.success(result.response!.toJson());
}
