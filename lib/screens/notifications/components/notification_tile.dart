import 'package:flutter/material.dart';
import '../../../core/models/notification.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;
  final VoidCallback onDismiss;
  final VoidCallback onDelete;

  const NotificationTile({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onMarkRead,
    required this.onDismiss,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: notification.isUnread ? 4 : 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification.isUnread
            ? BorderSide(
                color: _getPriorityColor(notification.priority),
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Priority and Category Icons
                  Row(
                    children: [
                      Text(
                        notification.priorityIcon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notification.categoryIcon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  
                  // Title
                  Expanded(
                    child: Text(
                      notification.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: notification.isUnread ? FontWeight.bold : FontWeight.normal,
                        color: notification.isUnread
                            ? theme.textTheme.titleMedium?.color
                            : theme.textTheme.titleMedium?.color?.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Time ago
                  Text(
                    notification.timeAgo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Message
              Text(
                notification.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: notification.isUnread
                      ? theme.textTheme.bodyMedium?.color
                      : theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Footer Row
              Row(
                children: [
                  // Tags
                  if (notification.tags != null && notification.tags!.isNotEmpty) ...[
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: notification.tags!.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ] else ...[
                    const Spacer(),
                  ],
                  
                  // Action Button
                  if (notification.actionLabel != null)
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        notification.actionLabel!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Mark as Read/Unread
                  if (notification.isUnread)
                    TextButton.icon(
                      onPressed: onMarkRead,
                      icon: const Icon(Icons.done, size: 16),
                      label: const Text('Mark Read'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  
                  // Dismiss
                  TextButton.icon(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Dismiss'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  
                  // Delete
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// Compact notification tile for list views
class CompactNotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;

  const CompactNotificationTile({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onMarkRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getPriorityColor(notification.priority).withOpacity(0.2),
        child: Text(
          notification.priorityIcon,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      title: Text(
        notification.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: notification.isUnread ? FontWeight.bold : FontWeight.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.message,
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                notification.category,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                notification.timeAgo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: notification.isUnread
          ? IconButton(
              icon: const Icon(Icons.done),
              onPressed: onMarkRead,
              tooltip: 'Mark as read',
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
