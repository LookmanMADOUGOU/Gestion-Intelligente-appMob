import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../products/domain/product_model.dart';
import '../../products/presentation/products_controller.dart';
import '../../suppliers/domain/supplier_model.dart';
import '../../suppliers/presentation/suppliers_controller.dart';
import 'purchases_controller.dart';

class PurchaseCreateScreen extends ConsumerStatefulWidget {
  const PurchaseCreateScreen({super.key});

  @override
  ConsumerState<PurchaseCreateScreen> createState() => _PurchaseCreateScreenState();
}

class _PurchaseCreateScreenState extends ConsumerState<PurchaseCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  ProductModel? _selectedProduct;
  SupplierModel? _selectedSupplier;
  final _manualSupplierController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _coutUnitaireController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _manualSupplierController.dispose();
    _quantiteController.dispose();
    _coutUnitaireController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onProductSelected(ProductModel? product) {
    setState(() {
      _selectedProduct = product;
      if (product != null && _coutUnitaireController.text.isEmpty) {
        _coutUnitaireController.text = product.prixAchat.toStringAsFixed(0);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un produit'), backgroundColor: AppColors.error),
      );
      return;
    }

    final supplierName = _selectedSupplier?.nom ?? _manualSupplierController.text.trim();
    if (supplierName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez spécifier le nom du fournisseur'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(purchasesRepositoryProvider);
      final payload = {
        'produit': _selectedProduct!.id,
        'quantite': int.parse(_quantiteController.text.trim()),
        'fournisseur': supplierName,
        if (_selectedSupplier != null) 'fournisseur_fk': _selectedSupplier!.id,
        'cout_unitaire': double.tryParse(_coutUnitaireController.text.trim()) ?? _selectedProduct!.prixAchat,
        'statut': 'RECU',
        'notes': _notesController.text.trim(),
      };

      await repo.createPurchase(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Arrivage de +${_quantiteController.text} ${_selectedProduct!.nom} enregistré !'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsControllerProvider);
    final suppliersState = ref.watch(suppliersControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réceptionner Marchandise'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sélecteur Produit
              const Text('Produit à approvisionner *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<ProductModel>(
                value: _selectedProduct,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Sélectionner le produit...',
                  prefixIcon: const Icon(Icons.inventory_2_outlined),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: productsState.products.map((p) {
                  return DropdownMenuItem<ProductModel>(
                    value: p,
                    child: Text('${p.nom} (Stock actuel: ${p.stockActuel})', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: _onProductSelected,
                validator: (val) => val == null ? 'Veuillez sélectionner un produit' : null,
              ),
              const SizedBox(height: 16),

              // Quantité reçue
              TextFormField(
                controller: _quantiteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantité livrée *',
                  hintText: 'Ex: 50',
                  prefixIcon: Icon(Icons.add_box_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Quantité obligatoire';
                  final num = int.tryParse(val.trim());
                  if (num == null || num <= 0) return 'Entrez un nombre entier positif';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sélecteur Fournisseur
              const Text('Fournisseur partenaire', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<SupplierModel>(
                value: _selectedSupplier,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Choisir parmi vos partenaires...',
                  prefixIcon: const Icon(Icons.storefront_outlined),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: suppliersState.suppliers.map((s) {
                  return DropdownMenuItem<SupplierModel>(
                    value: s,
                    child: Text(s.nom, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (s) {
                  setState(() {
                    _selectedSupplier = s;
                    if (s != null) {
                      _manualSupplierController.text = s.nom;
                    }
                  });
                },
              ),
              const SizedBox(height: 8),
              if (_selectedSupplier == null)
                TextFormField(
                  controller: _manualSupplierController,
                  decoration: const InputDecoration(
                    labelText: 'Ou saisir le nom du fournisseur *',
                    hintText: 'Ex: Distributeur Local',
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                ),
              const SizedBox(height: 16),

              // Coût unitaire d'achat
              TextFormField(
                controller: _coutUnitaireController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Prix / Coût d\'achat unitaire (FCFA)',
                  hintText: 'Ex: 1500',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Notes ou numéro de bon de livraison
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes / N° Bon de livraison',
                  hintText: 'Ex: Facture BL-2026-042',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Valider l\'Arrivage & Incrémenter le Stock',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
