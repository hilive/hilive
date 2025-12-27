import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../providers/player_provider.dart';
import '../providers/favorite_provider.dart';

class DesktopPlayerBar extends ConsumerWidget {
  const DesktopPlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final playerNotifier = ref.read(playerProvider.notifier);
    final favoriteState = ref.watch(favoriteProvider);
    final track = playerState.currentTrack;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(color: AppTheme.cardColor.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          // Track info (left)
          SizedBox(
            width: 280,
            child: track != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/player'),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: track.coverUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: track.coverUrl!,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.music_note, color: Colors.white),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                track.artist,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            favoriteState.isFavorite(track.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20,
                          ),
                          color: favoriteState.isFavorite(track.id)
                              ? AppTheme.errorColor
                              : AppTheme.textSecondary,
                          onPressed: () {
                            ref.read(favoriteProvider.notifier).toggleFavorite(track);
                          },
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Controls (center)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(_getPlayModeIcon(playerState.playMode), size: 20),
                      color: playerState.playMode != PlayMode.sequence
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                      onPressed: playerNotifier.togglePlayMode,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, size: 28),
                      color: AppTheme.textPrimary,
                      onPressed: playerNotifier.previous,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          playerState.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 24,
                        ),
                        color: Colors.white,
                        padding: EdgeInsets.zero,
                        onPressed: playerNotifier.togglePlay,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, size: 28),
                      color: AppTheme.textPrimary,
                      onPressed: playerNotifier.next,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.repeat, size: 20),
                      color: AppTheme.textSecondary,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: Row(
                    children: [
                      Text(
                        _formatDuration(playerState.position),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                          ),
                          child: Slider(
                            value: playerState.progress.clamp(0.0, 1.0),
                            onChanged: playerNotifier.seekToProgress,
                            activeColor: AppTheme.primaryColor,
                            inactiveColor: AppTheme.cardColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(playerState.duration),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Volume and extras (right)
          SizedBox(
            width: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.queue_music, size: 20),
                    color: AppTheme.textSecondary,
                    onPressed: () {},
                  ),
                  Icon(
                    playerState.volume == 0
                        ? Icons.volume_off
                        : playerState.volume < 0.5
                            ? Icons.volume_down
                            : Icons.volume_up,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  SizedBox(
                    width: 100,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                      ),
                      child: Slider(
                        value: playerState.volume,
                        onChanged: playerNotifier.setVolume,
                        activeColor: AppTheme.textSecondary,
                        inactiveColor: AppTheme.cardColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlayModeIcon(PlayMode mode) {
    switch (mode) {
      case PlayMode.sequence:
        return Icons.repeat;
      case PlayMode.loop:
        return Icons.repeat;
      case PlayMode.single:
        return Icons.repeat_one;
      case PlayMode.shuffle:
        return Icons.shuffle;
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
