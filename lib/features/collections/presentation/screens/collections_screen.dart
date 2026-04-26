import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'collection_detail_screen.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  // TODO: endpoint pendiente de implementación en backend (/api/collections)
  final List<Map<String, dynamic>> _collections = [];

  void _showCreateDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.carbon800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Nueva Colección', style: TextStyle(color: AppColors.carbon50, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(color: AppColors.carbon100),
          decoration: const InputDecoration(labelText: 'Nombre de la colección'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.carbon400)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _collections.add({'name': name, 'routes': []});
                });
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold500, foregroundColor: AppColors.carbon950),
            child: const Text('Crear', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.carbon900,
      appBar: AppBar(
        title: const Text('Mis Colecciones'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: _collections.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _collections.length,
              itemBuilder: (context, i) => _buildCollectionCard(_collections[i], i),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.gold500,
        foregroundColor: AppColors.carbon950,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.carbon800,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.carbon700),
            ),
            child: const Icon(Icons.folder_outlined, size: 40, color: AppColors.carbon600),
          ),
          const SizedBox(height: 16),
          const Text('Sin colecciones', style: TextStyle(color: AppColors.carbon200, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Crea una colección para organizar tus rutas', style: TextStyle(color: AppColors.carbon400, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Crear colección', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(Map<String, dynamic> collection, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CollectionDetailScreen(collectionName: collection['name']),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.carbon800,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.carbon700),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha:0.25), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gold500.withValues(alpha:0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.folder_rounded, color: AppColors.gold500, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  collection['name'],
                  style: const TextStyle(color: AppColors.carbon50, fontWeight: FontWeight.w700, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${(collection['routes'] as List).length} rutas',
                  style: const TextStyle(color: AppColors.carbon400, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
