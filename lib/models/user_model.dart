class UserModel {
  int? id;
  String name;
  String email;
  String password;
  String? profileImage;
  String role; // "admin" or "user"

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.profileImage,
    this.role = "user",
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name.trim(),
        'email': email.toLowerCase().trim(),
        'password': password,
        'profileImage': profileImage,
        'role': role,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'],
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        password: map['password'] ?? '',
        profileImage: map['profileImage'],
        role: map['role'] ?? 'user',
      );
}
