import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_display.dart';
import '../../../shared/widgets/loading_indicator.dart';
import 'inventory_controller.dart';

class MovementsScreen extends ConsumerWidget {
  const MovementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(movementsControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des Mouvements"),
      ),
      body: Column(
        children: [
          // Filtres par type de mouvement
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(ref, "Tous", null, state.filterType == null),
                const SizedBox(width: 8),
                _buildFilterChip(ref, "Ventes", "VENTE", state.filterType == "VENTE"),
                const SizedBox(width: 8),
                _buildFilterChip(ref, "Achats", "ACHAT", state.filterType == "ACHAT"),
                const SizedBox(width: 8),
                _buildFilterChip(ref, "Inventaires", "INVENTAIRE", state.filterType == "INVENTAIRE"),
                const SizedBox(width: 8),
                _buildFilterChip(ref, "Ajustements", "AJUSTEMENT", state.filterType == "AJUSTEMENT"),
                const SizedBox(width: 8),
                _buildFilterChip(ref, "Entrées", "ENTREE", state.filterType == "ENTREE"),
                const SizedBox(width: 8),
                _buildFilterChip(ref, "Sorties", "SORTIE", state.filterType == "SORTIE"),
              ],
            ),
          ),

          // Liste des mouvements
          Expanded(
            child: state.isLoading && state.movements.isEmpty
                ? const LoadingIndicator(message: "Chargement de l'audit trail...")
                : state.errorMessage != null && state.movements.isEmpty
                    ? ErrorDisplay(
                        message: state.errorMessage!,
                        onRetry: () => ref.read(movementsControllerProvider.notifier).loadMovements(),
                      )
                    : state.movements.isEmpty
                        ? const EmptyState(
                            title: "Aucun mouvement",
                            message: "Aucun flux de stock n'a été enregistré pour ce critère.",
                            icon: Icons.history_rounded,
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref.read(movementsControllerProvider.notifier).loadMovements(isRefresh: true),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.movements.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final mvt = state.movements[index];
                                final isPositive = mvt.stockApres >= mvt.stockAvant;
                                final delta = mvt.stockApres - mvt.stockAvant;
                                final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(mvt.dateMouvement);

                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Icône avec code couleur
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: (isPositive ? AppColors.success : AppColors.danger).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          isPositive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                          color: isPositive ? AppColors.success : AppColors.danger,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Contenu
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    mvt.produitNom,
                                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  "${delta >= 0 ? '+' : ''}$delta",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                    color: isPositive ? AppColors.success : AppColors.danger,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${mvt.typeMouvement} • Stock : ${mvt.stockAvant} ➔ ${mvt.stockApres}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? Colors.white70 : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "Par : ${mvt.utilisateurUsername}",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                                  ),
                                                ),
                                                Text(
                                                  dateStr,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (mvt.commentaire != null && mvt.commentaire!.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                mvt.commentaire!,
                                                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String label, String? value, bool selected) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: selected,
      onSelected: (_) => ref.read(movementsControllerProvider.notifier).setFilterType(value),
    );
  }
}
