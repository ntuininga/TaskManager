import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/core/constants/app_constants.dart';

class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final StreamController<bool> _premiumController =
      StreamController<bool>.broadcast();

  Stream<bool> get premiumStream => _premiumController.stream;

  static const _keyIsPremium = 'isPremium';

  PurchaseService() {
    _init();
  }

  Future<void> _init() async {
    // 1. Subscribe to the purchase stream FIRST — before anything else.
    //    This ensures we never miss an event, including ones from a previous
    //    session that didn't complete (e.g. app killed mid-purchase).
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (error) {
        _premiumController.addError(error);
      },
    );

    // 2. Immediately emit cached premium state so the UI is correct on launch
    //    without waiting for the network.
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyIsPremium) ?? false) {
      _premiumController.add(true);
    }

    // 3. Silently restore purchases from Google Play on every launch.
    //    This handles the reinstall case — Google Play re-delivers the purchase
    //    through purchaseStream as PurchaseStatus.restored.
    try {
      await _iap.restorePurchases();
    } catch (e) {
      // restorePurchases failing (e.g. no network) is non-fatal.
      // The cached SharedPreferences value above already covers offline users.
      print('PurchaseService: restorePurchases failed: $e');
    }
  }

  Future<void> buyPremium() async {
    final response =
        await _iap.queryProductDetails({AppConstants.premiumProductId});

    if (response.error != null) {
      throw Exception('Failed to load product: ${response.error!.message}');
    }

    if (response.productDetails.isEmpty) {
      throw Exception(
        'Product "${AppConstants.premiumProductId}" not found. '
        'Check that it is Active in Play Console.',
      );
    }

    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      final valid = await _verifyPurchase(purchase);
      if (valid) {
        await _grantPremium();
        // Complete the purchase only after successfully granting entitlement.
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
    }

    if (purchase.status == PurchaseStatus.error) {
      _premiumController.addError(
        purchase.error?.message ?? 'Unknown purchase error',
      );
    }

    // Pending = awaiting external action (e.g. cash payment at a kiosk).
    // Acknowledge immediately so the store doesn't keep re-delivering it,
    // but do NOT grant premium yet — wait for purchased status.
    if (purchase.status == PurchaseStatus.pending) {
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _grantPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, true);
    _premiumController.add(true);
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // Client-side check: confirms the product ID matches.
    // For a small app this is sufficient. Replace with server-side
    // receipt verification if the app scales and revenue justifies it.
    return purchase.productID == AppConstants.premiumProductId;
  }

  void dispose() {
    _subscription?.cancel();
    _premiumController.close();
  }
}