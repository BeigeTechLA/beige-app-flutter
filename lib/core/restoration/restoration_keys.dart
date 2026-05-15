/// Pref keys + constants for state restoration.
///
/// All restoration keys share the `restoration.` prefix so a single
/// [clearAll] call can wipe them without touching unrelated prefs.
abstract class RestorationKeys {
  static const _prefix = 'restoration.';

  static const lastRoute = '${_prefix}last_route';
  static const lastQueryJson = '${_prefix}last_query_json';
  static const lastPathParamsJson = '${_prefix}last_path_params_json';
  static const lastActiveTs = '${_prefix}last_active_ts';
  static const schemaVersion = '${_prefix}schema_version';

  /// Bump when persisted JSON shape changes — older installs wipe on read.
  static const currentSchemaVersion = 1;

  /// All keys, used by [RouteRestorationService.clearAll].
  static const allKeys = <String>[
    lastRoute,
    lastQueryJson,
    lastPathParamsJson,
    lastActiveTs,
    schemaVersion,
  ];
}

/// Feature flag — flip to `false` to disable restoration entirely.
const bool kRestorationEnabled = true;

/// Time-to-live for a persisted route before falling back to home.
const Duration kRestorationTtl = Duration(minutes: 30);
