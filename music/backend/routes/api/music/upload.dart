import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../lib/services/auth_service.dart';
import '../../../lib/services/music_service.dart';
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

  final title = json['title'] as String?;
  final artist = json['artist'] as String?;
  final audioUrl = json['audioUrl'] as String?;
  final duration = json['duration'] as int?;
  final fileSize = json['fileSize'] as int?;

  if (title == null || artist == null || audioUrl == null || 
      duration == null || fileSize == null) {
    return ResponseUtils.error('缺少必填字段');
  }

  final musicService = MusicService();
  final music = musicService.create(
    title: title,
    artist: artist,
    album: json['album'] as String?,
    coverUrl: json['coverUrl'] as String?,
    audioUrl: audioUrl,
    duration: duration,
    trackNumber: json['trackNumber'] as int?,
    genre: json['genre'] as String?,
    year: json['year'] as int?,
    bitrate: json['bitrate'] as int?,
    format: json['format'] as String?,
    fileSize: fileSize,
    uploaderId: user.id,
    isPublic: json['isPublic'] as bool? ?? true,
  );

  return ResponseUtils.created(music.toJson());
}
