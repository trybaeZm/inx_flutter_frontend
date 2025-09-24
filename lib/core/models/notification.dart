// import 'package:json_annotation/json_annotation.dart';

// part 'notification.g.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String notificationType;
  final String category;
  final String priority;
  final String? actionUrl;
  final String? actionLabel;
  final Map<String, dynamic>? metadata;
  final List<String>? tags;
  final String status;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? dismissedAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.category,
    required this.priority,
    this.actionUrl,
    this.actionLabel,
    this.metadata,
    this.tags,
    required this.status,
    required this.createdAt,
    this.readAt,
    this.dismissedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      notificationType: json['notification_type'] ?? '',
      category: json['category'] ?? '',
      priority: json['priority'] ?? 'normal',
      status: json['status'] ?? 'unread',
      actionUrl: json['action_url'],
      actionLabel: json['action_label'],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      dismissedAt: json['dismissed_at'] != null ? DateTime.parse(json['dismissed_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'category': category,
      'priority': priority,
      'status': status,
      'action_url': actionUrl,
      'action_label': actionLabel,
      'metadata': metadata,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'dismissed_at': dismissedAt?.toIso8601String(),
    };
  }

  bool get isUnread => status == 'unread';
  bool get isRead => status == 'read';
  bool get isDismissed => status == 'dismissed';
  bool get isUrgent => priority == 'urgent';
  bool get isHigh => priority == 'high';
  bool get isNormal => priority == 'normal';
  bool get isLow => priority == 'low';

  String get priorityIcon {
    switch (priority) {
      case 'urgent':
        return '🚨';
      case 'high':
        return '⚠️';
      case 'normal':
        return 'ℹ️';
      case 'low':
        return '📝';
      default:
        return 'ℹ️';
    }
  }

  String get categoryIcon {
    switch (category) {
      case 'Sales':
        return '💰';
      case 'Orders':
        return '📦';
      case 'Inventory':
        return '🏪';
      case 'Customers':
        return '👥';
      case 'Financial':
        return '💳';
      case 'System':
        return '⚙️';
      case 'AI Insights':
        return '🤖';
      case 'Business Alerts':
        return '📢';
      default:
        return '📌';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class NotificationSettings {
  final String id;
  final bool generalEnabled;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final bool quietHoursEnabled;
  final String? quietHoursStart;
  final String? quietHoursEnd;
  final String timezone;
  final Map<String, bool> categories;
  final Map<String, bool> types;

  NotificationSettings({
    required this.id,
    required this.generalEnabled,
    required this.pushEnabled,
    required this.emailEnabled,
    required this.smsEnabled,
    required this.quietHoursEnabled,
    this.quietHoursStart,
    this.quietHoursEnd,
    required this.timezone,
    required this.categories,
    required this.types,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      id: json['id'] ?? '',
      generalEnabled: json['general_enabled'] ?? true,
      pushEnabled: json['push_enabled'] ?? true,
      emailEnabled: json['email_enabled'] ?? true,
      smsEnabled: json['sms_enabled'] ?? false,
      quietHoursEnabled: json['quiet_hours_enabled'] ?? false,
      quietHoursStart: json['quiet_hours_start'] ?? '22:00',
      quietHoursEnd: json['quiet_hours_end'] ?? '08:00',
      timezone: json['timezone'] ?? 'UTC',
      categories: json['categories'] != null ? Map<String, bool>.from(json['categories']) : {},
      types: json['types'] != null ? Map<String, bool>.from(json['types']) : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'general_enabled': generalEnabled,
      'push_enabled': pushEnabled,
      'email_enabled': emailEnabled,
      'sms_enabled': smsEnabled,
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
      'timezone': timezone,
      'categories': categories,
      'types': types,
    };
  }
}

class NotificationStats {
  final int totalUnread;
  final int totalRead;
  final int totalDismissed;
  final int urgentUnread;
  final int highUnread;
  final int totalNotifications;

  NotificationStats({
    required this.totalUnread,
    required this.totalRead,
    required this.totalDismissed,
    required this.urgentUnread,
    required this.highUnread,
    required this.totalNotifications,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      totalUnread: json['total_unread'] ?? 0,
      totalRead: json['total_read'] ?? 0,
      totalDismissed: json['total_dismissed'] ?? 0,
      urgentUnread: json['urgent_unread'] ?? 0,
      highUnread: json['high_unread'] ?? 0,
      totalNotifications: json['total_notifications'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_unread': totalUnread,
      'total_read': totalRead,
      'total_dismissed': totalDismissed,
      'urgent_unread': urgentUnread,
      'high_unread': highUnread,
      'total_notifications': totalNotifications,
    };
  }

  bool get hasUrgentNotifications => urgentUnread > 0;
  bool get hasHighPriorityNotifications => highUnread > 0;
  bool get hasUnreadNotifications => totalUnread > 0;
}

class NotificationCreate {
  final String title;
  final String message;
  final String notificationType;
  final String category;
  final String priority;
  final String? actionUrl;
  final String? actionLabel;
  final Map<String, dynamic>? metadata;
  final List<String>? tags;
  final DateTime? expiresAt;

  NotificationCreate({
    required this.title,
    required this.message,
    required this.notificationType,
    required this.category,
    this.priority = 'normal',
    this.actionUrl,
    this.actionLabel,
    this.metadata,
    this.tags,
    this.expiresAt,
  });

  factory NotificationCreate.fromJson(Map<String, dynamic> json) {
    return NotificationCreate(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      notificationType: json['notification_type'] ?? '',
      category: json['category'] ?? '',
      priority: json['priority'] ?? 'normal',
      actionUrl: json['action_url'],
      actionLabel: json['action_label'],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'category': category,
      'priority': priority,
      'action_url': actionUrl,
      'action_label': actionLabel,
      'metadata': metadata,
      'tags': tags,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}

class NotificationSettingsUpdate {
  final bool? generalEnabled;
  final bool? pushEnabled;
  final bool? emailEnabled;
  final bool? smsEnabled;
  final bool? quietHoursEnabled;
  final String? quietHoursStart;
  final String? quietHoursEnd;
  final String? timezone;
  final Map<String, bool>? categories;
  final Map<String, bool>? types;

  NotificationSettingsUpdate({
    this.generalEnabled,
    this.pushEnabled,
    this.emailEnabled,
    this.smsEnabled,
    this.quietHoursEnabled,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.timezone,
    this.categories,
    this.types,
  });

  factory NotificationSettingsUpdate.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsUpdate(
      generalEnabled: json['general_enabled'],
      pushEnabled: json['push_enabled'],
      emailEnabled: json['email_enabled'],
      smsEnabled: json['sms_enabled'],
      quietHoursEnabled: json['quiet_hours_enabled'],
      quietHoursStart: json['quiet_hours_start'],
      quietHoursEnd: json['quiet_hours_end'],
      timezone: json['timezone'],
      categories: json['categories'] != null ? Map<String, bool>.from(json['categories']) : null,
      types: json['types'] != null ? Map<String, bool>.from(json['types']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'general_enabled': generalEnabled,
      'push_enabled': pushEnabled,
      'email_enabled': emailEnabled,
      'sms_enabled': smsEnabled,
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
      'timezone': timezone,
      'categories': categories,
      'types': types,
    };
  }
}

// Notification types and categories for type safety
class NotificationTypes {
  static const String revenueSpike = 'revenue_spike';
  static const String revenueDrop = 'revenue_drop';
  static const String salesTrend = 'sales_trend';
  static const String productPerformance = 'product_performance';
  static const String newOrder = 'new_order';
  static const String orderStatusChange = 'order_status_change';
  static const String highValueOrder = 'high_value_order';
  static const String bulkOrder = 'bulk_order';
  static const String lowStock = 'low_stock';
  static const String outOfStock = 'out_of_stock';
  static const String stockAnomaly = 'stock_anomaly';
  static const String inventoryTurnover = 'inventory_turnover';
  static const String customerActivity = 'customer_activity';
  static const String customerChurnRisk = 'customer_churn_risk';
  static const String newCustomer = 'new_customer';
  static const String vipCustomer = 'vip_customer';
  static const String walletBalance = 'wallet_balance';
  static const String withdrawalRequest = 'withdrawal_request';
  static const String paymentIssue = 'payment_issue';
  static const String aiAnomalyDetection = 'ai_anomaly_detection';
  static const String aiPrediction = 'ai_prediction';
  static const String aiOptimization = 'ai_optimization';
  static const String systemUpdate = 'system_update';
  static const String businessMilestone = 'business_milestone';
  static const String competitiveAlert = 'competitive_alert';
}

class NotificationCategories {
  static const String sales = 'Sales';
  static const String orders = 'Orders';
  static const String inventory = 'Inventory';
  static const String customers = 'Customers';
  static const String financial = 'Financial';
  static const String system = 'System';
  static const String aiInsights = 'AI Insights';
  static const String businessAlerts = 'Business Alerts';
}

class NotificationPriorities {
  static const String low = 'low';
  static const String normal = 'normal';
  static const String high = 'high';
  static const String urgent = 'urgent';
}
