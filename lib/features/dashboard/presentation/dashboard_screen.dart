import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/badge_pill.dart';
import '../../../shared/widgets/error_display.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/sync_status_bar.dart';
import '../../auth/presentation/auth_controller.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final dashboardState = ref.watch(dashboardControllerProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bonjour, ${user?.displayName ?? 'Utilisateur'}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                BadgePill.fromRole(user?.role ?? 'Utilisateur'),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: "Alertes et Notifications",
            onPressed: () => context.push('/alerts'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: "Paramètres",
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          SyncStatusBar(
            isOffline: dashboardState.isOffline,
            onRefresh: () => ref.read(dashboardControllerProvider.notifier).loadDashboard(isRefresh: true),
          ),
          Expanded(
            child: dashboardState.isLoading && dashboardState.kpi == null
                ? const LoadingIndicator(message: "Chargement des indicateurs...")
                : dashboardState.errorMessage != null && dashboardState.kpi == null
                    ? ErrorDisplay(
                        message: dashboardState.errorMessage!,
                        onRetry: () => ref.read(dashboardControllerProvider.notifier).loadDashboard(),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(dashboardControllerProvider.notifier).loadDashboard(isRefresh: true),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Grille des 4 KPI clés
                              _buildKpiGrid(context, dashboardState),
                              const SizedBox(height: 24),

                              // Barre d'actions rapides métier
                              _buildQuickActions(context, user),
                              const SizedBox(height: 24),

                              // Graphique d'évolution des ventes
                              _buildSalesTrendCard(context, dashboardState, isDark),
                              const SizedBox(height: 24),

                              // Top produits consommés / vendus
                              _buildTopConsumedCard(context, dashboardState, isDark),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(BuildContext context, DashboardState state) {
    final kpi = state.kpi;
    final totalProd = kpi?.totalProducts ?? 0;
    final totalStock = kpi?.totalStock ?? 0;
    final inRupture = kpi?.productsInRupture ?? 0;
    final activeAlerts = kpi?.activeAlerts ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.35,
      children: [
        StatCard(
          title: "Total Produits",
          value: totalProd.toString(),
          subtitle: "Références au catalogue",
          icon: Icons.inventory_2_outlined,
          iconColor: AppColors.accent,
          onTap: () => context.push('/products'),
        ),
        StatCard(
          title: "Unités en Stock",
          value: NumberFormat('#,###', 'fr_FR').format(totalStock),
          subtitle: "Quantité cumulée",
          icon: Icons.layers_outlined,
          iconColor: AppColors.success,
          onTap: () => context.push('/stock-levels'),
        ),
        StatCard(
          title: "En Rupture",
          value: inRupture.toString(),
          subtitle: "Articles à commander",
          icon: Icons.error_outline_rounded,
          iconColor: AppColors.danger,
          iconBgColor: const Color(0xFFFEE2E2),
          onTap: () => context.push('/products?filter=rupture'),
        ),
        StatCard(
          title: "Alertes Actives",
          value: activeAlerts.toString(),
          subtitle: "Seuils franchis",
          icon: Icons.notifications_active_outlined,
          iconColor: AppColors.warning,
          iconBgColor: const Color(0xFFFEF3C7),
          onTap: () => context.push('/alerts'),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Actions rapides",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (user?.canOperatePos ?? true)
              Expanded(
                child: _buildActionBtn(
                  context,
                  label: "Caisse POS",
                  icon: Icons.point_of_sale_rounded,
                  color: AppColors.success,
                  onTap: () => context.push('/cash-register'),
                ),
              ),
            if (user?.canOperatePos ?? true) const SizedBox(width: 8),
            if (user?.canManageStock ?? true)
              Expanded(
                child: _buildActionBtn(
                  context,
                  label: "Inventaire",
                  icon: Icons.tune_rounded,
                  color: AppColors.accent,
                  onTap: () => context.push('/stock-adjust'),
                ),
              ),
            if (user?.canManageStock ?? true) const SizedBox(width: 8),
            Expanded(
              child: _buildActionBtn(
                context,
                label: "Prévisions IA",
                icon: Icons.auto_graph_rounded,
                color: AppColors.purple,
                onTap: () => context.push('/predictions'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBtn(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesTrendCard(BuildContext context, DashboardState state, bool isDark) {
    final trend = state.kpi?.salesTrend ?? [];

    return Container(
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
              const Text(
                "Évolution des Ventes",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Text(
                "Derniers 14 jours",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: trend.isEmpty
                ? Center(
                    child: Text(
                      "Aucune vente enregistrée sur cette période",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (val, meta) => Text(
                              val.toInt().toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: (trend.length / 4).ceilToDouble(),
                            getTitlesWidget: (val, meta) {
                              final idx = val.toInt();
                              if (idx >= 0 && idx < trend.length) {
                                final dStr = trend[idx].date;
                                final parts = dStr.split('-');
                                if (parts.length >= 3) {
                                  return Text("${parts[2]}/${parts[1]}", style: const TextStyle(fontSize: 9));
                                }
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: trend.asMap().entries.map((entry) {
                            return FlSpot(entry.key.toDouble(), entry.value.quantite.toDouble());
                          }).toList(),
                          isCurved: true,
                          color: AppColors.accent,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.accent.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopConsumedCard(BuildContext context, DashboardState state, bool isDark) {
    final topList = state.kpi?.topConsumed ?? [];

    return Container(
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
          const Text(
            "Top Produits les Plus Vendus",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          if (topList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  "Aucune donnée de vente enregistrée",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            )
          else ...[
            ...topList.map((item) {
              final maxQte = topList.first.quantite;
              final ratio = maxQte > 0 ? item.quantite / maxQte : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.produitNom,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "${item.quantite} vendus",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 6,
                        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
