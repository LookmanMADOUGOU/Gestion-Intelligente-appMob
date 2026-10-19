import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_display.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/stat_card.dart';
import '../domain/prediction_model.dart';
import 'reports_controller.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsControllerProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports & Intelligence IA'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Statistiques & Ventes'),
            Tab(icon: Icon(Icons.psychology_outlined), text: 'Prévisions & IA'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(reportsControllerProvider.notifier).loadAll(isRefresh: true),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && state.summary == null) {
            return const LoadingIndicator(message: 'Calcul des indicateurs décisionnels...');
          }

          if (state.errorMessage != null && state.summary == null) {
            return ErrorDisplay(
              message: state.errorMessage!,
              onRetry: () => ref.read(reportsControllerProvider.notifier).loadAll(isRefresh: true),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _SalesAnalyticsTab(state: state),
              _AiDecisionTab(state: state, currencyFormatter: currencyFormatter),
            ],
          );
        },
      ),
    );
  }
}

class _SalesAnalyticsTab extends StatelessWidget {
  final ReportsState state;

  const _SalesAnalyticsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;
    final trend = state.trend;

    return RefreshIndicator(
      onRefresh: () => Future.value(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Grid
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Articles Actifs',
                    value: '${summary?.totalProducts ?? 0}',
                    icon: Icons.inventory_2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Stock Total',
                    value: '${summary?.totalStock ?? 0}',
                    icon: Icons.layers,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Ruptures Stock',
                    value: '${summary?.productsInRupture ?? 0}',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Alertes Actives',
                    value: '${summary?.activeAlerts ?? 0}',
                    icon: Icons.notifications_active,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Évolution des ventes (fl_chart)
            const Text(
              'Tendance des Ventes (14 derniers jours)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: SizedBox(
                  height: 200,
                  child: (trend == null || trend.sales.isEmpty)
                      ? const Center(child: Text('Données de ventes insuffisantes pour la période.'))
                      : LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (val) => FlLine(
                                color: Colors.grey.withOpacity(0.15),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  getTitlesWidget: (val, meta) => Text(
                                    val.toInt().toString(),
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 22,
                                  getTitlesWidget: (val, meta) {
                                    final idx = val.toInt();
                                    if (idx >= 0 && idx < trend.sales.length && idx % 3 == 0) {
                                      final rawDate = trend.sales[idx].date;
                                      final parts = rawDate.split('-');
                                      if (parts.length >= 3) {
                                        return Text('${parts[2]}/${parts[1]}', style: const TextStyle(fontSize: 10, color: Colors.grey));
                                      }
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: trend.sales.asMap().entries.map((e) {
                                  return FlSpot(e.key.toDouble(), e.value.quantite.toDouble());
                                }).toList(),
                                isCurved: true,
                                color: AppColors.primary,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.primary.withOpacity(0.12),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Top Articles Consommés
            const Text(
              'Articles les Plus Vendus',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (summary == null || summary.topConsumed.isEmpty)
              const EmptyState(
                title: 'Aucune donnée',
                message: 'Aucun enregistrement de vente récent.',
                icon: Icons.bar_chart,
              )
            else
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withOpacity(0.15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: summary.topConsumed.map((item) {
                      final maxQte = summary.topConsumed.first.quantite;
                      final ratio = maxQte > 0 ? (item.quantite / maxQte) : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.produitNom, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Text('${item.quantite} vendus', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 6,
                                backgroundColor: Colors.grey.withOpacity(0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AiDecisionTab extends ConsumerWidget {
  final ReportsState state;
  final NumberFormat currencyFormatter;

  const _AiDecisionTab({required this.state, required this.currencyFormatter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decision = state.decisionSupport;
    if (decision == null) {
      return const EmptyState(
        title: 'Moteur IA non initialisé',
        message: 'Impossible de calculer les projections IA pour le moment.',
        icon: Icons.psychology_outlined,
      );
    }

    final filteredItems = state.filterRisk == null
        ? decision.items
        : decision.items.filterRisk(state.filterRisk!);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bannière Budget Recommandé
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Budget Réapprovisionnement IA Suggéré',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormatter.format(decision.budgetTotalReappro),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${decision.nbCritique} article(s) critique(s) • ${decision.nbEleve} à surveiller',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Filtres par Niveau de Risque
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _RiskFilterChip(
                  label: 'Tous (${decision.totalProduits})',
                  isSelected: state.filterRisk == null,
                  color: AppColors.primary,
                  onTap: () => ref.read(reportsControllerProvider.notifier).setFilterRisk(null),
                ),
                const SizedBox(width: 8),
                _RiskFilterChip(
                  label: 'Critiques (${decision.nbCritique})',
                  isSelected: state.filterRisk == 'CRITIQUE',
                  color: AppColors.error,
                  onTap: () => ref.read(reportsControllerProvider.notifier).setFilterRisk('CRITIQUE'),
                ),
                const SizedBox(width: 8),
                _RiskFilterChip(
                  label: 'Élevé (${decision.nbEleve})',
                  isSelected: state.filterRisk == 'ELEVE',
                  color: AppColors.warning,
                  onTap: () => ref.read(reportsControllerProvider.notifier).setFilterRisk('ELEVE'),
                ),
                const SizedBox(width: 8),
                _RiskFilterChip(
                  label: 'Dormants (${decision.nbDormant})',
                  isSelected: state.filterRisk == 'DORMANT',
                  color: Colors.purple,
                  onTap: () => ref.read(reportsControllerProvider.notifier).setFilterRisk('DORMANT'),
                ),
                const SizedBox(width: 8),
                _RiskFilterChip(
                  label: 'Surstock (${decision.nbSurstock})',
                  isSelected: state.filterRisk == 'SURSTOCK',
                  color: AppColors.info,
                  onTap: () => ref.read(reportsControllerProvider.notifier).setFilterRisk('SURSTOCK'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Liste des diagnostics décisionnels
          if (filteredItems.isEmpty)
            const EmptyState(
              title: 'Aucun article',
              message: 'Aucun produit ne correspond au filtre sélectionné.',
              icon: Icons.check_circle_outline,
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return _PredictionCard(
                  item: item,
                  currencyFormatter: currencyFormatter,
                );
              },
            ),
        ],
      ),
    );
  }
}

extension _FilterExt on List<PredictionItemModel> {
  List<PredictionItemModel> filterRisk(String risk) {
    if (risk == 'DORMANT') return where((x) => x.isDormant).toList();
    return where((x) => x.niveauRisque == risk).toList();
  }
}

class _RiskFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _RiskFilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(isSelected ? 1.0 : 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final PredictionItemModel item;
  final NumberFormat currencyFormatter;

  const _PredictionCard({required this.item, required this.currencyFormatter});

  @override
  Widget build(BuildContext context) {
    Color riskColor;
    switch (item.niveauRisque) {
      case 'CRITIQUE':
        riskColor = AppColors.error;
        break;
      case 'ELEVE':
        riskColor = AppColors.warning;
        break;
      case 'SURSTOCK':
        riskColor = AppColors.info;
        break;
      default:
        riskColor = AppColors.success;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: riskColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.produitNom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      if (item.produitReference.isNotEmpty)
                        Text('Réf: ${item.produitReference}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: riskColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    item.labelRisque,
                    style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ItemMetric(label: 'Stock Actuel', value: '${item.stockActuel} pcs'),
                _ItemMetric(
                  label: 'Rupture estimée',
                  value: item.stockoutDays != null ? '${item.stockoutDays!.toStringAsFixed(1)} j' : 'N/A',
                  valueColor: item.stockoutDays != null && item.stockoutDays! <= 5 ? AppColors.error : null,
                ),
                _ItemMetric(label: 'Consommation', value: '${item.consoMoyenne.toStringAsFixed(1)} /j'),
                _ItemMetric(label: 'Point Commande', value: '${item.rop.toStringAsFixed(0)} pcs'),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, size: 18, color: riskColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.recommandation,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            if (item.actionRequise && item.qteRecommandee > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantité à commander : +${item.qteRecommandee} pcs',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  Text(
                    'Budget : ${currencyFormatter.format(item.budgetEstime)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ItemMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ItemMetric({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}
