import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/rating_provider.dart';
import '../widgets/star_rating.dart';

/// Lets a passenger rate the driver of a completed trip (1–5 stars + optional comment).
class RatingScreen extends StatefulWidget {
  final int userId;
  final int driverId;
  final int tripId;
  final String? driverName;

  const RatingScreen({
    super.key,
    required this.userId,
    required this.driverId,
    required this.tripId,
    this.driverName,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _commentController = TextEditingController();
  int _score = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_score < 1) {
      _snack('Selecciona una puntuación', isError: true);
      return;
    }
    final provider = context.read<RatingProvider>();
    final ok = await provider.submit(
      fkIdUser: widget.userId,
      fkIdDriver: widget.driverId,
      fkIdTrip: widget.tripId,
      score: _score,
      comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      _snack('¡Gracias por tu calificación!');
      Navigator.pop(context, true);
    } else {
      _snack(provider.error ?? 'No se pudo enviar la calificación', isError: true);
    }
  }

  void _snack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context.watch<RatingProvider>().isSubmitting;
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(title: const Text('Calificar viaje'), backgroundColor: AppColors.carbon950),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.carbon800,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.carbon700),
            ),
            child: Column(
              children: [
                const Icon(Icons.local_taxi_rounded, color: AppColors.gold500, size: 40),
                const SizedBox(height: 10),
                Text(
                  widget.driverName?.isNotEmpty == true
                      ? '¿Cómo estuvo tu viaje con ${widget.driverName}?'
                      : '¿Cómo estuvo tu viaje?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.carbon50, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Center(
                  child: StarRating(
                    initialRating: _score.toDouble(),
                    interactive: true,
                    size: 40,
                    onRatingChanged: (v) => setState(() => _score = v.round()),
                  ),
                ),
                const SizedBox(height: 6),
                Text('$_score de 5', style: const TextStyle(color: AppColors.carbon400)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Comentario (opcional)',
              style: TextStyle(color: AppColors.carbon200, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 4,
            maxLength: 500,
            style: const TextStyle(color: AppColors.carbon50),
            decoration: const InputDecoration(
              hintText: 'Cuéntanos sobre el servicio, puntualidad, trato…',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: submitting ? null : _submit,
              icon: submitting
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.carbon950))
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(submitting ? 'Enviando…' : 'Enviar calificación'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
