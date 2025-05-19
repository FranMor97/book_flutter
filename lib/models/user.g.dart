// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String?,
      appName: json['appName'] as String,
      firstName: json['firstName'] as String,
      email: json['email'] as String,
      lastName1: json['lastName1'] as String,
      lastName2: json['lastName2'] as String?,
      idNumber: json['idNumber'] as String,
      mobilePhone: json['mobilePhone'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      registrationDate: json['registrationDate'] == null
          ? null
          : DateTime.parse(json['registrationDate'] as String),
      role: json['role'] as String? ?? 'client',
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'appName': instance.appName,
      'firstName': instance.firstName,
      'email': instance.email,
      'lastName1': instance.lastName1,
      'lastName2': instance.lastName2,
      'idNumber': instance.idNumber,
      'mobilePhone': instance.mobilePhone,
      'birthDate': instance.birthDate.toIso8601String(),
      'registrationDate': instance.registrationDate?.toIso8601String(),
      'role': instance.role,
      'avatar': instance.avatar,
    };
