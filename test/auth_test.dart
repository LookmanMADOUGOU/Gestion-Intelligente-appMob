import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tech_mobile/features/auth/domain/user_model.dart';
import 'package:smart_tech_mobile/features/auth/presentation/auth_controller.dart';

void main() {
  group('Tests du Contrôleur et de l\'État d\'Authentification', () {
    test('État initial déconnecté', () {
      const state = AuthState();
      expect(state.isLoading, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
    });

    test('Mise à jour d\'état via copyWith', () {
      final user = UserModel(
        id: 7,
        username: 'magasinier_bob',
        role: UserRole.magasinier,
      );

      final state = const AuthState().copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );

      expect(state.isAuthenticated, isTrue);
      expect(state.user?.username, equals('magasinier_bob'));
      expect(state.user?.role, equals(UserRole.magasinier));
      expect(state.user?.canManageStock, isTrue);
      expect(state.user?.canAccessCaisse, isFalse);
    });
  });
}
