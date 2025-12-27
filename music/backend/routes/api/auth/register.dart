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
  final username = json['username'] as String?;
  final password = json['password'] as String?;

  if (email == null || username == null || password == null) {
    return ResponseUtils.error('缺少必填字段：email, username, password');
  }

  final authService = AuthService();
  final result = authService.register(
    email: email,
    username: username,
    password: password,
  );

  if (result.error != null) {
    return ResponseUtils.error(result.error!);
  }

  return ResponseUtils.created(result.response!.toJson());
}
