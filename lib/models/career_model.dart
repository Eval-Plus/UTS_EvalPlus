import 'package:flutter/material.dart';

/// Modelo único para Career - Unifica data y API response
class CareerModel {
  final int id;
  final String nombre;
  final String codigo;
  final String icon;
  final String color;
  final String? descripcion;
  final bool activo;

  CareerModel({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.icon,
    required this.color,
    this.descripcion,
    this.activo = true,
  });

  // ==================== FACTORY CONSTRUCTORS ====================

  /// Crear desde respuesta del API
  factory CareerModel.fromJson(Map<String, dynamic> json) {
    return CareerModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] as bool? ?? true,
    );
  }

  // ==================== COMPUTED PROPERTIES ====================

  /// Convierte el nombre de la carrera a un IconData único.
  /// Prioriza el mapeo por nombre; si no coincide, usa el campo [icon] del API.
  IconData get iconData {
    final nameIcon = _iconByCareerName(nombre);
    if (nameIcon != null) return nameIcon;
    return _iconByApiString(icon);
  }

  /// Mapeo de íconos por nombre de carrera.
  /// Retorna null si el nombre no tiene un ícono asignado.
  static IconData? _iconByCareerName(String nombre) {
    // Normalizar para comparación: minúsculas sin espacios extra
    final normalized = nombre.toLowerCase().trim();

    if (normalized.contains('administración de empresas')) {
      return Icons.business_center_rounded;
    }
    if (normalized.contains('contabilidad financiera')) {
      return Icons.account_balance_rounded;
    }
    if (normalized.contains('gestión comercial')) {
      return Icons.storefront_rounded;
    }
    if (normalized.contains('gestión contable')) {
      return Icons.receipt_long_rounded;
    }
    if (normalized.contains('gestión empresarial')) {
      return Icons.corporate_fare_rounded;
    }
    if (normalized.contains('mercadeo')) {
      return Icons.campaign_rounded;
    }
    if (normalized.contains('contaduría pública')) {
      return Icons.calculate_rounded;
    }

    return null;
  }

  /// Mapeo de íconos por el string del campo [icon] que retorna el API.
  static IconData _iconByApiString(String iconString) {
    switch (iconString.toLowerCase()) {
      case 'computer':
        return Icons.computer;
      case 'business_center':
        return Icons.business_center;
      case 'gavel':
        return Icons.gavel;
      case 'school':
        return Icons.school;
      case 'engineering':
        return Icons.engineering;
      case 'science':
        return Icons.science;
      case 'business':
        return Icons.business;
      default:
        return Icons.school;
    }
  }

  /// Convierte el string hexadecimal a Color
  Color get colorValue {
    try {
      final hexColor = color.replaceAll('0x', '').replaceAll('#', '');
      return Color(int.parse('0xFF$hexColor'));
    } catch (e) {
      return const Color(0xFFA8B820); // Color por defecto
    }
  }

  // ==================== SERIALIZATION ====================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'icon': icon,
      'color': color,
      'descripcion': descripcion,
      'activo': activo,
    };
  }

  // ==================== UTILITY ====================

  @override
  String toString() => 'CareerModel(id: $id, codigo: $codigo, nombre: $nombre)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareerModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}