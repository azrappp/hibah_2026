import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hibah_2026/config/app_config.dart';
import 'package:hibah_2026/widgets/gender_radio_group_widget.dart';
import 'package:hibah_2026/pages/menu_history/menu_day_list_page.dart';
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

class _MealRecommendationPageState extends State<MealRecommendationPage>
    with TickerProviderStateMixin {
  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color healthGreenSoft = Color(0xFFEFF4F1);
  static const Color background = Color(0xFFF7F7F7);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);
  final eatenTrayKey = GlobalKey();
  final List<int> eatenOrderIds = [];
  final eatenTrayScrollController = ScrollController();
  final Set<int> animatingItemIds = {};
  DateTime selectedDate = DateTime.now();

  bool isLoading = false;
  bool isGenerating = false;
  String? errorMessage;

  DailyMenu? dailyMenu;
  @override
  void dispose() {
    eatenTrayScrollController.dispose();
    super.dispose();
  }

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

  List<MenuItem> get allMenuItems {
    final menu = dailyMenu;
    if (menu == null) return [];

    return menu.meals.expand((meal) => meal.items).toList();
  }

  List<MenuItem> get eatenMenuItems {
    final items = allMenuItems.where((item) => item.isEaten).toList();

    final orderedItems = <MenuItem>[];

    for (final id in eatenOrderIds) {
      final index = items.indexWhere((item) => item.menuItemId == id);
      if (index != -1) {
        orderedItems.add(items[index]);
      }
    }

    final missingItems = items.where((item) {
      return !eatenOrderIds.contains(item.menuItemId);
    }).toList();

    return [...orderedItems, ...missingItems];
  }

  Future<void> fetchMenuByDate() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
        dailyMenu = null;
      });

      final uri = AppConfig.apiUri(
        '/api/meal/clients/${widget.clientId}/menu-by-date?date=$selectedDateString',
      );

      final response = await http.get(uri);

      if (!mounted) return;

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
        errorMessage = 'Gagal memuat menu harian.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Tidak dapat terhubung ke server.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> animateFoodToEatenTray({
    required GlobalKey sourceKey,
    required String imageAsset,
  }) async {
    final sourceContext = sourceKey.currentContext;
    final targetContext = eatenTrayKey.currentContext;

    if (sourceContext == null || targetContext == null) return;

    final sourceBox = sourceContext.findRenderObject() as RenderBox?;
    final targetBox = targetContext.findRenderObject() as RenderBox?;

    if (sourceBox == null || targetBox == null) return;

    final overlay = Overlay.of(context);

    final sourceTopLeft = sourceBox.localToGlobal(Offset.zero);
    final sourceCenter = Offset(
      sourceTopLeft.dx + sourceBox.size.width / 2,
      sourceTopLeft.dy + sourceBox.size.height / 2,
    );

    final trayTopLeft = targetBox.localToGlobal(Offset.zero);

    const trayHorizontalPadding = 12.0;
    const itemSize = 52.0;
    const itemGap = 10.0;
    const itemStep = itemSize + itemGap;

    final nextIndex = eatenMenuItems.length;

    final maxVisibleX = targetBox.size.width - trayHorizontalPadding - itemSize;
    final rawTargetX = trayHorizontalPadding + (nextIndex * itemStep);

    final targetX = rawTargetX > maxVisibleX ? maxVisibleX : rawTargetX;

    final targetCenter = Offset(
      trayTopLeft.dx + targetX + itemSize / 2,
      trayTopLeft.dy + targetBox.size.height / 2,
    );

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );

    final curve = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutQuart,
    );

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) {
        return AnimatedBuilder(
          animation: curve,
          builder: (_, __) {
            final t = curve.value;

            final controlPoint = Offset(
              sourceCenter.dx + (targetCenter.dx - sourceCenter.dx) * 0.45,
              sourceCenter.dy - 90,
            );

            final p0 = sourceCenter;
            final p1 = controlPoint;
            final p2 = targetCenter;

            final x =
                (1 - t) * (1 - t) * p0.dx +
                2 * (1 - t) * t * p1.dx +
                t * t * p2.dx;

            final y =
                (1 - t) * (1 - t) * p0.dy +
                2 * (1 - t) * t * p1.dy +
                t * t * p2.dy;

            final scale = 1.0 - (t * 0.12);

            final opacity = t < 0.45
                ? 0.2 - (t / 0.45 * 0.45)
                : 0.55 + ((t - 0.45) / 0.55 * 0.45);
            return Positioned(
              left: x - itemSize / 2,
              top: y - itemSize / 2,
              child: IgnorePointer(
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: scale,
                    child: SizedBox(
                      width: itemSize,
                      height: itemSize,
                      child: Image.asset(imageAsset, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    overlay.insert(entry);
    await controller.forward();

    entry.remove();
    controller.dispose();
  }

  Future<void> toggleEaten(
    MenuItem item,
    GlobalKey imageKey,
    String imageAsset,
  ) async {
    if (animatingItemIds.contains(item.menuItemId)) return;

    final previousValue = item.isEaten;

    setState(() {
      animatingItemIds.add(item.menuItemId);
    });

    try {
      if (!item.isEaten) {
        await animateFoodToEatenTray(
          sourceKey: imageKey,
          imageAsset: imageAsset,
        );
      }

      setState(() {
        item.isEaten = !item.isEaten;

        if (item.isEaten) {
          eatenOrderIds.remove(item.menuItemId);
          eatenOrderIds.add(item.menuItemId);
        } else {
          eatenOrderIds.remove(item.menuItemId);
        }
      });
      if (item.isEaten) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (eatenTrayScrollController.hasClients) {
            eatenTrayScrollController.animateTo(
              eatenTrayScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
            );
          }
        });
      }

      final uri = AppConfig.apiUri('/api/meal/items/${item.menuItemId}/eaten');

      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isEaten': item.isEaten}),
      );

      if (!mounted) return;

      if (response.statusCode != 200) {
        setState(() {
          item.isEaten = previousValue;
        });

        debugPrint(
          'Failed update eaten: ${response.statusCode} - ${response.body}',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui status makanan.')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        item.isEaten = previousValue;
      });

      debugPrint('Exception update eaten: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat terhubung ke server.')),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        animatingItemIds.remove(item.menuItemId);
      });
    }
  }

  Future<void> generateWeeklyMenu() async {
    try {
      setState(() {
        isGenerating = true;
        errorMessage = null;
      });

      final uri = AppConfig.apiUri(
        '/api/meal/${widget.screeningId}/menu-weekly',
      );

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'startDate': selectedDateString}),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        await fetchMenuByDate();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu mingguan berhasil dibuat.')),
        );

        return;
      }

      setState(() {
        errorMessage = 'Gagal membuat rekomendasi menu.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Tidak dapat terhubung ke server.';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isGenerating = false;
      });
    }
  }

  Future<void> openDailyMenus() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MenuDayListPage(clientId: widget.clientId),
      ),
    );
  }

  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: healthGreen,
              secondary: healthGreenSoft,
            ),
          ),
          child: child!,
        );
      },
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

  double get eatenCalories {
    final menu = dailyMenu;
    if (menu == null) return 0.0;

    double total = 0.0;

    for (final meal in menu.meals) {
      for (final item in meal.items) {
        if (item.isEaten) {
          total += item.energyKcal;
        }
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Rekomendasi Menu',
          style: TextStyle(fontWeight: FontWeight.w900, color: textDark),
        ),
        actions: [
          IconButton(
            onPressed: openDailyMenus,
            icon: const Icon(Icons.calendar_view_week_rounded),
            tooltip: 'Daftar Menu',
          ),
        ],
        backgroundColor: background,
        surfaceTintColor: background,
        elevation: 0,
        foregroundColor: textDark,
      ),
      bottomNavigationBar: dailyMenu == null
          ? null
          : SafeArea(
              top: false,
              child: EatenFoodTray(
                key: eatenTrayKey,
                items: eatenMenuItems,
                scrollController: eatenTrayScrollController,
                progress: progress,
                totalItems: totalItems,
              ),
            ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchMenuByDate,
          color: healthGreen,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
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
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(color: healthGreen),
                  ),
                )
              else if (dailyMenu == null)
                EmptyMenuCard(
                  dateText: formatDateLong(selectedDate),
                  isGenerating: isGenerating,
                  onGenerate: generateWeeklyMenu,
                )
              else ...[
                DailyNutritionSummary(
                  menu: dailyMenu!,
                  eatenCalories: eatenCalories,
                ),

                const SizedBox(height: 28),

                Text(
                  'Menu Harian',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textDark,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Centang makanan yang sudah dikonsumsi hari ini.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 16),

                ...dailyMenu!.meals.map(
                  (meal) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: MealSectionCard(
                      meal: meal,
                      onToggleEaten: toggleEaten,
                      isItemBusy: (menuItemId) =>
                          animatingItemIds.contains(menuItemId),
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

/* -------------------------------------------------------------------------- */
/*                                  TOP CARDS                                 */
/* -------------------------------------------------------------------------- */

class DateSelectorCard extends StatelessWidget {
  const DateSelectorCard({
    super.key,
    required this.dateText,
    required this.onTap,
  });

  final String dateText;
  final VoidCallback onTap;

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color healthGreenSoft = Color(0xFFEFF4F1);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);
  static const Color borderSoft = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderSoft, width: 1.1),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 35,
                height: 35,
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: textDark,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Menu',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: textMedium,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      dateText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: textDark,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.chevron_right_rounded,
                size: 30,
                color: textMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DailyNutritionSummary extends StatelessWidget {
  const DailyNutritionSummary({
    super.key,
    required this.menu,
    required this.eatenCalories,
  });

  final DailyMenu menu;
  final double eatenCalories;

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color healthGreenSoft = Color(0xFFEFF4F1);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);
  static const Color borderSoft = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    final remaining = menu.energyKcal - eatenCalories;
    final safeRemaining = remaining < 0 ? 0 : remaining;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderSoft, width: 1.1),
      ),
      child: Column(
        children: [
          Text(
            'Target Menu Harian',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textMedium,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${menu.energyKcal.round()} kkal',
            style: const TextStyle(
              color: GenderRadioGroupWidget.healthGreen,
              fontFamily: 'GeistMono',
              fontSize: 36,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.4,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Tersisa ${safeRemaining.round()} kkal berdasarkan makanan yang sudah dimakan.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textMedium,
              fontWeight: FontWeight.w600,
              height: 1.35,
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

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color healthGreenSoft = Color(0xFFEFF4F1);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      decoration: BoxDecoration(
        color: healthGreenSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textMedium,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: textDark,
                fontFamily: 'GeistMono',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ),
        ],
      ),
    );
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

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color healthGreenSoft = Color(0xFFEFF4F1);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);
  static const Color borderSoft = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    final progressPercent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderSoft, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kalori Terpenuhi',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: textDark,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '$eatenItems dari $totalItems makanan sudah dimakan',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textMedium,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: healthGreenSoft,
              color: healthGreen,
            ),
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$progressPercent%',
              style: const TextStyle(
                color: healthGreen,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                fontFamily: 'GeistMono',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                  MEAL LIST                                 */
/* -------------------------------------------------------------------------- */

class MealSectionCard extends StatelessWidget {
  const MealSectionCard({
    super.key,
    required this.meal,
    required this.onToggleEaten,
    required this.isItemBusy,
  });

  final Meal meal;
  final Future<void> Function(
    MenuItem item,
    GlobalKey imageKey,
    String imageAsset,
  )
  onToggleEaten;
  final bool Function(int menuItemId) isItemBusy;
  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color healthGreenSoft = Color(0xFFEFF4F1);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);
  static const Color borderSoft = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    final eatenCount = meal.items.where((item) => item.isEaten).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderSoft, width: 1.1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
          ),
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.fromLTRB(18, 8, 14, 8),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            mealTimeLabel(meal.mealTime),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: textDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          children: [
            ...meal.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MealItemTile(
                  item: item,
                  onToggleEaten: onToggleEaten,
                  isBusy: isItemBusy(item.menuItemId),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData mealIcon(String mealTime) {
    switch (mealTime) {
      case 'breakfast':
        return Icons.wb_sunny_rounded;
      case 'morning_snack':
        return Icons.local_cafe_rounded;
      case 'lunch':
        return Icons.lunch_dining_rounded;
      case 'afternoon_snack':
        return Icons.cookie_rounded;
      case 'dinner':
        return Icons.nightlight_round;
      default:
        return Icons.restaurant_rounded;
    }
  }

  static String mealTimeLabel(String mealTime) {
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
    required this.isBusy,
  });

  final MenuItem item;
  final bool isBusy;

  final Future<void> Function(
    MenuItem item,
    GlobalKey imageKey,
    String imageAsset,
  )
  onToggleEaten;

  static const Color accent = Color(0xFF2F5D50);
  static const Color accentSoft = Color(0xFFEFF4F1);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);
  static const Color textSoft = Color(0xFF8A8A8A);
  static const Color borderSoft = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    final isEaten = item.isEaten;
    final imageKey = GlobalKey();

    final imageAsset = getFoodImageAsset(
      categoryCode: item.categoryCode,
      foodName: item.foodName,
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isEaten ? accent.withValues(alpha: 0.30) : borderSoft,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              key: imageKey,
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Opacity(
                opacity: isEaten ? 0.3 : 1.0,
                child: Image.asset(imageAsset, fit: BoxFit.contain),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.foodName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isEaten ? textMedium : textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    item.urt ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isEaten ? textMedium : textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    item.gram == null
                        ? '${item.energyKcal.round()} kkal'
                        : '${item.gram!.round()} g • ${item.energyKcal.round()} kkal',
                    style: const TextStyle(
                      color: textSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            _EatenActionButton(
              isEaten: isEaten,
              isBusy: isBusy,
              onPressed: isBusy
                  ? null
                  : () => onToggleEaten(item, imageKey, imageAsset),
            ),
          ],
        ),
      ),
    );
  }
}
/* -------------------------------------------------------------------------- */
/*                                EMPTY & ERROR                               */
/* -------------------------------------------------------------------------- */

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

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color healthGreenSoft = Color(0xFFEFF4F1);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);
  static const Color borderSoft = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderSoft, width: 1.1),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: const Icon(
              Icons.restaurant_menu_rounded,
              size: 28,
              color: textDark,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Menu belum tersedia',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textDark,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Belum ada rekomendasi menu untuk $dateText.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textMedium,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: isGenerating ? null : onGenerate,
              icon: isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.collections_bookmark),
              label: Text(
                isGenerating ? 'Membuat menu...' : 'Buat Menu Mingguan',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: healthGreen,
                disabledBackgroundColor: healthGreen.withValues(alpha: 0.35),

                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
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

  static const Color errorSoft = Color(0xFFFFECEC);
  static const Color error = Color(0xFFD84A4A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: errorSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: error.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                   MODELS                                   */
/* -------------------------------------------------------------------------- */

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
    final day = json['day'] ?? <String, dynamic>{};
    final summary = day['summary'] ?? <String, dynamic>{};

    return DailyMenu(
      clientName: json['client']?['fullName']?.toString() ?? '-',
      menuRecommendationId: toInt(json['menuRecommendationId']),
      screeningId: toInt(json['screeningId']),
      dietType: json['dietType']?.toString() ?? '-',
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

  static const List<String> categoryOrder = [
    'MP',
    'LH',
    'LN',
    'S',
    'B',
    'SS',
    'M',
    'G',
  ];

  static int categoryRank(String code) {
    final index = categoryOrder.indexOf(code.toUpperCase());
    return index == -1 ? 999 : index;
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .map((item) => MenuItem.fromJson(item))
        .toList();

    items.sort((a, b) {
      final rankA = categoryRank(a.categoryCode);
      final rankB = categoryRank(b.categoryCode);

      if (rankA != rankB) {
        return rankA.compareTo(rankB);
      }

      return a.foodName.compareTo(b.foodName);
    });

    return Meal(mealTime: json['mealTime']?.toString() ?? '-', items: items);
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
    required this.energyKcal,
    required this.isEaten,
  });

  final int menuItemId;
  final String foodName;
  final String categoryCode;
  final double portion;
  final String? urt;
  final double? gram;
  final double energyKcal;
  bool isEaten;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final nutrition = json['nutrition'];

    return MenuItem(
      menuItemId: toInt(json['menuItemId']),
      foodName: json['foodName']?.toString() ?? '-',
      categoryCode: json['categoryCode']?.toString() ?? '-',
      portion: toDouble(json['portion']),
      urt: json['urt']?.toString(),
      gram: json['gram'] == null ? null : toDouble(json['gram']),
      energyKcal: nutrition is Map<String, dynamic>
          ? toDouble(nutrition['energyKcal'])
          : 0.0,
      isEaten: json['isEaten'] == true,
    );
  }
}

String getFoodImageAsset({
  required String categoryCode,
  required String foodName,
}) {
  final code = categoryCode.toUpperCase();
  final name = foodName.toLowerCase();

  if (code == 'MP') {
    return 'assets/images/nasi.png';
  }

  if (code == 'LH') {
    if (name.contains('ayam')) {
      return 'assets/images/ayam.png';
    }

    if (name.contains('ikan') ||
        name.contains('tongkol') ||
        name.contains('lele') ||
        name.contains('bandeng') ||
        name.contains('kembung') ||
        name.contains('tuna') ||
        name.contains('belut') ||
        name.contains('salmon') ||
        name.contains('sarden')) {
      return 'assets/images/ikan.png';
    }

    return 'assets/images/daging.png';
  }

  if (code == 'LN') {
    if (name.contains('tempe')) {
      return 'assets/images/tempe.png';
    }

    return 'assets/images/kacang.png';
  }

  if (code == 'S' ||
      name.contains('sayur') ||
      name.contains('bayam') ||
      name.contains('kangkung') ||
      name.contains('wortel') ||
      name.contains('buncis') ||
      name.contains('sawi')) {
    return 'assets/images/sayur.png';
  }

  if (code == 'B' ||
      name.contains('buah') ||
      name.contains('pisang') ||
      name.contains('apel') ||
      name.contains('jeruk') ||
      name.contains('pepaya') ||
      name.contains('melon') ||
      name.contains('semangka')) {
    return 'assets/images/buah.png';
  }

  if (code == 'M' ||
      code == 'G' ||
      name.contains('minyak') ||
      name.contains('margarin') ||
      name.contains('mentega')) {
    return 'assets/images/minyak.png';
  }

  if (code == 'SS') {
    return 'assets/images/buah.png';
  }

  return 'assets/images/nasi.png';
}

int toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;

  return 0;
}

double toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;

  return 0.0;
}

class EatenFoodTray extends StatelessWidget {
  const EatenFoodTray({
    super.key,
    required this.items,
    required this.scrollController,
    required this.progress,
    required this.totalItems,
  });

  final List<MenuItem> items;
  final ScrollController scrollController;
  final double progress;
  final int totalItems;

  static const Color accent = Color(0xFF2F5D50);
  static const Color background = Color(0xFFF7F7F7);
  static const Color borderSoft = Color(0xFFE3E3E3);

  @override
  Widget build(BuildContext context) {
    final showEmptySlot = items.length < totalItems;
    final itemCount = items.length + (showEmptySlot ? 1 : 0);
    return Container(
      decoration: const BoxDecoration(
        color: background,
        border: Border(top: BorderSide(color: borderSoft, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 3,
              backgroundColor: const Color(0xFFE8E8E8),
              color: accent,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Makanan Terkonsumsi',
            style: TextStyle(fontWeight: FontWeight.w900, color: accent),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: SizedBox(
              height: 64,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: ListView.separated(
                  key: ValueKey(items.map((item) => item.menuItemId).join('-')),
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: itemCount,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (showEmptySlot && index == items.length) {
                      return const _EmptyFoodSlot();
                    }
                    final item = items[index];
                    final imageAsset = getFoodImageAsset(
                      categoryCode: item.categoryCode,
                      foodName: item.foodName,
                    );
                    return AnimatedScale(
                      key: ValueKey(item.menuItemId),
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutBack,
                      scale: 1,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: 1,
                        child: Container(
                          width: 52,
                          height: 52,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(imageAsset, fit: BoxFit.contain),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFoodSlot extends StatelessWidget {
  const _EmptyFoodSlot();

  @override
  Widget build(BuildContext context) {
    return Container(width: 52, height: 52);
  }
}

class _EatenActionButton extends StatelessWidget {
  const _EatenActionButton({
    required this.isEaten,
    required this.isBusy,
    required this.onPressed,
  });

  final bool isEaten;
  final bool isBusy;
  final VoidCallback? onPressed;

  static const Color accent = Color(0xFF2F5D50);
  static const Color borderSoft = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    final color = isEaten ? Color.fromARGB(255, 138, 138, 138) : accent;
    final backgroundColor = isEaten
        ? const Color.fromARGB(255, 199, 197, 197)
        : const Color(0xFFEFF4F1);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isBusy ? borderSoft : color.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isBusy
                ? SizedBox(
                    key: const ValueKey('loading'),
                    width: 8,
                    height: 8,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Icon(
                    isEaten ? Icons.close_rounded : Icons.check_rounded,
                    key: ValueKey(isEaten ? 'close' : 'check'),
                    size: 12,
                    color: color,
                  ),
          ),
        ),
      ),
    );
  }
}
