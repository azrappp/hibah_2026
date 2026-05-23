import 'package:flutter/material.dart';
import 'package:hibah_2026/pages/screening_page.dart';
import 'package:hibah_2026/pages/meal_recommendation_page.dart';
import 'package:provider/provider.dart';
import 'package:hibah_2026/pages/screening_monitoring_page.dart';
import 'package:hibah_2026/main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hibah_2026/app_session.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const Color primaryPurple = Color(0xFF5E4AA0);
  static const Color cardPurple = Color(0xFFF0EAF5);
  static const Color textDark = Color(0xFF202124);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? homeData;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadLatestScreening();
    });
  }

  Future<void> loadLatestScreening() async {
    final session = context.read<AppSession>();

    if (!session.hasClient || session.clientId == null) {
      openScreeningPage();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:3000/api/clients/${session.clientId}/latest-screening',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;

      if (response.statusCode == 404) {
        openScreeningPage();
        return;
      }

      if (response.statusCode != 200) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load screening history';
        });

        debugPrint(
          'Failed load screening history: ${response.statusCode} ${response.body}',
        );
        return;
      }

      final body = jsonDecode(response.body);

      setState(() {
        homeData = body['data'];
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Cannot connect to server';
      });

      debugPrint('Exception loadLatestScreening: $e');
    }
  }

  void openScreeningPage() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => FlowController(),
          child: ScreeningPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: loadLatestScreening,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final clientName = homeData?['fullName']?.toString() ?? 'User';
    final latestScreening = homeData?['latestScreening'];

    final int? latestScreeningId = latestScreening?['screeningId'] is int
        ? latestScreening['screeningId']
        : int.tryParse(latestScreening?['screeningId']?.toString() ?? '');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadLatestScreening,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $clientName 👋',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: HomePage.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Selamat datang kembali. Pantau kesehatan dan rekomendasi menu Anda dengan mudah.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: HomePage.cardPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      tooltip: 'Ganti Pengguna',
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('Ganti Pengguna?'),
                              content: const Text(
                                'Data sesi pengguna saat ini akan dihapus dari aplikasi ini. '
                                'Apakah Anda yakin ingin melanjutkan?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, false);
                                  },
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, true);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: HomePage.primaryPurple,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Ya, Ganti'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmed != true) return;

                        final session = context.read<AppSession>();

                        await session.clear();

                        if (!context.mounted) return;

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider(
                              create: (_) => FlowController(),
                              child: ScreeningPage(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: HomePage.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              HomeActionCard(
                title: 'Rekomendasi Menu',
                subtitle: 'Lihat rekomendasi menu harian dan mingguan',
                onTap: () {
                  if (!session.hasClient || latestScreeningId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Silakan lakukan screening terlebih dahulu.',
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MealRecommendationPage(
                        clientId: session.clientId!,
                        screeningId: latestScreeningId.toString(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              HomeActionCard(
                title: 'Monitoring Kesehatan',
                subtitle: 'Pantau hasil screening dan grafik kesehatan',
                onTap: () {
                  if (!session.hasClient) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Silakan lakukan screening terlebih dahulu.',
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ScreeningMonitoringPage(clientId: session.clientId!),
                    ),
                  );
                },
              ),
              const SizedBox(height: 26),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Screening Terakhir',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: HomePage.textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (!session.hasClient || session.clientId == null) {
                        openScreeningPage();
                        return;
                      }

                      startRepeatScreening(
                        context: context,
                        clientId: session.clientId!.toString(),
                      );
                    },
                    child: const Text(
                      'Perbarui',
                      style: TextStyle(
                        color: HomePage.primaryPurple,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              ScreeningSummaryGrid(latestScreening: latestScreening),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeActionCard extends StatelessWidget {
  const HomeActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  static const Color primaryPurple = Color(0xFF5E4AA0);
  static const Color cardPurple = Color(0xFFF0EAF5);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardPurple,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 108,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: primaryPurple,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.35),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.black87,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScreeningSummaryGrid extends StatelessWidget {
  const ScreeningSummaryGrid({super.key, required this.latestScreening});

  final Map<String, dynamic>? latestScreening;

  String valueFrom(
    Map<String, dynamic>? map,
    List<String> keys, {
    String fallback = '-',
  }) {
    if (map == null) return fallback;

    for (final key in keys) {
      final value = map[key];
      if (value != null) {
        return value.toString();
      }
    }

    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final anthropometry =
        latestScreening?['anthropometryAssessment'] as Map<String, dynamic>?;

    final clinical =
        latestScreening?['clinicalAssessment'] as Map<String, dynamic>?;

    final biochemical =
        latestScreening?['biochemicalAssessment'] as Map<String, dynamic>?;

    final physicalActivity =
        latestScreening?['physicalActivityAssessment'] as Map<String, dynamic>?;

    final energy =
        latestScreening?['energyRequirement'] as Map<String, dynamic>?;

    final calorie = valueFrom(energy, [
      'dailyEnergyKcal',
      'eerKcal',
      'energyKcal',
      'totalEnergyKcal',
      'calorieNeed',
    ]);

    final height = valueFrom(anthropometry, [
      'heightCm',
      'height',
      'bodyHeightCm',
    ]);

    final weight = valueFrom(anthropometry, [
      'weightKg',
      'weight',
      'bodyWeightKg',
    ]);

    final bmi = valueFrom(anthropometry, ['bmi', 'imt']);

    final bmiStatus = valueFrom(anthropometry, [
      'bmiStatus',
      'imtStatus',
      'nutritionStatus',
    ]);

    final waist = valueFrom(anthropometry, [
      'waistCircumferenceCm',
      'waistCm',
      'abdominalCircumferenceCm',
    ]);

    final activity = valueFrom(physicalActivity, [
      'activityLevel',
      'physicalActivityLevel',
      'category',
    ]);

    final bloodPressure = valueFrom(clinical, [
      'bloodPressure',
      'bloodPressureMmHg',
      'systolicDiastolic',
    ]);

    final hypertensionStatus = valueFrom(clinical, [
      'hypertensionStatus',
      'bloodPressureStatus',
      'status',
    ]);

    final bloodSugar = valueFrom(biochemical, [
      'bloodSugar',
      'bloodSugarMgDl',
      'glucoseMgDl',
      'fastingBloodSugar',
    ]);

    final diabetesStatus = valueFrom(biochemical, [
      'diabetesStatus',
      'bloodSugarStatus',
      'glucoseStatus',
      'status',
    ]);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: LargeMetricCard(
                title: 'Kebutuhan Kalori',
                value: calorie,
                unit: 'kkal',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SmallMetricCard(
                title: 'Tinggi\nBadan',
                value: height == '-' ? '-' : '$height cm',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SmallMetricCard(
                title: 'Berat\nBadan',
                value: weight == '-' ? '-' : '$weight Kg',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: LargeMetricCard(title: 'IMT', value: bmi, unit: bmiStatus),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SmallMetricCard(
                title: 'Lingkar\nPerut',
                value: waist == '-' ? '-' : '$waist cm',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SmallMetricCard(
                title: 'Aktivitas\nFisik',
                value: activity,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatusMetricCard(
                title: 'Hipertensi',
                value: bloodPressure,
                status: hypertensionStatus,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatusMetricCard(
                title: 'Diabetes Melitus',
                value: bloodSugar == '-' ? '-' : '$bloodSugar mg/dl',
                status: diabetesStatus,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class LargeMetricCard extends StatelessWidget {
  const LargeMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
  });

  final String title;
  final String value;
  final String unit;

  static const Color primaryPurple = Color(0xFF5E4AA0);
  static const Color cardPurple = Color(0xFFF0EAF5);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      decoration: BoxDecoration(
        color: cardPurple,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: primaryPurple,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: primaryPurple,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              color: primaryPurple,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class SmallMetricCard extends StatelessWidget {
  const SmallMetricCard({super.key, required this.title, required this.value});

  final String title;
  final String value;

  static const Color cardPurple = Color(0xFFF0EAF5);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      decoration: BoxDecoration(
        color: cardPurple,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusMetricCard extends StatelessWidget {
  const StatusMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.status,
  });

  final String title;
  final String value;
  final String status;

  static const Color primaryPurple = Color(0xFF5E4AA0);
  static const Color cardPurple = Color(0xFFF0EAF5);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 158,
      decoration: BoxDecoration(
        color: cardPurple,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: primaryPurple,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Center(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Spacer(),
          Text(
            status,
            style: const TextStyle(
              color: primaryPurple,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> startRepeatScreening({
  required BuildContext context,
  required String clientId,
}) async {
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/screening/$clientId/new-screening'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      debugPrint(
        'Failed new screening: ${response.statusCode} ${response.body}',
      );
      return;
    }

    final body = jsonDecode(response.body);
    final screeningId = body['data']['screeningId'].toString();

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => FlowController(
            clientId: clientId,
            screeningId: screeningId,
            isRepeatScreening: true,
          ),
          child: ScreeningPage(),
        ),
      ),
    );
  } catch (e) {
    debugPrint('Exception startRepeatScreening: $e');
  }
}
