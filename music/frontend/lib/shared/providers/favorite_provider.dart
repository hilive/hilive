import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../models/music.dart';

class FavoriteState {
  final List<Music> items;
  final Set<String> favoriteIds;
  final bool isLoading;
  final String? error;

  const FavoriteState({
    this.items = const [],
    this.favoriteIds = const {},
    this.isLoading = false,
    this.error,
  });

  FavoriteState copyWith({
    List<Music>? items,
    Set<String>? favoriteIds,
    bool? isLoading,
    String? error,
  }) {
    return FavoriteState(
      items: items ?? this.items,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool isFavorite(String musicId) => favoriteIds.contains(musicId);
}

class FavoriteNotifier extends StateNotifier<FavoriteState> {
  final ApiClient _apiClient;

  FavoriteNotifier(this._apiClient) : super(const FavoriteState());

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _apiClient.get('/api/favorites', queryParameters: {
      'pageSize': 100,
    });

    final body = response.data as Map<String, dynamic>;
    if (body['success'] == true) {
      final data = body['data'] as Map<String, dynamic>;
      final items = (data['items'] as List).map((e) {
        final item = e as Map<String, dynamic>;
        return Music.fromJson(item['music'] as Map<String, dynamic>);
      }).toList();

      state = state.copyWith(
        items: items,
        favoriteIds: items.map((m) => m.id).toSet(),
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: body['error'] as String?,
      );
    }
  }

  Future<bool> toggleFavorite(Music music) async {
    final isFavorite = state.favoriteIds.contains(music.id);

    if (isFavorite) {
      // Remove from favorites
      final response = await _apiClient.delete('/api/favorites/${music.id}');
      final body = response.data as Map<String, dynamic>;
      
      if (body['success'] == true) {
        state = state.copyWith(
          items: state.items.where((m) => m.id != music.id).toList(),
          favoriteIds: {...state.favoriteIds}..remove(music.id),
        );
        return true;
      }
    } else {
      // Add to favorites
      final response = await _apiClient.post('/api/favorites', data: {
        'musicId': music.id,
      });
      final body = response.data as Map<String, dynamic>;
      
      if (body['success'] == true) {
        state = state.copyWith(
          items: [music, ...state.items],
          favoriteIds: {...state.favoriteIds, music.id},
        );
        return true;
      }
    }
    return false;
  }

  Future<bool> checkFavorite(String musicId) async {
    final response = await _apiClient.get('/api/favorites/$musicId');
    final body = response.data as Map<String, dynamic>;
    
    if (body['success'] == true) {
      final isFavorite = body['data']['isFavorite'] as bool;
      if (isFavorite && !state.favoriteIds.contains(musicId)) {
        state = state.copyWith(
          favoriteIds: {...state.favoriteIds, musicId},
        );
      } else if (!isFavorite && state.favoriteIds.contains(musicId)) {
        state = state.copyWith(
          favoriteIds: {...state.favoriteIds}..remove(musicId),
        );
      }
      return isFavorite;
    }
    return false;
  }
}

final favoriteProvider = StateNotifierProvider<FavoriteNotifier, FavoriteState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FavoriteNotifier(apiClient);
});
