import 'package:flutter/material.dart';
import '../../data/datasources/subscription_api_service.dart';
import '../../data/models/plan_model.dart';
import '../../data/models/subscription_model.dart';

/// Holds the traveller's available plans, current active subscription and premium flag,
/// and drives subscribe/cancel. Premium subscribe returns a PendingPayment subscription
/// whose `fkIdPayment` the UI then confirms through the (simulated) checkout.
class SubscriptionProvider with ChangeNotifier {
  final SubscriptionApiService apiService;

  SubscriptionProvider({required this.apiService});

  List<PlanModel> _plans = [];
  SubscriptionModel? _active;
  bool _isPremium = false;
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _error;

  List<PlanModel> get plans => _plans;
  SubscriptionModel? get active => _active;
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;

  void setToken(String token) => apiService.setBearerToken(token);

  /// Plan of the current active subscription, if any (matched by id).
  PlanModel? get activePlan {
    final sub = _active;
    if (sub == null) return null;
    for (final p in _plans) {
      if (p.id == sub.fkIdPlan) return p;
    }
    return null;
  }

  Future<void> load(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        apiService.getPlansByTargetRole('Traveller'),
        apiService.getActiveByUser(userId),
        apiService.getPremiumStatus(userId),
      ]);
      _plans = results[0] as List<PlanModel>;
      _active = results[1] as SubscriptionModel?;
      _isPremium = results[2] as bool;
    } catch (e) {
      _error = _clean(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Subscribes the user to [plan]. Returns the created subscription (or null on error).
  /// For Premium the caller should route to checkout when `fkIdPayment` is present.
  Future<SubscriptionModel?> subscribe({
    required int userId,
    required PlanModel plan,
    String paymentMethod = 'Yape',
    bool autoRenew = true,
  }) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();
    try {
      final sub = await apiService.subscribe(
        fkIdUser: userId,
        fkIdPlan: plan.id,
        autoRenew: autoRenew,
        paymentMethod: paymentMethod,
      );
      _active = sub;
      _isProcessing = false;
      notifyListeners();
      return sub;
    } catch (e) {
      _error = _clean(e);
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> cancel(int subscriptionId, int userId) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();
    try {
      await apiService.cancel(subscriptionId);
      await load(userId);
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _clean(e);
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// Re-reads active subscription + premium flag (e.g. after confirming a payment).
  Future<void> refreshStatus(int userId) async {
    try {
      _active = await apiService.getActiveByUser(userId);
      _isPremium = await apiService.getPremiumStatus(userId);
      notifyListeners();
    } catch (_) {/* keep previous state */}
  }

  String _clean(Object e) => e.toString().replaceAll('Exception: ', '');
}
