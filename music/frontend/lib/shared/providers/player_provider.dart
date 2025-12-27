import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/music.dart';

enum PlayMode {
  sequence,
  loop,
  single,
  shuffle,
}

class PlayerState {
  final Music? currentTrack;
  final List<Music> queue;
  final int currentIndex;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final double volume;
  final PlayMode playMode;
  final bool isFavorite;

  const PlayerState({
    this.currentTrack,
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 0.7,
    this.playMode = PlayMode.sequence,
    this.isFavorite = false,
  });

  PlayerState copyWith({
    Music? currentTrack,
    List<Music>? queue,
    int? currentIndex,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    double? volume,
    PlayMode? playMode,
    bool? isFavorite,
  }) {
    return PlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      playMode: playMode ?? this.playMode,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  double get progress {
    if (duration.inMilliseconds == 0) return 0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  bool get hasNext => currentIndex < queue.length - 1;
  bool get hasPrevious => currentIndex > 0;
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  final AudioPlayer _audioPlayer;

  PlayerNotifier() : _audioPlayer = AudioPlayer(), super(const PlayerState()) {
    _initPlayer();
  }

  void _initPlayer() {
    _audioPlayer.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
        isLoading: playerState.processingState == ProcessingState.loading ||
            playerState.processingState == ProcessingState.buffering,
      );

      if (playerState.processingState == ProcessingState.completed) {
        _handleTrackComplete();
      }
    });

    _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });
  }

  void _handleTrackComplete() {
    switch (state.playMode) {
      case PlayMode.single:
        seek(Duration.zero);
        play();
        break;
      case PlayMode.sequence:
        if (state.hasNext) {
          next();
        } else {
          pause();
        }
        break;
      case PlayMode.loop:
        if (state.hasNext) {
          next();
        } else {
          playAt(0);
        }
        break;
      case PlayMode.shuffle:
        if (state.queue.isNotEmpty) {
          final randomIndex = DateTime.now().millisecondsSinceEpoch % state.queue.length;
          playAt(randomIndex);
        }
        break;
    }
  }

  Future<void> playTrack(Music track, {List<Music>? queue}) async {
    final newQueue = queue ?? [track];
    final index = newQueue.indexWhere((m) => m.id == track.id);

    state = state.copyWith(
      currentTrack: track,
      queue: newQueue,
      currentIndex: index >= 0 ? index : 0,
      isLoading: true,
    );

    await _audioPlayer.setUrl(track.audioUrl);
    await _audioPlayer.play();
  }

  Future<void> playAt(int index) async {
    if (index < 0 || index >= state.queue.length) return;

    final track = state.queue[index];
    state = state.copyWith(
      currentTrack: track,
      currentIndex: index,
      isLoading: true,
    );

    await _audioPlayer.setUrl(track.audioUrl);
    await _audioPlayer.play();
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> next() async {
    if (state.playMode == PlayMode.shuffle && state.queue.isNotEmpty) {
      final randomIndex = DateTime.now().millisecondsSinceEpoch % state.queue.length;
      await playAt(randomIndex);
    } else if (state.hasNext) {
      await playAt(state.currentIndex + 1);
    } else if (state.playMode == PlayMode.loop && state.queue.isNotEmpty) {
      await playAt(0);
    }
  }

  Future<void> previous() async {
    if (state.position.inSeconds > 3) {
      await seek(Duration.zero);
    } else if (state.hasPrevious) {
      await playAt(state.currentIndex - 1);
    } else if (state.playMode == PlayMode.loop && state.queue.isNotEmpty) {
      await playAt(state.queue.length - 1);
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void seekToProgress(double progress) {
    final position = Duration(
      milliseconds: (state.duration.inMilliseconds * progress).round(),
    );
    seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  void setPlayMode(PlayMode mode) {
    state = state.copyWith(playMode: mode);
  }

  void togglePlayMode() {
    final modes = PlayMode.values;
    final nextIndex = (state.playMode.index + 1) % modes.length;
    state = state.copyWith(playMode: modes[nextIndex]);
  }

  void setFavorite(bool isFavorite) {
    state = state.copyWith(isFavorite: isFavorite);
  }

  void addToQueue(Music track) {
    state = state.copyWith(queue: [...state.queue, track]);
  }

  void removeFromQueue(int index) {
    if (index < 0 || index >= state.queue.length) return;
    
    final newQueue = List<Music>.from(state.queue)..removeAt(index);
    var newIndex = state.currentIndex;
    
    if (index < state.currentIndex) {
      newIndex--;
    } else if (index == state.currentIndex) {
      // Current track removed, play next or stop
      if (newQueue.isEmpty) {
        state = const PlayerState();
        _audioPlayer.stop();
        return;
      }
      newIndex = newIndex.clamp(0, newQueue.length - 1);
    }

    state = state.copyWith(
      queue: newQueue,
      currentIndex: newIndex,
      currentTrack: newQueue.isNotEmpty ? newQueue[newIndex] : null,
    );
  }

  void clearQueue() {
    _audioPlayer.stop();
    state = const PlayerState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier();
});
