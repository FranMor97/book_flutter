// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  // Helper function to safely parse DateTime
  DateTime parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    try {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is int) {
        // Handle timestamp in milliseconds
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else if (value is DateTime) {
        return value;
      }
    } catch (e) {
      // If parsing fails, return current date
      print('Error parsing date: $e');
    }

    return DateTime.now();
  }

  // Helper function to safely parse nullable DateTime
  DateTime? parseNullableDateTime(dynamic value) {
    if (value == null) return null;

    try {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is int) {
        // Handle timestamp in milliseconds
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else if (value is DateTime) {
        return value;
      }
    } catch (e) {
      // If parsing fails, return null
      print('Error parsing date: $e');
    }

    return null;
  }

  // Helper function to safely get string value
  String? getStringOrNull(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  // Helper function to safely get required string with default
  String getStringWithDefault(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    final stringValue = value.toString();
    return stringValue.isEmpty ? defaultValue : stringValue;
  }

  return User(
    id: getStringOrNull(json['id'] ?? json['_id']), // Also check for _id field
    appName: getStringWithDefault(json['appName'], ''),
    firstName: getStringWithDefault(json['firstName'], ''),
    email: getStringWithDefault(json['email'], ''),
    lastName1: getStringWithDefault(json['lastName1'], ''),
    lastName2: getStringOrNull(json['lastName2']),
    idNumber: getStringWithDefault(json['idNumber'], ''),
    mobilePhone: getStringWithDefault(json['mobilePhone'], ''),
    birthDate: parseDateTime(json['birthDate']),
    registrationDate: parseNullableDateTime(json['registrationDate']),
    role: getStringWithDefault(json['role'], 'client'),
    avatar: getStringOrNull(json['avatar']),
  );
}

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
