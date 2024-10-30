class Prescription {
  Prescription({
    this.totalQuantity,
    this.remainingQuantity,
    this.thresholdQuantity,
    this.refillDates = const [],
    this.isRefillReminder = true,
  });

  int? totalQuantity;
  int? remainingQuantity;
  int? thresholdQuantity;
  List<DateTime>? refillDates;
  bool isRefillReminder;
}
