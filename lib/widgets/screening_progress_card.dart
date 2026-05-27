import 'package:flutter/material.dart';
import 'package:hibah_2026/widgets/mini_line_chart.dart';

class ScreeningProgressCard extends StatelessWidget {
  const ScreeningProgressCard({
    super.key,
    required this.title,
    required this.currentValue,
    required this.status,
    required this.values,
    this.unit = '',
    this.labels,
  });

  final String title;
  final String currentValue;
  final String status;
  final List<double> values;
  final String unit;
  final List<String>? labels;

  static const Color healthGreen = Color(0xFF04C83A);
  static const Color healthGreenSoft = Color(0xFFEAF8E9);
  static const Color backgroundWhite = Colors.white;
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);
  static const Color textSoft = Color(0xFF8A8A8A);
  static const Color borderSoft = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    final trend = getTrend(values);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: backgroundWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              TrendBadge(trend: trend),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    currentValue,
                    style: const TextStyle(
                      color: textDark,
                      fontFamily: 'GeistMono',
                      fontSize: 30,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.1,
                    ),
                  ),
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 5),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      color: textMedium,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          Text(
            status,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textMedium,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Tap titik grafik untuk melihat detail.',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          MiniLineChart(values: values, labels: labels, unit: unit, height: 86),
        ],
      ),
    );
  }

  String getTrend(List<double> values) {
    if (values.length < 2) return 'stabil';

    final first = values.first;
    final last = values.last;

    if (last > first) return 'naik';
    if (last < first) return 'turun';

    return 'stabil';
  }
}

class TrendBadge extends StatelessWidget {
  const TrendBadge({super.key, required this.trend});

  final String trend;

  static const Color healthGreen = Color.fromARGB(255, 0, 123, 35);
  static const Color healthGreenSoft = Color(0xFFEAF8E9);
  static const Color warning = Color(0xFFE89B22);
  static const Color warningSoft = Color(0xFFFFF4E5);
  static const Color neutral = Color(0xFF8A8A8A);
  static const Color neutralSoft = Color(0xFFF1F1F1);

  @override
  Widget build(BuildContext context) {
    final isUp = trend == 'naik';
    final isDown = trend == 'turun';

    final Color color = isUp
        ? warning
        : isDown
        ? healthGreen
        : neutral;

    final Color backgroundColor = isUp
        ? warningSoft
        : isDown
        ? healthGreenSoft
        : neutralSoft;

    final IconData icon = isUp
        ? Icons.trending_up_rounded
        : isDown
        ? Icons.trending_down_rounded
        : Icons.trending_flat_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 4),
          Text(
            trend,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
