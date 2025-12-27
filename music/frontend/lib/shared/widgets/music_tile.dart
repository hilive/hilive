import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../models/music.dart';
import '../providers/player_provider.dart';
import '../providers/favorite_provider.dart';

class MusicTile extends ConsumerWidget {
  final Music music;
  final List<Music>? queue;
  final VoidCallback? onTap;
  final bool showIndex;
  final int? index;

  const MusicTile({
    super.key,
    required this.music,
    this.queue,
    this.onTap,
    this.showIndex = false,
    this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final favoriteState = ref.watch(favoriteProvider);
    final isPlaying = playerState.currentTrack?.id == music.id;
    final isFavorite = favoriteState.isFavorite(music.id);

    return InkWell(
      onTap: onTap ?? () {
        ref.read(playerProvider.notifier).playTrack(music, queue: queue);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Index or cover
            if (showIndex && index != null)
              SizedBox(
                width: 32,
                child: Text(
                  '${index! + 1}',
                  style: TextStyle(
                    color: isPlaying ? AppTheme.primaryColor : AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: music.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: music.coverUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _buildPlaceholder(),
                        errorWidget: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            const SizedBox(width: 12),
            
            // Track info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    music.title,
                    style: TextStyle(
                      color: isPlaying ? AppTheme.primaryColor : AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isPlaying) ...[
                        const Icon(
                          Icons.equalizer,
                          color: AppTheme.primaryColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          '${music.artist}${music.album != null ? ' · ${music.album}' : ''}',
                          style: TextStyle(
                            color: isPlaying ? AppTheme.primaryColor : AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Duration
            Text(
              music.durationFormatted,
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            
            // Favorite button
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? AppTheme.errorColor : AppTheme.textTertiary,
                size: 20,
              ),
              onPressed: () {
                ref.read(favoriteProvider.notifier).toggleFavorite(music);
              },
            ),
            
            // More button
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: AppTheme.textTertiary,
                size: 20,
              ),
              onPressed: () => _showMoreOptions(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(
        Icons.music_note,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  void _showMoreOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: AppTheme.textPrimary),
              title: const Text('添加到歌单', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show playlist selection dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue_music, color: AppTheme.textPrimary),
              title: const Text('添加到播放队列', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                ref.read(playerProvider.notifier).addToQueue(music);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已添加到播放队列')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: AppTheme.textPrimary),
              title: const Text('查看艺术家', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to artist page
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
