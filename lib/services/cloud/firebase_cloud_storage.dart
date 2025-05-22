import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:po_pal/services/cloud/cloud_exceptions.dart';
import 'package:po_pal/services/cloud/cloud_exercise.dart';

class FirebaseCloudStorage {
  final _firestore = FirebaseFirestore.instance;

  // User document reference
  DocumentReference _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  // Exercises collection reference
  CollectionReference<Map<String, dynamic>> _exercises(String uid) =>
      _userDoc(uid).collection('exercises');

  // Create user document
  Future<void> createUserDocument({required String uid}) async {
    try {
      await _userDoc(uid).set({'_': 1}, SetOptions(merge: true));
    } catch (e) {
      throw CouldNotCreateUserDocumentException();
    }
  }

  // Create exercise
  Future<CloudExercise> createExercise({
    required String uid,
    required String name,
    required int weight,
    required int reps,
  }) async {
    try {
      final docRef = await _exercises(
        uid,
      ).add({'name': name, 'weight': weight, 'reps': reps});

      final docSnap = await docRef.get();
      return CloudExercise.fromSnapshot(docSnap);
    } catch (e) {
      throw CouldNotCreateExerciseException();
    }
  }

  //get all notes
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

  //update exercise
  Future<void> updateExercise({
    required String uid,
    required String documentId,
    required int weight,
    required int reps,
  }) async {
    try {
      final updates = <String, dynamic>{};
      updates['weight'] = weight;
      updates['reps'] = reps;

      await _exercises(uid).doc(documentId).update(updates);
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

  // Delete user document
  Future<void> deleteUser({required String uid}) async {
    try {
      //delete subcollections first
      final exerciseDocs = await _exercises(uid).get();
      for (var doc in exerciseDocs.docs) {
        await doc.reference.delete();
      }

      await _userDoc(uid).delete();
    } catch (e) {
      throw CouldNotDeleteUserDocumentException();
    }
  }

  //singleton
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
