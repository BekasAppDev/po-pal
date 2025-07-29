import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:po_pal/services/cloud/cloud_exercise_history.dart';
import 'package:po_pal/services/cloud/firebase_cloud_storage.dart';

class ExerciseChart extends StatelessWidget {
  final String userId;
  final String exerciseId;
  const ExerciseChart({
    super.key,
    required this.userId,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    final storage = FirebaseCloudStorage();

    return StreamBuilder<Iterable<CloudExerciseHistory>>(
      stream: storage.getExerciseHistory(uid: userId, exerciseId: exerciseId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final history =
            snapshot.data!.toList()
              ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

        if (history.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insights_outlined, size: 70, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "No progress yet",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Your progress on this exercise will appear here once you log a session.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        }

        final spots = List<FlSpot>.generate(history.length, (i) {
          final entry = history[i];
          final double value;
          value = (entry.weight).toDouble();

          return FlSpot(i.toDouble(), value);
        });

        final minY = 0.0;
        final maxY =
            (history
                .map((e) => (e.weight).toDouble())
                .fold<double>(
                  0,
                  (prev, element) => element > prev ? element : prev,
                )) *
            1.1;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (spots.length - 1).toDouble(),
              minY: minY,
              maxY: maxY,
              backgroundColor: Colors.white,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3,
                  color: Colors.black,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(0, 0, 0, 0.8),
                        Color.fromRGBO(255, 255, 255, 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      );
                    },
                    interval: (maxY - minY) / 4,
                    minIncluded: true,
                    maxIncluded: true,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor:
                      (touchedSpot) => const Color.fromARGB(255, 234, 232, 232),
                ),
                getTouchedSpotIndicator: (barData, spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      FlLine(color: Colors.transparent, strokeWidth: 0),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.black,
                            strokeWidth: 0,
                            strokeColor: Colors.transparent,
                          );
                        },
                      ),
                    );
                  }).toList();
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  top: BorderSide(
                    color: Color.fromARGB(255, 234, 232, 232),
                    width: 2,
                  ),
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 234, 232, 232),
                    width: 2,
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                drawHorizontalLine: true,
                horizontalInterval: (maxY - minY) / 4,
                getDrawingHorizontalLine:
                    (value) => const FlLine(
                      color: Color.fromARGB(255, 234, 232, 232),
                      strokeWidth: 2,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}
