class AuthResult {
  final String token;
  final String email;
  final String role;
  final String? name;

  AuthResult({required this.token, required this.email, required this.role, this.name});

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      name: json['name'] as String?
    );

    
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'email': email,
      'role': role,
      'name': name,
    };
  }

}