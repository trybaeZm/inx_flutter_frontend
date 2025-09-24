import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/models/notification.dart';

class AppNavbar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showSearch;
  final bool showMenuButton;
  final bool showPrimaryAction;
  final String primaryActionLabel;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onPrimaryActionPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onThemeToggle;

  const AppNavbar({
    Key? key,
    this.title = 'Inxource',
    this.subtitle,
    this.showSearch = true,
    this.showMenuButton = true,
    this.showPrimaryAction = true,
    this.primaryActionLabel = 'Create Order Link',
    this.onMenuPressed,
    this.onPrimaryActionPressed,
    this.onSearchPressed,
    this.onNotificationPressed,
    this.onThemeToggle,
  }) : super(key: key);

  @override
  ConsumerState<AppNavbar> createState() => _AppNavbarState();

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class _AppNavbarState extends ConsumerState<AppNavbar> {
  Timer? _refreshTimer;
  final GlobalKey _notifKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Refresh unread count every 30 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 90), (timer) {
      if (mounted) {
        ref.read(unreadCountProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Responsive breakpoints
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
        child: Row(
          children: [
            // Left cluster: menu + brand + title | subtitle
            if (widget.showMenuButton)
              Padding(
                padding: EdgeInsets.only(right: isMobile ? 8 : 8),
                child: _NotionIconButton(
                  icon: Icons.menu_rounded,
                  onPressed: widget.onMenuPressed ?? () {},
                  tooltip: 'Menu',
                ),
              ),
            
            // Brand icon
            Container(
              width: isMobile ? 24 : 28,
              height: isMobile ? 24 : 28,
              decoration: BoxDecoration(
                color: isDark ? NotionColors.darkHover : NotionColors.lightHover,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.business_rounded,
                color: theme.iconTheme.color,
                size: isMobile ? 14 : 16,
              ),
            ),
            SizedBox(width: isMobile ? 6 : 8),
            
            // Title and subtitle
            Flexible(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.subtitle != null && widget.subtitle!.isNotEmpty && !isMobile) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 1,
                      height: 16,
                      color: theme.dividerColor,
                    ),
                    Flexible(
                      child: Text(
                        widget.subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),

            // Primary action
            if (widget.showPrimaryAction)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _PrimaryActionButton(
                  label: widget.primaryActionLabel,
                  onPressed: widget.onPrimaryActionPressed ?? () {},
                ),
              ),

            // Right actions
            if (widget.showSearch)
              _NotionIconButton(
                icon: Icons.search_rounded,
                onPressed: widget.onSearchPressed ?? () => _showSearchDialog(context),
                tooltip: 'Search',
              ),
            
            if (widget.showSearch) const SizedBox(width: 4),
            
            // Notifications
            Consumer(builder: (context, ref, _) {
              final unreadCountAsync = ref.watch(unreadCountProvider);
              final unreadCount = unreadCountAsync.when(
                data: (count) => count,
                loading: () => 0,
                error: (_, __) => 0,
              );
              
              return _NotionIconButton(
                buttonKey: _notifKey,
                icon: Icons.notifications_none_rounded,
                onPressed: widget.onNotificationPressed ?? () async { await _openNotificationsDropdown(); },
                tooltip: 'Notifications',
                hasBadge: unreadCount > 0,
                badgeCount: unreadCount > 0 ? unreadCount : null,
              );
            }),
            
            const SizedBox(width: 4),
            
            // Theme toggle
            Consumer(builder: (context, ref, _) {
              final controller = ref.read(themeModeProvider.notifier);
              return _NotionIconButton(
                icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                onPressed: () => controller.toggle(),
                tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
              );
            }),
            
            SizedBox(width: isMobile ? 4 : 8),
            
            // User profile
            _UserProfileButton(
              user: currentUser,
              onSignOut: () async {
                await authNotifier.signOut();
                if (context.mounted) {
                  context.go('/sign-in');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width > 600 ? 500 : MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search everything...',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Search'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No new notifications'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openNotificationsDropdown() async {
    // Ensure we have latest list
    final notifier = ref.read(notificationsProvider.notifier);
    if (!ref.read(notificationsProvider).hasValue) {
      await notifier.refresh();
    }
    final items = ref.read(notificationsProvider).maybeWhen(
      data: (list) => list.take(5).toList(),
      orElse: () => <NotificationModel>[],
    );

    final RenderBox? box = _notifKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = box != null
        ? RelativeRect.fromRect(
            box.localToGlobal(Offset.zero, ancestor: overlay) & box.size,
            Offset.zero & overlay.size,
          )
        : const RelativeRect.fromLTRB(0, 0, 0, 0);

    final selected = await showMenu<String>(
      context: context,
      position: position,
      items: <PopupMenuEntry<String>>[
        if (items.isEmpty)
          const PopupMenuItem<String>(value: 'empty', child: Text('No new notifications'))
        else ...items.map((n) => PopupMenuItem<String>(
              value: 'open:${n.id}',
              child: SizedBox(
                width: 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(n.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            )),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(value: 'view_all', child: Text('View all notifications')),
        const PopupMenuItem<String>(value: 'mark_all', child: Text('Mark all as read')),
      ],
    );

    if (selected == null) return;
    if (selected == 'view_all') {
      if (mounted) context.go('/notifications');
      return;
    }
    if (selected == 'mark_all') {
      await ref.read(notificationsProvider.notifier).markAllAsRead();
      await ref.read(unreadCountProvider.notifier).refresh();
      return;
    }
    if (selected.startsWith('open:')) {
      final id = selected.substring(5);
      final notif = items.firstWhere((e) => e.id == id, orElse: () => items.first);
      if (notif.isUnread) {
        await ref.read(notificationsProvider.notifier).markAsRead(notif.id);
        await ref.read(unreadCountProvider.notifier).refresh();
      }
      if (mounted) {
        if (notif.actionUrl != null && notif.actionUrl!.isNotEmpty) {
          context.go(notif.actionUrl!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(notif.message), duration: const Duration(seconds: 2)),
          );
        }
      }
    }
  }

  void _toggleTheme(BuildContext context) {}

  @override
  Size get preferredSize => const Size.fromHeight(54);
}

class _NotionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool hasBadge;
  final int? badgeCount;
  final Key? buttonKey;

  const _NotionIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.hasBadge = false,
    this.badgeCount,
    this.buttonKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    Widget button = Container(
      key: buttonKey,
      width: isMobile ? 28 : 32,
      height: isMobile ? 28 : 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onPressed,
          child: Icon(
            icon,
            size: isMobile ? 16 : 18,
            color: theme.iconTheme.color,
          ),
        ),
      ),
    );

    if (hasBadge) {
      button = Stack(
        children: [
          button,
          Positioned(
            right: isMobile ? 4 : 6,
            top: isMobile ? 4 : 6,
            child: Container(
              padding: badgeCount != null 
                ? EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                : EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: badgeCount != null ? 16 : 8,
                minHeight: badgeCount != null ? 16 : 8,
              ),
              decoration: BoxDecoration(
                color: NotionColors.red,
                shape: badgeCount != null ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: badgeCount != null ? BorderRadius.circular(8) : null,
              ),
              child: badgeCount != null
                ? Text(
                    badgeCount! > 99 ? '99+' : badgeCount.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  )
                : null,
            ),
          ),
        ],
      );
    }

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryActionButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        Icons.link_rounded, 
        size: isMobile ? 14 : 16, 
        color: theme.textTheme.bodyMedium?.color
      ),
      label: Text(
        label, 
        style: GoogleFonts.inter(
          color: theme.textTheme.bodyMedium?.color, 
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 12 : 14,
        )
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? NotionColors.darkHover : NotionColors.lightHover,
        foregroundColor: theme.textTheme.bodyMedium?.color,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12, 
          vertical: isMobile ? 8 : 10
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }
}

class _UserProfileButton extends StatelessWidget {
  final dynamic user;
  final VoidCallback onSignOut;

  const _UserProfileButton({
    Key? key,
    required this.user,
    required this.onSignOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'profile':
            Navigator.pushNamed(context, '/profile');
            break;
          case 'settings':
            Navigator.pushNamed(context, '/settings');
            break;
          case 'logout':
            onSignOut();
            break;
        }
      },
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: isMobile ? 28 : 32,
        height: isMobile ? 28 : 32,
        decoration: BoxDecoration(
          color: NotionColors.blue,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            user?.email?.substring(0, 1).toUpperCase() ?? 'U',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 12 : 14,
            ),
          ),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: _MenuItemContent(
            icon: Icons.person_outline_rounded,
            title: 'Profile',
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: _MenuItemContent(
            icon: Icons.settings_outlined,
            title: 'Settings',
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: _MenuItemContent(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            isDestructive: true,
          ),
        ),
      ],
    );
  }
}

class _MenuItemContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;

  const _MenuItemContent({
    Key? key,
    required this.icon,
    required this.title,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive ? NotionColors.red : theme.textTheme.bodyMedium?.color;
    
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
} 