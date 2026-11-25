// Exposes dependencies for reading and writing lightweight startup prefs.
// Keeps SharedPreferences access isolated from bootstrap and UI widgets.
export 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

export '../../feature/profile/domain/entities/app_settings.dart'
    show AppLanguage;
export '../error/app_crash_logger.dart';
