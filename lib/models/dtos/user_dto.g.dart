// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
      id: json['_id'] as String?,
      appName: json['appName'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String?,
      lastName1: json['lastName1'] as String? ?? '',
      lastName2: json['lastName2'] as String?,
      idNumber: json['idNumber'] as String? ?? '',
      mobilePhone: json['mobilePhone'] as String? ?? '',
      birthDate: json['birthDate'] != null
          ? UserDto._dateTimeFromJson(json['birthDate'] as String)
          : DateTime.now(),
      registrationDate: json['registrationDate'] != null
          ? UserDto._dateTimeFromJson(json['registrationDate'] as String)
          : DateTime.now(),
      role: json['role'] as String? ?? 'client',
      avatar: json['avatar'] as String? ?? '',
    );

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
      '_id': instance.id,
      'appName': instance.appName,
      'firstName': instance.firstName,
      'email': instance.email,
      'password': instance.password,
      'lastName1': instance.lastName1,
      'lastName2': instance.lastName2,
      'idNumber': instance.idNumber,
      'mobilePhone': instance.mobilePhone,
      'birthDate': UserDto._dateTimeToJson(instance.birthDate),
      'registrationDate': UserDto._dateTimeToJson(instance.registrationDate),
      'role': instance.role,
      'avatar': instance.avatar,
    };
