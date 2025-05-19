import 'package:json_annotation/json_annotation.dart';
import '../user.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  @JsonKey(name: '_id') // MongoDB uses _id by default
  final String? id;

  final String appName;
  final String firstName;
  final String email;
  final String? password; // Include password for register/login requests
  final String lastName1;
  final String? lastName2;
  final String idNumber;
  final String mobilePhone;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime birthDate;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime registrationDate;

  final String role;
  final String? avatar;

  @JsonKey(ignore: true)
  final String? token; // For login response

  UserDto({
    this.id,
    required this.appName,
    required this.firstName,
    required this.email,
    this.password,
    required this.lastName1,
    this.lastName2,
    required this.idNumber,
    required this.mobilePhone,
    required this.birthDate,
    required this.registrationDate,
    this.role = 'client',
    this.avatar,
    this.token,
  });

  // From JSON
  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  // To JSON
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  // Helper methods for DateTime conversion
  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();

  // Convert DTO to domain User
  User toUser() {
    return User(
      id: id,
      appName: appName,
      firstName: firstName,
      email: email,
      lastName1: lastName1,
      lastName2: lastName2,
      idNumber: idNumber,
      mobilePhone: mobilePhone,
      birthDate: birthDate,
      registrationDate: registrationDate,
      role: role,
      avatar: avatar,
    );
  }

  // For registration
  factory UserDto.forRegistration({
    required String appName,
    required String firstName,
    required String email,
    required String password,
    required String lastName1,
    String? lastName2,
    required String idNumber,
    required String mobilePhone,
    required DateTime birthDate,
    String? avatar,
  }) {
    return UserDto(
      appName: appName,
      firstName: firstName,
      email: email,
      password: password,
      lastName1: lastName1,
      lastName2: lastName2,
      idNumber: idNumber,
      mobilePhone: mobilePhone,
      birthDate: birthDate,
      avatar: avatar,
      registrationDate: DateTime.now(),
    );
  }

  // For login
  factory UserDto.forLogin({
    required String email,
    required String password,
  }) {
    return UserDto(
      appName: '',
      firstName: '',
      email: email,
      password: password,
      lastName1: '',
      idNumber: '',
      mobilePhone: '',
      birthDate: DateTime.now(),
      registrationDate: DateTime.now(),
    );
  }
}
