import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../payments/presentation/screens/payment_screen.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../../routes/domain/entities/route.dart';
import '../providers/reservation_provider.dart';

class ReservationFormScreen extends StatefulWidget {
  final TransportRoute route;

  const ReservationFormScreen({super.key, required this.route});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  int _seats = 1;
  String _paymentMethod = 'Yape';
  RouteStop? _originStop;
  RouteStop? _destinationStop;
  bool _submitting = false;

  static const _paymentMethods = ['Yape', 'Plin', 'Card', 'Cash'];
  static const _paymentIcons = {
    'Yape': Icons.phone_android_rounded,
    'Plin': Icons.phone_iphone_rounded,
    'Card': Icons.credit_card_rounded,
    'Cash': Icons.money_rounded,
  };

  @override
  void initState() {
    super.initState();
    final stops = widget.route.stops;
    if (stops.isNotEmpty) {
      _originStop = stops.first;
      _destinationStop = stops.length > 1 ? stops.last : stops.first;
    }
  }

  @override
  void dispose() {
    _dniController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_originStop == null || _destinationStop == null) {
      _showSnack('Selecciona origen y destino');
      return;
    }
    if (_originStop!.id == _destinationStop!.id) {
      _showSnack('El origen y destino deben ser diferentes');
      return;
    }

    setState(() => _submitting = true);

    final user = context.read<UserProvider>().currentUser;
    if (user == null) {
      _showSnack('Debes iniciar sesion');
      setState(() => _submitting = false);
      return;
    }

    final userId = int.tryParse(user.id) ?? 0;
    final provider = context.read<ReservationProvider>();
    final result = await provider.createReservation(
      userId: userId,
      routeId: widget.route.id,
      originStopId: _originStop!.id,
      destinationStopId: _destinationStop!.id,
      driverId: widget.route.driverId,
      price: widget.route.price,
      seats: _seats,
      documentNumber: _dniController.text.trim(),
      paymentMethod: _paymentMethod,
      availableSeats: 20,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result == null) {
      _showSnack(provider.error ?? 'Error al crear reserva');
      return;
    }

    // The reservation already registered a Pending payment (its fkIdPayment); take the
    // passenger to the (simulated) checkout to confirm it, which also confirms the reservation.
    final total = widget.route.price * _seats;
    if (result.fkIdPayment != null) {
      final paid = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            paymentId: result.fkIdPayment!,
            amount: total,
            method: _paymentMethod,
          ),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paid == true ? 'Reserva pagada y confirmada' : 'Reserva creada (pago pendiente)'),
          backgroundColor: paid == true ? AppColors.success : AppColors.warning,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva creada exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.route;
    final stops = route.stops;

    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(
        title: const Text('Reservar viaje'),
        backgroundColor: AppColors.carbon950,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildRouteHeader(route),
            const SizedBox(height: 20),

            _sectionTitle('Selecciona tus paraderos'),
            const SizedBox(height: 8),
            _buildStopDropdown(
              label: 'Paradero de origen',
              icon: Icons.radio_button_checked,
              iconColor: AppColors.success,
              stops: stops,
              value: _originStop,
              onChanged: (s) => setState(() => _originStop = s),
            ),
            const SizedBox(height: 12),
            _buildStopDropdown(
              label: 'Paradero de destino',
              icon: Icons.location_on_rounded,
              iconColor: AppColors.gold500,
              stops: stops,
              value: _destinationStop,
              onChanged: (s) => setState(() => _destinationStop = s),
            ),

            const SizedBox(height: 24),
            _sectionTitle('Datos del pasajero'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _dniController,
              keyboardType: TextInputType.number,
              maxLength: 8,
              style: const TextStyle(color: AppColors.carbon50),
              decoration: _inputDecoration('Numero de DNI', Icons.badge_rounded),
              validator: (v) {
                if (v == null || v.trim().length != 8) return 'DNI debe tener 8 digitos';
                if (int.tryParse(v.trim()) == null) return 'Solo numeros';
                return null;
              },
            ),

            const SizedBox(height: 16),
            _sectionTitle('Asientos'),
            const SizedBox(height: 8),
            _buildSeatSelector(),

            const SizedBox(height: 24),
            _sectionTitle('Metodo de pago'),
            const SizedBox(height: 8),
            _buildPaymentMethodSelector(),

            const SizedBox(height: 24),
            _buildPriceSummary(route),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gold600, AppColors.gold500, AppColors.gold400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold500.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: AppColors.carbon950,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.carbon950),
                        )
                      : const Icon(Icons.confirmation_num_rounded, size: 20),
                  label: Text(
                    _submitting ? 'Procesando...' : 'Confirmar reserva',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteHeader(TransportRoute route) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.gold500.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_bus_rounded, color: AppColors.gold500, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.name,
                  style: const TextStyle(
                    color: AppColors.carbon50,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${route.duration} | ${route.distance}',
                  style: const TextStyle(color: AppColors.carbon400, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            'S/ ${route.price.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.gold500,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStopDropdown({
    required String label,
    required IconData icon,
    required Color iconColor,
    required List<RouteStop> stops,
    required RouteStop? value,
    required ValueChanged<RouteStop?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<RouteStop>(
              initialValue: value,
              isExpanded: true,
              dropdownColor: AppColors.carbon800,
              style: const TextStyle(color: AppColors.carbon100, fontSize: 14),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: AppColors.carbon400, fontSize: 13),
                border: InputBorder.none,
              ),
              items: stops
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.name, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: onChanged,
              validator: (v) => v == null ? 'Requerido' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.event_seat_rounded, color: AppColors.gold500, size: 20),
              SizedBox(width: 10),
              Text('Asientos', style: TextStyle(color: AppColors.carbon200, fontSize: 14)),
            ],
          ),
          Row(
            children: [
              _seatButton(Icons.remove, _seats > 1, () => setState(() => _seats--)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_seats',
                  style: const TextStyle(
                    color: AppColors.carbon50,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              _seatButton(Icons.add, _seats < 10, () => setState(() => _seats++)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _seatButton(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? AppColors.gold500.withValues(alpha: 0.2) : AppColors.carbon700,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.gold500 : AppColors.carbon600,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _paymentMethods.map((method) {
        final selected = _paymentMethod == method;
        return GestureDetector(
          onTap: () => setState(() => _paymentMethod = method),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.gold500.withValues(alpha: 0.15)
                  : AppColors.carbon800,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? AppColors.gold500 : AppColors.carbon700,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _paymentIcons[method] ?? Icons.payment_rounded,
                  color: selected ? AppColors.gold500 : AppColors.carbon400,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  method,
                  style: TextStyle(
                    color: selected ? AppColors.gold500 : AppColors.carbon200,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceSummary(TransportRoute route) {
    final total = route.price * _seats;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold500.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _priceRow('Precio por asiento', 'S/ ${route.price.toStringAsFixed(2)}'),
          if (_seats > 1) ...[
            const SizedBox(height: 6),
            _priceRow('Asientos', 'x $_seats'),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: AppColors.carbon700),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: AppColors.carbon50,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                'S/ ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.gold500,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.carbon400, fontSize: 13)),
        Text(value, style: const TextStyle(color: AppColors.carbon200, fontSize: 13)),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.carbon200,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.carbon400),
      prefixIcon: Icon(icon, color: AppColors.gold500, size: 20),
      counterText: '',
      filled: true,
      fillColor: AppColors.carbon800,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.carbon700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.carbon700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.gold500),
      ),
    );
  }
}
