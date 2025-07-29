import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:po_pal/services/cloud/cloud_exceptions.dart';
import 'package:po_pal/services/cloud/cloud_exercise.dart';
import 'package:po_pal/services/cloud/cloud_exercise_history.dart';
import 'package:po_pal/services/cloud/cloud_workout.dart';

class FirebaseCloudStorage {
  final _firestore = FirebaseFirestore.instance;

  // User document reference
  DocumentReference _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  // Exercises collection reference
  CollectionReference<Map<String, dynamic>> _exercises(String uid) =>
      _userDoc(uid).collection('exercises');

  // Workouts collection reference
  CollectionReference<Map<String, dynamic>> _workouts(String uid) =>
      _userDoc(uid).collection('workouts');

  // Exercise History subcollection reference
  CollectionReference<Map<String, dynamic>> _exerciseHistory(
    String uid,
    String exerciseId,
  ) => _exercises(uid).doc(exerciseId).collection('history');

  // Create exercise
  Future<CloudExercise> createExercise({
    required String uid,
    required String name,
    required double weight,
    required int reps,
  }) async {
    try {
      final userRef = _userDoc(uid);
      final userSnap = await userRef.get();

      if (!userSnap.exists) {
        await userRef.set({'_': 1}, SetOptions(merge: true));
      }

      final docRef = await _exercises(uid).add({
        'name': name,
        'weight': weight,
        'reps': reps,
        'relevancy': 1,
        'history': [],
      });

      final docSnap = await docRef.get();
      return CloudExercise.fromSnapshot(docSnap);
    } catch (e) {
      throw CouldNotCreateExerciseException();
    }
  }

  // Get all exercises
  Stream<Iterable<CloudExercise>> allExercises({required String uid}) {
    try {
      return _exercises(uid).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => CloudExercise.fromSnapshot(doc)),
      );
    } catch (e) {
      throw CouldNotGetExercisesException();
    }
  }

  // Get exercise history
  Stream<Iterable<CloudExerciseHistory>> getExerciseHistory({
    required String uid,
    required String exerciseId,
  }) {
    return _exerciseHistory(uid, exerciseId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(
            (doc) => CloudExerciseHistory.fromSnapshot(doc),
          ),
        );
  }

  // Update exercise
  Future<void> updateExercise({
    required String uid,
    required String documentId,
    required double weight,
    required int reps,
  }) async {
    try {
      final doc = await _exercises(uid).doc(documentId).get();
      if (!doc.exists) throw CouldNotUpdateExerciseException();

      final currentData = doc.data()!;
      await _exerciseHistory(uid, documentId).add({
        'weight': currentData['weight'],
        'reps': currentData['reps'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _exercises(uid).doc(documentId).update({
        'weight': weight,
        'reps': reps,
        'relevancy': FieldValue.increment(1),
      });
    } catch (e) {
      throw CouldNotUpdateExerciseException();
    }
  }

  // Delete exercise
  Future<void> deleteExercise({
    required String uid,
    required String documentId,
  }) async {
    try {
      await _exercises(uid).doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteExerciseException();
    }
  }

  // Create workout
  Future<CloudWorkout> createWorkout({
    required String uid,
    required String title,
    required List<String> exerciseIds,
  }) async {
    try {
      final userRef = _userDoc(uid);
      final userSnap = await userRef.get();

      if (!userSnap.exists) {
        await userRef.set({'_': 1}, SetOptions(merge: true));
      }

      final docRef = await _workouts(
        uid,
      ).add({'title': title, 'exerciseIds': exerciseIds, 'relevancy': 1});

      final docSnap = await docRef.get();
      return CloudWorkout.fromSnapshot(docSnap);
    } catch (e) {
      throw CouldNotCreateWorkoutException();
    }
  }

  // Update workout
  Future<void> updateWorkout({
    required String uid,
    required String documentId,
    required String title,
    required List<String> exerciseIds,
  }) async {
    try {
      await _workouts(uid).doc(documentId).update({
        'title': title,
        'exerciseIds': exerciseIds,
        'relevancy': FieldValue.increment(1),
      });
    } catch (e) {
      throw CouldNotUpdateWorkoutException();
    }
  }

  // Delete workout
  Future<void> deleteWorkout({
    required String uid,
    required String documentId,
  }) async {
    try {
      await _workouts(uid).doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteWorkoutException();
    }
  }

  // Get all workouts
  Stream<Iterable<CloudWorkout>> allWorkouts({required String uid}) {
    try {
      return _workouts(uid).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => CloudWorkout.fromSnapshot(doc)),
      );
    } catch (e) {
      throw CouldNotGetWorkoutsException();
    }
  }

  Future<void> deleteUser({required String uid}) async {
    try {
      final exerciseDocs = await _exercises(uid).get();
      for (var doc in exerciseDocs.docs) {
        await doc.reference.delete();
      }

      final workoutDocs = await _workouts(uid).get();
      for (var doc in workoutDocs.docs) {
        await doc.reference.delete();
      }

      await _userDoc(uid).delete();
    } catch (e) {
      throw CouldNotDeleteUserDocumentException();
    }
  }

  // Singleton
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
