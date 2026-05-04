class JoinRequest {
  final String inviteCode;
  final String password;
  final String name;
  final String? phone;

  JoinRequest({
    required this.inviteCode,
    required this.password,
    required this.name,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'inviteCode': inviteCode,
      'password': password,
      'name': name,
      'phone': phone,
    };
  }
}
