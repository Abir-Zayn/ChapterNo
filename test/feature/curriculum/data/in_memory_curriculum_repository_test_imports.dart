// Exposes test packages and curriculum domain/repository types for unit tests.
// Keeps test dependency declarations separate from repository test cases.
export 'dart:async';

export 'package:chapter_no/feature/curriculum/data/repo/in_memory_curriculum_repository.dart';
export 'package:chapter_no/feature/curriculum/domain/entities/academic_group.dart';
export 'package:chapter_no/feature/curriculum/domain/entities/chapter.dart';
export 'package:chapter_no/feature/curriculum/domain/entities/curriculum_failure.dart';
export 'package:chapter_no/feature/curriculum/domain/entities/education_board.dart';
export 'package:chapter_no/feature/curriculum/domain/entities/subject.dart';
export 'package:chapter_no/feature/curriculum/domain/entities/topic.dart';
export 'package:chapter_no/feature/curriculum/domain/repositories/curriculum_repository.dart';
export 'package:dartz/dartz.dart' show Either, Left, Right;
export 'package:flutter_test/flutter_test.dart';
