class ScreeningSummary {
  ScreeningSummary({
    required this.screeningId,
    required this.clientId,
    required this.screeningStatus,
    required this.createdAt,
    this.diabetesStatus,
    this.hypertensionStatus,
    this.obesityStatus,
    this.finalScreeningCategory,
    this.referralRequired = false,
    this.referralReason,
    this.screeningSummary,
  });

  final int screeningId;
  final int clientId;
  final String screeningStatus;
  final DateTime createdAt;

  final String? diabetesStatus;
  final String? hypertensionStatus;
  final String? obesityStatus;
  final String? finalScreeningCategory;
  final bool referralRequired;
  final String? referralReason;
  final String? screeningSummary;

  factory ScreeningSummary.fromJson(Map<String, dynamic> json) {
    final result = json['screeningResult'];

    return ScreeningSummary(
      screeningId: json['screeningId'],
      clientId: json['clientId'],
      screeningStatus: json['screeningStatus']?.toString() ?? '-',
      createdAt: DateTime.parse(json['createdAt']),
      diabetesStatus: result?['diabetesStatus']?.toString(),
      hypertensionStatus: result?['hypertensionStatus']?.toString(),
      obesityStatus: result?['obesityStatus']?.toString(),
      finalScreeningCategory: result?['finalScreeningCategory']?.toString(),
      referralRequired: result?['referralRequired'] == true,
      referralReason: result?['referralReason']?.toString(),
      screeningSummary: result?['screeningSummary']?.toString(),
    );
  }
}
