import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tech_mobile/features/auth/domain/user_model.dart';
import 'package:smart_tech_mobile/features/products/domain/product_model.dart';
import 'package:smart_tech_mobile/features/purchases/domain/purchase_model.dart';
import 'package:smart_tech_mobile/features/reports/domain/prediction_model.dart';
import 'package:smart_tech_mobile/features/suppliers/domain/supplier_model.dart';

void main() {
  group('Tests des Modèles Métier SMART-TECH', () {
    test('Désérialisation JSON UserModel avec rôle RBAC', () {
      final jsonAdmin = {
        'id': 1,
        'username': 'admin_boss',
        'email': 'admin@smarttech.com',
        'first_name': 'Super',
        'last_name': 'Admin',
        'is_staff': true,
        'is_superuser': true,
        'role': 'Admin',
      };
      final userAdmin = UserModel.fromJson(jsonAdmin);
      expect(userAdmin.role, equals(UserRole.admin));
      expect(userAdmin.canManageStock, isTrue);
      expect(userAdmin.canAccessReports, isTrue);

      final jsonCaissier = {
        'id': 5,
        'username': 'caisse_01',
        'email': 'caisse1@smarttech.com',
        'is_staff': false,
        'is_superuser': false,
        'role': 'Caissier',
      };
      final userCaissier = UserModel.fromJson(jsonCaissier);
      expect(userCaissier.role, equals(UserRole.caissier));
      expect(userCaissier.canManageStock, isFalse);
      expect(userCaissier.canAccessReports, isFalse);
    });

    test('Désérialisation JSON ProductModel et calculs de marge', () {
      final jsonProduct = {
        'id': 42,
        'nom': 'Smartphone Galaxy',
        'reference': 'REF-GAL-01',
        'categorie': 2,
        'categorie_nom': 'Téléphonie',
        'prix_achat': '120000.00',
        'prix_unitaire': '160000.00',
        'stock_actuel': 5,
        'seuil_alerte': 10,
        'stock_maximum': 30,
        'date_creation': '2026-10-15T10:00:00Z',
      };

      final product = ProductModel.fromJson(jsonProduct);
      expect(product.id, equals(42));
      expect(product.nom, equals('Smartphone Galaxy'));
      expect(product.prixAchat, equals(120000.0));
      expect(product.prixUnitaire, equals(160000.0));
      expect(product.margeUnitaire, equals(40000.0));
      expect(product.isRupture, isTrue); // 5 <= seuil_alerte (10)
    });

    test('Désérialisation JSON SupplierModel avec détection de dettes', () {
      final jsonSupplier = {
        'id': 10,
        'nom': 'Fournisseur Alpha SARL',
        'telephone': '+229 97 00 11 22',
        'dette_fournisseur': '450000.00',
        'total_approvisionnements_count': 12,
        'total_achats_montant': '3500000.00',
        'date_creation': '2026-01-01T08:00:00Z',
      };

      final supplier = SupplierModel.fromJson(jsonSupplier);
      expect(supplier.id, equals(10));
      expect(supplier.hasDebt, isTrue);
      expect(supplier.detteFournisseur, equals(450000.0));
      expect(supplier.totalApprovisionnementsCount, equals(12));
    });

    test('Désérialisation JSON PurchaseModel', () {
      final jsonPurchase = {
        'id': 101,
        'produit': 42,
        'produit_nom': 'Smartphone Galaxy',
        'quantite': 50,
        'fournisseur': 'Fournisseur Alpha SARL',
        'cout_unitaire': '115000.00',
        'statut': 'RECU',
        'date_approvisionnement': '2026-10-19T14:00:00Z',
      };

      final purchase = PurchaseModel.fromJson(jsonPurchase);
      expect(purchase.id, equals(101));
      expect(purchase.quantite, equals(50));
      expect(purchase.coutUnitaire, equals(115000.0));
      expect(purchase.coutTotal, equals(5750000.0));
    });

    test('Désérialisation DecisionSupportSummaryModel et métriques IA', () {
      final jsonDecision = {
        'total_produits': 25,
        'nb_critique': 3,
        'nb_eleve': 5,
        'nb_dormant': 2,
        'nb_surstock': 1,
        'nb_securise': 14,
        'budget_total_reappro': 1250000.0,
        'items': [
          {
            'produit_id': 1,
            'produit_nom': 'Produit Urgent',
            'produit_reference': 'PU-01',
            'stock_actuel': 2,
            'seuil_alerte': 10,
            'stock_maximum': 50,
            'conso_moyenne': 4.5,
            'tendance': 'ACCÉLÉRATION',
            'stockout_days': 0.4,
            'niveau_risque': 'CRITIQUE',
            'label_risque': 'Rupture Imminente',
            'badge_color': 'red',
            'recommandation': 'Commander immédiatement',
            'action_requise': true,
            'safety_stock': 15.0,
            'rop': 35.0,
            'lead_time_days': 5,
            'is_dormant': false,
            'qte_recommandee': 48,
            'budget_estime': 240000.0,
            'prix_achat': 5000.0,
          }
        ],
      };

      final summary = DecisionSupportSummaryModel.fromJson(jsonDecision);
      expect(summary.totalProduits, equals(25));
      expect(summary.nbCritique, equals(3));
      expect(summary.budgetTotalReappro, equals(1250000.0));
      expect(summary.items.length, equals(1));

      final firstItem = summary.items.first;
      expect(firstItem.isCritical, isTrue);
      expect(firstItem.actionRequise, isTrue);
      expect(firstItem.qteRecommandee, equals(48));
    });
  });
}
