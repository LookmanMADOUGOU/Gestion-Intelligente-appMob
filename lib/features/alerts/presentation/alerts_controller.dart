import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/alerts_repository.dart';
import '../domain/alert_model.dart';

class AlertsState {
  final bool isLoading;
  final List<AlerteModel> alerts;
  final List<NotificationModel> notifications;
  final String? errorMessage;

  const AlertsState({
    this.isLoading = false,
    this.alerts = const [],
    this.notifications = const [],
    this.errorMessage,
  });

  int get unreadNotificationsCount => notifications.where((n) => !n.lue).length;
  int get activeAlertsCount => alerts.where((a) => !a.estResolue).length;

  AlertsState copyWith({
    bool? isLoading,
    List<AlerteModel>? alerts,
    List<NotificationModel>? notifications,
    String? errorMessage,
  }) {
    return AlertsState(
      isLoading: isLoading ?? this.isLoading,
      alerts: alerts ?? this.alerts,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
    );
  }
}

class AlertsController extends StateNotifier<AlertsState> {
  final AlertsRepository _repository;

  AlertsController(this._repository) : super(const AlertsState()) {
    loadAll();
  }

  Future<void> loadAll({bool isRefresh = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final alertsFuture = _repository.getAlerts();
      final notifsFuture = _repository.getNotifications();

      final results = await Future.wait([alertsFuture, notifsFuture]);

      state = state.copyWith(
        isLoading: false,
        alerts: results[0] as List<AlerteModel>,
        notifications: results[1] as List<NotificationModel>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> resolveAlert(int alertId) async {
    try {
      await _repository.resolveAlert(alertId);
      loadAll(isRefresh: true);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> markNotificationRead(int notifId) async {
    try {
      await _repository.markNotificationAsRead(notifId);
      loadAll(isRefresh: true);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _repository.markAllNotificationsAsRead();
      loadAll(isRefresh: true);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) => AlertsRepository());

final alertsControllerProvider = StateNotifierProvider<AlertsController, AlertsState>((ref) {
  final repo = ref.watch(alertsRepositoryProvider);
  return AlertsController(repo);
});
