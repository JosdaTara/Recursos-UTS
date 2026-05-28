import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  String? id;
  String nombre;
  String correo;
  String password;
  String documento;
  String programa;
  bool activo;

  Usuario({
    this.id,
    required this.nombre,
    required this.correo,
    this.password = '1234',
    required this.documento,
    required this.programa,
    this.activo = true,
  });

  Map<String, dynamic> toFirestore() => {
    'id': id ?? correo,
    'nombre': nombre,
    'correo': correo,
    'password': password,
    'documento': documento,
    'programa': programa,
    'activo': activo,
  };

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: d['id'] as String?,
      nombre: d['nombre'] as String,
      correo: d['correo'] as String,
      password: d['password'] as String? ?? '1234',
      documento: d['documento'] as String,
      programa: d['programa'] as String,
      activo: d['activo'] as bool? ?? true,
    );
  }
}
