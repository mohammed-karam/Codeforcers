class ProblemRef {
  const ProblemRef({
    required this.contestId,
    required this.index,
    required this.name,
    this.rating,
    this.tags = const <String>[],
  });

  final int contestId;
  final String index;
  final String name;
  final int? rating;
  final List<String> tags;

    String get id => '$contestId$index';

    String get code => '$contestId $index';

  String get statementUrl =>
      'https://codeforces.com/problemset/problem/$contestId/$index';

  factory ProblemRef.fromJson(Map<String, dynamic> json) {
    final contestId = json['contestId'];
    final index = json['index'];
    final name = json['name'];

    if (contestId is! int || index is! String || name is! String) {
      throw const FormatException('Problem entry is missing its id');
    }

    final rating = json['rating'];
    final tags = json['tags'];

    return ProblemRef(
      contestId: contestId,
      index: index,
      name: name,
      rating: rating is int ? rating : null,
      tags: tags is List
          ? tags.map((tag) => tag.toString()).toList(growable: false)
          : const <String>[],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'contestId': contestId,
        'index': index,
        'name': name,
        'rating': rating,
        'tags': tags,
      };
}
