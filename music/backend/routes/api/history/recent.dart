import 'package:dart_frog/dart_frog.dart';
import '../../../lib/services/auth_service.dart';
import '../../../lib/services/history_service.dart';
import '../../../lib/utils/response_utils.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return ResponseUtils.error('Method not allowed', statusCode: 405);
  }

  final authService = AuthService();
  final authHeader = context.request.headers['Authorization'];
  final user = authService.getUserFromToken(authHeader);

  if (user == null) {
    return ResponseUtils.unauthorized();
  }

  final params = context.request.uri.queryParameters;
  final limit = int.tryParse(params['limit'] ?? '10') ?? 10;

  final historyService = HistoryService();
  final recentMusic = historyService.getRecentlyPlayed(user.id, limit: limit);

  return ResponseUtils.success(recentMusic.map((m) => m.toJson()).toList());
}
