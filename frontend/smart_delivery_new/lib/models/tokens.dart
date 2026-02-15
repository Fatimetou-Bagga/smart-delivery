class Tokens {
  final String access;
  final String? refresh;

  Tokens({required this.access, this.refresh});

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
      access: json['access'] as String,
      refresh: json['refresh'] as String?,
    );
  }
}
