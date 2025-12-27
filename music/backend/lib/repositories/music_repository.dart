import 'package:uuid/uuid.dart';
import '../models/music.dart';

class MusicRepository {
  static final MusicRepository _instance = MusicRepository._internal();
  factory MusicRepository() => _instance;
  MusicRepository._internal() {
    _initPresetMusic();
  }

  final _uuid = const Uuid();
  final Map<String, Music> _music = {};

  void _initPresetMusic() {
    // 预置一些示例音乐
    final presetMusic = [
      Music(
        id: _uuid.v4(),
        title: 'Moonlight Sonata',
        artist: 'Ludwig van Beethoven',
        album: 'Classical Masterpieces',
        coverUrl: 'https://images.unsplash.com/photo-1507838153414-b4b713384a76?w=300',
        audioUrl: '/api/music/preset/moonlight-sonata.mp3',
        duration: 360,
        genre: 'Classical',
        year: 1801,
        bitrate: 320,
        format: 'mp3',
        fileSize: 8640000,
        uploaderId: 'system',
        isPublic: true,
        playCount: 1250,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Music(
        id: _uuid.v4(),
        title: 'Jazz in the Night',
        artist: 'The Smooth Quartet',
        album: 'Late Night Sessions',
        coverUrl: 'https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=300',
        audioUrl: '/api/music/preset/jazz-night.mp3',
        duration: 285,
        genre: 'Jazz',
        year: 2023,
        bitrate: 320,
        format: 'mp3',
        fileSize: 6840000,
        uploaderId: 'system',
        isPublic: true,
        playCount: 890,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Music(
        id: _uuid.v4(),
        title: 'Electric Dreams',
        artist: 'Synthwave Masters',
        album: 'Neon Horizons',
        coverUrl: 'https://images.unsplash.com/photo-1614149162883-504ce4d13909?w=300',
        audioUrl: '/api/music/preset/electric-dreams.mp3',
        duration: 240,
        genre: 'Electronic',
        year: 2024,
        bitrate: 320,
        format: 'mp3',
        fileSize: 5760000,
        uploaderId: 'system',
        isPublic: true,
        playCount: 2100,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Music(
        id: _uuid.v4(),
        title: 'Acoustic Morning',
        artist: 'Sarah Chen',
        album: 'Sunrise Sessions',
        coverUrl: 'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=300',
        audioUrl: '/api/music/preset/acoustic-morning.mp3',
        duration: 198,
        genre: 'Folk',
        year: 2024,
        bitrate: 256,
        format: 'mp3',
        fileSize: 3960000,
        uploaderId: 'system',
        isPublic: true,
        playCount: 560,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Music(
        id: _uuid.v4(),
        title: 'Urban Beats',
        artist: 'DJ Metro',
        album: 'City Lights',
        coverUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=300',
        audioUrl: '/api/music/preset/urban-beats.mp3',
        duration: 210,
        genre: 'Hip Hop',
        year: 2024,
        bitrate: 320,
        format: 'mp3',
        fileSize: 5040000,
        uploaderId: 'system',
        isPublic: true,
        playCount: 3200,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Music(
        id: _uuid.v4(),
        title: 'Ocean Waves',
        artist: 'Ambient Collective',
        album: 'Nature Sounds',
        coverUrl: 'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=300',
        audioUrl: '/api/music/preset/ocean-waves.mp3',
        duration: 420,
        genre: 'Ambient',
        year: 2023,
        bitrate: 192,
        format: 'mp3',
        fileSize: 6300000,
        uploaderId: 'system',
        isPublic: true,
        playCount: 1800,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Music(
        id: _uuid.v4(),
        title: 'Rock Anthem',
        artist: 'Thunder Road',
        album: 'Highway to Glory',
        coverUrl: 'https://images.unsplash.com/photo-1498038432885-c6f3f1b912ee?w=300',
        audioUrl: '/api/music/preset/rock-anthem.mp3',
        duration: 275,
        genre: 'Rock',
        year: 2024,
        bitrate: 320,
        format: 'mp3',
        fileSize: 6600000,
        uploaderId: 'system',
        isPublic: true,
        playCount: 4500,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Music(
        id: _uuid.v4(),
        title: 'Chill Vibes',
        artist: 'Lo-Fi Studio',
        album: 'Study Sessions',
        coverUrl: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=300',
        audioUrl: '/api/music/preset/chill-vibes.mp3',
        duration: 180,
        genre: 'Lo-Fi',
        year: 2024,
        bitrate: 256,
        format: 'mp3',
        fileSize: 3600000,
        uploaderId: 'system',
        isPublic: true,
        playCount: 6800,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    for (final music in presetMusic) {
      _music[music.id] = music;
    }
  }

  Music? findById(String id) => _music[id];

  List<Music> findAll({int page = 1, int pageSize = 20, String? uploaderId}) {
    var items = _music.values.where((m) => m.isPublic).toList();
    
    if (uploaderId != null) {
      items = items.where((m) => m.uploaderId == uploaderId).toList();
    }
    
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    final start = (page - 1) * pageSize;
    if (start >= items.length) return [];
    
    return items.skip(start).take(pageSize).toList();
  }

  int count({String? uploaderId}) {
    var items = _music.values.where((m) => m.isPublic);
    if (uploaderId != null) {
      items = items.where((m) => m.uploaderId == uploaderId);
    }
    return items.length;
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
    final id = _uuid.v4();
    final music = Music(
      id: id,
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
      createdAt: DateTime.now(),
    );
    _music[id] = music;
    return music;
  }

  Music? update(String id, {
    String? title,
    String? artist,
    String? album,
    String? coverUrl,
    String? genre,
    int? year,
    bool? isPublic,
  }) {
    final music = _music[id];
    if (music == null) return null;

    final updated = music.copyWith(
      title: title,
      artist: artist,
      album: album,
      coverUrl: coverUrl,
      genre: genre,
      year: year,
      isPublic: isPublic,
      updatedAt: DateTime.now(),
    );
    _music[id] = updated;
    return updated;
  }

  Music? incrementPlayCount(String id) {
    final music = _music[id];
    if (music == null) return null;
    
    final updated = music.copyWith(playCount: music.playCount + 1);
    _music[id] = updated;
    return updated;
  }

  bool delete(String id) {
    return _music.remove(id) != null;
  }

  List<Music> search(String query, {int limit = 20}) {
    final lowerQuery = query.toLowerCase();
    return _music.values
        .where((m) => m.isPublic && (
            m.title.toLowerCase().contains(lowerQuery) ||
            m.artist.toLowerCase().contains(lowerQuery) ||
            (m.album?.toLowerCase().contains(lowerQuery) ?? false)
        ))
        .take(limit)
        .toList();
  }

  List<Music> findByIds(List<String> ids) {
    return ids.map((id) => _music[id]).whereType<Music>().toList();
  }

  List<String> getUniqueArtists() {
    return _music.values
        .where((m) => m.isPublic)
        .map((m) => m.artist)
        .toSet()
        .toList();
  }

  List<String> getUniqueAlbums() {
    return _music.values
        .where((m) => m.isPublic && m.album != null)
        .map((m) => m.album!)
        .toSet()
        .toList();
  }

  List<Music> findByArtist(String artist) {
    return _music.values
        .where((m) => m.isPublic && m.artist.toLowerCase() == artist.toLowerCase())
        .toList();
  }

  List<Music> findByAlbum(String album) {
    return _music.values
        .where((m) => m.isPublic && m.album?.toLowerCase() == album.toLowerCase())
        .toList();
  }
}
