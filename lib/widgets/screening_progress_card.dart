import 'package:flutter/material.dart';
import 'package:hibah_2026/widgets/mini_line_chart.dart';

class ScreeningProgressCard extends StatelessWidget {
  const ScreeningProgressCard({
    super.key,
    required this.title,
    required this.currentValue,
    required this.status,
    required this.series,
    required this.finalStatus,
    this.unit = '',
    this.labels,
  });

  final String title;
  final String currentValue;
  final String status;
  final String finalStatus;
  final List<ChartSeries> series;
  final String unit;
  final List<String>? labels;

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color healthGreenSoft = Color(0xFFEFF4F1);
  static const Color backgroundWhite = Colors.white;
  static const Color textDark = Color(0xFF25262A);
  static const Color textMedium = Color(0xFF666666);
  static const Color textSoft = Color(0xFF8A8A8A);
  static const Color borderSoft = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              FinalStatusBadge(status: finalStatus),
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
                      fontSize: 18,
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
                  padding: const EdgeInsets.only(top: 3),
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

          MiniLineChart(
            series: series,
            labels: labels,
            unit: unit,
            height: 110,
          ),
        ],
      ),
    );
  }
}

class FinalStatusBadge extends StatelessWidget {
  const FinalStatusBadge({super.key, required this.status});

  final String status;

  static const Color good = Color(0xFF2F5D50);
  static const Color goodSoft = Color(0xFFEFF4F1);

  static const Color warning = Color(0xFFE89B22);
  static const Color warningSoft = Color(0xFFFFF4E5);

  static const Color danger = Color(0xFFB85C5C);
  static const Color dangerSoft = Color(0xFFFFF1F1);

  static const Color neutral = Color(0xFF666666);
  static const Color neutralSoft = Color(0xFFF1F1F1);

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final bool isNormal = normalized.contains('normal');
    final bool isWarning =
        normalized.contains('pre') ||
        normalized.contains('overweight') ||
        normalized.contains('elevated') ||
        normalized.contains('risk');

    final bool isDanger =
        normalized.contains('diabetes') ||
        normalized.contains('hypertension') ||
        normalized.contains('obesity') ||
        normalized.contains('obesitas');

    Color color = neutral;
    Color backgroundColor = neutralSoft;

    if (isNormal) {
      color = good;
      backgroundColor = goodSoft;
    } else if (isDanger) {
      color = danger;
      backgroundColor = dangerSoft;
    } else if (isWarning) {
      color = warning;
      backgroundColor = warningSoft;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.isEmpty ? '-' : status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
