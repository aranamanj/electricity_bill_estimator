class ElectricityCalculator {
  // Tiered tariff: sen/kWh → RM/kWh (divide by 100)
  static const double _rate1 = 0.218; // 1–200 kWh
  static const double _rate2 = 0.334; // 201–300 kWh
  static const double _rate3 = 0.516; // 301–600 kWh
  static const double _rate4 = 0.546; // 601–1000 kWh

  static double calculateTotalCharges(double units) {
    if (units <= 0) return 0.0;
    double total = 0.0;

    if (units <= 200) {
      total = units * _rate1;
    } else if (units <= 300) {
      total = (200 * _rate1) + ((units - 200) * _rate2);
    } else if (units <= 600) {
      total = (200 * _rate1) + (100 * _rate2) + ((units - 300) * _rate3);
    } else {
      total = (200 * _rate1) +
          (100 * _rate2) +
          (300 * _rate3) +
          ((units - 600) * _rate4);
    }
    return double.parse(total.toStringAsFixed(3));
  }

  static double calculateFinalCost(double totalCharges, double rebatePercent) {
    final discount = totalCharges * (rebatePercent / 100);
    return double.parse((totalCharges - discount).toStringAsFixed(3));
  }
}