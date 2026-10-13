
class OnlineFriendsModel {
  String status;
  List<String> result;

  OnlineFriendsModel({
    required this.status,
    required this.result,
  });

  factory OnlineFriendsModel.fromJson(Map<String, dynamic> json) {
    return OnlineFriendsModel(
      status: json['status'] as String,
      result: List<String>.from(json['result'] as List<dynamic>),
    );
  }
}