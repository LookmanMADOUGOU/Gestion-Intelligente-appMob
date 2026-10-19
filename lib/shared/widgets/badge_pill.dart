import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum BadgeType { normal, success, warning, danger, info, purple }

class BadgePill extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;

  const BadgePill({
    super.key,
    required this.label,
    this.type = BadgeType.normal,
    this.icon,
  });

  factory BadgePill.fromStockStatus(String status) {
    switch (status.toUpperCase()) {
      case 'RUPTURE':
        return const BadgePill(label: 'Rupture', type: BadgeType.danger, icon: Icons.error_outline);
      case 'STOCK FAIBLE':
        return const BadgePill(label: 'Stock faible', type: BadgeType.warning, icon: Icons.warning_amber_rounded);
      case 'SURSTOCK':
        return const BadgePill(label: 'Surstock', type: BadgeType.info, icon: Icons.layers_outlined);
      default:
        return const BadgePill(label: 'Normal', type: BadgeType.success, icon: Icons.check_circle_outline);
    }
  }

  factory BadgePill.fromRole(String role) {
    switch (role) {
      case 'Admin':
      case 'Administrateur':
        return const BadgePill(label: 'Admin', type: BadgeType.purple, icon: Icons.security);
      case 'Manager':
        return const BadgePill(label: 'Manager', type: BadgeType.info, icon: Icons.insights);
      case 'Magasinier':
        return const BadgePill(label: 'Magasinier', type: BadgeType.warning, icon: Icons.inventory_2_outlined);
      case 'Caissier':
        return const BadgePill(label: 'Caissier', type: BadgeType.success, icon: Icons.point_of_sale);
      default:
        return BadgePill(label: role, type: BadgeType.normal);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (type) {
      case BadgeType.success:
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF065F46);
        border = const Color(0xFFA7F3D0);
        break;
      case BadgeType.warning:
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFF92400E);
        border = const Color(0xFFFDE68A);
        break;
      case BadgeType.danger:
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFF991B1B);
        border = const Color(0xFFFECACA);
        break;
      case BadgeType.info:
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF1E40AF);
        border = const Color(0xFFBFDBFE);
        break;
      case BadgeType.purple:
        bg = const Color(0xFFF5F3FF);
        fg = const Color(0xFF5B21B6);
        border = const Color(0xFFDDD6FE);
        break;
      case BadgeType.normal:
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF334155);
        border = const Color(0xFFCBD5E1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
