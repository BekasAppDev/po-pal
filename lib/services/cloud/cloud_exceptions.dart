class CloudException implements Exception {
  const CloudException();
}

class CouldNotCreateUserDocumentException implements CloudException {}

class CouldNotCreateExerciseException implements CloudException {}

class CouldNotGetExercisesException implements CloudException {}

class CouldNotUpdateExerciseException implements CloudException {}

class CouldNotDeleteExerciseException implements CloudException {}

class CouldNotCreateWorkoutException implements CloudException {}

class CouldNotUpdateWorkoutException implements CloudException {}

class CouldNotDeleteWorkoutException implements CloudException {}

class CouldNotGetWorkoutsException implements CloudException {}

class CouldNotDeleteUserDocumentException implements Exception {}
