// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_rank_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRankModel _$UserRankModelFromJson(Map<String, dynamic> json) =>
    UserRankModel(
      rank: (json['rank'] as num).toInt(),
      name: json['name'] as String,
      xp: (json['xp'] as num).toInt(),
      userAvatarUrl: json['userAvatarUrl'] as String,
      badgeType: json['badgeType'] as String,
    );

Map<String, dynamic> _$UserRankModelToJson(UserRankModel instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'name': instance.name,
      'xp': instance.xp,
      'userAvatarUrl': instance.userAvatarUrl,
      'badgeType': instance.badgeType,
    };
