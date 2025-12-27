import 'package:uuid/uuid.dart';
import '../models/favorite.dart';

class FavoriteRepository {
  static final FavoriteRepository _instance = FavoriteRepository._internal();
  factory FavoriteRepository() => _instance;
  FavoriteRepository._internal();

  final _uuid = const Uuid();
  final Map<String, Favorite> _favorites = {};
  final Map<String, Set<String>> _userFavorites = {}; // userId -> Set<musicId>

  Favorite? findById(String id) => _favorites[id];

  bool isFavorite(String userId, String musicId) {
    return _userFavorites[userId]?.contains(musicId) ?? false;
  }

  Favorite? findByUserAndMusic(String userId, String musicId) {
    return _favorites.values.firstWhere(
      (f) => f.userId == userId && f.musicId == musicId,
      orElse: () => Favorite(
        id: '',
        userId: '',
        musicId: '',
        createdAt: DateTime.now(),
      ),
    );
  }

  List<Favorite> findByUserId(String userId, {int page = 1, int pageSize = 20}) {
    final items = _favorites.values
        .where((f) => f.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    final start = (page - 1) * pageSize;
    if (start >= items.length) return [];
    
    return items.skip(start).take(pageSize).toList();
  }

  int countByUserId(String userId) {
    return _userFavorites[userId]?.length ?? 0;
  }

  Favorite? add(String userId, String musicId) {
    // Check if already favorited
    if (isFavorite(userId, musicId)) return null;

    final id = _uuid.v4();
    final favorite = Favorite(
      id: id,
      userId: userId,
      musicId: musicId,
      createdAt: DateTime.now(),
    );
    
    _favorites[id] = favorite;
    _userFavorites.putIfAbsent(userId, () => {}).add(musicId);
    
    return favorite;
  }

  bool remove(String userId, String musicId) {
    final favorite = _favorites.values.firstWhere(
      (f) => f.userId == userId && f.musicId == musicId,
      orElse: () => Favorite(id: '', userId: '', musicId: '', createdAt: DateTime.now()),
    );
    
    if (favorite.id.isEmpty) return false;
    
    _favorites.remove(favorite.id);
    _userFavorites[userId]?.remove(musicId);
    
    return true;
  }

  List<String> getFavoriteMusicIds(String userId) {
    return _userFavorites[userId]?.toList() ?? [];
  }
}
