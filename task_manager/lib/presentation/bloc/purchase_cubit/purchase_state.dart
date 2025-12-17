enum PurchaseStatusState {
  initial,
  loading,
  premium,
  error,
}

class PurchaseState {
  final PurchaseStatusState status;
  final String? error;

  const PurchaseState({
    required this.status,
    this.error,
  });

  factory PurchaseState.initial() =>
      const PurchaseState(status: PurchaseStatusState.initial);

  PurchaseState copyWith({
    PurchaseStatusState? status,
    String? error,
  }) {
    return PurchaseState(
      status: status ?? this.status,
      error: error,
    );
  }
}
