import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hibah_2026/config/app_config.dart';
import 'package:http/http.dart' as http;

class MenuDayDetailPage extends StatefulWidget {
  const MenuDayDetailPage({super.key, required this.menuDayId});

  final int menuDayId;

  @override
  State<MenuDayDetailPage> createState() => _MenuDayDetailPageState();
}

class _MenuDayDetailPageState extends State<MenuDayDetailPage> {
  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color background = Color(0xFFF7F7F7);
  static const Color textDark = Color(0xFF25262A);

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? detail;

  @override
  void initState() {
    super.initState();
    fetchMenuDayDetail();
  }

  Future<void> fetchMenuDayDetail() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
        AppConfig.apiUri('/api/screening/menu-days/${widget.menuDayId}'),
        headers: {'Accept': 'application/json'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        setState(() {
          detail = body['data'];
        });

        return;
      }

      setState(() {
        errorMessage = 'Gagal memuat detail menu.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Tidak dapat terhubung ke server.';
      });
    }
    {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = detail;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Detail Menu Harian',
          style: TextStyle(fontWeight: FontWeight.w800, color: textDark),
        ),
        backgroundColor: background,
        surfaceTintColor: background,
        foregroundColor: textDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchMenuDayDetail,
          color: healthGreen,
          child: Builder(
            builder: (context) {
              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: healthGreen),
                );
              }

              if (errorMessage != null) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _InfoCard(
                      title: 'Gagal Memuat Data',
                      message: errorMessage!,
                    ),
                  ],
                );
              }

              if (data == null) {
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: const [
                    _InfoCard(
                      title: 'Data Tidak Tersedia',
                      message: 'Detail menu belum tersedia.',
                    ),
                  ],
                );
              }

              final recommendation = data['menuRecommendation'];
              final groupedItems = groupMenuItemsByMealTime(data['items']);
              final recapItems = summarizeAllItems(data['items']);
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  _HeaderCard(
                    title: formatDate(parseDate(data['menuDate'])),
                    subtitle:
                        'Diet ${formatValue(recommendation?['dietType'])}',
                  ),

                  const SizedBox(height: 14),

                  _SectionCard(
                    title: 'Ringkasan Nutrisi',
                    children: [
                      _DetailRow(
                        label: 'Energi',
                        value: '${formatNumber(data['energyKcal'])} kkal',
                        highlight: true,
                      ),
                      _DetailRow(
                        label: 'Karbohidrat',
                        value: '${formatNumber(data['carbG'])} g',
                      ),
                      _DetailRow(
                        label: 'Protein',
                        value: '${formatNumber(data['proteinG'])} g',
                      ),
                      _DetailRow(
                        label: 'Lemak',
                        value: '${formatNumber(data['fatG'])} g',
                      ),
                      _DetailRow(
                        label: 'Natrium',
                        value: '${formatNumber(data['sodiumMg'])} mg',
                      ),
                      _DetailRow(
                        label: 'Serat',
                        value: '${formatNumber(data['fiberG'])} g',
                      ),
                    ],
                  ),

                  if (recapItems.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: 'Rekap Bahan',
                      children: recapItems.map((item) {
                        return _RecapFoodRow(item: item);
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 12),

                  _SectionCard(
                    title: 'Daftar Menu',
                    children: groupedItems.isEmpty
                        ? const [_DetailRow(label: 'Menu', value: '-')]
                        : groupedItems.entries.map((entry) {
                            return _MealTimeGroup(
                              title: formatMealTime(entry.key),
                              items: entry.value,
                            );
                          }).toList(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> groupMenuItemsByMealTime(
    dynamic rawItems,
  ) {
    if (rawItems is! List) return {};

    final items = rawItems
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    items.sort((a, b) {
      final mealA = getMealTimeOrder(a['mealTime']);
      final mealB = getMealTimeOrder(b['mealTime']);

      if (mealA != mealB) {
        return mealA.compareTo(mealB);
      }

      final categoryA = getCategoryOrder(a['categoryCode']);
      final categoryB = getCategoryOrder(b['categoryCode']);

      if (categoryA != categoryB) {
        return categoryA.compareTo(categoryB);
      }

      final nameA = a['foodName']?.toString() ?? '';
      final nameB = b['foodName']?.toString() ?? '';

      return nameA.compareTo(nameB);
    });

    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final item in items) {
      final mealTime = item['mealTime']?.toString().toLowerCase() ?? 'other';

      grouped.putIfAbsent(mealTime, () => []);
      grouped[mealTime]!.add(item);
    }

    return grouped;
  }

  int getMealTimeOrder(dynamic mealTime) {
    final value = mealTime?.toString().toLowerCase() ?? '';

    if (value.contains('breakfast') || value.contains('sarapan')) {
      return 1;
    }

    if (value.contains('lunch') || value.contains('siang')) {
      return 2;
    }

    if (value.contains('dinner') || value.contains('malam')) {
      return 3;
    }

    if (value.contains('snack')) {
      return 4;
    }

    return 99;
  }

  String formatMealTime(dynamic mealTime) {
    final value = mealTime?.toString().toLowerCase() ?? '';

    if (value.contains('breakfast') || value.contains('sarapan')) {
      return 'Sarapan';
    }

    if (value.contains('lunch') || value.contains('siang')) {
      return 'Makan Siang';
    }

    if (value.contains('dinner') || value.contains('malam')) {
      return 'Makan Malam';
    }

    if (value.contains('snack')) {
      return 'Snack';
    }

    return 'Lainnya';
  }

  int getCategoryOrder(dynamic categoryCode) {
    final code = categoryCode?.toString().toUpperCase() ?? '';

    switch (code) {
      case 'MP':
        return 1;
      case 'LH':
        return 2;
      case 'LN':
        return 3;
      case 'SS':
        return 4;
      default:
        return 99;
    }
  }

  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  static String formatDate(DateTime? date) {
    if (date == null) return '-';

    const dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    const monthNames = [
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

    final dayName = dayNames[date.weekday - 1];
    final day = date.day;
    final monthName = monthNames[date.month - 1];
    final year = date.year;

    return '$dayName, $day $monthName $year';
  }

  static String formatValue(dynamic value) {
    if (value == null) return '-';
    final text = value.toString();
    if (text.trim().isEmpty) return '-';
    return text;
  }

  static String formatNumber(dynamic value) {
    if (value == null) return '-';

    final number = num.tryParse(value.toString());

    if (number == null) {
      return value.toString();
    }

    if (number % 1 == 0) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(1);
  }

  List<Map<String, dynamic>> summarizeAllItems(dynamic rawItems) {
    if (rawItems is! List) return [];

    final items = rawItems
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    final grouped = <String, Map<String, dynamic>>{};

    for (final item in items) {
      final foodName = item['foodName']?.toString().trim() ?? '-';
      final categoryCode = item['categoryCode']?.toString().trim() ?? '-';

      final key = foodName.toLowerCase();

      if (!grouped.containsKey(key)) {
        grouped[key] = {
          'foodName': foodName,
          'categoryCode': categoryCode,
          'gram': 0.0,
        };
      }

      grouped[key]!['gram'] = grouped[key]!['gram'] + toDouble(item['gram']);
    }

    final recapItems = grouped.values.toList();

    recapItems.sort((a, b) {
      final categoryA = getCategoryOrder(a['categoryCode']);
      final categoryB = getCategoryOrder(b['categoryCode']);

      if (categoryA != categoryB) {
        return categoryA.compareTo(categoryB);
      }

      final nameA = a['foodName']?.toString() ?? '';
      final nameB = b['foodName']?.toString() ?? '';

      return nameA.compareTo(nameB);
    });

    return recapItems;
  }

  double toDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }
}

class _FoodItemCard extends StatelessWidget {
  const _FoodItemCard({required this.item});

  final Map<String, dynamic> item;

  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    final foodName = item['foodName']?.toString() ?? '-';
    final urt = item['urt']?.toString();
    final gram = _formatNumber(item['gram']);
    final energy = _formatNumber(item['energyKcal']);
    final protein = _formatNumber(item['proteinG']);
    final fat = _formatNumber(item['fatG']);
    final carb = _formatNumber(item['carbG']);

    final portionText = [
      if (urt != null && urt.trim().isNotEmpty) urt,
      if (gram != '-') '$gram g',
    ].join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEDED), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  foodName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textDark,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),

          if (portionText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              portionText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textMedium,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniChip(label: '$energy kkal'),
              _MiniChip(label: 'Karbo $carb g'),
              _MiniChip(label: 'Protein $protein g'),
              _MiniChip(label: 'Lemak $fat g'),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatNumber(dynamic value) {
    if (value == null) return '-';

    final number = num.tryParse(value.toString());

    if (number == null) {
      return value.toString();
    }

    if (number % 1 == 0) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(1);
  }
}

class _RecapFoodRow extends StatelessWidget {
  const _RecapFoodRow({required this.item});

  final Map<String, dynamic> item;

  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    final foodName = item['foodName']?.toString() ?? '-';
    final gram = _formatNumber(item['gram']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              foodName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textDark,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$gram g',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatNumber(dynamic value) {
    if (value == null) return '-';

    final number = num.tryParse(value.toString());

    if (number == null) {
      return value.toString();
    }

    if (number % 1 == 0) {
      return number.toInt().toString();
    }

    return number.toStringAsFixed(1);
  }
}

class _MealTimeGroup extends StatelessWidget {
  const _MealTimeGroup({required this.title, required this.items});

  final String title;
  final List<Map<String, dynamic>> items;

  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${items.length} item menu',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _FoodItemCard(item: item)),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFEDEDED), width: 1),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFF666666),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEDEDED), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  static const Color textDark = Color(0xFF25262A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDEDED), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: highlight ? healthGreen : textDark,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.message});

  final String title;
  final String message;

  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDEDED), width: 1),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textMedium,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
