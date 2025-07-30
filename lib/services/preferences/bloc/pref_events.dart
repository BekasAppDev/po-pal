import 'package:flutter/foundation.dart';
import 'package:po_pal/utilities/enums/sort_option.dart';

@immutable
abstract class PrefEvent {
  const PrefEvent();
}

class PrefEventLoadPreferences extends PrefEvent {
  const PrefEventLoadPreferences();
}

class PrefEventSetWeightPref extends PrefEvent {
  final bool isKg;
  const PrefEventSetWeightPref(this.isKg);
}

class PrefEventSetExerciseSortPref extends PrefEvent {
  final SortOption exerciseSortOption;
  const PrefEventSetExerciseSortPref(this.exerciseSortOption);
}

class PrefEventSetWorkoutSortPref extends PrefEvent {
  final SortOption workoutSortOption;
  const PrefEventSetWorkoutSortPref(this.workoutSortOption);
}

class PrefEventSetChartModePref extends PrefEvent {
  final bool chartMode;
  const PrefEventSetChartModePref(this.chartMode);
}
