import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppTopBar extends StatelessWidget {
  final Widget title;
  final List<Widget> actions;
  final bool showAvatar;
  final String avatarUrl;
  final double toolbarHeight;
  final bool showBottomDivider;
  final VoidCallback? onAvatarTap;

  const AppTopBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.showAvatar = true,
    this.avatarUrl =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDr11wzd8buMvNR4mriuWIU841mjwSq7ArdqsYxcCYUGdK6al-abc7TzhSR8uDE0xdrpfU8L_fD9Y-V-iNyjfx_7ebj7yy0x_Q_s1qHjX9EnL0D2d-x5DKN93QxHqSGcX-yMMw31nKYKtz8JjrIyt4OzpzaFwBfIgI_mINteYmYYMV0CArpqK5SsMvLKK_WzcvaaY0QRWMvU9u2XC0C-PDmr0PJgECqfwRRwFspoaSh98w2YYLnn_fshmAOpG3Q0Wf9bKvw6BP9wRs',
    this.toolbarHeight = 70,
    this.showBottomDivider = true,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final appBarBg = Theme.of(context).scaffoldBackgroundColor;
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: appBarBg,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 2,
      toolbarHeight: toolbarHeight,
      bottom: showBottomDivider
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: AppTheme.primary.withOpacity(0.1),
                height: 1,
              ),
            )
          : null,
      title: Row(
        children: [
          Expanded(child: Align(alignment: Alignment.centerLeft, child: title)),
          for (final action in actions) action,
          if (showAvatar) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: onAvatarTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primary, width: 2),
          image: DecorationImage(
            image: NetworkImage(avatarUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
