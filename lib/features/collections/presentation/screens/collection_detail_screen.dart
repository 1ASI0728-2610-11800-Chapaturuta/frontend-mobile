import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class CollectionDetailScreen extends StatelessWidget {
  final String collectionName;

  const CollectionDetailScreen({super.key, required this.collectionName});

  @override
  Widget build(BuildContext context) {
    // TODO: endpoint pendiente de implementación en backend (/api/collections/{id})
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(
        title: Text(collectionName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_bus_outlined, size: 48, color: AppColors.carbon600),
            const SizedBox(height: 12),
            const Text('Colección vacía', style: TextStyle(color: AppColors.carbon200, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Agrega rutas desde el detalle de cada ruta', style: TextStyle(color: AppColors.carbon400, fontSize: 13), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
