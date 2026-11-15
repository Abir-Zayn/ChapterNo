// Signed-in student identity used by the auth flow.
// Holds only the minimum identity data the client needs.
import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({required this.id, required this.email});

  final String id;
  final String email;

  @override
  List<Object?> get props => [id, email];
}
