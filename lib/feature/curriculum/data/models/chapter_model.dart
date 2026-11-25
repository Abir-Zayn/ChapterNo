// Serialization DTO mapping chapters rows to Chapter domain entities.
// Validates required keys and converts nullable bilingual chapter summaries.
import 'models_imports.dart';

class ChapterModel {
  const ChapterModel({
    required this.id,
    required this.subjectId,
    required this.chapterNumber,
    required this.titleEn,
    required this.titleBn,
    required this.sortOrder,
    required this.isActive,
    this.summaryEn,
    this.summaryBn,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final subjectId = json['subject_id'];
    final chapterNumber = json['chapter_number'];
    final titleEn = json['title_en'];
    final titleBn = json['title_bn'];
    if (id is! num ||
        subjectId is! num ||
        chapterNumber is! num ||
        titleEn is! String ||
        titleBn is! String) {
      throw const FormatException('Invalid chapter payload');
    }
    return ChapterModel(
      id: id.toInt(),
      subjectId: subjectId.toInt(),
      chapterNumber: chapterNumber.toInt(),
      titleEn: titleEn,
      titleBn: titleBn,
      summaryEn: json['summary_en'] as String?,
      summaryBn: json['summary_bn'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  factory ChapterModel.fromEntity(Chapter entity) {
    return ChapterModel(
      id: entity.id,
      subjectId: entity.subjectId,
      chapterNumber: entity.chapterNumber,
      titleEn: entity.titleEn,
      titleBn: entity.titleBn,
      summaryEn: entity.summaryEn,
      summaryBn: entity.summaryBn,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
    );
  }

  final int id;
  final int subjectId;
  final int chapterNumber;
  final String titleEn;
  final String titleBn;
  final String? summaryEn;
  final String? summaryBn;
  final int sortOrder;
  final bool isActive;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'subject_id': subjectId,
    'chapter_number': chapterNumber,
    'title_en': titleEn,
    'title_bn': titleBn,
    'summary_en': summaryEn,
    'summary_bn': summaryBn,
    'sort_order': sortOrder,
    'is_active': isActive,
  };

  Chapter toEntity() => Chapter(
    id: id,
    subjectId: subjectId,
    chapterNumber: chapterNumber,
    titleEn: titleEn,
    titleBn: titleBn,
    summaryEn: summaryEn,
    summaryBn: summaryBn,
    sortOrder: sortOrder,
    isActive: isActive,
  );
}
