import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MiniLineChart extends StatelessWidget {
  const MiniLineChart({
    super.key,
    required this.values,
    required this.height,
    this.labels,
    this.unit = '',
  });

  final List<double> values;
  final List<String>? labels;
  final String unit;
  final double height;

  static const Color healthGreen = Color(0xFF2F5D50);
  static const Color healthGreenSoft = Color(0xFFEFF4F1);
  static const Color gridSoft = Color(0xFFEDEDED);
  static const Color textSoft = Color(0xFF8A8A8A);
  static const Color textDark = Color(0xFF25262A);

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Belum ada data grafik.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (values.length == 1) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Data pertama: ${formatValue(values.first)} $unit',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final spots = values.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    final minY = getMinY(values);
    final maxY = getMaxY(values);

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (values.length - 1).toDouble(),
            minY: minY,
            maxY: maxY,

            clipData: const FlClipData.all(),

            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: getInterval(minY, maxY),
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: gridSoft,
                  strokeWidth: 1,
                  dashArray: [4, 4],
                );
              },
            ),

            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: labels != null && labels!.isNotEmpty,
                  reservedSize: 28,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();

                    if (labels == null ||
                        index < 0 ||
                        index >= labels!.length ||
                        index >= values.length) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        shortLabel(labels![index]),
                        style: const TextStyle(
                          color: textSoft,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            borderData: FlBorderData(show: false),

            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipRoundedRadius: 12,
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                getTooltipColor: (_) => textDark,
                getTooltipItems: (spots) {
                  return spots.map((spot) {
                    final index = spot.x.toInt();
                    final label = getTooltipLabel(index);

                    return LineTooltipItem(
                      '$label\n${formatValue(spot.y)} $unit',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    );
                  }).toList();
                },
              ),
              getTouchedSpotIndicator: (barData, spotIndexes) {
                return spotIndexes.map((index) {
                  return TouchedSpotIndicatorData(
                    const FlLine(color: healthGreen, strokeWidth: 1.4),
                    FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: healthGreen,
                        );
                      },
                    ),
                  );
                }).toList();
              },
            ),

            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.32,
                color: healthGreen,
                barWidth: 3,
                isStrokeCapRound: true,
                preventCurveOverShooting: true,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      healthGreen.withValues(alpha: 0.22),
                      healthGreen.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 3.8,
                      color: Colors.white,
                      strokeWidth: 2.4,
                      strokeColor: healthGreen,
                    );
                  },
                ),
              ),
            ],
          ),

          // Animation is supported here.
          duration: const Duration(milliseconds: 850),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  double getMinY(List<double> data) {
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) {
      return minValue - 1;
    }

    return minValue - (range * 0.18);
  }

  double getMaxY(List<double> data) {
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) {
      return maxValue + 1;
    }

    return maxValue + (range * 0.18);
  }

  double getInterval(double minY, double maxY) {
    final range = maxY - minY;

    if (range <= 0) return 1;

    return range / 3;
  }

  String formatValue(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  String shortLabel(String label) {
    if (label.length <= 5) return label;

    // Example: 2026-05-22 -> 05/22
    if (label.length >= 10 && label.contains('-')) {
      final parts = label.split('-');
      if (parts.length >= 3) {
        return '${parts[1]}/${parts[2]}';
      }
    }

    return label.substring(0, 5);
  }

  String getTooltipLabel(int index) {
    if (labels == null || index < 0 || index >= labels!.length) {
      return 'Data ${index + 1}';
    }

    return labels![index];
  }
}
