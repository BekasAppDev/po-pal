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
  final SortOption exerciseOption;
  const PrefEventSetExerciseSortPref(this.exerciseOption);
}

class PrefEventSetWorkoutSortPref extends PrefEvent {
  final SortOption workoutOption;
  const PrefEventSetWorkoutSortPref(this.workoutOption);
}
