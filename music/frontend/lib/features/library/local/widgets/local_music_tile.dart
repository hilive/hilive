import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player_app/core/theme/app_theme.dart';
import 'package:music_player_app/shared/models/local_music.dart';
import 'package:music_player_app/shared/providers/player_provider.dart';
import 'package:music_player_app/features/library/local/providers/local_music_provider.dart';

/// 本地音乐列表项组件
class LocalMusicTile extends ConsumerWidget {
  final LocalMusic music;
  final List<LocalMusic>? queue;
  final VoidCallback? onTap;
  final bool showIndex;
  final int? index;

  const LocalMusicTile({
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
    final isPlaying = playerState.currentTrack?.id == music.id;

    return InkWell(
      onTap: onTap ?? () {
        // 转换为 Music 列表并播放
        final musicList = queue?.map((e) => e.toMusic()).toList();
        ref.read(playerProvider.notifier).playTrack(music.toMusic(), queue: musicList);
        // 更新播放次数
        ref.read(localMusicProvider.notifier).incrementPlayCount(music.id);
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
                child: music.coverPath != null
                    ? Image.file(
                        File(music.coverPath!),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            const SizedBox(width: 12),
            
            // Track info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 本地标识
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          '本地',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          music.title,
                          style: TextStyle(
                            color: isPlaying ? AppTheme.primaryColor : AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
            // 歌曲信息
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: music.coverPath != null
                        ? Image.file(
                            File(music.coverPath!),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          music.title,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          music.artist,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.cardColor),
            ListTile(
              leading: const Icon(Icons.queue_music, color: AppTheme.textPrimary),
              title: const Text('添加到播放队列', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                ref.read(playerProvider.notifier).addToQueue(music.toMusic());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已添加到播放队列')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppTheme.textPrimary),
              title: const Text('歌曲信息', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                _showMusicInfo(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
              title: const Text('从本地库中移除', style: TextStyle(color: AppTheme.errorColor)),
              onTap: () {
                Navigator.pop(context);
                _confirmRemove(context, ref);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showMusicInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('歌曲信息', style: TextStyle(color: AppTheme.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('标题', music.title),
              _buildInfoRow('艺术家', music.artist),
              if (music.album != null) _buildInfoRow('专辑', music.album!),
              _buildInfoRow('时长', music.durationFormatted),
              _buildInfoRow('格式', music.format.toUpperCase()),
              _buildInfoRow('大小', _formatFileSize(music.fileSize)),
              if (music.bitrate != null) _buildInfoRow('比特率', '${music.bitrate} kbps'),
              if (music.year != null) _buildInfoRow('年份', '${music.year}'),
              if (music.genre != null) _buildInfoRow('流派', music.genre!),
              _buildInfoRow('文件路径', music.filePath),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _confirmRemove(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('移除歌曲', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          '确定要从本地库中移除「${music.title}」吗？\n\n这不会删除文件本身。',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(localMusicProvider.notifier).removeMusic(music.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已从本地库中移除')),
              );
            },
            child: const Text('移除', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}
