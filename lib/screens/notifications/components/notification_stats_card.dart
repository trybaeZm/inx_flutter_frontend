import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/notification_provider.dart';

class NotificationStatsCard extends ConsumerWidget {
  const NotificationStatsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(notificationStatsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: statsAsync.when(
          data: (stats) => _buildStatsContent(theme, stats),
          loading: () => _buildLoadingContent(theme),
          error: (error, stackTrace) => _buildErrorContent(theme, error.toString()),
        ),
      ),
    );
  }

  Widget _buildStatsContent(ThemeData theme, dynamic stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.analytics,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Stats',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Overview of your notifications',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Stats Grid
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                theme,
                icon: Icons.mark_email_unread,
                label: 'Unread',
                value: stats.totalUnread.toString(),
                color: theme.colorScheme.primary,
                isUrgent: stats.hasUrgentNotifications,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                theme,
                icon: Icons.mark_email_read,
                label: 'Read',
                value: stats.totalRead.toString(),
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                theme,
                icon: Icons.close,
                label: 'Dismissed',
                value: stats.totalDismissed.toString(),
                color: theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                theme,
                icon: Icons.notifications,
                label: 'Total',
                value: stats.totalNotifications.toString(),
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Priority Alerts
        if (stats.hasUrgentNotifications || stats.hasHighPriorityNotifications) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: stats.hasUrgentNotifications 
                  ? Colors.red.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: stats.hasUrgentNotifications 
                    ? Colors.red.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  stats.hasUrgentNotifications ? Icons.priority_high : Icons.warning,
                  color: stats.hasUrgentNotifications ? Colors.red : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stats.hasUrgentNotifications 
                            ? 'Urgent Notifications'
                            : 'High Priority Notifications',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: stats.hasUrgentNotifications ? Colors.red : Colors.orange,
                        ),
                      ),
                      Text(
                        stats.hasUrgentNotifications
                            ? '${stats.urgentUnread} require immediate attention'
                            : '${stats.highUnread} need your attention',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isUrgent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: isUrgent ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header skeleton
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Stats grid skeleton
        Row(
          children: [
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorContent(ThemeData theme, String error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error Loading Stats',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    'Unable to load notification statistics',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Error message
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// Compact stats card for mobile
class CompactNotificationStatsCard extends ConsumerWidget {
  const CompactNotificationStatsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(notificationStatsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: statsAsync.when(
          data: (stats) => _buildCompactStatsContent(theme, stats),
          loading: () => _buildCompactLoadingContent(theme),
          error: (error, stackTrace) => _buildCompactErrorContent(theme, error.toString()),
        ),
      ),
    );
  }

  Widget _buildCompactStatsContent(ThemeData theme, dynamic stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.analytics,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Stats',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (stats.hasUrgentNotifications)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stats.urgentUnread} Urgent',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Stats Row
        Row(
          children: [
            Expanded(
              child: _buildCompactStatItem(
                theme,
                label: 'Unread',
                value: stats.totalUnread.toString(),
                color: theme.colorScheme.primary,
              ),
            ),
            Expanded(
              child: _buildCompactStatItem(
                theme,
                label: 'Read',
                value: stats.totalRead.toString(),
                color: theme.colorScheme.secondary,
              ),
            ),
            Expanded(
              child: _buildCompactStatItem(
                theme,
                label: 'Total',
                value: stats.totalNotifications.toString(),
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactStatItem(
    ThemeData theme, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCompactLoadingContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Spacer(),
            Container(
              width: 80,
              height: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: List.generate(3, (index) => Expanded(
            child: Container(
              height: 40,
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildCompactErrorContent(ThemeData theme, String error) {
    return Row(
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Error loading stats',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
