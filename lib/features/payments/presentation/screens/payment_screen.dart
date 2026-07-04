import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/payment_provider.dart';

/// Simulated checkout. Shows a fictitious Yape/Plin QR (for illustration) and a single
/// "Pagar" button that confirms the pending payment created with the reservation.
/// No real gateway is contacted — the backend just moves the payment to Completed.
class PaymentScreen extends StatelessWidget {
  final int paymentId;
  final double amount;
  final String method; // Yape | Plin | Card | Cash

  const PaymentScreen({
    super.key,
    required this.paymentId,
    required this.amount,
    required this.method,
  });

  bool get _isQrMethod => method == 'Yape' || method == 'Plin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(title: const Text('Pago'), backgroundColor: AppColors.carbon950),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _amountCard(),
              const SizedBox(height: 24),
              if (_isQrMethod) ...[
                _qrCard(),
                const SizedBox(height: 20),
              ] else
                _methodCard(),
              const _SimulatedNotice(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: provider.isProcessing ? null : () => _pay(context, provider),
                  icon: provider.isProcessing
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.carbon950))
                      : const Icon(Icons.lock_outline_rounded, size: 20),
                  label: Text(provider.isProcessing ? 'Procesando…' : 'Pagar S/ ${amount.toStringAsFixed(2)}'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pay(BuildContext context, PaymentProvider provider) async {
    final ok = await provider.pay(paymentId, method);
    if (!context.mounted) return;
    if (ok) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.carbon800,
          icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
          title: const Text('¡Pago exitoso!', style: TextStyle(color: AppColors.carbon50)),
          content: const Text(
            'Tu reserva quedó confirmada.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.carbon200),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Aceptar'),
              ),
            ),
          ],
        ),
      );
      if (context.mounted) Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'No se pudo procesar el pago'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Widget _amountCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold500.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text('Total a pagar', style: TextStyle(color: AppColors.carbon400, fontSize: 13)),
          const SizedBox(height: 6),
          Text('S/ ${amount.toStringAsFixed(2)}',
              style: const TextStyle(color: AppColors.gold500, fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Método: $method', style: const TextStyle(color: AppColors.carbon200, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _qrCard() {
    final accent = method == 'Yape' ? const Color(0xFF742284) : const Color(0xFF0AC1D9);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.smartphone_rounded, color: accent, size: 20),
              const SizedBox(width: 8),
              Text('Escanea con $method',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.qr_code_2_rounded, size: 180, color: accent.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 12),
          const Text('QR de demostración', style: TextStyle(color: AppColors.carbon400, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _methodCard() {
    final isCash = method == 'Cash';
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: Column(
        children: [
          Icon(isCash ? Icons.payments_rounded : Icons.credit_card_rounded,
              color: AppColors.gold500, size: 48),
          const SizedBox(height: 12),
          Text(
            isCash ? 'Pago en efectivo al abordar' : 'Pago con tarjeta',
            style: const TextStyle(color: AppColors.carbon100, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SimulatedNotice extends StatelessWidget {
  const _SimulatedNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.info, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pago simulado con fines de demostración. No se realiza ningún cobro real.',
              style: TextStyle(color: AppColors.carbon200, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
