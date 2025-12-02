/// Modelo de Career dentro de UserModel
class UserCareer {
  final int id;
  final String nombre;
  final String codigo;
  final String icon;
  final String color;
  final DateTime enrolledAt;

  UserCareer({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.icon,
    required this.color,
    required this.enrolledAt,
  });

  factory UserCareer.fromJson(Map<String, dynamic> json) {
    return UserCareer(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      enrolledAt: DateTime.parse(json['enrolledAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'icon': icon,
      'color': color,
      'enrolledAt': enrolledAt.toIso8601String(),
    };
  }
}

/// 👇 NUEVO: Modelo de Role dentro de UserModel
class UserRole {
  final int id;
  final String name;
  final String displayName;
  final String? description;
  final DateTime assignedAt;

  UserRole({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    required this.assignedAt,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'] as int,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String?,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'description': description,
      'assignedAt': assignedAt.toIso8601String(),
    };
  }
}

/// UserModel con careers y roles
class UserModel {
  final int id;
  final String nombreCompleto;
  final String email;
  final String? profilePicture;
  final String? identificacion;
  final List<UserCareer> careers;
  final List<UserRole> roles; // 👈 NUEVO
  final List<String> materias;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool hasMicrosoftAccount;

  UserModel({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    this.profilePicture,
    this.identificacion,
    required this.careers,
    required this.roles, // 👈 NUEVO
    required this.materias,
    required this.isProfileComplete,
    required this.createdAt,
    required this.updatedAt,
    required this.hasMicrosoftAccount,
  });

  /// Getters de conveniencia
  String get firstName {
    final parts = nombreCompleto.split(' ');
    return parts.isNotEmpty ? parts[0] : nombreCompleto;
  }

  String get initials {
    final parts = nombreCompleto.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nombreCompleto.length >= 2
        ? nombreCompleto.substring(0, 2).toUpperCase()
        : nombreCompleto.toUpperCase();
  }

  /// Getter para códigos de carreras (retrocompatibilidad)
  List<String> get careerCodes => careers.map((c) => c.codigo).toList();

  /// 👇 NUEVO: Helpers para verificar roles
  bool get isStudent => roles.any((r) => r.name == 'STUDENT');
  bool get isTeacher => roles.any((r) => r.name == 'TEACHER');
  bool get isAdmin => roles.any((r) => r.name == 'ADMIN');

  /// 👇 NUEVO: Obtener nombres de roles
  List<String> get roleNames => roles.map((r) => r.name).toList();
  List<String> get roleDisplayNames => roles.map((r) => r.displayName).toList();

  /// 👇 NUEVO: Getter para el rol principal
  String get primaryRoleDisplay {
    if (roles.isEmpty) return 'Usuario';
    return roles.first.displayName;
  }

  /// Crear desde JSON (Backend)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      nombreCompleto: json['nombreCompleto'] as String,
      email: json['email'] as String,
      profilePicture: json['profilePicture'] as String?,
      identificacion: json['identificacion'] as String?,
      careers: (json['careers'] as List?)
              ?.map((career) => UserCareer.fromJson(career))
              .toList() ??
          [],
      roles: (json['roles'] as List?) // 👈 NUEVO
              ?.map((role) => UserRole.fromJson(role))
              .toList() ??
          [],
      materias: (json['materias'] as List?)?.cast<String>() ?? [],
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      hasMicrosoftAccount: json['hasMicrosoftAccount'] as bool? ?? false,
    );
  }

  /// Convertir a JSON (para almacenar)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreCompleto': nombreCompleto,
      'email': email,
      'profilePicture': profilePicture,
      'identificacion': identificacion,
      'careers': careers.map((c) => c.toJson()).toList(),
      'roles': roles.map((r) => r.toJson()).toList(), // 👈 NUEVO
      'materias': materias,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'hasMicrosoftAccount': hasMicrosoftAccount,
    };
  }

  /// Copiar con cambios
  UserModel copyWith({
    int? id,
    String? nombreCompleto,
    String? email,
    String? profilePicture,
    String? identificacion,
    List<UserCareer>? careers,
    List<UserRole>? roles, // 👈 NUEVO
    List<String>? materias,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasMicrosoftAccount,
  }) {
    return UserModel(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      identificacion: identificacion ?? this.identificacion,
      careers: careers ?? this.careers,
      roles: roles ?? this.roles, // 👈 NUEVO
      materias: materias ?? this.materias,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasMicrosoftAccount: hasMicrosoftAccount ?? this.hasMicrosoftAccount,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, nombre: $nombreCompleto, email: $email, '
        'careers: ${careers.length}, roles: ${roleNames.join(", ")})';
  }
}
