import '../models/favorite.dart';
import '../models/music.dart';
import '../repositories/favorite_repository.dart';
import '../repositories/music_repository.dart';

class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  final _favoriteRepo = FavoriteRepository();
  final _musicRepo = MusicRepository();

  bool isFavorite(String userId, String musicId) {
    return _favoriteRepo.isFavorite(userId, musicId);
  }

  ({List<FavoriteWithMusic> items, int total}) getByUserId(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) {
    final favorites = _favoriteRepo.findByUserId(userId, page: page, pageSize: pageSize);
    final total = _favoriteRepo.countByUserId(userId);

    final items = favorites.map((f) {
      final music = _musicRepo.findById(f.musicId);
      if (music == null) return null;
      return FavoriteWithMusic(favorite: f, music: music);
    }).whereType<FavoriteWithMusic>().toList();

    return (items: items, total: total);
  }

  Favorite? add(String userId, String musicId) {
    final music = _musicRepo.findById(musicId);
    if (music == null) return null;

    return _favoriteRepo.add(userId, musicId);
  }

  bool remove(String userId, String musicId) {
    return _favoriteRepo.remove(userId, musicId);
  }

  List<Music> getFavoriteMusic(String userId) {
    final musicIds = _favoriteRepo.getFavoriteMusicIds(userId);
    return _musicRepo.findByIds(musicIds);
  }
}
