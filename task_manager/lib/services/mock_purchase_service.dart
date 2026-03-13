// // mock_purchase_service.dart
// import 'dart:async';
// import 'package:task_manager/services/purchase_service.dart';

// class MockPurchaseService implements PurchaseService {
//   final StreamController<bool> _premiumController =
//       StreamController<bool>.broadcast();

//   @override
//   Stream<bool> get premiumStream => _premiumController.stream;

//   @override
//   Future<void> buyPremium() async {
//     // Simulate a short delay like a real purchase
//     await Future.delayed(const Duration(seconds: 2));
//     _premiumController.add(true);
//   }

//   @override
//   Future<void> restorePurchases() async {
//     // No-op in mock
//   }

//   @override
//   void dispose() {
//     _premiumController.close();
//   }
// }