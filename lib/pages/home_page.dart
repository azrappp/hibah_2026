import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hibah_2026/app_session.dart';
import 'package:hibah_2026/config/app_config.dart';
import 'package:hibah_2026/main.dart';
import 'package:hibah_2026/pages/screening_page.dart';
import 'package:hibah_2026/pages/meal_recommendation_page.dart';
import 'package:hibah_2026/pages/screening_monitoring_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/* -------------------------------------------------------------------------- */
/*                                  HOME PAGE                                 */
/* -------------------------------------------------------------------------- */

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  String? errorMessage;

  HomeApiData? homeData;
  MenuByDateData? menuData;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadHome();
    });
  }

  Future<void> loadHome() async {
    final session = context.read<AppSession>();

    if (!session.hasClient || session.clientId == null) {
      openScreeningPage();
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final latestScreeningResponse = await http.get(
        AppConfig.apiUri('/api/clients/${session.clientId}/latest-screening'),
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;

      if (latestScreeningResponse.statusCode == 404) {
        openScreeningPage();
        return;
      }

      if (latestScreeningResponse.statusCode != 200) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load latest screening';
        });

        debugPrint(
          'Failed latest screening: '
          '${latestScreeningResponse.statusCode} ${latestScreeningResponse.body}',
        );
        return;
      }

      final latestBody = jsonDecode(latestScreeningResponse.body);
      final loadedHomeData = HomeApiData.fromJson(latestBody['data']);

      final selectedDate = todayString();

      MenuByDateData? loadedMenuData;

      try {
        final menuResponse = await http.get(
          AppConfig.apiUri(
            '/api/meal/clients/${session.clientId}/menu-by-date?date=$selectedDate',
          ),
          headers: {'Content-Type': 'application/json'},
        );

        if (menuResponse.statusCode == 200) {
          final menuBody = jsonDecode(menuResponse.body);
          loadedMenuData = MenuByDateData.fromJson(menuBody['data']);
        } else {
          debugPrint(
            'Menu by date not loaded: ${menuResponse.statusCode} ${menuResponse.body}',
          );
        }
      } catch (e) {
        debugPrint('Exception load menu by date: $e');
      }

      if (!mounted) return;

      setState(() {
        homeData = loadedHomeData;
        menuData = loadedMenuData;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Cannot connect to server';
      });

      debugPrint('Exception loadHome: $e');
    }
  }

  String todayString() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  void openScreeningPage() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => FlowController(),
          child: const ScreeningPage(),
        ),
      ),
    );
  }

  void openMealRecommendationPage() {
    final session = context.read<AppSession>();
    final screeningId = homeData?.latestScreening.screeningId;

    if (!session.hasClient || session.clientId == null || screeningId == null) {
      showNeedScreeningMessage();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealRecommendationPage(
          clientId: session.clientId!,
          screeningId: screeningId.toString(),
        ),
      ),
    );
  }

  void openMonitoringPage() {
    final session = context.read<AppSession>();

    if (!session.hasClient || session.clientId == null) {
      showNeedScreeningMessage();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScreeningMonitoringPage(clientId: session.clientId!),
      ),
    );
  }

  void showNeedScreeningMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Silakan lakukan screening terlebih dahulu.'),
      ),
    );
  }

  Future<void> logoutAndChangeUser() async {
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Ya, Ganti'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (confirmed != true) return;

    final session = context.read<AppSession>();
    await session.clear();

    if (!mounted) return;
    openScreeningPage();
  }

  Future<void> startRepeatScreeningFromHome() async {
    final session = context.read<AppSession>();

    if (!session.hasClient || session.clientId == null) {
      openScreeningPage();
      return;
    }

    await startRepeatScreening(
      context: context,
      clientId: session.clientId!.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.green)),
      );
    }

    if (errorMessage != null) {
      return ErrorHomeView(message: errorMessage!, onRetry: loadHome);
    }

    final data = homeData;

    if (data == null) {
      return ErrorHomeView(message: 'Home data is empty', onRetry: loadHome);
    }

    final viewData = HomeViewData.fromApi(home: data, menu: menuData);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadHome,
          color: AppColors.green,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            children: [
              HomeHeader(data: viewData, onLogoutTap: logoutAndChangeUser),

              const SizedBox(height: 22),

              const Text(
                'Beranda',
                style: TextStyle(
                  fontSize: 18,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 20),

              CalorieOverviewCard(data: viewData),

              const SizedBox(height: 28),

              SectionHeader(
                title: 'Monitor Kesehatan',
                actionText: 'Perbarui',
                onActionTap: startRepeatScreeningFromHome,
              ),

              const SizedBox(height: 14),

              HealthMonitorCard(onTap: openMonitoringPage),

              const SizedBox(height: 18),

              HealthMetricRow(data: viewData),

              const SizedBox(height: 30),

              SectionHeader(
                title: 'Menu Hari ini',
                actionText: 'Detail',
                onActionTap: openMealRecommendationPage,
              ),

              const SizedBox(height: 14),

              if (viewData.meals.isEmpty)
                EmptyMealCard(onTap: openMealRecommendationPage)
              else
                MealList(
                  meals: viewData.meals,
                  onMealTap: openMealRecommendationPage,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                  API MODEL                                 */
/* -------------------------------------------------------------------------- */

class HomeApiData {
  const HomeApiData({
    required this.clientId,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.latestScreening,
  });

  final int clientId;
  final String fullName;
  final int? age;
  final String? gender;
  final LatestScreening latestScreening;

  factory HomeApiData.fromJson(Map<String, dynamic> json) {
    return HomeApiData(
      clientId: parseInt(json['clientId']) ?? 0,
      fullName: json['fullName']?.toString() ?? 'User',
      age: parseInt(json['age']),
      gender: json['gender']?.toString(),
      latestScreening: LatestScreening.fromJson(
        json['latestScreening'] ?? <String, dynamic>{},
      ),
    );
  }
}

class LatestScreening {
  const LatestScreening({
    required this.screeningId,
    required this.anthropometry,
    required this.biochemical,
    required this.clinical,
    required this.physicalActivity,
    required this.screeningResult,
    required this.energyRequirement,
  });

  final int? screeningId;
  final AnthropometryData? anthropometry;
  final BiochemicalData? biochemical;
  final ClinicalData? clinical;
  final PhysicalActivityData? physicalActivity;
  final ScreeningResultData? screeningResult;
  final EnergyRequirementData? energyRequirement;

  factory LatestScreening.fromJson(Map<String, dynamic> json) {
    return LatestScreening(
      screeningId: parseInt(json['screeningId']),
      anthropometry: json['anthropometryAssessment'] == null
          ? null
          : AnthropometryData.fromJson(json['anthropometryAssessment']),
      biochemical: json['biochemicalAssessment'] == null
          ? null
          : BiochemicalData.fromJson(json['biochemicalAssessment']),
      clinical: json['clinicalAssessment'] == null
          ? null
          : ClinicalData.fromJson(json['clinicalAssessment']),
      physicalActivity: json['physicalActivityAssessment'] == null
          ? null
          : PhysicalActivityData.fromJson(json['physicalActivityAssessment']),
      screeningResult: json['screeningResult'] == null
          ? null
          : ScreeningResultData.fromJson(json['screeningResult']),
      energyRequirement: json['energyRequirement'] == null
          ? null
          : EnergyRequirementData.fromJson(json['energyRequirement']),
    );
  }
}

class AnthropometryData {
  const AnthropometryData({
    required this.weightKg,
    required this.heightCm,
    required this.bmi,
    required this.waistCircumferenceCm,
    required this.bmiStatus,
    required this.waistStatus,
  });

  final double? weightKg;
  final double? heightCm;
  final double? bmi;
  final double? waistCircumferenceCm;
  final String? bmiStatus;
  final String? waistStatus;

  factory AnthropometryData.fromJson(Map<String, dynamic> json) {
    return AnthropometryData(
      weightKg: parseDouble(json['weightKg']),
      heightCm: parseDouble(json['heightCm']),
      bmi: parseDouble(json['bmi']),
      waistCircumferenceCm: parseDouble(json['waistCircumferenceCm']),
      bmiStatus: json['bmiStatus']?.toString(),
      waistStatus: json['waistStatus']?.toString(),
    );
  }
}

class BiochemicalData {
  const BiochemicalData({
    required this.fastingGlucoseMgDl,
    required this.randomGlucoseMgDl,
    required this.glucoseStatus,
  });

  final double? fastingGlucoseMgDl;
  final double? randomGlucoseMgDl;
  final String? glucoseStatus;

  factory BiochemicalData.fromJson(Map<String, dynamic> json) {
    return BiochemicalData(
      fastingGlucoseMgDl: parseDouble(json['fastingGlucoseMgDl']),
      randomGlucoseMgDl: parseDouble(json['randomGlucoseMgDl']),
      glucoseStatus: json['glucoseStatus']?.toString(),
    );
  }
}

class ClinicalData {
  const ClinicalData({
    required this.systolicBp,
    required this.diastolicBp,
    required this.bloodPressureStatus,
  });

  final int? systolicBp;
  final int? diastolicBp;
  final String? bloodPressureStatus;

  factory ClinicalData.fromJson(Map<String, dynamic> json) {
    return ClinicalData(
      systolicBp: parseInt(json['systolicBp']),
      diastolicBp: parseInt(json['diastolicBp']),
      bloodPressureStatus: json['bloodPressureStatus']?.toString(),
    );
  }

  String get bloodPressureText {
    if (systolicBp == null || diastolicBp == null) return '-';
    return '$systolicBp/$diastolicBp';
  }
}

class PhysicalActivityData {
  const PhysicalActivityData({required this.activityLevel});

  final String? activityLevel;

  factory PhysicalActivityData.fromJson(Map<String, dynamic> json) {
    return PhysicalActivityData(
      activityLevel: json['activityLevel']?.toString(),
    );
  }
}

class ScreeningResultData {
  const ScreeningResultData({
    required this.diabetesStatus,
    required this.hypertensionStatus,
    required this.obesityStatus,
  });

  final String? diabetesStatus;
  final String? hypertensionStatus;
  final String? obesityStatus;

  factory ScreeningResultData.fromJson(Map<String, dynamic> json) {
    return ScreeningResultData(
      diabetesStatus: json['diabetesStatus']?.toString(),
      hypertensionStatus: json['hypertensionStatus']?.toString(),
      obesityStatus: json['obesityStatus']?.toString(),
    );
  }
}

class EnergyRequirementData {
  const EnergyRequirementData({
    required this.dailyEnergyKcal,
    required this.carbohydrateGram,
    required this.fatGram,
    required this.proteinGram,
  });

  final double? dailyEnergyKcal;
  final double? carbohydrateGram;
  final double? fatGram;
  final double? proteinGram;

  factory EnergyRequirementData.fromJson(Map<String, dynamic> json) {
    return EnergyRequirementData(
      dailyEnergyKcal: parseDouble(json['dailyEnergyKcal']),
      carbohydrateGram: parseDouble(json['carbohydrateGram']),
      fatGram: parseDouble(json['fatGram']),
      proteinGram: parseDouble(json['proteinGram']),
    );
  }
}

class MenuByDateData {
  const MenuByDateData({
    required this.screeningId,
    required this.targetEnergyKcal,
    required this.targetCarbohydrateG,
    required this.targetProteinG,
    required this.targetFatG,
    required this.day,
  });

  final int? screeningId;
  final double? targetEnergyKcal;
  final double? targetCarbohydrateG;
  final double? targetProteinG;
  final double? targetFatG;
  final MenuDayData? day;

  factory MenuByDateData.fromJson(Map<String, dynamic> json) {
    return MenuByDateData(
      screeningId: parseInt(json['screeningId']),
      targetEnergyKcal: parseDouble(json['targetEnergyKcal']),
      targetCarbohydrateG: parseDouble(json['targetCarbohydrateG']),
      targetProteinG: parseDouble(json['targetProteinG']),
      targetFatG: parseDouble(json['targetFatG']),
      day: json['day'] == null ? null : MenuDayData.fromJson(json['day']),
    );
  }
}

class MenuDayData {
  const MenuDayData({required this.summary, required this.meals});

  final MenuSummaryData? summary;
  final List<MenuMealData> meals;

  factory MenuDayData.fromJson(Map<String, dynamic> json) {
    final rawMeals = json['meals'];

    return MenuDayData(
      summary: json['summary'] == null
          ? null
          : MenuSummaryData.fromJson(json['summary']),
      meals: rawMeals is List
          ? rawMeals.map((item) => MenuMealData.fromJson(item)).toList()
          : <MenuMealData>[],
    );
  }
}

class MenuSummaryData {
  const MenuSummaryData({
    required this.energyKcal,
    required this.proteinG,
    required this.fatG,
    required this.carbG,
    required this.sodiumMg,
    required this.fiberG,
  });

  final double? energyKcal;
  final double? proteinG;
  final double? fatG;
  final double? carbG;
  final double? sodiumMg;
  final double? fiberG;

  factory MenuSummaryData.fromJson(Map<String, dynamic> json) {
    return MenuSummaryData(
      energyKcal: parseDouble(json['energyKcal']),
      proteinG: parseDouble(json['proteinG']),
      fatG: parseDouble(json['fatG']),
      carbG: parseDouble(json['carbG']),
      sodiumMg: parseDouble(json['sodiumMg']),
      fiberG: parseDouble(json['fiberG']),
    );
  }
}

class MenuMealData {
  const MenuMealData({required this.mealTime, required this.items});

  final String mealTime;
  final List<MenuItemData> items;

  factory MenuMealData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return MenuMealData(
      mealTime: json['mealTime']?.toString() ?? '-',
      items: rawItems is List
          ? rawItems.map((item) => MenuItemData.fromJson(item)).toList()
          : <MenuItemData>[],
    );
  }
}

class MenuItemData {
  const MenuItemData({
    required this.foodName,
    required this.urt,
    required this.gram,
    required this.nutrition,
    required this.isEaten,
  });

  final String foodName;
  final String urt;
  final double? gram;
  final NutritionData? nutrition;
  final bool isEaten;

  factory MenuItemData.fromJson(Map<String, dynamic> json) {
    return MenuItemData(
      foodName: json['foodName']?.toString() ?? '-',
      urt: json['urt']?.toString() ?? '-',
      gram: parseDouble(json['gram']),
      nutrition: json['nutrition'] == null
          ? null
          : NutritionData.fromJson(json['nutrition']),
      isEaten: json['isEaten'] == true,
    );
  }
}

class NutritionData {
  const NutritionData({
    required this.energyKcal,
    required this.proteinG,
    required this.fatG,
    required this.carbG,
  });

  final double? energyKcal;
  final double? proteinG;
  final double? fatG;
  final double? carbG;

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      energyKcal: parseDouble(json['energyKcal']),
      proteinG: parseDouble(json['proteinG']),
      fatG: parseDouble(json['fatG']),
      carbG: parseDouble(json['carbG']),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                VIEW MAPPING                                */
/* -------------------------------------------------------------------------- */

class HomeViewData {
  const HomeViewData({
    required this.userName,
    required this.gender,
    required this.greeting,
    required this.streak,
    required this.targetCalories,
    required this.intakeCalories,
    required this.remainingCalories,
    required this.activityLevel,
    required this.weightKg,
    required this.bloodPressure,
    required this.bloodSugar,
    required this.meals,
    required this.macros,
  });

  final String userName;
  final String greeting;
  final int streak;
  final String? gender;
  final int targetCalories;
  final int intakeCalories;
  final int remainingCalories;
  final String activityLevel;

  final String weightKg;
  final String bloodPressure;
  final String bloodSugar;

  final List<MealSummary> meals;
  final List<MacroSummary> macros;

  double get calorieProgress {
    if (targetCalories <= 0) return 0;
    return (intakeCalories / targetCalories).clamp(0.0, 1.0);
  }

  static EatenNutritionSummary calculateEatenNutrition(
    List<MenuMealData> meals,
  ) {
    double energy = 0;
    double protein = 0;
    double fat = 0;
    double carb = 0;

    for (final meal in meals) {
      for (final item in meal.items) {
        if (!item.isEaten) continue;

        energy += item.nutrition?.energyKcal ?? 0;
        protein += item.nutrition?.proteinG ?? 0;
        fat += item.nutrition?.fatG ?? 0;
        carb += item.nutrition?.carbG ?? 0;
      }
    }

    return EatenNutritionSummary(
      energyKcal: energy,
      proteinG: protein,
      fatG: fat,
      carbG: carb,
    );
  }

  factory HomeViewData.fromApi({
    required HomeApiData home,
    required MenuByDateData? menu,
  }) {
    final latest = home.latestScreening;
    final energy = latest.energyRequirement;
    final anthropometry = latest.anthropometry;
    final clinical = latest.clinical;
    final biochemical = latest.biochemical;
    final physicalActivity = latest.physicalActivity;

    final targetEnergy = menu?.targetEnergyKcal ?? energy?.dailyEnergyKcal ?? 0;

    final eatenSummary = calculateEatenNutrition(menu?.day?.meals ?? []);

    final intakeEnergy = eatenSummary.energyKcal;
    final remaining = targetEnergy - intakeEnergy;

    final targetCarb =
        menu?.targetCarbohydrateG ?? energy?.carbohydrateGram ?? 0;
    final targetProtein = menu?.targetProteinG ?? energy?.proteinGram ?? 0;
    final targetFat = menu?.targetFatG ?? energy?.fatGram ?? 0;

    final currentCarb = eatenSummary.carbG;
    final currentProtein = eatenSummary.proteinG;
    final currentFat = eatenSummary.fatG;

    return HomeViewData(
      userName: home.fullName,
      gender: home.gender,
      greeting: getGreeting(),
      streak: 10,
      targetCalories: targetEnergy.round(),
      intakeCalories: intakeEnergy.round(),
      remainingCalories: remaining < 0 ? 0 : remaining.round(),
      activityLevel: normalizeActivity(physicalActivity?.activityLevel),
      weightKg: formatNumber(anthropometry?.weightKg),
      bloodPressure: clinical?.bloodPressureText ?? '-',
      bloodSugar: formatNumber(
        biochemical?.randomGlucoseMgDl ?? biochemical?.fastingGlucoseMgDl,
      ),
      meals: buildMealSummaries(menu?.day?.meals ?? []),
      macros: [
        MacroSummary(
          label: 'Lemak',
          current: currentFat.round(),
          target: targetFat.round(),
          color: const Color(0xFFEFA08C),
        ),
        MacroSummary(
          label: 'Karbohidrat',
          current: currentCarb.round(),
          target: targetCarb.round(),
          color: const Color(0xFFE9B95F),
        ),
        MacroSummary(
          label: 'Protein',
          current: currentProtein.round(),
          target: targetProtein.round(),
          color: const Color(0xFF72BFE2),
        ),
      ],
    );
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 11) return 'Selamat Pagi!';
    if (hour < 15) return 'Selamat Siang!';
    if (hour < 18) return 'Selamat Sore!';

    return 'Selamat Malam!';
  }

  static String normalizeActivity(String? value) {
    switch (value?.toLowerCase()) {
      case 'very_low':
      case 'verylow':
        return 'Sangat Rendah';
      case 'low':
        return 'Rendah';
      case 'moderate':
        return 'Sedang';
      case 'high':
        return 'Tinggi';
      case 'very_high':
      case 'veryhigh':
        return 'Sangat Tinggi';
      default:
        return value ?? '-';
    }
  }

  static List<MealSummary> buildMealSummaries(List<MenuMealData> apiMeals) {
    return apiMeals.map((meal) {
      final totalCalories = meal.items.fold<double>(
        0,
        (sum, item) => sum + (item.nutrition?.energyKcal ?? 0),
      );

      final foodNames = meal.items.map((item) => item.foodName).toList();

      final portions = meal.items.map((item) {
        final gram = item.gram == null ? '' : ' (${formatNumber(item.gram)} g)';
        return '${item.foodName} ${item.urt}$gram';
      }).toList();

      return MealSummary(
        title: mealTimeLabel(meal.mealTime),
        menuName: buildSimpleMenuName(foodNames),
        calories: totalCalories.round(),
        description: portions.join(', '),
      );
    }).toList();
  }

  static String mealTimeLabel(String value) {
    switch (value) {
      case 'breakfast':
        return 'Sarapan';
      case 'morning_snack':
        return 'Snack Pagi';
      case 'lunch':
        return 'Makan Siang';
      case 'afternoon_snack':
        return 'Snack Sore';
      case 'dinner':
        return 'Makan Malam';
      default:
        return value;
    }
  }

  static String buildSimpleMenuName(List<String> foodNames) {
    if (foodNames.isEmpty) return 'Menu belum tersedia';

    final cleanNames = foodNames.map((name) {
      return name
          .replaceAll(', segar', '')
          .replaceAll(', mentah', '')
          .replaceAll(', daging', '')
          .trim();
    }).toList();

    if (cleanNames.length <= 2) {
      return cleanNames.join(' dan ');
    }

    return cleanNames.take(3).join(', ');
  }
}

class MealSummary {
  const MealSummary({
    required this.title,
    required this.menuName,
    required this.calories,
    required this.description,
  });

  final String title;
  final String menuName;
  final int calories;
  final String description;
}

class MacroSummary {
  const MacroSummary({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
  });

  final String label;
  final int current;
  final int target;
  final Color color;

  double get progress {
    if (target <= 0) return 0;
    return (current / target).clamp(0.0, 1.0);
  }
}

class EatenNutritionSummary {
  const EatenNutritionSummary({
    required this.energyKcal,
    required this.proteinG,
    required this.fatG,
    required this.carbG,
  });

  final double energyKcal;
  final double proteinG;
  final double fatG;
  final double carbG;
}
/* -------------------------------------------------------------------------- */
/*                                   HEADER                                   */
/* -------------------------------------------------------------------------- */

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.data, required this.onLogoutTap});

  final HomeViewData data;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(gender: data.gender),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.greeting.toString(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMedium,
                ),
              ),
              Text(
                data.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        LogoutButton(onTap: onLogoutTap),
      ],
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.gender});

  final String? gender;

  String get assetPath {
    final normalizedGender = gender?.toLowerCase().trim();

    if (normalizedGender == 'perempuan' ||
        normalizedGender == 'female' ||
        normalizedGender == 'wanita') {
      return 'assets/icons/female.svg';
    }

    return 'assets/icons/male.svg';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: SvgPicture.asset(assetPath, fit: BoxFit.cover),
    );
  }
}

class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            Icons.logout_rounded,
            size: 14,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                              CALORIE OVERVIEW                              */
/* -------------------------------------------------------------------------- */

class CalorieOverviewCard extends StatelessWidget {
  const CalorieOverviewCard({super.key, required this.data});

  final HomeViewData data;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TargetCalorieText(value: data.targetCalories),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: RemainingCalorieCircle(
                  remainingCalories: data.remainingCalories,
                  progress: data.calorieProgress,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(flex: 6, child: CalorieSideInfo(data: data)),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: data.macros
                .map(
                  (macro) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: MacroProgressItem(macro: macro),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class TargetCalorieText extends StatelessWidget {
  const TargetCalorieText({super.key, required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
        children: [
          TextSpan(
            text: 'Target kalori: ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          TextSpan(
            text: '$value kkal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class RemainingCalorieCircle extends StatelessWidget {
  const RemainingCalorieCircle({
    super.key,
    required this.remainingCalories,
    required this.progress,
  });

  final int remainingCalories;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: safeProgress),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, animatedProgress, _) {
        return SizedBox(
          width: 152,
          height: 152,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: 132,
                height: 132,
                child: CircularProgressIndicator(
                  value: animatedProgress,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  color: AppColors.green,
                  backgroundColor: AppColors.greenSoft,
                ),
              ),

              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: remainingCalories.toDouble(),
                ),
                duration: const Duration(milliseconds: 850),
                curve: Curves.easeOutCubic,
                builder: (context, animatedCalories, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Tersisa',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSoft,
                        ),
                      ),

                      const SizedBox(height: 8),

                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          animatedCalories.round().toString(),
                          style: const TextStyle(
                            fontFamily: 'GeistMono',
                            fontSize: 34,
                            height: 0.95,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: -1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 7),

                      const Text(
                        'kkal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class CalorieSideInfo extends StatelessWidget {
  const CalorieSideInfo({super.key, required this.data});

  final HomeViewData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Makanan Dimakan',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.rice_bowl_outlined,
              size: 24,
              color: Color.fromARGB(255, 60, 60, 59),
            ),

            const SizedBox(width: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${data.intakeCalories}',
                  style: const TextStyle(
                    fontFamily: 'GeistMono',
                    fontSize: 18,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(width: 4),

                const Text(
                  'kkal',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Aktifitas Fisik',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textMedium,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_walk,
              size: 24,
              color: Color.fromARGB(255, 121, 121, 120),
            ),

            const SizedBox(width: 4),

            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  data.activityLevel.toString(),
                  style: const TextStyle(
                    fontFamily: 'GeistMono',
                    fontSize: 12,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(width: 4),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class MacroProgressItem extends StatelessWidget {
  const MacroProgressItem({super.key, required this.macro});

  final MacroSummary macro;

  @override
  Widget build(BuildContext context) {
    final primary = macro.color;
    final secondary = Color.alphaBlend(
      primary.withValues(alpha: 0.3),
      Colors.white,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          macro.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: macro.progress,
            minHeight: 5,
            backgroundColor: secondary,
            valueColor: AlwaysStoppedAnimation<Color>(
              primary.withValues(alpha: 0.80),
            ),
          ),
        ),

        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              '${macro.current}g',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSoft,
              ),
            ),
            Text(
              '/${macro.target}g',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                              HEALTH MONITORING                             */
/* -------------------------------------------------------------------------- */

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.actionText,
    required this.onActionTap,
  });

  final String title;
  final String actionText;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        GestureDetector(
          onTap: onActionTap,
          child: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Text(
              actionText,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textSoft,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HealthMonitorCard extends StatelessWidget {
  const HealthMonitorCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 18, 24, 16),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pantau Perkembangan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tekanan darah dan gula darah',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HealthMetricRow extends StatelessWidget {
  const HealthMetricRow({super.key, required this.data});

  final HomeViewData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: HealthMetricCard(
            title: 'Berat Badan',
            icon: Icons.fitness_center_rounded,
            value: data.weightKg,
            unit: 'kg',
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: HealthMetricCard(
            title: 'Tekanan darah',
            icon: Icons.monitor_heart_rounded,
            value: data.bloodPressure,
            unit: 'mmHg',
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: HealthMetricCard(
            title: 'Gula Darah',
            icon: Icons.water_drop_rounded,
            value: data.bloodSugar,
            unit: 'mg/dL',
          ),
        ),
      ],
    );
  }
}

class HealthMetricCard extends StatelessWidget {
  const HealthMetricCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.unit,
  });

  final String title;
  final IconData icon;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
      child: SizedBox(
        height: 36,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Flexible(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: const TextStyle(color: AppColors.textDark),
                      children: [
                        TextSpan(
                          text: value,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: ' $unit',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                  MEAL LIST                                 */
/* -------------------------------------------------------------------------- */

class MealList extends StatelessWidget {
  const MealList({super.key, required this.meals, required this.onMealTap});

  final List<MealSummary> meals;
  final VoidCallback onMealTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: meals
          .map(
            (meal) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MealCard(meal: meal, onTap: onMealTap),
            ),
          )
          .toList(),
    );
  }
}

class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.meal, required this.onTap});

  final MealSummary meal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const SizedBox(width: 6),
                          Text(
                            meal.calories.toString(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'kkal',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        meal.menuName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 22,
                  height: 22,
                  child: const Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyMealCard extends StatelessWidget {
  const EmptyMealCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Menu hari ini belum tersedia. Tap untuk melihat rekomendasi menu.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                ERROR VIEW                                  */
/* -------------------------------------------------------------------------- */

class ErrorHomeView extends StatelessWidget {
  const ErrorHomeView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                SHARED STYLE                                */
/* -------------------------------------------------------------------------- */
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class AppColors {
  const AppColors._();

  static const Color background = Color(0xFFF7F7F7);

  static const Color textDark = Color(0xFF242424);
  static const Color textMedium = Color(0xFF666666);
  static const Color textMuted = Color(0xFF8A8A8A);
  static const Color textSoft = Color(0xFFB8B8B8);

  static const Color green = Color(0xFF05C73C);
  static const Color greenSoft = Color(0xFFEAF8E9);

  static const Color beige = Color(0xFFE6D9C2);
  static const Color red = Color(0xFFD84A4A);
  static const Color iconCircle = Color(0xFFF4F1F4);
}

/* -------------------------------------------------------------------------- */
/*                                  HELPERS                                   */
/* -------------------------------------------------------------------------- */

int? parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();

  return int.tryParse(value.toString());
}

double? parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();

  return double.tryParse(value.toString());
}

String formatNumber(double? value) {
  if (value == null) return '-';

  if (value % 1 == 0) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(1);
}

/* -------------------------------------------------------------------------- */
/*                            REPEAT SCREENING API                            */
/* -------------------------------------------------------------------------- */

Future<void> startRepeatScreening({
  required BuildContext context,
  required String clientId,
}) async {
  try {
    final response = await http.post(
      AppConfig.apiUri('/api/screening/$clientId/new-screening'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      debugPrint(
        'Failed new screening: ${response.statusCode} ${response.body}',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memulai screening baru.')),
        );
      }

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
          child: const ScreeningPage(),
        ),
      ),
    );
  } catch (e) {
    debugPrint('Exception startRepeatScreening: $e');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat terhubung ke server.')),
      );
    }
  }
}
