import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:po_pal/services/cloud/cloud_exercise_history.dart';
import 'package:po_pal/services/cloud/firebase_cloud_storage.dart';
import 'package:po_pal/services/preferences/bloc/pref_bloc.dart';
import 'package:po_pal/services/preferences/bloc/pref_events.dart';
import 'package:po_pal/services/preferences/bloc/pref_states.dart';

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

        return BlocBuilder<PrefBloc, PrefState>(
          builder: (context, state) {
            final chartMode =
                state is PrefStateLoaded ? state.chartMode : false;

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
                      Icon(
                        Icons.insights_outlined,
                        size: 70,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "No progress yet",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
              final value =
                  chartMode
                      ? (entry.weight * entry.reps).toDouble()
                      : entry.weight.toDouble();
              return FlSpot(i.toDouble(), value);
            });

            final minY = 0.0;
            final maxY =
                history
                    .map(
                      (e) =>
                          chartMode
                              ? (e.weight * e.reps).toDouble()
                              : e.weight.toDouble(),
                    )
                    .fold<double>(
                      0,
                      (prev, element) => element > prev ? element : prev,
                    ) *
                1.1;

            return SizedBox.expand(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 36,
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    context.read<PrefBloc>().add(
                                      const PrefEventSetChartModePref(false),
                                    );
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color:
                                          !chartMode
                                              ? Colors.black12
                                              : Colors.white,
                                      border: const Border(
                                        left: BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            234,
                                            232,
                                            232,
                                          ),
                                          width: 2,
                                        ),
                                        top: BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            234,
                                            232,
                                            232,
                                          ),
                                          width: 2,
                                        ),
                                        bottom: BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            234,
                                            232,
                                            232,
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Weight'),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    context.read<PrefBloc>().add(
                                      const PrefEventSetChartModePref(true),
                                    );
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color:
                                          chartMode
                                              ? Colors.black12
                                              : Colors.white,
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                          255,
                                          234,
                                          232,
                                          232,
                                        ),
                                        width: 2,
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Load'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
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
                                gradient: const LinearGradient(
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
                                  (_) =>
                                      const Color.fromARGB(255, 234, 232, 232),
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final rawEntry = history[spot.spotIndex];
                                  final displayValue =
                                      chartMode
                                          ? rawEntry.weight * rawEntry.reps
                                          : rawEntry.weight;
                                  return LineTooltipItem(
                                    displayValue.toStringAsFixed(1),
                                    const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                            getTouchedSpotIndicator: (barData, spotIndexes) {
                              return spotIndexes.map((index) {
                                return TouchedSpotIndicatorData(
                                  FlLine(
                                    color: Colors.transparent,
                                    strokeWidth: 0,
                                  ),
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
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
