// Exposes Dartz, domain contracts, and data sources for curriculum repositories.
// Keeps repository dependency declarations separate from repository logic.
export 'package:dartz/dartz.dart';

export '../../domain/entities/academic_group.dart';
export '../../domain/entities/chapter.dart';
export '../../domain/entities/curriculum_failure.dart';
export '../../domain/entities/education_board.dart';
export '../../domain/entities/subject.dart';
export '../../domain/entities/topic.dart';
export '../../domain/repositories/curriculum_repository.dart';
export '../resource/curriculum_cache_store.dart' show CacheLookupResult;
export '../resource/curriculum_local_cache_data_source.dart';
export '../resource/curriculum_remote_data_source.dart';
