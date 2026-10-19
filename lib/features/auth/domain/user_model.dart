class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String roleLabel;
  final bool isStaff;
  final bool isSuperuser;
  final Map<String, dynamic> permissions;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.roleLabel,
    required this.isStaff,
    required this.isSuperuser,
    required this.permissions,
  });

  bool get isAdmin => role == 'Admin' || isSuperuser;
  bool get isManager => role == 'Manager';
  bool get isMagasinier => role == 'Magasinier';
  bool get isCaissier => role == 'Caissier';

  bool get canManageUsers => permissions['can_manage_users'] == true || isAdmin;
  bool get canViewFinances => permissions['can_view_finances'] == true || isAdmin;
  bool get canManageStock => permissions['can_manage_stock'] == true || isAdmin;
  bool get canOperatePos => permissions['can_operate_pos'] == true || isAdmin;
  bool get canViewReports => permissions['can_view_reports'] == true || isAdmin;
  bool get canViewAiPredictions => permissions['can_view_ai_predictions'] == true || isAdmin;

  String get displayName {
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    return username;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      role: json['role'] as String? ?? 'Utilisateur',
      roleLabel: json['role_label'] as String? ?? 'Utilisateur',
      isStaff: json['is_staff'] as bool? ?? false,
      isSuperuser: json['is_superuser'] as bool? ?? false,
      permissions: json['permissions'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'role_label': roleLabel,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'permissions': permissions,
    };
  }
}
