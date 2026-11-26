// Reads and persists lightweight display preferences needed before frame one.
// Falls back safely when SharedPreferences is unavailable or throws.
import 'startup_preferences_imports.dart';

class StartupPreferencesSnapshot {
  const StartupPreferencesSnapshot({
    this.initialDarkMode = false,
    this.appLanguage = AppLanguage.english,
  });

  final bool initialDarkMode;
  final AppLanguage appLanguage;
}

class StartupPreferences {
  const StartupPreferences({this._prefsLoader});

  static const String darkModeKey = 'startup.dark_mode_enabled';
  static const String appLanguageKey = 'startup.app_language';

  final Future<SharedPreferences> Function()? _prefsLoader;

  Future<StartupPreferencesSnapshot> load({AppCrashLogger? logger}) async {
    try {
      final prefs =
          await (_prefsLoader?.call() ?? SharedPreferences.getInstance());
      final darkMode = prefs.getBool(darkModeKey) ?? false;
      final storedLang = prefs.getString(appLanguageKey);
      final language = AppLanguage.values.firstWhere(
        (item) => item.name == storedLang,
        orElse: () => AppLanguage.english,
      );
      return StartupPreferencesSnapshot(
        initialDarkMode: darkMode,
        appLanguage: language,
      );
    } catch (error) {
      logger?.recordError(
        operation: 'startup_preferences',
        stage: 'load',
        error: error,
      );
      return const StartupPreferencesSnapshot();
    }
  }

  Future<void> save({
    bool? darkModeEnabled,
    AppLanguage? appLanguage,
    AppCrashLogger? logger,
  }) async {
    try {
      final prefs =
          await (_prefsLoader?.call() ?? SharedPreferences.getInstance());
      if (darkModeEnabled != null) {
        await prefs.setBool(darkModeKey, darkModeEnabled);
      }
      if (appLanguage != null) {
        await prefs.setString(appLanguageKey, appLanguage.name);
      }
    } catch (error) {
      logger?.recordError(
        operation: 'startup_preferences',
        stage: 'save',
        error: error,
      );
    }
  }
}
