import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'name': 'Music Player API',
      'version': '1.0.0',
      'status': 'running',
      'endpoints': {
        'auth': '/api/auth',
        'users': '/api/users',
        'music': '/api/music',
        'playlists': '/api/playlists',
        'favorites': '/api/favorites',
        'history': '/api/history',
        'search': '/api/search',
      },
    },
  );
}
