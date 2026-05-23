import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MiniLineChart extends StatelessWidget {
  const MiniLineChart({
    super.key,
    required this.values,
    this.labels,
    this.height = 78,
    this.lineColor = const Color(0xFF5E4AA0),
    this.unit = '',
  });

  final List<double> values;
  final List<String>? labels;
  final double height;
  final Color lineColor;
  final String unit;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Belum cukup data',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final spots = values.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    final yPadding = ((maxValue - minValue).abs() * 0.18).clamp(1.0, 20.0);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (values.length - 1).toDouble(),
          minY: minValue == maxValue ? minValue - 1 : minValue - yPadding,
          maxY: minValue == maxValue ? maxValue + 1 : maxValue + yPadding,

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: getHorizontalInterval(minValue, maxValue),
            getDrawingHorizontalLine: (_) =>
                FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
          ),

          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),

          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchSpotThreshold: 22,
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(color: lineColor.withOpacity(0.35), strokeWidth: 2),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 5,
                        color: Colors.white,
                        strokeWidth: 3,
                        strokeColor: lineColor,
                      );
                    },
                  ),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 12,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              tooltipMargin: 10,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipColor: (_) => const Color(0xFF202124),
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final index = spot.x.toInt();
                  final value = spot.y;
                  final label = getLabel(index);

                  return LineTooltipItem(
                    '${formatNumber(value)} $unit\n$label',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  );
                }).toList();
              },
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.32,
              preventCurveOverShooting: true,
              barWidth: 3,
              color: lineColor,
              isStrokeCapRound: true,
              isStrokeJoinRound: true,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) {
                  return spot.x == 0 || spot.x == values.length - 1;
                },
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3.5,
                    color: lineColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withOpacity(0.12),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      ),
    );
  }

  String getLabel(int index) {
    if (labels == null || index < 0 || index >= labels!.length) {
      return 'Screening ${index + 1}';
    }

    return labels![index];
  }

  double getHorizontalInterval(double minValue, double maxValue) {
    final range = (maxValue - minValue).abs();

    if (range <= 5) return 1;
    if (range <= 20) return 5;
    if (range <= 50) return 10;

    return 25;
  }

  String formatNumber(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }
}
