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

  final email = json['email'] as String?;
  final password = json['password'] as String?;

  if (email == null || password == null) {
    return ResponseUtils.error('缺少必填字段：email, password');
  }

  final authService = AuthService();
  final result = authService.login(email: email, password: password);

  if (result.error != null) {
    return ResponseUtils.error(result.error!, statusCode: 401);
  }

  return ResponseUtils.success(result.response!.toJson());
}
