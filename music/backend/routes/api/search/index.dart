import 'package:dart_frog/dart_frog.dart';
import '../../../lib/services/search_service.dart';
import '../../../lib/utils/response_utils.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return ResponseUtils.error('Method not allowed', statusCode: 405);
  }

  final params = context.request.uri.queryParameters;
  final query = params['q'] ?? params['query'] ?? '';
  final limit = int.tryParse(params['limit'] ?? '20') ?? 20;

  if (query.isEmpty) {
    return ResponseUtils.error('搜索关键词不能为空');
  }

  final searchService = SearchService();
  final result = searchService.search(query, limit: limit);

  return ResponseUtils.success(result.toJson());
}
