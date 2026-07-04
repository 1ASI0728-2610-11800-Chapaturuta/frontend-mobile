import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../payments/presentation/screens/payment_screen.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../data/models/plan_model.dart';
import '../../data/models/subscription_model.dart';
import '../providers/subscription_provider.dart';

/// Passenger plans & subscription. Shows the current subscription, lists available plans,
/// and subscribes: Free activates at once; Premium routes to the (simulated) checkout.
class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  final _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  int? get _userId {
    final raw = context.read<UserProvider>().currentUser?.id;
    return raw == null ? null : int.tryParse(raw);
  }

  Future<void> _load() async {
    final userId = _userId;
    if (userId == null) return;
    await context.read<SubscriptionProvider>().load(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(title: const Text('Planes y suscripción'), backgroundColor: AppColors.carbon950),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.plans.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold500));
          }
          return RefreshIndicator(
            color: AppColors.gold500,
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _statusCard(provider),
                const SizedBox(height: 20),
                const Text('Planes disponibles',
                    style: TextStyle(color: AppColors.carbon100, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                if (provider.plans.isEmpty)
                  _empty('No hay planes disponibles por ahora')
                else
                  ...provider.plans.map((p) => _planCard(p, provider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusCard(SubscriptionProvider provider) {
    final active = provider.active;
    final premium = provider.isPremium;
    final plan = provider.activePlan;

    final title = premium ? 'Plan Premium activo' : 'Plan Free';
    final accent = premium ? AppColors.gold500 : AppColors.carbon400;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: premium
              ? [AppColors.gold600.withValues(alpha: 0.25), AppColors.carbon800]
              : [AppColors.carbon800, AppColors.carbon800],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(premium ? Icons.workspace_premium_rounded : Icons.person_outline_rounded,
                  color: accent, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: TextStyle(color: accent, fontSize: 17, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          if (active != null && plan != null) ...[
            const SizedBox(height: 8),
            Text(plan.name, style: const TextStyle(color: AppColors.carbon100, fontSize: 14)),
          ],
          if (active != null && active.isActive) ...[
            const SizedBox(height: 4),
            Text('Vigente hasta ${_dateFmt.format(active.endsAt)}',
                style: const TextStyle(color: AppColors.carbon400, fontSize: 12)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: provider.isProcessing ? null : () => _confirmCancel(active),
              icon: const Icon(Icons.cancel_outlined, size: 16),
              label: const Text('Cancelar suscripción'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
            ),
          ] else if (!premium) ...[
            const SizedBox(height: 6),
            const Text('Suscríbete a Premium para búsquedas ilimitadas y el Asistente IA.',
                style: TextStyle(color: AppColors.carbon400, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _planCard(PlanModel plan, SubscriptionProvider provider) {
    final isCurrent = provider.active?.fkIdPlan == plan.id && (provider.active?.isActive ?? false);
    final premium = plan.isPremium;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: premium ? AppColors.gold500.withValues(alpha: 0.5) : AppColors.carbon700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (premium) const Icon(Icons.workspace_premium_rounded, color: AppColors.gold500, size: 20),
              if (premium) const SizedBox(width: 6),
              Expanded(
                child: Text(plan.name,
                    style: const TextStyle(color: AppColors.carbon50, fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('ACTUAL',
                      style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w800)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(plan.isFree ? 'Gratis' : 'S/ ${plan.price.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: premium ? AppColors.gold500 : AppColors.carbon100,
                      fontSize: 24, fontWeight: FontWeight.w800)),
              if (!plan.isFree)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 4),
                  child: Text(plan.billingLabel, style: const TextStyle(color: AppColors.carbon400, fontSize: 13)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...plan.benefitList.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(b, style: const TextStyle(color: AppColors.carbon200, fontSize: 13))),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (isCurrent || provider.isProcessing) ? null : () => _subscribe(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: premium ? AppColors.gold500 : AppColors.carbon700,
                foregroundColor: premium ? AppColors.carbon950 : AppColors.carbon50,
              ),
              child: Text(isCurrent ? 'Plan actual' : (plan.isFree ? 'Activar plan Free' : 'Suscribirme')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _subscribe(PlanModel plan) async {
    final userId = _userId;
    if (userId == null) return;
    final provider = context.read<SubscriptionProvider>();

    String method = 'Yape';
    if (plan.isPremium) {
      final picked = await _pickPaymentMethod();
      if (picked == null) return;
      method = picked;
    }

    final sub = await provider.subscribe(userId: userId, plan: plan, paymentMethod: method);
    if (!mounted) return;

    if (sub == null) {
      _snack(provider.error ?? 'No se pudo suscribir', isError: true);
      return;
    }

    // Premium subscriptions come back PendingPayment with a payment to confirm.
    if (plan.isPremium && sub.fkIdPayment != null) {
      final paid = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(paymentId: sub.fkIdPayment!, amount: plan.price, method: method),
        ),
      );
      if (!mounted) return;
      if (paid == true) {
        await provider.refreshStatus(userId);
        if (mounted) _snack('¡Bienvenido a Premium!');
      } else {
        _snack('Suscripción creada (pago pendiente)', isError: false);
      }
    } else {
      await provider.load(userId);
      if (mounted) _snack('Plan activado');
    }
  }

  Future<String?> _pickPaymentMethod() {
    const methods = ['Yape', 'Plin', 'Card', 'Cash'];
    const icons = {
      'Yape': Icons.phone_android_rounded,
      'Plin': Icons.phone_iphone_rounded,
      'Card': Icons.credit_card_rounded,
      'Cash': Icons.payments_rounded,
    };
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.carbon800,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Elige tu método de pago',
                  style: TextStyle(color: AppColors.carbon50, fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            ...methods.map((m) => ListTile(
                  leading: Icon(icons[m], color: AppColors.gold500),
                  title: Text(m, style: const TextStyle(color: AppColors.carbon100)),
                  onTap: () => Navigator.pop(ctx, m),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(SubscriptionModel sub) async {
    final userId = _userId;
    if (userId == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.carbon800,
        title: const Text('Cancelar suscripción', style: TextStyle(color: AppColors.carbon50)),
        content: const Text(
          'Perderás los beneficios Premium. Si estás dentro de los primeros 7 días, se registra un reembolso automático.',
          style: TextStyle(color: AppColors.carbon200),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Volver')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, cancelar', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final ok = await context.read<SubscriptionProvider>().cancel(sub.id, userId);
    if (!mounted) return;
    _snack(ok ? 'Suscripción cancelada' : (context.read<SubscriptionProvider>().error ?? 'Error'),
        isError: !ok);
  }

  Widget _empty(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(color: AppColors.carbon400)),
    );
  }

  void _snack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? AppColors.danger : AppColors.success),
    );
  }
}
