// Mocktail double for AuthRepository shared by auth Cubit and page tests.
// Call registerAuthFallbacks() once per test file before stubbing.
import 'package:chapter_no/feature/auth/domain/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void registerAuthFallbacks() {
  registerFallbackValue(DateTime(2000));
}
