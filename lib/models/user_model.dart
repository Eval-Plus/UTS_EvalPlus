class UserModel {
  final int id;
  final String nombreCompleto;
  final String email;
  final String? profilePicture;
  final String? identificacion;
  final List<String> carreras;
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
    required this.carreras,
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

  /// Crear desde JSON (Backend)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      nombreCompleto: json['nombreCompleto'] as String,
      email: json['email'] as String,
      profilePicture: json['profilePicture'] as String?,
      identificacion: json['identificacion'] as String?,
      carreras: (json['carreras'] as List?)?.cast<String>() ?? [],
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
      'carreras': carreras,
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
    List<String>? carreras,
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
      carreras: carreras ?? this.carreras,
      materias: materias ?? this.materias,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasMicrosoftAccount: hasMicrosoftAccount ?? this.hasMicrosoftAccount,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, nombre: $nombreCompleto, email: $email)';
  }
}
