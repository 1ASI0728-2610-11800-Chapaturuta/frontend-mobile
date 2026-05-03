import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../data/models/company_stop_model.dart';

class StopCard extends StatelessWidget {
  final CompanyStopModel stop;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StopCard({
    super.key,
    required this.stop,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.carbon800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.carbon700),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 58,
              height: 58,
              child: stop.imageUrl == null
                  ? Container(
                      color: AppColors.carbon700,
                      child: const Icon(Icons.pin_drop_outlined, color: AppColors.gold500),
                    )
                  : Image.network(stop.imageUrl!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.carbon50,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stop.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.carbon400, fontSize: 12),
                ),
                if (stop.districtLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    stop.districtLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.gold300, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Editar',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: AppColors.gold500),
          ),
          IconButton(
            tooltip: 'Eliminar',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}
