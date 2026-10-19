import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/storage/local_cache_service.dart';
import '../../core/theme/app_colors.dart';

class SyncStatusBar extends StatelessWidget {
  final bool isOffline;
  final VoidCallback? onRefresh;

  const SyncStatusBar({
    super.key,
    this.isOffline = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final lastSync = LocalCacheService.getGlobalLastSyncTime();
    final timeStr = lastSync != null
        ? DateFormat('dd/MM HH:mm').format(lastSync)
        : 'Jamais';

    if (!isOffline && lastSync == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isOffline ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.wifi_off_rounded : Icons.sync_rounded,
            size: 14,
            color: isOffline ? const Color(0xFF92400E) : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isOffline
                  ? "Mode Hors Ligne (Données en cache - Dernière sync : $timeStr)"
                  : "Dernière synchro : $timeStr",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isOffline ? const Color(0xFF92400E) : AppColors.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRefresh != null) ...[
            InkWell(
              onTap: onRefresh,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "Actualiser",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
