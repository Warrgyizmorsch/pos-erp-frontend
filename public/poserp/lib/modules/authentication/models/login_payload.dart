class LoginPayload {
  final String email;
  final String password;

  LoginPayload({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
