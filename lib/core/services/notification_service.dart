import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import '../services/supabase_service.dart';
// import '../../core/config/app_config.dart';

class NotificationService {
  static const String baseUrl = 'http://localhost:8001/api/v1';
  
  // Get auth token from Supabase session
  String? _getAuthToken() {
    final token = SupabaseService.client.auth.currentSession?.accessToken;
    return token;
  }

  // Get user notifications with filtering
  Future<List<NotificationModel>> getNotifications({
    int limit = 50,
    String? status,
    String? category,
    String? priority,
  }) async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      
      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;
      if (priority != null) queryParams['priority'] = priority;

      final uri = Uri.parse('$baseUrl/notifications').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting notifications: $e');
    }
  }

  // Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$baseUrl/notifications/unread-count');
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['unread_count'] ?? 0;
      } else {
        throw Exception('Failed to get unread count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting unread count: $e');
    }
  }

  // Mark notification as read
  Future<bool> markNotificationRead(String notificationId) async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$baseUrl/notifications/mark-read/$notificationId');
      
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<bool> markAllNotificationsRead() async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$baseUrl/notifications/mark-all-read');
      
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error marking all notifications as read: $e');
    }
  }

  // Dismiss notification
  Future<bool> dismissNotification(String notificationId) async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$baseUrl/notifications/dismiss/$notificationId');
      
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error dismissing notification: $e');
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$baseUrl/notifications/$notificationId');
      
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  // Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$baseUrl/notifications/settings');
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return NotificationSettings.fromJson(jsonData);
      } else {
        throw Exception('Failed to get notification settings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting notification settings: $e');
    }
  }

  // Update notification settings
  Future<NotificationSettings> updateNotificationSettings(
    NotificationSettingsUpdate settings,
  ) async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$baseUrl/notifications/settings');
      
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(settings.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return NotificationSettings.fromJson(jsonData);
      } else {
        throw Exception('Failed to update notification settings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating notification settings: $e');
    }
  }

  // Trigger AI analysis
  Future<Map<String, dynamic>> triggerAIAnalysis() async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$baseUrl/notifications/ai-analyze');
      
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to trigger AI analysis: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error triggering AI analysis: $e');
    }
  }

  // Create custom notification
  Future<String> createCustomNotification(NotificationCreate notification) async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$baseUrl/notifications/create');
      
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(notification.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['notification_id'] ?? '';
      } else {
        throw Exception('Failed to create notification: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating custom notification: $e');
    }
  }

  // Get notification statistics
  Future<NotificationStats> getNotificationStats() async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$baseUrl/notifications/stats');
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return NotificationStats.fromJson(jsonData);
      } else {
        throw Exception('Failed to get notification stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting notification stats: $e');
    }
  }

  // Stream notifications for real-time updates
  Stream<List<NotificationModel>> streamNotifications({
    int limit = 50,
    String? status,
    String? category,
    String? priority,
  }) async* {
    while (true) {
      try {
        final notifications = await getNotifications(
          limit: limit,
          status: status,
          category: category,
          priority: priority,
        );
        yield notifications;
        
        // Wait for 30 seconds before next update
        await Future.delayed(const Duration(seconds: 30));
      } catch (e) {
        // If error occurs, wait longer before retry
        await Future.delayed(const Duration(minutes: 1));
      }
    }
  }

  // Stream unread count for real-time updates
  Stream<int> streamUnreadCount() async* {
    while (true) {
      try {
        final count = await getUnreadCount();
        yield count;
        
        // Wait for 15 seconds before next update
        await Future.delayed(const Duration(seconds: 15));
      } catch (e) {
        // If error occurs, wait longer before retry
        await Future.delayed(const Duration(minutes: 1));
      }
    }
  }
}
