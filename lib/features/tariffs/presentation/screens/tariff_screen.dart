import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../driver/presentation/providers/driver_provider.dart';
import '../../../network/routes/data/models/company_route_model.dart';
import '../../../network/routes/presentation/providers/company_route_provider.dart';
import '../../data/models/tariff_model.dart';
import '../providers/tariff_provider.dart';

/// Lets a driver configure their fare (base/per-km/per-minute/min) and the days
/// it applies, plus per-route estimated durations. Backed by TariffsController.
class TariffScreen extends StatefulWidget {
  const TariffScreen({super.key});

  @override
  State<TariffScreen> createState() => _TariffScreenState();
}

class _TariffScreenState extends State<TariffScreen> {
  static const _dayLabels = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];

  final _formKey = GlobalKey<FormState>();
  final _baseFare = TextEditingController();
  final _pricePerKm = TextEditingController();
  final _pricePerMinute = TextEditingController();
  final _minFare = TextEditingController();
  final _durationMinutes = TextEditingController();

  final Set<int> _days = {1, 2, 3, 4, 5};
  int? _durationRouteId;
  bool _saving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _baseFare.dispose();
    _pricePerKm.dispose();
    _pricePerMinute.dispose();
    _minFare.dispose();
    _durationMinutes.dispose();
    super.dispose();
  }

  int? get _driverId => context.read<DriverProvider>().driver?.id;

  Future<void> _load() async {
    final driverId = _driverId;
    if (driverId == null) return;
    await Future.wait([
      context.read<TariffProvider>().load(driverId),
      context.read<CompanyRouteProvider>().load(driverId),
    ]);
    _hydrateFromTariff();
  }

  void _hydrateFromTariff() {
    final tariff = context.read<TariffProvider>().tariff;
    if (tariff != null && !_initialized) {
      _baseFare.text = tariff.baseFare.toString();
      _pricePerKm.text = tariff.pricePerKm.toString();
      _pricePerMinute.text = tariff.pricePerMinute.toString();
      _minFare.text = tariff.minFare.toString();
      _days
        ..clear()
        ..addAll(tariff.availableDays);
      _initialized = true;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(title: const Text('Mi tarifa')),
      body: Consumer<TariffProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.loaded) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold500));
          }
          return RefreshIndicator(
            color: AppColors.gold500,
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!provider.hasTariff)
                  _infoBanner('Aún no tienes una tarifa. Complétala para publicar tus precios.'),
                _fareForm(provider),
                const SizedBox(height: 24),
                if (provider.hasTariff) _routeDurationSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _fareForm(TariffProvider provider) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.carbon800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.carbon700),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(Icons.payments_outlined, 'Precios (S/)'),
            const SizedBox(height: 12),
            _moneyField(_baseFare, 'Tarifa base'),
            const SizedBox(height: 12),
            _moneyField(_pricePerKm, 'Precio por km'),
            const SizedBox(height: 12),
            _moneyField(_pricePerMinute, 'Precio por minuto'),
            const SizedBox(height: 12),
            _moneyField(_minFare, 'Tarifa mínima'),
            const SizedBox(height: 20),
            _sectionTitle(Icons.calendar_today_outlined, 'Días disponibles'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(7, (i) {
                final selected = _days.contains(i);
                return FilterChip(
                  label: Text(_dayLabels[i]),
                  selected: selected,
                  onSelected: (v) => setState(() => v ? _days.add(i) : _days.remove(i)),
                  backgroundColor: AppColors.carbon900,
                  selectedColor: AppColors.gold500.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.gold500,
                  labelStyle: TextStyle(
                    color: selected ? AppColors.gold500 : AppColors.carbon200,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                  shape: StadiumBorder(
                    side: BorderSide(color: selected ? AppColors.gold500 : AppColors.carbon700),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : () => _save(provider),
                child: Text(_saving
                    ? 'Guardando…'
                    : (provider.hasTariff ? 'Actualizar tarifa' : 'Crear tarifa')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeDurationSection() {
    final routes = context.watch<CompanyRouteProvider>().routes;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.timer_outlined, 'Duración estimada por ruta'),
          const SizedBox(height: 12),
          if (routes.isEmpty)
            const Text('No tienes rutas registradas.',
                style: TextStyle(color: AppColors.carbon400, fontSize: 13))
          else ...[
            DropdownButtonFormField<int>(
              initialValue: _durationRouteId,
              isExpanded: true,
              dropdownColor: AppColors.carbon800,
              decoration: const InputDecoration(labelText: 'Ruta'),
              hint: const Text('Selecciona una ruta…',
                  style: TextStyle(color: AppColors.carbon400)),
              items: routes
                  .map((r) => DropdownMenuItem<int>(
                        value: r.id,
                        child: Text(_routeLabel(r),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _durationRouteId = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _durationMinutes,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Minutos estimados'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _saveRouteDuration,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Guardar duración'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _save(TariffProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    final driverId = _driverId;
    if (driverId == null) return;
    if (_days.isEmpty) {
      _snack('Selecciona al menos un día.', isError: true);
      return;
    }

    setState(() => _saving = true);
    final existing = provider.tariff;
    final model = TariffModel(
      id: existing?.id ?? 0,
      fkIdDriver: driverId,
      baseFare: double.tryParse(_baseFare.text) ?? 0,
      pricePerKm: double.tryParse(_pricePerKm.text) ?? 0,
      pricePerMinute: double.tryParse(_pricePerMinute.text) ?? 0,
      minFare: double.tryParse(_minFare.text) ?? 0,
      currency: existing?.currency ?? 'PEN',
      availableDays: _days.toList()..sort(),
    );
    final ok = await provider.save(model);
    if (!mounted) return;
    setState(() => _saving = false);
    _snack(ok ? 'Tarifa guardada' : (provider.error ?? 'No se pudo guardar'), isError: !ok);
  }

  Future<void> _saveRouteDuration() async {
    final routeId = _durationRouteId;
    final minutes = int.tryParse(_durationMinutes.text);
    if (routeId == null) {
      _snack('Selecciona una ruta.', isError: true);
      return;
    }
    if (minutes == null || minutes <= 0) {
      _snack('Ingresa los minutos estimados.', isError: true);
      return;
    }
    final result = await context
        .read<TariffProvider>()
        .setRouteDuration(fkIdRoute: routeId, estimatedMinutes: minutes);
    if (!mounted) return;
    _snack(
      result != null ? 'Duración guardada' : (context.read<TariffProvider>().error ?? 'No se pudo guardar'),
      isError: result == null,
    );
  }

  String _routeLabel(CompanyRouteModel r) {
    final base = r.name.isNotEmpty ? r.name : 'Ruta #${r.id}';
    return '$base · S/ ${r.price.toStringAsFixed(2)}';
  }

  Widget _moneyField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
      decoration: InputDecoration(labelText: label, prefixText: 'S/ '),
      validator: (v) {
        final value = double.tryParse(v ?? '');
        if (value == null || value < 0) return 'Ingresa un monto válido';
        return null;
      },
    );
  }

  Widget _sectionTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gold500, size: 20),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                color: AppColors.carbon100, fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _infoBanner(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gold500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold500.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.gold500, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.carbon100, fontSize: 13))),
        ],
      ),
    );
  }

  void _snack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.carbon800,
      ),
    );
  }
}
