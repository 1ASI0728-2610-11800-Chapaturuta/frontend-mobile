import 'package:flutter/material.dart';
import '../../data/datasources/notification_api_service.dart';
import '../../data/models/notification_model.dart';

/// Holds the user's notifications and drives mark-as-read and delete.
class NotificationProvider with ChangeNotifier {
  final NotificationApiService apiService;

  NotificationProvider({required this.apiService});

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void setToken(String token) => apiService.setBearerToken(token);

  Future<void> load(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _notifications = await apiService.getByUser(userId);
    } catch (e) {
      _error = _clean(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx < 0 || _notifications[idx].isRead) return;
    // Optimistic: flip locally, revert if the request fails.
    _notifications[idx] = _notifications[idx].copyWith(isRead: true);
    notifyListeners();
    try {
      final updated = await apiService.markAsRead(id);
      _notifications[idx] = updated;
      notifyListeners();
    } catch (_) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: false);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final unread = _notifications.where((n) => !n.isRead).map((n) => n.id).toList();
    for (final id in unread) {
      await markAsRead(id);
    }
  }

  Future<bool> delete(int id) async {
    final removed = _notifications.where((n) => n.id == id).toList();
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    try {
      await apiService.delete(id);
      return true;
    } catch (e) {
      // Restore on failure.
      _notifications.addAll(removed);
      _error = _clean(e);
      notifyListeners();
      return false;
    }
  }

  String _clean(Object e) => e.toString().replaceAll('Exception: ', '');
}
