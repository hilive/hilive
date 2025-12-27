import 'package:dart_frog/dart_frog.dart';
import '../../../lib/services/music_service.dart';
import '../../../lib/utils/response_utils.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return ResponseUtils.error('Method not allowed', statusCode: 405);
  }

  final params = context.request.uri.queryParameters;
  final page = int.tryParse(params['page'] ?? '1') ?? 1;
  final pageSize = int.tryParse(params['pageSize'] ?? '20') ?? 20;
  final uploaderId = params['uploaderId'];

  final musicService = MusicService();
  final result = musicService.getAll(
    page: page,
    pageSize: pageSize,
    uploaderId: uploaderId,
  );

  return ResponseUtils.paginated(
    items: result.items.map((m) => m.toJson()).toList(),
    total: result.total,
    page: page,
    pageSize: pageSize,
  );
}
