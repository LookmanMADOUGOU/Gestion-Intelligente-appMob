import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/badge_pill.dart';
import '../../../shared/widgets/error_display.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../cash_register/presentation/cash_register_controller.dart';
import '../data/product_repository.dart';
import '../domain/product_model.dart';

final productDetailProvider = FutureProvider.family<ProductModel, int>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  return await repo.getProduct(id);
});

class ProductDetailScreen extends ConsumerWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProduct = ref.watch(productDetailProvider(productId));
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fiche Produit"),
        actions: [
          if (user?.canManageStock == true)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: "Modifier le produit",
              onPressed: () => context.push('/products/$productId/edit'),
            ),
        ],
      ),
      body: asyncProduct.when(
        loading: () => const LoadingIndicator(message: "Chargement de la fiche..."),
        error: (err, _) => ErrorDisplay(
          message: err.toString(),
          onRetry: () => ref.refresh(productDetailProvider(productId)),
        ),
        data: (product) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Entête Produit
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.nom,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          ),
                          BadgePill.fromStockStatus(product.statutStock),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Référence : ${product.reference} ${product.sku != null ? '• SKU: ${product.sku}' : ''}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      if (product.codeBarres != null && product.codeBarres!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.qr_code, size: 14, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              "Code-barres : ${product.codeBarres}",
                              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ],
                      if (product.description != null && product.description!.isNotEmpty) ...[
                        const Divider(height: 24),
                        Text(
                          product.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Niveaux de Stock
                const Text("Niveaux de Stock", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        label: "Stock Actuel",
                        value: "${product.stockActuel} ${product.unite}",
                        color: product.rupture ? AppColors.danger : AppColors.success,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        label: "Seuil d'Alerte",
                        value: "${product.seuilAlerte} ${product.unite}",
                        color: AppColors.warning,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricTile(
                        context,
                        label: "Stock Max",
                        value: "${product.stockMaximum} ${product.unite}",
                        color: AppColors.accent,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Données Financières & Marges
                const Text("Tarification & Rentabilité", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildFinanceRow("Prix de vente unitaire", currency.format(product.prixUnitaire), bold: true),
                      const Divider(height: 18),
                      _buildFinanceRow("Prix d'achat unitaire", currency.format(product.prixAchat)),
                      const Divider(height: 18),
                      _buildFinanceRow(
                        "Marge unitaire",
                        "${currency.format(product.margeUnitaire)} (${product.tauxMarge}%)",
                        color: product.margeUnitaire >= 0 ? AppColors.success : AppColors.danger,
                      ),
                      const Divider(height: 18),
                      _buildFinanceRow("Valeur stock au prix de vente", currency.format(product.valeurStockVente)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section Intelligence Artificielle & Prédictions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                          : [const Color(0xFFF5F3FF), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF4338CA) : const Color(0xFFDDD6FE),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: AppColors.purple, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Prévisions Intelligentes SMART TECH",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.purple),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Demande J+1 prévue", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  "${product.predictionMl ?? 'Calcul en cours'}",
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Jours avant rupture", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  "${product.predictionRupture ?? 'Calcul en cours'}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: product.rupture ? AppColors.danger : AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Boutons d'action
                Row(
                  children: [
                    if (user?.canManageStock == true)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/stock-adjust?productId=${product.id}'),
                          icon: const Icon(Icons.tune_rounded, size: 18),
                          label: const Text("Ajuster Stock"),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            side: const BorderSide(color: AppColors.accent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    if (user?.canManageStock == true && user?.canOperatePos == true)
                      const SizedBox(width: 12),
                    if (user?.canOperatePos == true)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: product.isOutOfStock
                              ? null
                              : () {
                                  ref.read(cartControllerProvider.notifier).addItem(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("${product.nom} ajouté au panier"),
                                      action: SnackBarAction(
                                        label: "Voir panier",
                                        onPressed: () => context.push('/cash-register'),
                                      ),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                          label: const Text("Ajouter au Panier"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricTile(BuildContext context, {required String label, required String value, required Color color, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildFinanceRow(String label, String value, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
