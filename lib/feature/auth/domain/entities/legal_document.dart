// A legal document (terms, privacy) shown to students as readable sections.
// Pure content model; text is supplied by the data layer.
import 'package:equatable/equatable.dart';

enum LegalDocumentType { terms, privacy }

class LegalSection extends Equatable {
  const LegalSection({required this.heading, required this.paragraphs});

  final String heading;
  final List<String> paragraphs;

  @override
  List<Object?> get props => [heading, paragraphs];
}

class LegalDocument extends Equatable {
  const LegalDocument({
    required this.type,
    required this.title,
    required this.summary,
    required this.lastUpdated,
    required this.sections,
    this.isDraft = false,
  });

  final LegalDocumentType type;
  final String title;
  final String summary;

  /// Display-ready date, for example "12 November 2026".
  final String lastUpdated;
  final List<LegalSection> sections;

  /// True until the owner and legal review approve the wording.
  final bool isDraft;

  @override
  List<Object?> get props => [
    type,
    title,
    summary,
    lastUpdated,
    sections,
    isDraft,
  ];
}
