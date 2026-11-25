// The signed-in student's public community profile and its counters.
// Only privacy-safe fields: no school-identifying data or contact details.
import 'package:equatable/equatable.dart';

/// Content tabs on the community profile dashboard.
enum CommunityProfileTab { posts, questions, notes }

/// Ordering for a profile's post lists.
enum CommunityProfileSort { newest, top }

class CommunityProfileStats extends Equatable {
  const CommunityProfileStats({
    required this.posts,
    required this.questions,
    required this.notes,
    required this.upvotes,
  });

  final int posts;
  final int questions;
  final int notes;
  final int upvotes;

  @override
  List<Object?> get props => [posts, questions, notes, upvotes];
}

class CommunityProfile extends Equatable {
  const CommunityProfile({
    required this.displayName,
    required this.handle,
    required this.initials,
    required this.batchLabel,
    required this.bio,
    required this.stats,
    this.verified = false,
    this.active = false,
  });

  final String displayName;

  /// Public handle, for example '@alex_studies'.
  final String handle;
  final String initials;

  /// Cohort label, for example "SSC Batch '26 · Science".
  final String batchLabel;
  final String bio;
  final CommunityProfileStats stats;

  /// Whether the profile shows a verified-student badge.
  final bool verified;

  /// Whether the profile shows an active-student badge.
  final bool active;

  @override
  List<Object?> get props => [
    displayName,
    handle,
    initials,
    batchLabel,
    bio,
    stats,
    verified,
    active,
  ];
}
