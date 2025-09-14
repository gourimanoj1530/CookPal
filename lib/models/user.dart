class User {
  final int id;
  final String email;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}