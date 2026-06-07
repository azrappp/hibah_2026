class MenuDaySummary {
  MenuDaySummary({
    required this.menuDayId,
    required this.dayNumber,
    required this.menuDate,
    required this.energyKcal,
    required this.proteinG,
    required this.fatG,
    required this.carbG,
    required this.sodiumMg,
    required this.fiberG,
    required this.dietType,
    required this.targetEnergyKcal,
    required this.menuRecommendationId,
  });

  final int menuDayId;
  final int dayNumber;
  final DateTime menuDate;

  final double energyKcal;
  final double proteinG;
  final double fatG;
  final double carbG;
  final double sodiumMg;
  final double fiberG;

  final String dietType;
  final double targetEnergyKcal;
  final int menuRecommendationId;

  factory MenuDaySummary.fromJson(Map<String, dynamic> json) {
    final recommendation = json['menuRecommendation'];

    return MenuDaySummary(
      menuDayId: json['menuDayId'],
      dayNumber: json['dayNumber'],
      menuDate: DateTime.parse(json['menuDate']).toLocal(),
      energyKcal: toDouble(json['energyKcal']),
      proteinG: toDouble(json['proteinG']),
      fatG: toDouble(json['fatG']),
      carbG: toDouble(json['carbG']),
      sodiumMg: toDouble(json['sodiumMg']),
      fiberG: toDouble(json['fiberG']),
      dietType: recommendation?['dietType']?.toString() ?? '-',
      targetEnergyKcal: toDouble(recommendation?['targetEnergyKcal']),
      menuRecommendationId: recommendation?['menuRecommendationId'] ?? 0,
    );
  }

  static double toDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }
}
