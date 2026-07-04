import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../data/models/collection_model.dart';
import '../providers/collection_provider.dart';
import 'collection_detail_screen.dart';

/// User collections of favourite routes: list, create, rename and delete.
class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
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
    await context.read<CollectionProvider>().load(userId);
  }

  Future<void> _showCreateDialog() async {
    final name = await _nameDialog(title: 'Nueva colección');
    if (name == null || name.isEmpty || !mounted) return;
    final userId = _userId;
    if (userId == null) return;
    final provider = context.read<CollectionProvider>();
    final ok = await provider.create(name, userId);
    if (!mounted) return;
    if (!ok) _snack(provider.error ?? 'No se pudo crear', isError: true);
  }

  Future<void> _rename(CollectionModel c) async {
    final name = await _nameDialog(title: 'Renombrar colección', initial: c.name);
    if (name == null || name.isEmpty || name == c.name || !mounted) return;
    final provider = context.read<CollectionProvider>();
    final ok = await provider.rename(c.id, name);
    if (!mounted) return;
    if (!ok) _snack(provider.error ?? 'No se pudo renombrar', isError: true);
  }

  Future<void> _delete(CollectionModel c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.carbon800,
        title: const Text('Eliminar colección', style: TextStyle(color: AppColors.carbon50)),
        content: Text('¿Eliminar "${c.name}"? Se perderán las rutas guardadas.',
            style: const TextStyle(color: AppColors.carbon200)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final provider = context.read<CollectionProvider>();
    final ok = await provider.delete(c.id);
    if (!mounted) return;
    if (!ok) _snack(provider.error ?? 'No se pudo eliminar', isError: true);
  }

  Future<String?> _nameDialog({required String title, String? initial}) {
    final controller = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.carbon800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: AppColors.carbon50, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.carbon100),
          decoration: const InputDecoration(labelText: 'Nombre de la colección'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Guardar'),
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
        title: const Text('Mis colecciones'),
        automaticallyImplyLeading: false,
        actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: _showCreateDialog)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.gold500,
        foregroundColor: AppColors.carbon950,
        child: const Icon(Icons.add_rounded),
      ),
      body: Consumer<CollectionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.collections.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold500));
          }
          if (provider.collections.isEmpty) {
            return _emptyState();
          }
          return RefreshIndicator(
            color: AppColors.gold500,
            onRefresh: _load,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.05,
              ),
              itemCount: provider.collections.length,
              itemBuilder: (context, i) => _collectionCard(provider.collections[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _collectionCard(CollectionModel c) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CollectionDetailScreen(collection: c)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.carbon800,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.carbon700),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gold500.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.folder_rounded, color: AppColors.gold500, size: 22),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  color: AppColors.carbon800,
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.carbon400, size: 20),
                  onSelected: (v) {
                    if (v == 'rename') _rename(c);
                    if (v == 'delete') _delete(c);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'rename', child: Text('Renombrar', style: TextStyle(color: AppColors.carbon100))),
                    PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: AppColors.danger))),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(c.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.carbon50, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 2),
            Text('${c.itemCount} ruta${c.itemCount == 1 ? '' : 's'}',
                style: const TextStyle(color: AppColors.carbon400, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        const Icon(Icons.folder_outlined, size: 56, color: AppColors.carbon600),
        const SizedBox(height: 16),
        const Text('Sin colecciones',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.carbon200, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Crea una colección para organizar tus rutas',
            textAlign: TextAlign.center, style: TextStyle(color: AppColors.carbon400, fontSize: 13)),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Crear colección'),
          ),
        ),
      ],
    );
  }

  void _snack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? AppColors.danger : AppColors.success),
    );
  }
}
