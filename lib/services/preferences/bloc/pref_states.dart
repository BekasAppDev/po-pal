import 'package:flutter/foundation.dart';
import 'package:po_pal/utilities/enums/sort_option.dart';

@immutable
abstract class PrefState {
  const PrefState();
}

class PrefStateInitial extends PrefState {
  const PrefStateInitial();
}

class PrefStateLoaded extends PrefState {
  final bool isKg;
  final SortOption exerciseSortOption;
  final SortOption workoutSortOption;
  final bool chartMode;

  const PrefStateLoaded({
    required this.isKg,
    required this.exerciseSortOption,
    required this.workoutSortOption,
    required this.chartMode,
  });
}
