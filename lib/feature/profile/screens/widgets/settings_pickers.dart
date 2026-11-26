// Modal bottom-sheet pickers for Settings Learning Track and Language.
// Keeps selection sheet UI separate from SettingsPage composition.
import 'widgets_imports.dart';

Future<LearningTrack?> showLearningTrackPicker(
  BuildContext context,
  LearningTrack current,
) {
  return showModalBottomSheet<LearningTrack>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: AppText.title('Learning Track'),
          ),
          for (final track in LearningTrack.values)
            ListTile(
              title: AppText(track.label),
              trailing: track == current
                  ? Icon(PhosphorIconsRegular.check, color: context.primary)
                  : null,
              onTap: () => Navigator.of(sheetContext).pop(track),
            ),
        ],
      ),
    ),
  );
}

Future<AppLanguage?> showAppLanguagePicker(
  BuildContext context,
  AppLanguage current,
) {
  return showModalBottomSheet<AppLanguage>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: AppText.title('App Language'),
          ),
          for (final lang in AppLanguage.values)
            ListTile(
              title: AppText(lang.label),
              trailing: lang == current
                  ? Icon(PhosphorIconsRegular.check, color: context.primary)
                  : null,
              onTap: () => Navigator.of(sheetContext).pop(lang),
            ),
        ],
      ),
    ),
  );
}
