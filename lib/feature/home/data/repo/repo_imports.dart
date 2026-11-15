// Exposes dependencies used by the Home repository implementations.
// Keeps external library and domain dependencies grouped in one location.
export 'package:dartz/dartz.dart';

export '../../domain/entities/daily_goal.dart';
export '../../domain/entities/learning_session.dart';
export '../../domain/entities/student_dashboard.dart';
export '../../domain/entities/study_activity_item.dart';
export '../../domain/entities/subject_progress.dart';
export '../../domain/repositories/home_repository.dart';
export 'in_memory_home_repository.dart';
