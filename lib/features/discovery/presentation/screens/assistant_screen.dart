import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../../subscriptions/presentation/screens/subscriptions_screen.dart';
import '../../data/models/journey_models.dart';
import '../providers/assistant_provider.dart';

/// Premium travel assistant: natural-language chat that returns graph-built itineraries.
/// Non-Premium users get an upgrade prompt instead of an error.
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int? get _userId {
    final raw = context.read<UserProvider>().currentUser?.id;
    return raw == null ? null : int.tryParse(raw);
  }

  Future<void> _send() async {
    final userId = _userId;
    final text = _controller.text.trim();
    if (userId == null || text.isEmpty) return;
    _controller.clear();
    FocusScope.of(context).unfocus();
    await context.read<AssistantProvider>().send(userId, text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(
        title: const Text('Asistente IA'),
        backgroundColor: AppColors.carbon950,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Nueva conversación',
            onPressed: () => context.read<AssistantProvider>().clear(),
          ),
        ],
      ),
      body: Consumer<AssistantProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Expanded(
                child: provider.messages.isEmpty
                    ? _intro()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.messages.length + (provider.isSending ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i >= provider.messages.length) return _typingBubble();
                          return _messageBubble(provider.messages[i]);
                        },
                      ),
              ),
              if (provider.premiumRequired) _premiumUpsell(),
              _inputBar(provider.isSending),
            ],
          );
        },
      ),
    );
  }

  Widget _intro() {
    const suggestions = [
      '¿Cómo llego de Surco a Comas?',
      '¿Qué rutas pasan por Miraflores?',
      'Quiero ir del Centro a San Juan de Lurigancho',
    ];
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 20),
        const Center(child: Icon(Icons.auto_awesome_rounded, color: AppColors.gold500, size: 56)),
        const SizedBox(height: 16),
        const Text('Asistente de viajes',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.carbon50, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text(
          'Dime a dónde quieres ir y armo tu ruta con transbordos. Exclusivo del plan Premium.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.carbon400, fontSize: 13),
        ),
        const SizedBox(height: 24),
        ...suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {
                  _controller.text = s;
                  _send();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.carbon800,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.carbon700),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.gold500, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(s, style: const TextStyle(color: AppColors.carbon200, fontSize: 13))),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _messageBubble(AssistantMessage msg) {
    final align = msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(
            color: msg.isUser ? AppColors.gold500 : AppColors.carbon800,
            borderRadius: BorderRadius.circular(14),
            border: msg.isUser ? null : Border.all(color: AppColors.carbon700),
          ),
          child: Text(
            msg.text,
            style: TextStyle(
              color: msg.isUser ? AppColors.carbon950 : AppColors.carbon100,
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ),
        for (final it in msg.itineraries) _itineraryCard(it),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _itineraryCard(JourneyItinerary it) {
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 6),
      padding: const EdgeInsets.all(14),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold500.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < it.segments.length; i++) _segmentRow(it.segments[i], i == it.segments.length - 1),
          const Divider(color: AppColors.carbon700, height: 20),
          Row(
            children: [
              _summaryChip(Icons.swap_horiz_rounded, '${it.transfers} transbordo(s)'),
              const SizedBox(width: 8),
              if (it.totalEtaLabel != null) _summaryChip(Icons.schedule_rounded, it.totalEtaLabel!),
              const Spacer(),
              Text('S/ ${it.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.gold500, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _segmentRow(JourneySegment seg, bool isLast) {
    final ride = seg.isRide;
    final icon = ride ? Icons.directions_bus_rounded : Icons.directions_walk_rounded;
    final color = ride ? AppColors.gold500 : AppColors.info;
    final detail = ride
        ? [if (seg.price != null) 'S/ ${seg.price!.toStringAsFixed(2)}', if (seg.etaLabel != null) seg.etaLabel!]
            .join(' · ')
        : [if (seg.meters != null) '${seg.meters!.round()} m', if (seg.etaLabel != null) seg.etaLabel!]
            .join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(icon, color: color, size: 18),
              if (!isLast)
                Container(width: 2, height: 22, margin: const EdgeInsets.symmetric(vertical: 2), color: AppColors.carbon700),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${seg.from.name}  →  ${seg.to.name}',
                    style: const TextStyle(color: AppColors.carbon100, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(
                  ride ? 'En ruta${detail.isNotEmpty ? ' · $detail' : ''}' : 'Caminar${detail.isNotEmpty ? ' · $detail' : ''}',
                  style: const TextStyle(color: AppColors.carbon400, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.carbon400),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: AppColors.carbon400, fontSize: 11)),
      ],
    );
  }

  Widget _typingBubble() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold500)),
          SizedBox(width: 10),
          Text('Armando tu ruta…', style: TextStyle(color: AppColors.carbon400, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _premiumUpsell() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gold500.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold500.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: AppColors.gold500),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Desbloquea el Asistente IA con Premium',
                style: TextStyle(color: AppColors.carbon100, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
            ),
            child: const Text('Ver planes'),
          ),
        ],
      ),
    );
  }

  Widget _inputBar(bool sending) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: const BoxDecoration(
          color: AppColors.carbon950,
          border: Border(top: BorderSide(color: AppColors.carbon700)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: AppColors.carbon50),
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: const InputDecoration(
                  hintText: '¿A dónde quieres ir?',
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: sending ? null : _send,
              child: Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: sending ? AppColors.carbon700 : AppColors.gold500,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send_rounded, color: sending ? AppColors.carbon400 : AppColors.carbon950, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
