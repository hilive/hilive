import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../lib/services/auth_service.dart';
import '../../../lib/services/history_service.dart';
import '../../../lib/utils/response_utils.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return ResponseUtils.error('Method not allowed', statusCode: 405);
  }

  final authService = AuthService();
  final authHeader = context.request.headers['Authorization'];
  final user = authService.getUserFromToken(authHeader);

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

  final musicId = json['musicId'] as String?;
  final playedDuration = json['playedDuration'] as int?;

  if (musicId == null || playedDuration == null) {
    return ResponseUtils.error('缺少必填字段');
  }

  final historyService = HistoryService();
  final history = historyService.record(
    userId: user.id,
    musicId: musicId,
    playedDuration: playedDuration,
    completed: json['completed'] as bool? ?? false,
  );

  return ResponseUtils.created(history.toJson());
}
