import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../models/music.dart';

class MusicState {
  final List<Music> items;
  final bool isLoading;
  final String? error;
  final int page;
  final bool hasMore;
  final int total;

  const MusicState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
    this.total = 0,
  });

  MusicState copyWith({
    List<Music>? items,
    bool? isLoading,
    String? error,
    int? page,
    bool? hasMore,
    int? total,
  }) {
    return MusicState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
    );
  }
}

class MusicNotifier extends StateNotifier<MusicState> {
  final ApiClient _apiClient;

  MusicNotifier(this._apiClient) : super(const MusicState());

  Future<void> loadMusic({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    final page = refresh ? 1 : state.page;
    state = state.copyWith(isLoading: true, error: null);

    final response = await _apiClient.get('/api/music', queryParameters: {
      'page': page,
      'pageSize': 20,
    });

    final body = response.data as Map<String, dynamic>;
    if (body['success'] == true) {
      final data = body['data'] as Map<String, dynamic>;
      final newItems = (data['items'] as List)
          .map((e) => Music.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        items: refresh ? newItems : [...state.items, ...newItems],
        isLoading: false,
        page: page + 1,
        hasMore: data['hasMore'] as bool,
        total: data['total'] as int,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: body['error'] as String?,
      );
    }
  }

  Future<void> refresh() => loadMusic(refresh: true);
}

final musicProvider = StateNotifierProvider<MusicNotifier, MusicState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MusicNotifier(apiClient);
});

// Search provider
class SearchState {
  final String query;
  final List<Music> tracks;
  final bool isLoading;
  final String? error;

  const SearchState({
    this.query = '',
    this.tracks = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<Music>? tracks,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      tracks: tracks ?? this.tracks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final ApiClient _apiClient;

  SearchNotifier(this._apiClient) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(query: query, isLoading: true, error: null);

    final response = await _apiClient.get('/api/search', queryParameters: {
      'q': query,
      'limit': 50,
    });

    final body = response.data as Map<String, dynamic>;
    if (body['success'] == true) {
      final data = body['data'] as Map<String, dynamic>;
      final tracks = (data['tracks'] as List)
          .map((e) => Music.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        tracks: tracks,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: body['error'] as String?,
      );
    }
  }

  void clear() {
    state = const SearchState();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SearchNotifier(apiClient);
});
