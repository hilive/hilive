import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../models/playlist.dart';

class PlaylistState {
  final List<Playlist> items;
  final bool isLoading;
  final String? error;

  const PlaylistState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  PlaylistState copyWith({
    List<Playlist>? items,
    bool? isLoading,
    String? error,
  }) {
    return PlaylistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PlaylistNotifier extends StateNotifier<PlaylistState> {
  final ApiClient _apiClient;

  PlaylistNotifier(this._apiClient) : super(const PlaylistState());

  Future<void> loadPlaylists() async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _apiClient.get('/api/playlists');

    final body = response.data as Map<String, dynamic>;
    if (body['success'] == true) {
      final data = body['data'] as Map<String, dynamic>;
      final items = (data['items'] as List)
          .map((e) => Playlist.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(items: items, isLoading: false);
    } else {
      state = state.copyWith(
        isLoading: false,
        error: body['error'] as String?,
      );
    }
  }

  Future<Playlist?> createPlaylist(String name, {String? description}) async {
    final response = await _apiClient.post('/api/playlists', data: {
      'name': name,
      'description': description,
    });

    final body = response.data as Map<String, dynamic>;
    if (body['success'] == true) {
      final playlist = Playlist.fromJson(body['data'] as Map<String, dynamic>);
      state = state.copyWith(items: [playlist, ...state.items]);
      return playlist;
    }
    return null;
  }

  Future<bool> deletePlaylist(String id) async {
    final response = await _apiClient.delete('/api/playlists/$id');

    final body = response.data as Map<String, dynamic>;
    if (body['success'] == true) {
      state = state.copyWith(
        items: state.items.where((p) => p.id != id).toList(),
      );
      return true;
    }
    return false;
  }

  Future<bool> addTrackToPlaylist(String playlistId, String musicId) async {
    final response = await _apiClient.post(
      '/api/playlists/$playlistId/tracks',
      data: {'musicId': musicId},
    );

    final body = response.data as Map<String, dynamic>;
    return body['success'] == true;
  }

  Future<bool> removeTrackFromPlaylist(String playlistId, String musicId) async {
    final response = await _apiClient.delete(
      '/api/playlists/$playlistId/tracks',
      data: {'musicId': musicId},
    );

    final body = response.data as Map<String, dynamic>;
    return body['success'] == true;
  }
}

final playlistProvider = StateNotifierProvider<PlaylistNotifier, PlaylistState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PlaylistNotifier(apiClient);
});

// Single playlist detail provider
final playlistDetailProvider = FutureProvider.family<PlaylistWithTracks?, String>((ref, id) async {
  final apiClient = ref.watch(apiClientProvider);
  
  final response = await apiClient.get('/api/playlists/$id');
  final body = response.data as Map<String, dynamic>;
  
  if (body['success'] == true) {
    return PlaylistWithTracks.fromJson(body['data'] as Map<String, dynamic>);
  }
  return null;
});
