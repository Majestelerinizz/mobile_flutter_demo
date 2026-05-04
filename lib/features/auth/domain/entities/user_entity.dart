import 'package:equatable/equatable.dart';

enum UserRole { manager, resident }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final UserRole role;
  final String? fcmToken;
  final String language;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    this.fcmToken,
    this.language = 'tr',
  });

  @override
  List<Object?> get props => [id, email, name, phone, role, fcmToken, language];
}
