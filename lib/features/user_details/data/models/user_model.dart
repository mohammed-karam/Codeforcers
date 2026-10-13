

class UserModel {
  final String country;
  final String lastName;
  final int lastOnlineTimeSeconds;
  final int rating;
  final int friendOfCount;
  final String titlePhoto;
  final String handle;
  final String avatar;
  final String firstName;
  final int contribution;
  final String organization;
  final String rank;
  final int maxRating;
  final int registrationTimeSeconds;
  final String maxRank; 


  UserModel({
    required this.country,
    required this.lastName,
    required this.lastOnlineTimeSeconds,
    required this.rating,
    required this.friendOfCount,
    required this.titlePhoto,
    required this.handle,
    required this.avatar,
    required this.firstName,
    required this.contribution,
    required this.organization,
    required this.rank,
    required this.maxRating,
    required this.registrationTimeSeconds,
    required this.maxRank,
  });


  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      country: json['country'] as String,
      lastName: json['lastName'] as String,
      lastOnlineTimeSeconds: json['lastOnlineTimeSeconds'] as int,
      rating: json['rating'] as int,  
      friendOfCount: json['friendOfCount'] as int,
      titlePhoto: json['titlePhoto'] as String,
      handle: json['handle'] as String,
      avatar: json['avatar'] as String,
      firstName: json['firstName'] as String,
      contribution: json['contribution'] as int,
      organization: json['organization'] as String? ?? '',
      rank: json['rank'] as String,
      maxRating: json['maxRating'] as int,
      registrationTimeSeconds: json['registrationTimeSeconds'] as int,
      maxRank: json['maxRank'] as String,
    );
  }
}



