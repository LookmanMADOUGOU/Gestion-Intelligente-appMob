import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../data/product_repository.dart';
import '../domain/product_model.dart';
import 'products_controller.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final int? productId;

  const ProductFormScreen({super.key, this.productId});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _referenceController = TextEditingController();
  final _skuController = TextEditingController();
  final _codeBarresController = TextEditingController();
  final _prixUnitaireController = TextEditingController();
  final _prixAchatController = TextEditingController();
  final _stockActuelController = TextEditingController();
  final _seuilAlerteController = TextEditingController(text: '5');
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit && widget.productId != null) {
      _loadProductData(widget.productId!);
      _isInit = true;
    }
  }

  Future<void> _loadProductData(int id) async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      final product = await repo.getProduct(id);
      _nomController.text = product.nom;
      _referenceController.text = product.reference;
      _skuController.text = product.sku ?? '';
      _codeBarresController.text = product.codeBarres ?? '';
      _prixUnitaireController.text = product.prixUnitaire.toString();
      _prixAchatController.text = product.prixAchat.toString();
      _stockActuelController.text = product.stockActuel.toString();
      _seuilAlerteController.text = product.seuilAlerte.toString();
      _descriptionController.text = product.description ?? '';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _referenceController.dispose();
    _skuController.dispose();
    _codeBarresController.dispose();
    _prixUnitaireController.dispose();
    _prixAchatController.dispose();
    _stockActuelController.dispose();
    _seuilAlerteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final repo = ref.read(productRepositoryProvider);

    final payload = {
      'nom': _nomController.text.trim(),
      'reference': _referenceController.text.trim(),
      'sku': _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
      'code_barres': _codeBarresController.text.trim().isEmpty ? null : _codeBarresController.text.trim(),
      'prix_unitaire': double.tryParse(_prixUnitaireController.text) ?? 0.0,
      'prix_achat': double.tryParse(_prixAchatController.text) ?? 0.0,
      'stock_actuel': int.tryParse(_stockActuelController.text) ?? 0,
      'seuil_alerte': int.tryParse(_seuilAlerteController.text) ?? 5,
      'description': _descriptionController.text.trim(),
    };

    try {
      if (widget.productId == null) {
        await repo.createProduct(payload);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Produit créé avec succès")),
          );
        }
      } else {
        await repo.updateProduct(widget.productId!, payload);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Produit mis à jour avec succès")),
          );
        }
      }
      ref.read(productsControllerProvider.notifier).loadProducts(isRefresh: true);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Modifier Produit" : "Nouveau Produit"),
      ),
      body: _isLoading && isEdit && _nomController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(labelText: "Nom du produit *"),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Nom obligatoire" : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _referenceController,
                            decoration: const InputDecoration(labelText: "Référence unique *"),
                            validator: (v) => (v == null || v.trim().isEmpty) ? "Référence obligatoire" : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _skuController,
                            decoration: const InputDecoration(labelText: "Code SKU"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _codeBarresController,
                      decoration: const InputDecoration(
                        labelText: "Code-barres EAN/UPC",
                        suffixIcon: Icon(Icons.qr_code_scanner, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _prixVenteControllerOrUnitaire,
                            decoration: const InputDecoration(labelText: "Prix de vente *", suffixText: "FCFA"),
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || double.tryParse(v) == null) ? "Prix invalide" : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _prixAchatController,
                            decoration: const InputDecoration(labelText: "Prix d'achat *", suffixText: "FCFA"),
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || double.tryParse(v) == null) ? "Coût invalide" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stockActuelController,
                            decoration: const InputDecoration(labelText: "Stock initial *"),
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || int.tryParse(v) == null) ? "Quantité invalide" : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _seuilAlerteController,
                            decoration: const InputDecoration(labelText: "Seuil d'alerte *"),
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || int.tryParse(v) == null) ? "Seuil invalide" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: "Description"),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isEdit ? "Enregistrer les modifications" : "Créer le produit"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  TextEditingController get _prixVenteControllerOrUnitaire => _prixUnitaireController;
}
