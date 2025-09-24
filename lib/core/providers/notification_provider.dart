import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Notifications list provider
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationsNotifier(service);
});

// Unread count provider
final unreadCountProvider = StateNotifierProvider<UnreadCountNotifier, AsyncValue<int>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return UnreadCountNotifier(service);
});

// Notification settings provider
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, AsyncValue<NotificationSettings>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationSettingsNotifier(service);
});

// Notification stats provider
final notificationStatsProvider = StateNotifierProvider<NotificationStatsNotifier, AsyncValue<NotificationStats>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationStatsNotifier(service);
});

// Filtered notifications provider
final filteredNotificationsProvider = Provider.family<AsyncValue<List<NotificationModel>>, NotificationFilter>((ref, filter) {
  final notificationsAsync = ref.watch(notificationsProvider);
  
  return notificationsAsync.when(
    data: (notifications) {
      List<NotificationModel> filtered = notifications;
      
      if (filter.status != null) {
        filtered = filtered.where((n) => n.status == filter.status).toList();
      }
      
      if (filter.category != null) {
        filtered = filtered.where((n) => n.category == filter.category).toList();
      }
      
      if (filter.priority != null) {
        filtered = filtered.where((n) => n.priority == filter.priority).toList();
      }
      
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        filtered = filtered.where((n) => 
          n.title.toLowerCase().contains(filter.searchQuery!.toLowerCase()) ||
          n.message.toLowerCase().contains(filter.searchQuery!.toLowerCase())
        ).toList();
      }
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

// Notification filter model
class NotificationFilter {
  final String? status;
  final String? category;
  final String? priority;
  final String? searchQuery;

  const NotificationFilter({
    this.status,
    this.category,
    this.priority,
    this.searchQuery,
  });

  NotificationFilter copyWith({
    String? status,
    String? category,
    String? priority,
    String? searchQuery,
  }) {
    return NotificationFilter(
      status: status ?? this.status,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Notifications notifier
class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationService _service;

  NotificationsNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      state = const AsyncValue.loading();
      final notifications = await _service.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadNotifications();
  }

  Future<void> loadMore({int limit = 20}) async {
    if (state.hasValue) {
      try {
        final currentNotifications = state.value!;
        final moreNotifications = await _service.getNotifications(limit: currentNotifications.length + limit);
        state = AsyncValue.data(moreNotifications);
      } catch (error, stackTrace) {
        // Don't override current state on error, just log it
        print('Error loading more notifications: $error');
      }
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _service.markNotificationRead(notificationId);
      if (success && state.hasValue) {
        final updatedNotifications = state.value!.map((notification) {
          if (notification.id == notificationId) {
            return NotificationModel(
              id: notification.id,
              title: notification.title,
              message: notification.message,
              notificationType: notification.notificationType,
              category: notification.category,
              priority: notification.priority,
              actionUrl: notification.actionUrl,
              actionLabel: notification.actionLabel,
              metadata: notification.metadata,
              tags: notification.tags,
              status: 'read',
              createdAt: notification.createdAt,
              readAt: DateTime.now(),
              dismissedAt: notification.dismissedAt,
            );
          }
          return notification;
        }).toList();
        
        state = AsyncValue.data(updatedNotifications);
      }
    } catch (error, stackTrace) {
      print('Error marking notification as read: $error');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final success = await _service.markAllNotificationsRead();
      if (success && state.hasValue) {
        final updatedNotifications = state.value!.map((notification) {
          if (notification.status == 'unread') {
            return NotificationModel(
              id: notification.id,
              title: notification.title,
              message: notification.message,
              notificationType: notification.notificationType,
              category: notification.category,
              priority: notification.priority,
              actionUrl: notification.actionUrl,
              actionLabel: notification.actionLabel,
              metadata: notification.metadata,
              tags: notification.tags,
              status: 'read',
              createdAt: notification.createdAt,
              readAt: DateTime.now(),
              dismissedAt: notification.dismissedAt,
            );
          }
          return notification;
        }).toList();
        
        state = AsyncValue.data(updatedNotifications);
      }
    } catch (error, stackTrace) {
      print('Error marking all notifications as read: $error');
    }
  }

  Future<void> dismiss(String notificationId) async {
    try {
      final success = await _service.dismissNotification(notificationId);
      if (success && state.hasValue) {
        final updatedNotifications = state.value!.map((notification) {
          if (notification.id == notificationId) {
            return NotificationModel(
              id: notification.id,
              title: notification.title,
              message: notification.message,
              notificationType: notification.notificationType,
              category: notification.category,
              priority: notification.priority,
              actionUrl: notification.actionUrl,
              actionLabel: notification.actionLabel,
              metadata: notification.metadata,
              tags: notification.tags,
              status: 'dismissed',
              createdAt: notification.createdAt,
              readAt: notification.readAt,
              dismissedAt: DateTime.now(),
            );
          }
          return notification;
        }).toList();
        
        state = AsyncValue.data(updatedNotifications);
      }
    } catch (error, stackTrace) {
      print('Error dismissing notification: $error');
    }
  }

  Future<void> delete(String notificationId) async {
    try {
      final success = await _service.deleteNotification(notificationId);
      if (success && state.hasValue) {
        final updatedNotifications = state.value!.where((n) => n.id != notificationId).toList();
        state = AsyncValue.data(updatedNotifications);
      }
    } catch (error, stackTrace) {
      print('Error deleting notification: $error');
    }
  }

  Future<void> triggerAIAnalysis() async {
    try {
      await _service.triggerAIAnalysis();
      // Refresh notifications after AI analysis
      await _loadNotifications();
    } catch (error, stackTrace) {
      print('Error triggering AI analysis: $error');
    }
  }
}

// Unread count notifier
class UnreadCountNotifier extends StateNotifier<AsyncValue<int>> {
  final NotificationService _service;

  UnreadCountNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      state = const AsyncValue.loading();
      final count = await _service.getUnreadCount();
      state = AsyncValue.data(count);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadUnreadCount();
  }

  void updateCount(int newCount) {
    if (state.hasValue) {
      state = AsyncValue.data(newCount);
    }
  }
}

// Notification settings notifier
class NotificationSettingsNotifier extends StateNotifier<AsyncValue<NotificationSettings>> {
  final NotificationService _service;

  NotificationSettingsNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      state = const AsyncValue.loading();
      final settings = await _service.getNotificationSettings();
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateSettings(NotificationSettingsUpdate update) async {
    try {
      final updatedSettings = await _service.updateNotificationSettings(update);
      state = AsyncValue.data(updatedSettings);
    } catch (error, stackTrace) {
      print('Error updating notification settings: $error');
    }
  }

  Future<void> refresh() async {
    await _loadSettings();
  }
}

// Notification stats notifier
class NotificationStatsNotifier extends StateNotifier<AsyncValue<NotificationStats>> {
  final NotificationService _service;

  NotificationStatsNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      state = const AsyncValue.loading();
      final stats = await _service.getNotificationStats();
      state = AsyncValue.data(stats);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadStats();
  }
}

// Real-time notification stream provider
final notificationStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.streamNotifications();
});

// Real-time unread count stream provider
final unreadCountStreamProvider = StreamProvider<int>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.streamUnreadCount();
});
