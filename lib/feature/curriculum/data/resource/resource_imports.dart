// Exposes Dart SDK primitives, domain entities, and DTO models for data sources.
// Keeps dependency declarations separate from remote and cache implementations.
export 'dart:async';
export 'dart:collection';
export 'dart:convert';
export 'dart:io';

export '../../domain/entities/academic_group.dart';
export '../../domain/entities/chapter.dart';
export '../../domain/entities/curriculum_failure.dart';
export '../../domain/entities/education_board.dart';
export '../../domain/entities/subject.dart';
export '../../domain/entities/topic.dart';
export '../models/chapter_model.dart';
export '../models/education_board_model.dart';
export '../models/subject_model.dart';
export '../models/topic_model.dart';
