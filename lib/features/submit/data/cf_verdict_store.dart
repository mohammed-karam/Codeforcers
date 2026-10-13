import 'dart:convert';

import 'package:codeforcers/features/submit/data/cf_submission.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CfVerdictStore {
  CfVerdictStore._({SharedPreferences? prefs}) : _prefs = prefs;

  static const String _prefKey = 'submit.last_submission';

  static CfVerdictStore? _instance;

    static CfVerdictStore get instance => _instance ??= CfVerdictStore._();

  static Future<void> init() async {
    _instance = CfVerdictStore._(prefs: await SharedPreferences.getInstance());
  }

  @visibleForTesting
  static void debugReset() => _instance = null;

  final SharedPreferences? _prefs;

  CfSubmission? _cached;
  bool _loaded = false;

    CfSubmission? read() {
    if (_loaded) return _cached;

    final raw = _prefs?.getString(_prefKey);
    if (raw == null || raw.isEmpty) return _cached = null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return _cached = null;
      return _cached = CfSubmission.fromJson(decoded);
    } catch (_) {
      return _cached = null;
    } finally {
      _loaded = true;
    }
  }

  Future<void> write(CfSubmission submission) async {
    _cached = submission;
    _loaded = true;
    await _prefs?.setString(_prefKey, jsonEncode(submission.toJson()));
  }

  Future<void> clear() async {
    _cached = null;
    _loaded = true;
    await _prefs?.remove(_prefKey);
  }
}
