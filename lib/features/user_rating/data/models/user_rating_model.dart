class UserRatingModel {
  final int contestId;
  final String contestName;
  final String handle;
  final int rank;
  final int ratingUpdateTimeSeconds;
  final int oldRating;
  final int newRating;

  UserRatingModel({
    required this.contestId,
    required this.contestName,
    required this.handle,
    required this.rank,
    required this.ratingUpdateTimeSeconds,
    required this.oldRating,
    required this.newRating,
  });

  int get ratingChange => newRating - oldRating;

  factory UserRatingModel.fromJson(Map<String, dynamic> json) {
    return UserRatingModel(
      contestId: json['contestId'] as int,
      contestName: json['contestName'] as String,
      handle: json['handle'] as String,
      rank: json['rank'] as int,
      ratingUpdateTimeSeconds: json['ratingUpdateTimeSeconds'] as int,
      oldRating: json['oldRating'] as int,
      newRating: json['newRating'] as int,
    );
  }
}
