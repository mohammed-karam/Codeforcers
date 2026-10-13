class FriendInfo {
  const FriendInfo({
    required this.handle,
    this.rating,
    this.maxRating,
    this.rank,
    this.titlePhoto,
  });

    final String handle;

    final int? rating;

    final int? maxRating;

    final String? rank;

    final String? titlePhoto;

  factory FriendInfo.fromJson(Map<String, dynamic> json) {
    return FriendInfo(
      handle: json['handle'] as String? ?? '',
      rating: _asInt(json['rating']),
      maxRating: _asInt(json['maxRating']),
      rank: json['rank'] as String?,
      titlePhoto: json['titlePhoto'] as String?,
    );
  }

  bool get isRated => rating != null;

        String get rankLabel {
    final raw = rank?.trim();
    if (raw == null || raw.isEmpty) return '';
    return raw
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }
}
