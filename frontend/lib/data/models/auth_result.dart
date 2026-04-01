class AuthResult {
  final String token;
  final String email;
  final String role;
  final String? name;
  final String? refreshToken;

  AuthResult({
    required this.token,
    required this.email,
    required this.role,
    this.name,
    this.refreshToken,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      name: json['name'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'email': email,
      'role': role,
      'name': name,
      'refreshToken': refreshToken,
    };
  }
}