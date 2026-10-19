import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../products/domain/product_model.dart';
import '../../products/presentation/products_controller.dart';
import '../data/inventory_repository.dart';
import 'inventory_controller.dart';

class StockAdjustmentScreen extends ConsumerStatefulWidget {
  final int? preselectedProductId;

  const StockAdjustmentScreen({super.key, this.preselectedProductId});

  @override
  ConsumerState<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends ConsumerState<StockAdjustmentScreen> {
  final _formKey = GlobalKey<FormState>();
  ProductModel? _selectedProduct;
  String _mode = 'INVENTAIRE'; // 'INVENTAIRE', 'ENTREE', 'SORTIE'
  final _quantityController = TextEditingController();
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final products = ref.read(productsControllerProvider).products;
      if (widget.preselectedProductId != null && products.isNotEmpty) {
        final found = products.where((p) => p.id == widget.preselectedProductId).firstOrNull;
        if (found != null) {
          setState(() {
            _selectedProduct = found;
            _quantityController.text = found.stockActuel.toString();
          });
        }
      } else if (products.isNotEmpty) {
        setState(() {
          _selectedProduct = products.first;
          _quantityController.text = products.first.stockActuel.toString();
        });
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) return;

    final qte = int.tryParse(_quantityController.text);
    if (qte == null) return;

    // Calcul du stock prévisionnel pour confirmation
    int stockApres;
    if (_mode == 'INVENTAIRE') {
      stockApres = qte;
    } else if (_mode == 'ENTREE') {
      stockApres = _selectedProduct!.stockActuel + qte;
    } else {
      stockApres = (_selectedProduct!.stockActuel - qte).clamp(0, 999999);
    }

    // Modal de confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmer l'ajustement"),
        content: Text(
          "Êtes-vous sûr de vouloir ajuster le stock de '${_selectedProduct!.nom}' ?\n\n"
          "Stock actuel : ${_selectedProduct!.stockActuel}\n"
          "Nouveau stock estimé : $stockApres\n"
          "Type d'opération : $_mode",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    final repo = ref.read(inventoryRepositoryProvider);

    try {
      if (_mode == 'INVENTAIRE') {
        await repo.ajusterStock(
          produitId: _selectedProduct!.id,
          nouvelleQuantite: qte,
          typeMouvement: 'INVENTAIRE',
          commentaire: _commentController.text.trim().isEmpty ? 'Comptage physique inventaire' : _commentController.text.trim(),
        );
      } else if (_mode == 'ENTREE') {
        await repo.ajusterStock(
          produitId: _selectedProduct!.id,
          quantite: qte,
          typeMouvement: 'ENTREE',
          commentaire: _commentController.text.trim().isEmpty ? 'Entrée de stock manuelle' : _commentController.text.trim(),
        );
      } else {
        await repo.ajusterStock(
          produitId: _selectedProduct!.id,
          quantite: qte,
          typeMouvement: 'SORTIE',
          commentaire: _commentController.text.trim().isEmpty ? 'Sortie exceptionnelle' : _commentController.text.trim(),
        );
      }

      // Rafraîchir les listes
      ref.read(productsControllerProvider.notifier).loadProducts(isRefresh: true);
      ref.read(movementsControllerProvider.notifier).loadMovements(isRefresh: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Stock mis à jour avec succès et consigné dans l'audit"),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
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
    final productsState = ref.watch(productsControllerProvider);
    final products = productsState.products;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajustement de Stock"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sélection du produit
              const Text("Produit concerné *", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (products.isEmpty)
                const Text("Aucun produit disponible")
              else
                DropdownButtonFormField<ProductModel>(
                  value: _selectedProduct,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.widgets_outlined, size: 20),
                  ),
                  items: products.map((p) {
                    return DropdownMenuItem<ProductModel>(
                      value: p,
                      child: Text("${p.nom} (Stock : ${p.stockActuel})", maxLines: 1, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedProduct = val;
                      if (_mode == 'INVENTAIRE' && val != null) {
                        _quantityController.text = val.stockActuel.toString();
                      }
                    });
                  },
                ),
              const SizedBox(height: 20),

              // Type d'opération
              const Text("Type d'opération *", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'INVENTAIRE', label: Text("Inventaire", style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: 'ENTREE', label: Text("+ Entrée", style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: 'SORTIE', label: Text("- Sortie", style: TextStyle(fontSize: 12))),
                ],
                selected: {_mode},
                onSelectionChanged: (set) {
                  setState(() {
                    _mode = set.first;
                    if (_mode == 'INVENTAIRE' && _selectedProduct != null) {
                      _quantityController.text = _selectedProduct!.stockActuel.toString();
                    } else {
                      _quantityController.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 20),

              // Champ Quantité
              Text(
                _mode == 'INVENTAIRE' ? "Nouveau stock physique compté *" : "Quantité à ajouter ou retirer *",
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: _mode == 'INVENTAIRE' ? "Ex: 45" : "Ex: 10",
                  suffixText: _selectedProduct?.unite ?? "unités",
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Quantité requise";
                  final parsed = int.tryParse(v);
                  if (parsed == null || parsed < 0) return "Nombre entier positif requis";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Motif / Justificatif
              const Text("Justificatif / Commentaire d'audit *", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: "Ex : Régularisation suite au comptage physique annuel",
                ),
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty) ? "Le motif est requis pour l'audit" : null,
              ),
              const SizedBox(height: 32),

              // Bouton Soumettre
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Valider l'ajustement"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
