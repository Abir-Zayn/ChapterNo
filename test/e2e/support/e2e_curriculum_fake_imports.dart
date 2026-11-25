// Exposes Dart core, dartz, and curriculum models for FakeCurriculumCatalogue.
// Keeps E2E curriculum cache double imports isolated and narrow.
export 'dart:async';
export 'dart:collection';
export 'dart:convert';

export 'package:dartz/dartz.dart' show Either, Left, Right;

export 'e2e_curriculum_models.dart';
