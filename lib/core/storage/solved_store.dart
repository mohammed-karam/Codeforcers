import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SolvedProblem {
  const SolvedProblem({
    required this.id,
    required this.name,
    this.rating,
    this.tags = const <String>[],
    required this.solvedAt,
  });

    final String id;
  final String name;
  final int? rating;
  final List<String> tags;

    final int solvedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'rating': rating,
        'tags': tags,
        'solvedAt': solvedAt,
      };

  factory SolvedProblem.fromJson(Map<String, dynamic> json) => SolvedProblem(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        rating: json['rating'] as int?,
        tags: (json['tags'] as List<dynamic>? ?? const [])
            .map((tag) => tag.toString())
            .toList(),
        solvedAt: json['solvedAt'] as int? ?? 0,
      );
}

class SolvedStore {
  SolvedStore._({SharedPreferences? prefs}) : _prefs = prefs;

  static const String _prefKey = 'solved.problems';

  static SolvedStore? _instance;

    static SolvedStore get instance => _instance ??= SolvedStore._();

  static Future<void> init() async {
    _instance = SolvedStore._(prefs: await SharedPreferences.getInstance());
  }

  @visibleForTesting
  static void debugReset() => _instance = null;

  final SharedPreferences? _prefs;

    final ValueNotifier<int> revision = ValueNotifier<int>(0);

  List<SolvedProblem>? _cached;

  List<SolvedProblem> get all => List<SolvedProblem>.unmodifiable(_load());

  int get count => _load().length;

  bool isSolved(String id) => _load().any((problem) => problem.id == id);

  SolvedProblem? find(String id) {
    for (final problem in _load()) {
      if (problem.id == id) return problem;
    }
    return null;
  }

  Future<void> mark({
    required String id,
    required String name,
    int? rating,
    List<String> tags = const <String>[],
  }) async {
    final problems = _load().toList();
    if (problems.any((problem) => problem.id == id)) return;

    problems.insert(
      0,
      SolvedProblem(
        id: id,
        name: name,
        rating: rating,
        tags: tags,
        solvedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    await _save(problems);
  }

  Future<void> unmark(String id) async {
    final problems =
        _load().where((problem) => problem.id != id).toList(growable: false);
    await _save(problems);
  }

    Map<String, int> countByRating() {
    final counts = <String, int>{for (final band in ratingBands) band.label: 0};
    for (final problem in _load()) {
      final label = ratingBandOf(problem.rating).label;
      counts[label] = (counts[label] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> clear() async => _save(const <SolvedProblem>[]);

  List<SolvedProblem> _load() {
    final cached = _cached;
    if (cached != null) return cached;

    final raw = _prefs?.getString(_prefKey);
    if (raw == null || raw.isEmpty) return _cached = <SolvedProblem>[];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return _cached = decoded
          .whereType<Map<String, dynamic>>()
          .map(SolvedProblem.fromJson)
          .toList();
    } catch (_) {
      return _cached = <SolvedProblem>[];
    }
  }

  Future<void> _save(List<SolvedProblem> problems) async {
    _cached = problems;
    revision.value++;
    final raw = jsonEncode(problems.map((problem) => problem.toJson()).toList());
    await _prefs?.setString(_prefKey, raw);
  }
}

class RatingBand {
  const RatingBand({
    required this.label,
    required this.min,
    required this.max,
    required this.color,
  });

  final String label;
  final int min;
  final int max;

    final Color color;

  bool contains(int? rating) =>
      rating != null && rating >= min && rating <= max;
}

const List<RatingBand> ratingBands = <RatingBand>[
  RatingBand(
    label: 'Beginner',
    min: 0,
    max: 1199,
    color: Color(0xFF16A34A),
  ),
  RatingBand(
    label: 'Easy',
    min: 1200,
    max: 1499,
    color: Color(0xFF2563EB),
  ),
  RatingBand(
    label: 'Medium',
    min: 1500,
    max: 1799,
    color: Color(0xFF9333EA),
  ),
  RatingBand(
    label: 'Hard',
    min: 1800,
    max: 100000,
    color: Color(0xFFDC2626),
  ),
];

RatingBand ratingBandOf(int? rating) {
  for (final band in ratingBands) {
    if (band.contains(rating)) return band;
  }
  return ratingBands.first;
}
