class CloudException implements Exception {
  const CloudException();
}

class CouldNotCreateUserDocumentException implements CloudException {}

class CouldNotCreateExerciseException implements CloudException {}

class CouldNotGetExercisesException implements CloudException {}

class CouldNotUpdateExerciseException implements CloudException {}

class CouldNotDeleteExerciseException implements CloudException {}

class CouldNotDeleteUserDocumentException implements Exception {}
