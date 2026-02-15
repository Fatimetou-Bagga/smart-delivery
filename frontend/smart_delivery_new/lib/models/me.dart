class Me {
  final int id;
  final String email;
  final String username;
  final String role;

  Me({required this.id, required this.email, required this.username, required this.role});

  factory Me.fromJson(Map<String, dynamic> json) {
    return Me(
      id: (json['id'] as num).toInt(),
      email: (json['email'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      role: (json['role'] ?? '') as String, // "CLIENT" / "COURIER" / "ADMIN"
    );
  }
}
