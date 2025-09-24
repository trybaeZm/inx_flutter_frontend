import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/models/notification.dart';
import '../../widgets/common/responsive_wrapper.dart';
import 'components/notification_tile.dart';
import 'components/notification_filter_bar.dart';
import 'components/notification_stats_card.dart';
import 'components/ai_analysis_card.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationFilter _currentFilter = const NotificationFilter();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _currentFilter = _currentFilter.copyWith(
        searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      );
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  void _onFilterChanged(NotificationFilter newFilter) {
    setState(() {
      _currentFilter = newFilter;
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(notificationsProvider.notifier).refresh();
    await ref.read(unreadCountProvider.notifier).refresh();
    await ref.read(notificationStatsProvider.notifier).refresh();
  }

  void _onMarkAllRead() async {
    await ref.read(notificationsProvider.notifier).markAllAsRead();
    await ref.read(unreadCountProvider.notifier).refresh();
    await ref.read(notificationStatsProvider.notifier).refresh();
  }

  void _onTriggerAIAnalysis() async {
    await ref.read(notificationsProvider.notifier).triggerAIAnalysis();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI analysis triggered successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () { _onRefresh(); },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _onMarkAllRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: Column(
          children: [
            // Search and Filter Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search notifications...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter Bar
                  NotificationFilterBar(
                    currentFilter: _currentFilter,
                    onFilterChanged: _onFilterChanged,
                  ),
                ],
              ),
            ),

            // Stats and AI Analysis Cards
            if (!isMobile) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(child: NotificationStatsCard()),
                    const SizedBox(width: 16),
                    Expanded(child: AIAnalysisCard(onTriggerAnalysis: _onTriggerAIAnalysis)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              // Mobile: Stack vertically
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    NotificationStatsCard(),
                    const SizedBox(height: 16),
                    AIAnalysisCard(
                      onTriggerAnalysis: _onTriggerAIAnalysis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Notifications List
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final filteredNotificationsAsync = ref.watch(
                    filteredNotificationsProvider(_currentFilter),
                  );

                  return filteredNotificationsAsync.when(
                    data: (notifications) {
                      if (notifications.isEmpty) {
                        return _buildEmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: NotificationTile(
                                notification: notification,
                                onTap: () => _onNotificationTap(notification),
                                onMarkRead: () => _onMarkRead(notification.id),
                                onDismiss: () => _onDismiss(notification.id),
                                onDelete: () => _onDelete(notification.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stackTrace) => _buildErrorState(error.toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _onTriggerAIAnalysis,
            icon: const Icon(Icons.psychology),
            label: const Text('Trigger AI Analysis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading notifications',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.red[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () { _onRefresh(); },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _onNotificationTap(NotificationModel notification) {
    // Mark as read if unread
    if (notification.isUnread) {
      _onMarkRead(notification.id);
    }

    // Navigate to action URL if available
    if (notification.actionUrl != null) {
      context.go(notification.actionUrl!);
    }
  }

  void _onMarkRead(String notificationId) async {
    await ref.read(notificationsProvider.notifier).markAsRead(notificationId);
    await ref.read(unreadCountProvider.notifier).refresh();
    await ref.read(notificationStatsProvider.notifier).refresh();
  }

  void _onDismiss(String notificationId) async {
    await ref.read(notificationsProvider.notifier).dismiss(notificationId);
    await ref.read(unreadCountProvider.notifier).refresh();
    await ref.read(notificationStatsProvider.notifier).refresh();
  }

  void _onDelete(String notificationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(notificationsProvider.notifier).delete(notificationId);
      await ref.read(unreadCountProvider.notifier).refresh();
      await ref.read(notificationStatsProvider.notifier).refresh();
    }
  }
}
