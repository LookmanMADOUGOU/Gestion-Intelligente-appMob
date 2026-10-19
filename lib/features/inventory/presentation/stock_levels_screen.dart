import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/badge_pill.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../products/presentation/products_controller.dart';

class StockLevelsScreen extends ConsumerWidget {
  const StockLevelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Niveaux de Stock & Inventaire"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: "Historique des mouvements",
            onPressed: () => context.push('/movements'),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: "Ajustement d'inventaire",
            onPressed: () => context.push('/stock-adjust'),
          ),
        ],
      ),
      body: state.isLoading && state.products.isEmpty
          ? const LoadingIndicator(message: "Calcul des niveaux de stock...")
          : state.products.isEmpty
              ? const EmptyState(
                  title: "Aucun produit en stock",
                  message: "Le catalogue ne contient aucun produit.",
                  icon: Icons.layers_clear_outlined,
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(productsControllerProvider.notifier).loadProducts(isRefresh: true),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = state.products[index];
                      final maxStock = p.stockMaximum > 0 ? p.stockMaximum : 100;
                      final ratio = (p.stockActuel / maxStock).clamp(0.0, 1.0);

                      Color barColor;
                      if (p.rupture) {
                        barColor = AppColors.danger;
                      } else if (p.statutStock == 'STOCK FAIBLE') {
                        barColor = AppColors.warning;
                      } else if (p.statutStock == 'SURSTOCK') {
                        barColor = AppColors.info;
                      } else {
                        barColor = AppColors.success;
                      }

                      return InkWell(
                        onTap: () => context.push('/products/${p.id}'),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      p.nom,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  BadgePill.fromStockStatus(p.statutStock),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Réf : ${p.reference} • Seuil critique : ${p.seuilAlerte} ${p.unite}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${p.stockActuel} ${p.unite} disponible(s)",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: barColor,
                                    ),
                                  ),
                                  Text(
                                    "Max : $maxStock",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 8,
                                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
