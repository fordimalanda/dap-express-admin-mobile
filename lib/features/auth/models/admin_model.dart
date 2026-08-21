class AdminModel {
  final String id;
  final String email;
  final String name;
  final String role;

  AdminModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'MANAGER',
    );
  }
}
