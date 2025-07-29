import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:po_pal/services/preferences/bloc/pref_events.dart';
import 'package:po_pal/services/preferences/bloc/pref_states.dart';
import 'package:po_pal/services/preferences/preferences_service.dart';
import 'package:po_pal/utilities/enums/sort_option.dart';

class PrefBloc extends Bloc<PrefEvent, PrefState> {
  PrefBloc() : super(const PrefStateInitial()) {
    //load preferences
    on<PrefEventLoadPreferences>((event, emit) async {
      final bool weightPref = await PreferencesService.getWeightPreference();
      final SortOption exerciseSortOption =
          await PreferencesService.getExerciseSortPreference();
      final SortOption workoutSortOption =
          await PreferencesService.getWorkoutSortPreference();
      emit(
        PrefStateLoaded(
          isKg: weightPref,
          exerciseSortOption: exerciseSortOption,
          workoutSortOption: workoutSortOption,
        ),
      );
    });

    //set weight preference
    on<PrefEventSetWeightPref>((event, emit) async {
      await PreferencesService.setWeightPreference(event.isKg);
      final state = this.state;
      if (state is PrefStateLoaded) {
        emit(
          PrefStateLoaded(
            isKg: event.isKg,
            exerciseSortOption: state.exerciseSortOption,
            workoutSortOption: state.workoutSortOption,
          ),
        );
      }
    });

    //set exercise sort preference
    on<PrefEventSetExerciseSortPref>((event, emit) async {
      await PreferencesService.setExerciseSortPreference(event.exerciseOption);
      final state = this.state;
      if (state is PrefStateLoaded) {
        emit(
          PrefStateLoaded(
            isKg: state.isKg,
            exerciseSortOption: event.exerciseOption,
            workoutSortOption: state.workoutSortOption,
          ),
        );
      }
    });

    //set workout sort preference
    on<PrefEventSetWorkoutSortPref>((event, emit) async {
      await PreferencesService.setWorkoutSortPreference(event.workoutOption);
      final state = this.state;
      if (state is PrefStateLoaded) {
        emit(
          PrefStateLoaded(
            isKg: state.isKg,
            exerciseSortOption: state.exerciseSortOption,
            workoutSortOption: event.workoutOption,
          ),
        );
      }
    });
  }
}
