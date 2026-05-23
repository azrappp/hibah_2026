class ClientScreeningHistory {
  ClientScreeningHistory({
    required this.client,
    required this.totalScreenings,
    required this.chartData,
    required this.history,
  });

  final ClientInfo client;
  final int totalScreenings;
  final List<ScreeningChartData> chartData;
  final List<ScreeningHistoryItem> history;

  factory ClientScreeningHistory.fromJson(Map<String, dynamic> json) {
    return ClientScreeningHistory(
      client: ClientInfo.fromJson(json['client']),
      totalScreenings: json['totalScreenings'] ?? 0,
      chartData: (json['chartData'] as List<dynamic>? ?? [])
          .map((item) => ScreeningChartData.fromJson(item))
          .toList(),
      history: (json['history'] as List<dynamic>? ?? [])
          .map((item) => ScreeningHistoryItem.fromJson(item))
          .toList(),
    );
  }
}

class ClientInfo {
  ClientInfo({
    required this.clientId,
    required this.fullName,
    required this.age,
    required this.gender,
    this.occupation,
  });

  final int clientId;
  final String fullName;
  final int age;
  final String gender;
  final String? occupation;

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      clientId: json['clientId'],
      fullName: json['fullName'] ?? '-',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '-',
      occupation: json['occupation'],
    );
  }
}

class ScreeningChartData {
  ScreeningChartData({
    required this.screeningDate,
    this.weightKg,
    this.bmi,
    this.waistCircumferenceCm,
    this.fastingGlucoseMgDl,
    this.postprandialGlucoseMgDl,
    this.randomGlucoseMgDl,
    this.hba1cPercent,
    this.systolicBp,
    this.diastolicBp,
  });

  final String screeningDate;
  final double? weightKg;
  final double? bmi;
  final double? waistCircumferenceCm;
  final double? fastingGlucoseMgDl;
  final double? postprandialGlucoseMgDl;
  final double? randomGlucoseMgDl;
  final double? hba1cPercent;
  final double? systolicBp;
  final double? diastolicBp;

  factory ScreeningChartData.fromJson(Map<String, dynamic> json) {
    return ScreeningChartData(
      screeningDate: json['screeningDate'] ?? '-',
      weightKg: toNullableDouble(json['weightKg']),
      bmi: toNullableDouble(json['bmi']),
      waistCircumferenceCm: toNullableDouble(json['waistCircumferenceCm']),
      fastingGlucoseMgDl: toNullableDouble(json['fastingGlucoseMgDl']),
      postprandialGlucoseMgDl: toNullableDouble(
        json['postprandialGlucoseMgDl'],
      ),
      randomGlucoseMgDl: toNullableDouble(json['randomGlucoseMgDl']),
      hba1cPercent: toNullableDouble(json['hba1cPercent']),
      systolicBp: toNullableDouble(json['systolicBp']),
      diastolicBp: toNullableDouble(json['diastolicBp']),
    );
  }
}

class ScreeningHistoryItem {
  ScreeningHistoryItem({
    required this.screeningId,
    required this.screeningDate,
    required this.screeningStatus,
  });

  final int screeningId;
  final String screeningDate;
  final String screeningStatus;

  factory ScreeningHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScreeningHistoryItem(
      screeningId: json['screeningId'],
      screeningDate: json['screeningDate'] ?? '-',
      screeningStatus: json['screeningStatus'] ?? '-',
    );
  }
}

double? toNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value);
  return null;
}
