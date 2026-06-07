class BillRecord {
  int? id;
  String month;
  double units;
  double rebatePercent;
  double totalCharges;
  double finalCost;

  BillRecord({
    this.id,
    required this.month,
    required this.units,
    required this.rebatePercent,
    required this.totalCharges,
    required this.finalCost,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'month': month,
        'units': units,
        'rebate_percent': rebatePercent,
        'total_charges': totalCharges,
        'final_cost': finalCost,
      };

  factory BillRecord.fromMap(Map<String, dynamic> map) => BillRecord(
        id: map['id'] as int?,
        month: map['month'] as String,
        units: (map['units'] as num).toDouble(),
        rebatePercent: (map['rebate_percent'] as num).toDouble(),
        totalCharges: (map['total_charges'] as num).toDouble(),
        finalCost: (map['final_cost'] as num).toDouble(),
      );
}