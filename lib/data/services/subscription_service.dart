import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/subscription_constants.dart';

@lazySingleton
class SubscriptionService {
  static const _keyIsPremium = 'subscription_is_premium';

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  ProductDetails? _productDetails;

  /// Preço formatado do produto (ex: "R$ 29,90"). Null antes da query.
  String? get premiumPrice => _productDetails?.price;

  final _premiumController = StreamController<bool>.broadcast();

  /// Stream que emite `true` quando a compra é concluída ou restaurada.
  Stream<bool> get premiumStream => _premiumController.stream;

  // ignore: unused_field  — mantido para evitar que a subscription seja coletada pelo GC
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  Future<void> initialize() async {
    // Carrega status em cache para resposta rápida no startup
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_keyIsPremium) ?? false;

    // Escuta o stream de compras da Play Store
    _purchaseSub =
        InAppPurchase.instance.purchaseStream.listen(_handlePurchases);

    // Busca detalhes do produto (preço real da loja)
    try {
      final resp = await InAppPurchase.instance
          .queryProductDetails({SubscriptionConstants.productPremium});
      if (resp.productDetails.isNotEmpty) {
        _productDetails = resp.productDetails.first;
      }
    } catch (_) {}

    // Restaura compras anteriores (ex: novo dispositivo, reinstalação)
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (_) {}
  }

  /// Abre o popup de compra da Play Store.
  Future<bool> purchase() async {
    if (_productDetails == null) return false;
    final param = PurchaseParam(productDetails: _productDetails!);
    return InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
  }

  /// Restaura uma compra anterior (para quem reinstalou o app).
  Future<void> restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != SubscriptionConstants.productPremium) continue;

      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        await _setPremium(true);
      }

      // Obrigatório: confirmar recebimento para evitar reembolso automático
      if (p.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(p);
      }
    }
  }

  Future<void> _setPremium(bool value) async {
    _isPremium = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, value);
    _premiumController.add(value);
  }
}
