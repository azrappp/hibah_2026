import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartSeries {
  const ChartSeries({
    required this.name,
    required this.values,
    required this.color,
    this.unit = '',
  });

  final String name;
  final List<double?> values;
  final Color color;
  final String unit;
}

class MiniLineChart extends StatelessWidget {
  const MiniLineChart({
    super.key,
    required this.series,
    required this.height,
    this.labels,
    this.unit = '',
  });

  final List<ChartSeries> series;
  final List<String>? labels;
  final String unit;
  final double height;

  static const Color gridSoft = Color(0xFFEDEDED);
  static const Color textSoft = Color(0xFF8A8A8A);
  static const Color textDark = Color(0xFF25262A);

  @override
  Widget build(BuildContext context) {
    final allValues = series
        .expand((item) => item.values)
        .whereType<double>()
        .toList();

    if (allValues.isEmpty) {
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

    final maxLength = series.fold<int>(
      0,
      (max, item) => item.values.length > max ? item.values.length : max,
    );

    final minY = getMinY(allValues);
    final maxY = getMaxY(allValues);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Legend(series: series),

        const SizedBox(height: 8),

        SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 4, 10, 4),
            child: LineChart(
              LineChartData(
                minX: -0.1,
                maxX: (maxLength - 1).toDouble() + 0.1,
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
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: getInterval(minY, maxY),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          formatValue(value),
                          style: const TextStyle(
                            color: textSoft,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
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
                            index >= maxLength) {
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
                  handleBuiltInTouches: true,
                  touchSpotThreshold: 18,
                  distanceCalculator: (touchPoint, spotPixelCoordinates) {
                    final dx = touchPoint.dx - spotPixelCoordinates.dx;
                    final dy = touchPoint.dy - spotPixelCoordinates.dy;
                    return dx * dx + dy * dy;
                  },
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 14,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    tooltipMargin: 10,
                    getTooltipColor: (_) => Colors.white,
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final index = spot.x.round();
                        final label = getTooltipLabel(index);

                        final seriesName =
                            spot.barIndex >= 0 && spot.barIndex < series.length
                            ? series[spot.barIndex].name
                            : 'Data';
                        final seriesUnit =
                            spot.barIndex >= 0 && spot.barIndex < series.length
                            ? series[spot.barIndex].unit
                            : unit;

                        return LineTooltipItem(
                          '$seriesName\n',
                          const TextStyle(
                            color: Color(0xFF25262A),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '${formatValue(spot.y)}${seriesUnit.isEmpty ? '' : ' $seriesUnit'}\n',
                              style: const TextStyle(
                                color: Color(0xFF444444),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                            ),
                            TextSpan(
                              text: shortLabel(label),
                              style: const TextStyle(
                                color: Color(0xFF8A8A8A),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                  getTouchedSpotIndicator: (barData, spotIndexes) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: (barData.color ?? textDark).withValues(
                            alpha: 0.28,
                          ),
                          strokeWidth: 1.2,
                          dashArray: [4, 4],
                        ),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4.6,
                              color: Colors.white,
                              strokeWidth: 2.4,
                              strokeColor: barData.color ?? textDark,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                ),

                lineBarsData: series.map((item) {
                  final spots = <FlSpot>[];

                  for (int i = 0; i < item.values.length; i++) {
                    final value = item.values[i];

                    if (value != null) {
                      spots.add(FlSpot(i.toDouble(), value));
                    }
                  }

                  return LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.28,
                    color: item.color,
                    barWidth: 2.6,
                    isStrokeCapRound: true,
                    preventCurveOverShooting: true,
                    belowBarData: BarAreaData(show: false),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3.4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: item.color,
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
              duration: const Duration(milliseconds: 850),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      ],
    );
  }

  static double getMinY(List<double> data) {
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) {
      return (minValue - 5).clamp(0, double.infinity).toDouble();
    }

    final minY = minValue - (range * 0.18);

    return minY < 0 ? 0 : minY;
  }

  bool shouldShowBottomLabel(int index, int maxLength) {
    if (labels == null || labels!.isEmpty) return false;
    if (index < 0 || index >= labels!.length) return false;

    if (maxLength <= 1) return index == 0;

    if (maxLength == 2) {
      if (labels![0] == labels![1]) {
        return index == 0;
      }

      return index == 0 || index == maxLength - 1;
    }

    final middle = (maxLength / 2).floor();

    return index == 0 || index == middle || index == maxLength - 1;
  }

  static double getMaxY(List<double> data) {
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) {
      return maxValue + 5;
    }

    return maxValue + (range * 0.30);
  }

  static double getInterval(double minY, double maxY) {
    final range = maxY - minY;

    if (range <= 10) return 2;
    if (range <= 30) return 10;
    if (range <= 80) return 20;

    return 50;
  }

  static String formatValue(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  static String shortLabel(String label) {
    if (label.length <= 5) return label;

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

class _Legend extends StatelessWidget {
  const _Legend({required this.series});

  final List<ChartSeries> series;

  static const Color textMedium = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: series.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              item.name,
              style: const TextStyle(
                color: textMedium,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
