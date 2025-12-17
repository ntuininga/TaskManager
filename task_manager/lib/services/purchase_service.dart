import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isPremium = false;

  final StreamController<bool> _premiumController =
      StreamController<bool>.broadcast();

  Stream<bool> get premiumStream => _premiumController.stream;

  static const String premiumProductId = 'premium';

  PurchaseService() {
    _init();
  }

  void _init() {
    _subscription = _iap.purchaseStream.listen(_onPurchaseUpdated);
  }

  Future<void> buyPremium() async {
    final response = await _iap.queryProductDetails({premiumProductId});

    if (response.productDetails.isEmpty) {
      throw Exception('Product not found');
    }

    final product = response.productDetails.first;

    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _onPurchaseUpdated(
    List<PurchaseDetails> purchases,
  ) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final valid = await _verifyPurchase(purchase);
        if (valid) {
          _isPremium = true;
          _premiumController.add(true);
        }
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    return purchase.productID == premiumProductId;
  }
}



