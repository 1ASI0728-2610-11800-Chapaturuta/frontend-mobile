import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showArrow;

  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold500, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15, color: AppColors.carbon100),
              ),
            ),
            if (showArrow)
              const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.gold500),
          ],
        ),
      ),
    );
  }
}