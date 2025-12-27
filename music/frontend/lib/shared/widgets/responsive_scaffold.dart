import 'package:flutter/material.dart';
import '../../core/utils/platform_utils.dart';
import 'main_scaffold.dart';
import 'desktop_scaffold.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget child;

  const ResponsiveScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Use desktop layout for desktop platforms or wide screens
    final isWideScreen = MediaQuery.of(context).size.width >= 900;
    
    if (PlatformUtils.isDesktop || isWideScreen) {
      return DesktopScaffold(child: child);
    }
    
    return MainScaffold(child: child);
  }
}
