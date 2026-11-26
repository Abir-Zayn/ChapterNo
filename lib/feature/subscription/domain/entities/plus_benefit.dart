// One benefit a student gains on the Plus plan, shown on the upgrade screen.
// The kind lets the UI pick an icon without the domain depending on Flutter.
import 'entities_imports.dart';

enum PlusBenefitKind { practice, aiSupport, revision, analytics, feedback }

class PlusBenefit extends Equatable {
  const PlusBenefit({
    required this.kind,
    required this.title,
    this.description,
  });

  final PlusBenefitKind kind;
  final String title;
  final String? description;

  @override
  List<Object?> get props => [kind, title, description];
}
