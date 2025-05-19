import 'package:json_annotation/json_annotation.dart';

import 'dtos/user_dto.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String? id;
  final String appName;
  final String firstName;
  final String email;
  final String lastName1;
  final String? lastName2;
  final String idNumber;
  final String mobilePhone;
  final DateTime birthDate;
  final DateTime? registrationDate;
  final String role;
  final String? avatar;

  User({
    this.id,
    required this.appName,
    required this.firstName,
    required this.email,
    required this.lastName1,
    this.lastName2,
    required this.idNumber,
    required this.mobilePhone,
    required this.birthDate,
    this.registrationDate,
    this.role = 'client',
    this.avatar,
  });

  // From JSON
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // To JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Convert User to UserDto
  UserDto toDto() {
    return UserDto(
      id: id,
      appName: appName,
      firstName: firstName,
      email: email,
      lastName1: lastName1,
      lastName2: lastName2,
      idNumber: idNumber,
      mobilePhone: mobilePhone,
      birthDate: birthDate,
      registrationDate: registrationDate ?? DateTime.now(),
      role: role,
      avatar: avatar,
    );
  }
}
