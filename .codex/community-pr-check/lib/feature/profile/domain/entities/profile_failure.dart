// Typed failure returned by Profile, Analytics, and Settings operations.
// Keeps domain error handling explicit without leaking raw exceptions.
import 'entities_imports.dart';

class ProfileFailure extends Equatable {
  const ProfileFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
