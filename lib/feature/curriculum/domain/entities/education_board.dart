// Immutable domain entity representing a Bangladesh education board.
// Carries bilingual board names and deterministic catalogue sort order.
import 'entities_imports.dart';

class EducationBoard extends Equatable {
  const EducationBoard({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.nameBn,
    required this.sortOrder,
    this.isActive = true,
  });

  final int id;
  final String code;
  final String nameEn;
  final String nameBn;
  final int sortOrder;
  final bool isActive;

  String get titleEn => nameEn;
  String get titleBn => nameBn;

  String localizedName({bool isBangla = false}) => isBangla ? nameBn : nameEn;

  @override
  List<Object?> get props => [id, code, nameEn, nameBn, sortOrder, isActive];
}
