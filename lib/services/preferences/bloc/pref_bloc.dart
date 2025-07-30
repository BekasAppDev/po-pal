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
      final bool chartMode = await PreferencesService.getChartModePreference();

      emit(
        PrefStateLoaded(
          isKg: weightPref,
          exerciseSortOption: exerciseSortOption,
          workoutSortOption: workoutSortOption,
          chartMode: chartMode,
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
            chartMode: state.chartMode,
          ),
        );
      }
    });

    //set exercise sort preference
    on<PrefEventSetExerciseSortPref>((event, emit) async {
      await PreferencesService.setExerciseSortPreference(
        event.exerciseSortOption,
      );
      final state = this.state;
      if (state is PrefStateLoaded) {
        emit(
          PrefStateLoaded(
            isKg: state.isKg,
            exerciseSortOption: event.exerciseSortOption,
            workoutSortOption: state.workoutSortOption,
            chartMode: state.chartMode,
          ),
        );
      }
    });

    //set workout sort preference
    on<PrefEventSetWorkoutSortPref>((event, emit) async {
      await PreferencesService.setWorkoutSortPreference(
        event.workoutSortOption,
      );
      final state = this.state;
      if (state is PrefStateLoaded) {
        emit(
          PrefStateLoaded(
            isKg: state.isKg,
            exerciseSortOption: state.exerciseSortOption,
            workoutSortOption: event.workoutSortOption,
            chartMode: state.chartMode,
          ),
        );
      }
    });

    //set chart mode preference
    on<PrefEventSetChartModePref>((event, emit) async {
      await PreferencesService.setChartModePreference(event.chartMode);
      final state = this.state;
      if (state is PrefStateLoaded) {
        emit(
          PrefStateLoaded(
            isKg: state.isKg,
            exerciseSortOption: state.exerciseSortOption,
            workoutSortOption: state.workoutSortOption,
            chartMode: event.chartMode,
          ),
        );
      }
    });
  }
}
