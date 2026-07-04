import 'package:flutter/material.dart';
import '../../data/datasources/payment_api_service.dart';
import '../../data/models/payment_model.dart';

/// Handles the (simulated) payment confirmation. Confirming a Pending payment also
/// activates the reservation it backs on the backend.
class PaymentProvider with ChangeNotifier {
  final PaymentApiService apiService;

  PaymentProvider({required this.apiService});

  bool _isProcessing = false;
  String? _error;
  PaymentModel? _lastPayment;

  bool get isProcessing => _isProcessing;
  String? get error => _error;
  PaymentModel? get lastPayment => _lastPayment;

  void setToken(String token) => apiService.setBearerToken(token);

  /// Confirms [paymentId] with a simulated gateway reference. Returns success.
  Future<bool> pay(int paymentId, String method) async {
    _isProcessing = true;
    _error = null;
    notifyListeners();
    try {
      final reference = _simulatedReference(method);
      _lastPayment = await apiService.confirm(paymentId, reference);
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  /// A fake transaction id standing in for a real gateway voucher (payment is simulated).
  String _simulatedReference(String method) {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final prefix = method.isEmpty ? 'SIM' : method.toUpperCase();
    return '$prefix-SIM-$stamp';
  }
}
