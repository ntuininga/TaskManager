import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/presentation/bloc/purchase_cubit/purchase_state.dart';
import 'package:task_manager/services/purchase_service.dart';

class PurchaseCubit extends Cubit<PurchaseState> {
  final PurchaseService _purchaseService;
  StreamSubscription<bool>? _sub;

  PurchaseCubit(this._purchaseService) : super(PurchaseState.initial()) {
    _listen();
  }

  void _listen() {
    _sub = _purchaseService.premiumStream.listen(
      (isPremium) {
        emit(state.copyWith(
          status: isPremium
              ? PurchaseStatusState.premium
              : PurchaseStatusState.initial,
          error: null,
        ));
      },
      onError: (e) {
        // Only emit error if we're not already premium — a restore failure
        // should not downgrade a user who is already confirmed premium.
        if (state.status != PurchaseStatusState.premium) {
          emit(state.copyWith(
            status: PurchaseStatusState.error,
            error: e.toString(),
          ));
        }
      },
    );
  }

  Future<void> buyPremium() async {
    emit(state.copyWith(status: PurchaseStatusState.loading, error: null));
    try {
      await _purchaseService.buyPremium();
      // Do NOT emit premium here — wait for purchaseStream to confirm.
      // If the user cancels the Play Store sheet, the stream simply stays
      // silent and we reset back to initial below.
    } catch (e) {
      emit(state.copyWith(
        status: PurchaseStatusState.error,
        error: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}