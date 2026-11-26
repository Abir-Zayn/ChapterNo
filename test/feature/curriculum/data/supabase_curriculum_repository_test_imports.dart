// Exposes test packages, Mocktail, and curriculum repository collaborators.
// Keeps test dependency declarations separate from repository test specs.
export 'dart:async';
export 'dart:io';

export 'package:chapter_no/feature/curriculum/data/repo/supabase_curriculum_repository.dart';
export 'package:chapter_no/feature/curriculum/data/resource/curriculum_cache_store.dart';
export 'package:chapter_no/feature/curriculum/data/resource/curriculum_local_cache_data_source.dart';
export 'package:chapter_no/feature/curriculum/data/resource/curriculum_remote_data_source.dart';
export 'package:chapter_no/feature/curriculum/domain/entities/academic_group.dart';
export 'package:chapter_no/feature/curriculum/domain/entities/curriculum_failure.dart';
export 'package:dartz/dartz.dart' show Either, Left, Right;
export 'package:flutter_test/flutter_test.dart';
export 'package:mocktail/mocktail.dart';
