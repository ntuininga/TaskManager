import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/presentation/bloc/purchase_cubit/purchase_state.dart';
import 'package:task_manager/services/purchase_service.dart';

class PurchaseCubit extends Cubit<PurchaseState> {
  final PurchaseService _purchaseService;
  StreamSubscription<bool>? _sub;

  PurchaseCubit(this._purchaseService)
      : super(PurchaseState.initial()) {
    _listen();
  }

  void _listen() {
    _sub = _purchaseService.premiumStream.listen((isPremium) {
      emit(
        state.copyWith(
          status: isPremium
              ? PurchaseStatusState.premium
              : PurchaseStatusState.initial,
        ),
      );
    });
  }

  Future<void> buyPremium() async {
    emit(state.copyWith(status: PurchaseStatusState.loading));
    try {
      await _purchaseService.buyPremium();
    } catch (e) {
      emit(
        state.copyWith(
          status: PurchaseStatusState.error,
          error: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
