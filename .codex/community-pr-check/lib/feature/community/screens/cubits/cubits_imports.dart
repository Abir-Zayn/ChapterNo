// Exposes dependencies used by the community feature's Cubits and states.
// Keeps dependency declarations separate from state transition code.
export 'package:dartz/dartz.dart' show Either, Left, Right;
export 'package:equatable/equatable.dart';
export 'package:flutter_bloc/flutter_bloc.dart' show Cubit;

export '../../data/resource/community_fixtures.dart';
export '../../domain/entities/activity_entry.dart';
export '../../domain/entities/community_failure.dart';
export '../../domain/entities/community_post.dart';
export '../../domain/entities/community_profile.dart';
export '../../domain/entities/community_subjects.dart';
export '../../domain/entities/post_draft.dart';
export '../../domain/repositories/community_repository.dart';
export '../../domain/usecase/post_draft_validator.dart';
