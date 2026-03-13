import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/core/constants/app_constants.dart';

class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final StreamController<bool> _premiumController =
      StreamController<bool>.broadcast();

  Stream<bool> get premiumStream => _premiumController.stream;

  static const _keyIsPremium = 'isPremium';

  /// In-memory flag — always in sync with SharedPreferences and the stream.
  /// Read this synchronously anywhere you need an instant answer without
  /// waiting for the cubit to rebuild (e.g. the save button in the bottom
  /// sheet). This prevents the "you already own this item" error caused by
  /// the cubit state not having rebuilt by the time the user presses save.
  bool _isPremium = false;
  bool get isPremium => _isPremium;

  PurchaseService() {
    _init();
  }

  Future<void> _init() async {
    // Step 1: Subscribe to purchaseStream FIRST so no events are ever missed,
    // including purchases that were interrupted mid-flow in a previous session.
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (error) {
        debugPrint('PurchaseService: purchaseStream error: $error');
        _premiumController.addError(error);
      },
    );

    // Step 2: Load cached premium state into the in-memory flag immediately,
    // and emit to the stream so the UI is correct on launch without waiting
    // for any network/Play Store call.
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyIsPremium) ?? false) {
      _isPremium = true;
      _premiumController.add(true);
      // Still run restore below to keep the cache in sync with Play Store
      // (e.g. handles edge cases like refunds).
    }

    // Step 3: Dual restore strategy for reliability.
    // - queryPastPurchases: directly queries Google Play's billing cache for
    //   currently owned products. Most reliable for the reinstall case.
    // - restorePurchases: fallback that emits via purchaseStream.
    await _restoreFromPlayStore();
  }

  /// Public entry point for manual restore (e.g. triggered from settings).
  Future<void> restoreFromPlayStore() => _restoreFromPlayStore();

  /// Queries Google Play directly for currently owned purchases.
  /// This is the most reliable restore path on Android.
  Future<void> _restoreFromPlayStore() async {
    try {
      final InAppPurchaseAndroidPlatformAddition androidAddition = _iap
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

      final QueryPurchaseDetailsResponse response =
          await androidAddition.queryPastPurchases();

      if (response.error != null) {
        debugPrint(
            'PurchaseService: queryPastPurchases error: ${response.error?.message}');
        // Try the fallback — if that also fails, the user will see an error.
        await _fallbackRestore();
        return;
      }

      if (response.pastPurchases.isEmpty) {
        // No purchases found in Play Store — user may not have bought yet,
        // or this is a fresh install with no prior purchase on this account.
        // Do NOT clear the cache here in case of a temporary Play Store issue.
        debugPrint('PurchaseService: no past purchases found');
        return;
      }

      for (final purchase in response.pastPurchases) {
        await _handlePurchase(purchase);
      }
    } catch (e) {
      debugPrint('PurchaseService: _restoreFromPlayStore failed: $e');
      // Try the fallback — if that also fails, the user will see an error.
      await _fallbackRestore();
    }
  }

  /// Fallback restore using the standard plugin API.
  /// Results are emitted on purchaseStream as PurchaseStatus.restored.
  Future<void> _fallbackRestore() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('PurchaseService: fallbackRestore failed: $e');
      // Surface to the user — cubit will emit an error state from this.
      _premiumController.addError(
        'Could not restore purchases. Please check your connection and try again.',
      );
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
        'Ensure it is Active in Google Play Console.',
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
        // Complete the purchase only AFTER granting entitlement.
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
    }

    if (purchase.status == PurchaseStatus.error) {
      debugPrint(
          'PurchaseService: purchase error: ${purchase.error?.message}');
      _premiumController.addError(
        purchase.error?.message ?? 'Unknown purchase error',
      );
    }

    // Pending = awaiting external payment confirmation (e.g. cash kiosk).
    // Acknowledge so the store doesn't re-deliver, but don't grant yet.
    if (purchase.status == PurchaseStatus.pending) {
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  /// Persists premium to SharedPreferences, sets the in-memory flag,
  /// and emits to all stream listeners.
  Future<void> _grantPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, true);
    _isPremium = true;
    _premiumController.add(true);
  }

  /// Client-side verification: confirms the product ID is correct.
  /// Sufficient for a small app. Replace with server-side verification
  /// if revenue justifies the added complexity.
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    return purchase.productID == AppConstants.premiumProductId;
  }

  void dispose() {
    _subscription?.cancel();
    _premiumController.close();
  }
}