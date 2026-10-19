import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/badge_pill.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../customers/domain/customer_model.dart';
import '../../customers/presentation/customers_controller.dart';
import '../../products/presentation/products_controller.dart';
import 'cash_register_controller.dart';
import 'receipt_dialog.dart';

class CashRegisterScreen extends ConsumerStatefulWidget {
  const CashRegisterScreen({super.key});

  @override
  ConsumerState<CashRegisterScreen> createState() => _CashRegisterScreenState();
}

class _CashRegisterScreenState extends ConsumerState<CashRegisterScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CartBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsControllerProvider);
    final cartState = ref.watch(cartControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = NumberFormat.currency(locale: 'fr_FR', symbol: 'F', decimalDigits: 0);

    // Filtrer les produits disponibles (stock > 0)
    final availableProducts = productsState.products.where((p) {
      if (_searchController.text.trim().isEmpty) return true;
      final q = _searchController.text.trim().toLowerCase();
      return p.nom.toLowerCase().contains(q) ||
          p.reference.toLowerCase().contains(q) ||
          (p.codeBarres?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Caisse Enregistreuse POS"),
        actions: [
          if (cartState.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: "Vider le panier",
              onPressed: () => ref.read(cartControllerProvider.notifier).clearCart(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Recherche tactile rapide
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Recherche produit ou code-barres...",
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Scanner code-barres activé")),
                    );
                  },
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Grille des articles
          Expanded(
            child: availableProducts.isEmpty
                ? const EmptyState(
                    title: "Aucun produit en stock",
                    message: "Ajoutez des produits avec du stock pour encaisser.",
                    icon: Icons.production_quantity_limits_rounded,
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: availableProducts.length,
                    itemBuilder: (context, index) {
                      final p = availableProducts[index];
                      final cartItem = cartState.items.where((i) => i.product.id == p.id).firstOrNull;
                      final inCartCount = cartItem?.quantity ?? 0;

                      return InkWell(
                        onTap: p.stockActuel <= 0
                            ? null
                            : () => ref.read(cartControllerProvider.notifier).addItem(p),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: inCartCount > 0
                                  ? AppColors.accent
                                  : (isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
                              width: inCartCount > 0 ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  BadgePill.fromStockStatus(p.statutStock),
                                  if (inCartCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "$inCartCount",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                p.nom,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    currency.format(p.prixUnitaire),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                  Text(
                                    "${p.stockActuel} disp.",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // Barre fixe du Panier en bas d'écran
      bottomSheet: cartState.items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${cartState.totalArticlesCount} article(s)",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        Text(
                          currency.format(cartState.totalNet),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _openCartBottomSheet(context),
                      icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
                      label: const Text("Encaisser"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        minimumSize: const Size(140, 46),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CartBottomSheet extends ConsumerWidget {
  const _CartBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartControllerProvider);
    final clientsState = ref.watch(customersControllerProvider);
    final currency = NumberFormat.currency(locale: 'fr_FR', symbol: 'F', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Barre de tirage
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Panier d'encaissement", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Message d'erreur
          if (cartState.errorMessage != null) ...[
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                cartState.errorMessage!,
                style: const TextStyle(color: AppColors.danger, fontSize: 12),
              ),
            ),
          ],

          // Liste des articles du panier
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: cartState.items.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = cartState.items[index];

                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.nom, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(
                            "${currency.format(item.customUnitPrice)} x ${item.quantity}",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currency.format(item.totalPrice),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 22),
                          onPressed: () => ref.read(cartControllerProvider.notifier).updateQuantity(item.product.id, -1),
                        ),
                        Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.w700)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 22),
                          onPressed: () => ref.read(cartControllerProvider.notifier).updateQuantity(item.product.id, 1),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          // Options de règlement et validation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
              border: Border(top: BorderSide(color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sélection du client
                DropdownButtonFormField<CustomerModel?>(
                  value: cartState.selectedClient,
                  decoration: const InputDecoration(
                    labelText: "Client (Optionnel sauf pour crédit)",
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text("Client Passant")),
                    ...clientsState.customers.map((c) => DropdownMenuItem(value: c, child: Text(c.nom))),
                  ],
                  onChanged: (c) => ref.read(cartControllerProvider.notifier).setClient(c),
                ),
                const SizedBox(height: 12),

                // Mode de paiement
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPayChip(ref, "Espèces", "ESPECES", cartState.modePaiement == "ESPECES"),
                      const SizedBox(width: 8),
                      _buildPayChip(ref, "Carte", "CARTE", cartState.modePaiement == "CARTE"),
                      const SizedBox(width: 8),
                      _buildPayChip(ref, "Mobile Money", "MOBILE_MONEY", cartState.modePaiement == "MOBILE_MONEY"),
                      const SizedBox(width: 8),
                      _buildPayChip(ref, "Crédit", "CREDIT", cartState.modePaiement == "CREDIT"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Total & Confirmation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("TOTAL À PAYER :", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                    Text(
                      currency.format(cartState.totalNet),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.success),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: cartState.isLoading
                      ? null
                      : () async {
                          final receipt = await ref.read(cartControllerProvider.notifier).checkout();
                          if (receipt != null && context.mounted) {
                            Navigator.pop(context);
                            ReceiptDialog.show(context, receipt);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: cartState.isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Confirmer l'encaissement"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayChip(WidgetRef ref, String label, String value, bool selected) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => ref.read(cartControllerProvider.notifier).setModePaiement(value),
    );
  }
}
