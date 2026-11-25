// Serialization DTO mapping education_boards rows to EducationBoard entities.
// Validates required JSON fields for both PostgREST payloads and local cache.
import 'models_imports.dart';

class EducationBoardModel {
  const EducationBoardModel({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.nameBn,
    required this.sortOrder,
    required this.isActive,
  });

  factory EducationBoardModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final code = json['code'];
    final nameEn = json['name_en'];
    final nameBn = json['name_bn'];
    if (id is! num ||
        code is! String ||
        nameEn is! String ||
        nameBn is! String) {
      throw const FormatException('Invalid education board payload');
    }
    return EducationBoardModel(
      id: id.toInt(),
      code: code,
      nameEn: nameEn,
      nameBn: nameBn,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  factory EducationBoardModel.fromEntity(EducationBoard entity) {
    return EducationBoardModel(
      id: entity.id,
      code: entity.code,
      nameEn: entity.nameEn,
      nameBn: entity.nameBn,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
    );
  }

  final int id;
  final String code;
  final String nameEn;
  final String nameBn;
  final int sortOrder;
  final bool isActive;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'code': code,
    'name_en': nameEn,
    'name_bn': nameBn,
    'sort_order': sortOrder,
    'is_active': isActive,
  };

  EducationBoard toEntity() => EducationBoard(
    id: id,
    code: code,
    nameEn: nameEn,
    nameBn: nameBn,
    sortOrder: sortOrder,
    isActive: isActive,
  );
}
