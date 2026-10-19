import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/badge_pill.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_display.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/presentation/auth_controller.dart';
import 'products_controller.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(productsControllerProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = NumberFormat.currency(locale: 'fr_FR', symbol: 'F', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Catalogue Produits"),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: "Scanner code-barres",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Caméra prête pour la détection de codes-barres produit"),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: user?.canManageStock == true
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/products/new'),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Nouveau", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              backgroundColor: AppColors.accent,
            )
          : null,
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher par nom, réf ou SKU...",
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(productsControllerProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onSubmitted: (val) => ref.read(productsControllerProvider.notifier).setSearchQuery(val),
            ),
          ),

          // Filtres rapides
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                FilterChip(
                  label: const Text("Tous"),
                  selected: state.filterRupture == null,
                  onSelected: (_) => ref.read(productsControllerProvider.notifier).toggleRuptureFilter(null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text("En Rupture"),
                  selected: state.filterRupture == true,
                  onSelected: (_) => ref.read(productsControllerProvider.notifier).toggleRuptureFilter(true),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text("En Stock"),
                  selected: state.filterRupture == false,
                  onSelected: (_) => ref.read(productsControllerProvider.notifier).toggleRuptureFilter(false),
                ),
              ],
            ),
          ),

          // Liste des produits
          Expanded(
            child: state.isLoading && state.products.isEmpty
                ? const LoadingIndicator(message: "Chargement du catalogue...")
                : state.errorMessage != null && state.products.isEmpty
                    ? ErrorDisplay(
                        message: state.errorMessage!,
                        onRetry: () => ref.read(productsControllerProvider.notifier).loadProducts(),
                      )
                    : state.products.isEmpty
                        ? const EmptyState(
                            title: "Aucun produit trouvé",
                            message: "Aucun article ne correspond à votre recherche ou filtre.",
                            icon: Icons.inventory_2_outlined,
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref.read(productsControllerProvider.notifier).loadProducts(isRefresh: true),
                            child: ListView.separated(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                              itemCount: state.products.length + (state.hasNext ? 1 : 0),
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                if (index == state.products.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  );
                                }

                                final product = state.products[index];
                                return InkWell(
                                  onTap: () => context.push('/products/${product.id}'),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
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
                                        // Badge icône produit
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.widgets_outlined,
                                            size: 24,
                                            color: isDark ? AppColors.accentLight : AppColors.accent,
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Détails
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      product.nom,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  BadgePill.fromStockStatus(product.statutStock),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Réf : ${product.reference}${product.sku != null ? ' • SKU: ${product.sku}' : ''}",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    currency.format(product.prixUnitaire),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppColors.accent,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Stock : ${product.stockActuel} ${product.unite}",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: product.rupture ? AppColors.danger : (isDark ? Colors.white70 : Colors.black87),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
}
