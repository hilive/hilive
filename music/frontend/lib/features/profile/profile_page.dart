import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
      ),
      body: ListView(
        children: [
          // User info card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    user?.username.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.username ?? '未登录',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Settings sections
          _buildSection('播放设置', [
            _buildSettingItem(
              icon: Icons.high_quality,
              title: '音质设置',
              subtitle: '标准音质',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.download,
              title: '下载设置',
              subtitle: '仅 WiFi 下载',
              onTap: () {},
            ),
          ]),

          _buildSection('通用设置', [
            _buildSettingItem(
              icon: Icons.dark_mode,
              title: '深色模式',
              subtitle: '已开启',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.language,
              title: '语言',
              subtitle: '简体中文',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.storage,
              title: '清除缓存',
              subtitle: '0 MB',
              onTap: () {},
            ),
          ]),

          _buildSection('关于', [
            _buildSettingItem(
              icon: Icons.info_outline,
              title: '关于我们',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.privacy_tip_outlined,
              title: '隐私政策',
              onTap: () {},
            ),
            _buildSettingItem(
              icon: Icons.description_outlined,
              title: '用户协议',
              onTap: () {},
            ),
          ]),

          // Logout button
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: const BorderSide(color: AppTheme.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('退出登录'),
            ),
          ),

          // Version
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '版本 1.0.0',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textPrimary),
      title: Text(
        title,
        style: const TextStyle(color: AppTheme.textPrimary),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: AppTheme.textSecondary),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textTertiary),
      onTap: onTap,
    );
  }
}
