import 'package:dart_frog/dart_frog.dart';
import '../../../lib/services/auth_service.dart';
import '../../../lib/services/history_service.dart';
import '../../../lib/utils/response_utils.dart';

Future<Response> onRequest(RequestContext context) async {
  final authService = AuthService();
  final authHeader = context.request.headers['Authorization'];
  final user = authService.getUserFromToken(authHeader);

  if (user == null) {
    return ResponseUtils.unauthorized();
  }

  final historyService = HistoryService();

  switch (context.request.method) {
    case HttpMethod.get:
      final params = context.request.uri.queryParameters;
      final page = int.tryParse(params['page'] ?? '1') ?? 1;
      final pageSize = int.tryParse(params['pageSize'] ?? '20') ?? 20;

      final result = historyService.getByUserId(
        user.id,
        page: page,
        pageSize: pageSize,
      );

      return ResponseUtils.paginated(
        items: result.items.map((h) => h.toJson()).toList(),
        total: result.total,
        page: page,
        pageSize: pageSize,
      );
    
    case HttpMethod.delete:
      historyService.clear(user.id);
      return ResponseUtils.success({'cleared': true});
    
    default:
      return ResponseUtils.error('Method not allowed', statusCode: 405);
  }
}
