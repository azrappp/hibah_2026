import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MealRecommendationPage extends StatefulWidget {
  const MealRecommendationPage({
    super.key,
    required this.clientId,
    required this.screeningId,
  });

  final String clientId;
  final String screeningId;

  @override
  State<MealRecommendationPage> createState() => _MealRecommendationPageState();
}

class _MealRecommendationPageState extends State<MealRecommendationPage> {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static const Color primaryPurple = Color(0xFF5E4AA0);
  static const Color cardPurple = Color(0xFFF0EAF5);
  static const Color softPurple = Color(0xFFF8F5FB);
  static const Color textDark = Color(0xFF202124);

  DateTime selectedDate = DateTime.now();

  bool isLoading = false;
  bool isGenerating = false;
  String? errorMessage;

  DailyMenu? dailyMenu;

  @override
  void initState() {
    super.initState();
    fetchMenuByDate();
  }

  String get selectedDateString {
    final year = selectedDate.year;
    final month = selectedDate.month.toString().padLeft(2, '0');
    final day = selectedDate.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> fetchMenuByDate() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
        dailyMenu = null;
      });

      final uri = Uri.parse(
        '$baseUrl/meal/clients/${widget.clientId}/menu-by-date?date=$selectedDateString',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];

        setState(() {
          dailyMenu = DailyMenu.fromJson(data);
        });

        return;
      }

      if (response.statusCode == 404) {
        setState(() {
          dailyMenu = null;
        });

        return;
      }

      setState(() {
        errorMessage = 'Failed to load menu: ${response.statusCode}';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> generateWeeklyMenu() async {
    try {
      setState(() {
        isGenerating = true;
        errorMessage = null;
      });

      final uri = Uri.parse('$baseUrl/meal/${widget.screeningId}/menu-weekly');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'startDate': selectedDateString}),
      );

      if (response.statusCode == 201) {
        await fetchMenuByDate();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Weekly menu generated successfully')),
        );

        return;
      }

      setState(() {
        errorMessage = 'Failed to generate menu: ${response.body}';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        isGenerating = false;
      });
    }
  }

  Future<void> toggleEaten(MenuItem item) async {
    final previousValue = item.isEaten;

    setState(() {
      item.isEaten = !item.isEaten;
    });

    try {
      final uri = Uri.parse('$baseUrl/meal/items/${item.menuItemId}/eaten');

      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isEaten': item.isEaten}),
      );

      if (response.statusCode != 200) {
        setState(() {
          item.isEaten = previousValue;
        });
      }
    } catch (_) {
      setState(() {
        item.isEaten = previousValue;
      });
    }
  }

  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedDate = pickedDate;
    });

    await fetchMenuByDate();
  }

  int get totalItems {
    if (dailyMenu == null) return 0;

    return dailyMenu!.meals.fold(0, (total, meal) => total + meal.items.length);
  }

  int get eatenItems {
    if (dailyMenu == null) return 0;

    return dailyMenu!.meals.fold(
      0,
      (total, meal) => total + meal.items.where((item) => item.isEaten).length,
    );
  }

  double get progress {
    if (totalItems == 0) return 0;
    return eatenItems / totalItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Rekomendasi Menu',
          style: TextStyle(fontWeight: FontWeight.w800, color: textDark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: textDark,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchMenuByDate,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DateSelectorCard(
                dateText: formatDateLong(selectedDate),
                onTap: pickDate,
              ),
              const SizedBox(height: 18),

              if (errorMessage != null) ...[
                ErrorCard(message: errorMessage!),
                const SizedBox(height: 18),
              ],

              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (dailyMenu == null)
                EmptyMenuCard(
                  dateText: formatDateLong(selectedDate),
                  isGenerating: isGenerating,
                  onGenerate: generateWeeklyMenu,
                )
              else ...[
                DailyNutritionSummary(menu: dailyMenu!),
                const SizedBox(height: 18),

                MealProgressCard(
                  eatenItems: eatenItems,
                  totalItems: totalItems,
                  progress: progress,
                ),
                const SizedBox(height: 22),

                const Text(
                  'Menu Harian',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 14),

                ...dailyMenu!.meals.map(
                  (meal) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: MealSectionCard(
                      meal: meal,
                      onToggleEaten: toggleEaten,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String formatDateLong(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];

    return '$dayName, ${date.day} $monthName ${date.year}';
  }
}

class MealProgressCard extends StatelessWidget {
  const MealProgressCard({
    super.key,
    required this.eatenItems,
    required this.totalItems,
    required this.progress,
  });

  final int eatenItems;
  final int totalItems;
  final double progress;

  static const Color primaryPurple = Color(0xFF5E4AA0);
  static const Color cardPurple = Color(0xFFF0EAF5);

  @override
  Widget build(BuildContext context) {
    final progressPercent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardPurple,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Konsumsi Menu',
            style: TextStyle(
              color: primaryPurple,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$eatenItems dari $totalItems item sudah dimakan',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.7),
              color: primaryPurple,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$progressPercent%',
              style: const TextStyle(
                color: primaryPurple,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DateSelectorCard extends StatelessWidget {
  const DateSelectorCard({
    super.key,
    required this.dateText,
    required this.onTap,
  });

  final String dateText;
  final VoidCallback onTap;

  static const Color primaryPurple = Color(0xFF5E4AA0);
  static const Color cardPurple = Color(0xFFF0EAF5);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardPurple,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: primaryPurple,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  dateText,
                  style: const TextStyle(
                    color: primaryPurple,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 32,
                color: Colors.black87,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyMenuCard extends StatelessWidget {
  const EmptyMenuCard({
    super.key,
    required this.dateText,
    required this.isGenerating,
    required this.onGenerate,
  });

  final String dateText;
  final bool isGenerating;
  final VoidCallback onGenerate;

  static const Color primaryPurple = Color(0xFF5E4AA0);
  static const Color cardPurple = Color(0xFFF0EAF5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardPurple,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.restaurant_menu_rounded,
            size: 48,
            color: primaryPurple,
          ),
          const SizedBox(height: 14),
          const Text(
            'Menu belum tersedia',
            style: TextStyle(
              color: primaryPurple,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada rekomendasi menu untuk $dateText.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: isGenerating ? null : onGenerate,
              icon: isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(
                isGenerating ? 'Generating...' : 'Generate Weekly Menu',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: Colors.red.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class DailyNutritionSummary extends StatelessWidget {
  const DailyNutritionSummary({super.key, required this.menu});

  final DailyMenu menu;

  static const Color primaryPurple = Color(0xFF5E4AA0);
  static const Color cardPurple = Color(0xFFF0EAF5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardPurple,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text(
            'Total Menu Harian',
            style: TextStyle(
              color: primaryPurple,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${menu.energyKcal.round()} kkal',
            style: const TextStyle(
              color: primaryPurple,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: NutritionMiniCard(
                  label: 'Protein',
                  value: '${menu.proteinG.toStringAsFixed(1)} g',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NutritionMiniCard(
                  label: 'Lemak',
                  value: '${menu.fatG.toStringAsFixed(1)} g',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NutritionMiniCard(
                  label: 'Karbo',
                  value: '${menu.carbG.toStringAsFixed(1)} g',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NutritionMiniCard extends StatelessWidget {
  const NutritionMiniCard({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  static const Color primaryPurple = Color(0xFF5E4AA0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: primaryPurple,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class MealSectionCard extends StatelessWidget {
  const MealSectionCard({
    super.key,
    required this.meal,
    required this.onToggleEaten,
  });

  final Meal meal;
  final ValueChanged<MenuItem> onToggleEaten;

  static const Color primaryPurple = Color(0xFF5E4AA0);
  static const Color cardPurple = Color(0xFFF0EAF5);
  static const Color softPurple = Color(0xFFF8F5FB);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: softPurple,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardPurple, width: 1),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          mealTimeLabel(meal.mealTime),
          style: const TextStyle(
            color: primaryPurple,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${meal.items.length} item',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        children: [
          ...meal.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MealItemTile(item: item, onToggleEaten: onToggleEaten),
            ),
          ),
        ],
      ),
    );
  }

  String mealTimeLabel(String mealTime) {
    switch (mealTime) {
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
        return mealTime;
    }
  }
}

class MealItemTile extends StatelessWidget {
  const MealItemTile({
    super.key,
    required this.item,
    required this.onToggleEaten,
  });

  final MenuItem item;
  final ValueChanged<MenuItem> onToggleEaten;

  static const Color primaryPurple = Color(0xFF5E4AA0);

  @override
  Widget build(BuildContext context) {
    final isEaten = item.isEaten;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onToggleEaten(item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isEaten
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFF0EAF5),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isEaten
                      ? Icons.check_circle_rounded
                      : Icons.restaurant_rounded,
                  color: isEaten ? Colors.green : primaryPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.foodName,
                  style: TextStyle(
                    color: isEaten
                        ? Colors.grey.shade500
                        : const Color(0xFF202124),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    decoration: isEaten
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.urt ?? '-',
                    style: const TextStyle(
                      color: primaryPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.gram == null ? '-' : '${item.gram!.round()} g',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 30,
                    child: FilledButton.tonalIcon(
                      onPressed: () => onToggleEaten(item),
                      icon: Icon(
                        isEaten ? Icons.undo_rounded : Icons.check_rounded,
                        size: 16,
                      ),
                      label: Text(
                        isEaten ? 'Batal' : 'Dimakan',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DummyDailyMenu {
  DummyDailyMenu({
    required this.dayText,
    required this.dateText,
    required this.energyKcal,
    required this.proteinG,
    required this.fatG,
    required this.carbG,
    required this.meals,
  });

  final String dayText;
  final String dateText;
  final double energyKcal;
  final double proteinG;
  final double fatG;
  final double carbG;
  final List<DummyMeal> meals;

  factory DummyDailyMenu.today() {
    return DummyDailyMenu(
      dayText: 'Jumat',
      dateText: '22 Mei 2026',
      energyKcal: 1600,
      proteinG: 60,
      fatG: 44,
      carbG: 240,
      meals: [
        DummyMeal(
          mealTime: 'Sarapan',
          energyKcal: 420,
          items: [
            DummyMealItem(
              foodName: 'Nasi',
              categoryCode: 'MP',
              urt: '1 Gelas',
              gram: 100,
              energyKcal: 175,
            ),
            DummyMealItem(
              foodName: 'Ayam, daging, segar',
              categoryCode: 'LH',
              urt: '1 Potong',
              gram: 40,
              energyKcal: 120,
            ),
            DummyMealItem(
              foodName: 'Bayam, segar',
              categoryCode: 'S',
              urt: '1 Gelas',
              gram: 100,
              energyKcal: 35,
            ),
          ],
        ),
        DummyMeal(
          mealTime: 'Snack Pagi',
          energyKcal: 160,
          items: [
            DummyMealItem(
              foodName: 'Apel malang, segar',
              categoryCode: 'B',
              urt: '1 Buah',
              gram: 85,
              energyKcal: 60,
            ),
          ],
        ),
        DummyMeal(
          mealTime: 'Makan Siang',
          energyKcal: 520,
          items: [
            DummyMealItem(
              foodName: 'Nasi beras merah',
              categoryCode: 'MP',
              urt: '1 Gelas',
              gram: 100,
              energyKcal: 180,
            ),
            DummyMealItem(
              foodName: 'Ikan kakap, segar',
              categoryCode: 'LH',
              urt: '1 Potong',
              gram: 50,
              energyKcal: 130,
            ),
            DummyMealItem(
              foodName: 'Tempe kedelai, mentah',
              categoryCode: 'LN',
              urt: '2 Potong',
              gram: 50,
              energyKcal: 100,
            ),
          ],
        ),
        DummyMeal(
          mealTime: 'Snack Sore',
          energyKcal: 140,
          items: [
            DummyMealItem(
              foodName: 'Melon, segar',
              categoryCode: 'B',
              urt: '1 Potong',
              gram: 100,
              energyKcal: 45,
            ),
          ],
        ),
        DummyMeal(
          mealTime: 'Makan Malam',
          energyKcal: 360,
          items: [
            DummyMealItem(
              foodName: 'Nasi',
              categoryCode: 'MP',
              urt: '1/2 Gelas',
              gram: 50,
              energyKcal: 88,
            ),
            DummyMealItem(
              foodName: 'Tahu, mentah',
              categoryCode: 'LN',
              urt: '2 Potong',
              gram: 100,
              energyKcal: 90,
            ),
            DummyMealItem(
              foodName: 'Wortel, segar',
              categoryCode: 'S',
              urt: '1 Gelas',
              gram: 100,
              energyKcal: 40,
            ),
          ],
        ),
      ],
    );
  }
}

class DailyMenu {
  DailyMenu({
    required this.clientName,
    required this.menuRecommendationId,
    required this.screeningId,
    required this.dietType,
    required this.energyKcal,
    required this.proteinG,
    required this.fatG,
    required this.carbG,
    required this.meals,
  });

  final String clientName;
  final int menuRecommendationId;
  final int screeningId;
  final String dietType;

  final double energyKcal;
  final double proteinG;
  final double fatG;
  final double carbG;

  final List<Meal> meals;

  factory DailyMenu.fromJson(Map<String, dynamic> json) {
    final day = json['day'];
    final summary = day['summary'];

    return DailyMenu(
      clientName: json['client']['fullName'] ?? '-',
      menuRecommendationId: json['menuRecommendationId'],
      screeningId: json['screeningId'],
      dietType: json['dietType'],
      energyKcal: toDouble(summary['energyKcal']),
      proteinG: toDouble(summary['proteinG']),
      fatG: toDouble(summary['fatG']),
      carbG: toDouble(summary['carbG']),
      meals: (day['meals'] as List<dynamic>? ?? [])
          .map((item) => Meal.fromJson(item))
          .toList(),
    );
  }
}

class Meal {
  Meal({required this.mealTime, required this.items});

  final String mealTime;
  final List<MenuItem> items;

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      mealTime: json['mealTime'],
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => MenuItem.fromJson(item))
          .toList(),
    );
  }
}

class MenuItem {
  MenuItem({
    required this.menuItemId,
    required this.foodName,
    required this.categoryCode,
    required this.portion,
    required this.urt,
    required this.gram,
    required this.isEaten,
  });

  final int menuItemId;
  final String foodName;
  final String categoryCode;
  final double portion;
  final String? urt;
  final double? gram;
  bool isEaten;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      menuItemId: json['menuItemId'],
      foodName: json['foodName'] ?? '-',
      categoryCode: json['categoryCode'] ?? '-',
      portion: toDouble(json['portion']),
      urt: json['urt'],
      gram: json['gram'] == null ? null : toDouble(json['gram']),
      isEaten: json['isEaten'] ?? false,
    );
  }
}

double toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? 0;

  return 0;
}

class DummyMeal {
  DummyMeal({
    required this.mealTime,
    required this.energyKcal,
    required this.items,
  });

  final String mealTime;
  final double energyKcal;
  final List<DummyMealItem> items;
}

class DummyMealItem {
  DummyMealItem({
    required this.foodName,
    required this.categoryCode,
    required this.urt,
    required this.gram,
    required this.energyKcal,
    this.isEaten = false,
  });

  final String foodName;
  final String categoryCode;
  final String urt;
  final double gram;
  final double energyKcal;

  bool isEaten;
}
