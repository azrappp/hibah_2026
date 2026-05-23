import 'package:flutter/material.dart';
import 'package:hibah_2026/widgets/mini_line_chart.dart';

class ScreeningProgressCard extends StatelessWidget {
  const ScreeningProgressCard({
    super.key,
    required this.title,
    required this.currentValue,
    required this.status,
    required this.values,
    required this.icon,
    this.unit = '',
    this.labels,
  });

  final String title;
  final String currentValue;
  final String status;
  final List<double> values;
  final IconData icon;
  final String unit;
  final List<String>? labels;

  static const Color primaryPurple = Color(0xFF5E4AA0);
  static const Color cardPurple = Color(0xFFF0EAF5);

  @override
  Widget build(BuildContext context) {
    final trend = getTrend(values);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardPurple,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: Colors.white.withOpacity(0.65),
                child: Icon(icon, color: primaryPurple, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: primaryPurple,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TrendBadge(trend: trend),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentValue,
                style: const TextStyle(
                  color: Color(0xFF202124),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 4),

          Text(
            status,
            style: const TextStyle(
              color: primaryPurple,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Tap titik grafik untuk melihat angka detail',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

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

  @override
  Widget build(BuildContext context) {
    final isUp = trend == 'naik';
    final isDown = trend == 'turun';

    final color = isUp
        ? Colors.orange
        : isDown
        ? Colors.green
        : Colors.grey;

    final icon = isUp
        ? Icons.trending_up_rounded
        : isDown
        ? Icons.trending_down_rounded
        : Icons.trending_flat_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
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
