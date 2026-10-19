import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_display.dart';
import '../../../shared/widgets/loading_indicator.dart';
import 'customers_controller.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customersControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = NumberFormat.currency(locale: 'fr_FR', symbol: 'F', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Répertoire Clients"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/customers/new'),
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text("Nouveau Client", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.accent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher par nom ou téléphone...",
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(customersControllerProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onSubmitted: (val) => ref.read(customersControllerProvider.notifier).setSearchQuery(val),
            ),
          ),
          Expanded(
            child: state.isLoading && state.customers.isEmpty
                ? const LoadingIndicator(message: "Chargement des clients...")
                : state.errorMessage != null && state.customers.isEmpty
                    ? ErrorDisplay(
                        message: state.errorMessage!,
                        onRetry: () => ref.read(customersControllerProvider.notifier).loadCustomers(),
                      )
                    : state.customers.isEmpty
                        ? const EmptyState(
                            title: "Aucun client enregistré",
                            message: "Créez une fiche client pour suivre les ventes à crédit et la fidélité.",
                            icon: Icons.people_outline_rounded,
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref.read(customersControllerProvider.notifier).loadCustomers(isRefresh: true),
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                              itemCount: state.customers.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final client = state.customers[index];
                                final hasCredit = client.soldeCredit > 0;

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
                                      CircleAvatar(
                                        backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                                        child: Text(
                                          client.nom.isNotEmpty ? client.nom[0].toUpperCase() : 'C',
                                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.accent),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              client.nom,
                                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                            ),
                                            const SizedBox(height: 4),
                                            if (client.telephone != null && client.telephone!.isNotEmpty) ...[
                                              Row(
                                                children: [
                                                  const Icon(Icons.phone_outlined, size: 13, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(client.telephone!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                            ],
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  "${client.totalAchatsCount} achat(s)",
                                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                ),
                                                Text(
                                                  hasCredit
                                                      ? "Crédit : ${currency.format(client.soldeCredit)}"
                                                      : "Crédit : Solde à zéro",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: hasCredit ? AppColors.danger : AppColors.success,
                                                  ),
                                                ),
                                              ],
                                            ),
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
}
