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
  
  /// Convierte el string de icono a IconData
  IconData get iconData {
    switch (icon.toLowerCase()) {
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
