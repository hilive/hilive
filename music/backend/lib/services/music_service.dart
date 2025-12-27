import '../models/music.dart';
import '../repositories/music_repository.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final _musicRepo = MusicRepository();

  Music? getById(String id) => _musicRepo.findById(id);

  ({List<Music> items, int total}) getAll({
    int page = 1,
    int pageSize = 20,
    String? uploaderId,
  }) {
    final items = _musicRepo.findAll(
      page: page,
      pageSize: pageSize,
      uploaderId: uploaderId,
    );
    final total = _musicRepo.count(uploaderId: uploaderId);
    return (items: items, total: total);
  }

  Music create({
    required String title,
    required String artist,
    String? album,
    String? coverUrl,
    required String audioUrl,
    required int duration,
    int? trackNumber,
    String? genre,
    int? year,
    int? bitrate,
    String? format,
    required int fileSize,
    required String uploaderId,
    bool isPublic = true,
  }) {
    return _musicRepo.create(
      title: title,
      artist: artist,
      album: album,
      coverUrl: coverUrl,
      audioUrl: audioUrl,
      duration: duration,
      trackNumber: trackNumber,
      genre: genre,
      year: year,
      bitrate: bitrate,
      format: format,
      fileSize: fileSize,
      uploaderId: uploaderId,
      isPublic: isPublic,
    );
  }

  Music? update(String id, String userId, {
    String? title,
    String? artist,
    String? album,
    String? coverUrl,
    String? genre,
    int? year,
    bool? isPublic,
  }) {
    final music = _musicRepo.findById(id);
    if (music == null || music.uploaderId != userId) return null;

    return _musicRepo.update(
      id,
      title: title,
      artist: artist,
      album: album,
      coverUrl: coverUrl,
      genre: genre,
      year: year,
      isPublic: isPublic,
    );
  }

  bool delete(String id, String userId) {
    final music = _musicRepo.findById(id);
    if (music == null || music.uploaderId != userId) return false;
    return _musicRepo.delete(id);
  }

  Music? incrementPlayCount(String id) {
    return _musicRepo.incrementPlayCount(id);
  }

  List<Music> search(String query, {int limit = 20}) {
    return _musicRepo.search(query, limit: limit);
  }

  List<Music> getByIds(List<String> ids) {
    return _musicRepo.findByIds(ids);
  }

  List<String> getArtists() => _musicRepo.getUniqueArtists();
  List<String> getAlbums() => _musicRepo.getUniqueAlbums();
  List<Music> getByArtist(String artist) => _musicRepo.findByArtist(artist);
  List<Music> getByAlbum(String album) => _musicRepo.findByAlbum(album);
}
