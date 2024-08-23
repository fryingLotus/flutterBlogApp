import 'package:blogapp/core/entities/user.dart';

class UserModel extends User {
  UserModel(
      {required super.id,
      required super.email,
      required super.name,
      super.avatarUrl});
  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
        id: map['id'] ?? '',
        email: map['email'] ?? '',
        name: map['name'] ?? '',
        avatarUrl: map['avatar_url'] ?? '');
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
  }) {
    return UserModel(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        avatarUrl: avatarUrl ?? this.avatarUrl);
  }
}
