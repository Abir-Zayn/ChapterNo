// A person visible in the Community feed, kept to privacy-safe fields.
// Only a display name, initials, and a rough location are shared; no email,
// phone number, or school-identifying detail ever belongs here.
import 'package:equatable/equatable.dart';

class CommunityAuthor extends Equatable {
  const CommunityAuthor({
    required this.id,
    required this.displayName,
    required this.initials,
    this.location,
  });

  /// Stable identifier; 'me' is reserved for the signed-in student.
  final String id;
  final String displayName;
  final String initials;
  final String? location;

  bool get isMe => id == 'me';

  @override
  List<Object?> get props => [id, displayName, initials, location];
}
