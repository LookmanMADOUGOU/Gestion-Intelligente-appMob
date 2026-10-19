import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_display.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../domain/alert_model.dart';
import 'alerts_controller.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> with SingleTickerProviderStateMixin {
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
    final state = ref.watch(alertsControllerProvider);
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes & Notifications'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(
              icon: Badge(
                isLabelVisible: state.activeAlertsCount > 0,
                label: Text('${state.activeAlertsCount}'),
                backgroundColor: AppColors.error,
                child: const Icon(Icons.warning_amber_rounded),
              ),
              text: 'Ruptures Stock',
            ),
            Tab(
              icon: Badge(
                isLabelVisible: state.unreadNotificationsCount > 0,
                label: Text('${state.unreadNotificationsCount}'),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.notifications_none),
              ),
              text: 'Notifications',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(alertsControllerProvider.notifier).loadAll(isRefresh: true),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading && state.alerts.isEmpty && state.notifications.isEmpty) {
            return const LoadingIndicator(message: 'Vérification des alertes...');
          }

          if (state.errorMessage != null && state.alerts.isEmpty) {
            return ErrorDisplay(
              message: state.errorMessage!,
              onRetry: () => ref.read(alertsControllerProvider.notifier).loadAll(isRefresh: true),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _AlertsTab(alerts: state.alerts, dateFormatter: dateFormatter),
              _NotificationsTab(notifications: state.notifications, dateFormatter: dateFormatter),
            ],
          );
        },
      ),
    );
  }
}

class _AlertsTab extends ConsumerWidget {
  final List<AlerteModel> alerts;
  final DateFormat dateFormatter;

  const _AlertsTab({required this.alerts, required this.dateFormatter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (alerts.isEmpty) {
      return const EmptyState(
        title: 'Aucune alerte active',
        message: 'Vos stocks sont actuellement à des niveaux nominaux.',
        icon: Icons.check_circle_outline,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(alertsControllerProvider.notifier).loadAll(isRefresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final alerte = alerts[index];
          final color = alerte.isCritical ? AppColors.error : AppColors.warning;

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: color.withOpacity(alerte.estResolue ? 0.2 : 0.4)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          alerte.estResolue ? Icons.check : Icons.warning_amber_rounded,
                          color: alerte.estResolue ? AppColors.success : color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alerte.produitNom,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              dateFormatter.format(alerte.dateCreation),
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (alerte.estResolue ? AppColors.success : color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          alerte.estResolue ? 'Résolue' : alerte.niveau,
                          style: TextStyle(
                            color: alerte.estResolue ? AppColors.success : color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    alerte.message,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                  if (!alerte.estResolue) ...[
                    const Divider(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.done_all, size: 16),
                        label: const Text('Marquer comme résolue'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        onPressed: () {
                          ref.read(alertsControllerProvider.notifier).resolveAlert(alerte.id);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationsTab extends ConsumerWidget {
  final List<NotificationModel> notifications;
  final DateFormat dateFormatter;

  const _NotificationsTab({required this.notifications, required this.dateFormatter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (notifications.isEmpty) {
      return const EmptyState(
        title: 'Aucune notification',
        message: 'Vous êtes à jour dans vos notifications.',
        icon: Icons.notifications_off_outlined,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.done_all, size: 16),
              label: const Text('Tout marquer comme lu'),
              onPressed: () => ref.read(alertsControllerProvider.notifier).markAllNotificationsRead(),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(alertsControllerProvider.notifier).loadAll(isRefresh: true),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Card(
                  elevation: 0,
                  color: notif.lue ? Theme.of(context).cardColor : AppColors.primary.withOpacity(0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: notif.lue ? Colors.grey.withOpacity(0.12) : AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: CircleAvatar(
                      backgroundColor: notif.lue ? Colors.grey.withOpacity(0.12) : AppColors.primary.withOpacity(0.12),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: notif.lue ? Colors.grey : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notif.titre,
                      style: TextStyle(
                        fontWeight: notif.lue ? FontWeight.w500 : FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notif.message, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          dateFormatter.format(notif.dateCreation),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: notif.lue
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.check, size: 18, color: AppColors.primary),
                            onPressed: () => ref.read(alertsControllerProvider.notifier).markNotificationRead(notif.id),
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
