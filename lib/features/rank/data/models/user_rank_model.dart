import 'package:json_annotation/json_annotation.dart';

part 'user_rank_model.g.dart';

@JsonSerializable()
class UserRankModel {
  final int rank;
  final String name;
  final int xp;
  final String userAvatarUrl;
  final String badgeType;

  UserRankModel({
    required this.rank,
    required this.name,
    required this.xp,
    required this.userAvatarUrl,
    required this.badgeType,
  });

  factory UserRankModel.fromJson(Map<String, dynamic> json) =>
      _$UserRankModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserRankModelToJson(this);
}
