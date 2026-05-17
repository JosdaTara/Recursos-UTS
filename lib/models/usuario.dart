// Modelo que representa un usuario registrado en el sistema
class Usuario {
  String nombre;      // Nombre completo del usuario
  String correo;      // Correo electrónico (usado para iniciar sesión)
  String documento;   // Número de documento de identidad
  String programa;    // Programa académico al que pertenece (ej: TECNOLOGÍA EN LOGÍSTICA)
  bool activo;        // true = puede solicitar préstamos, false = bloqueado

  Usuario({
    required this.nombre,
    required this.correo,
    required this.documento,
    required this.programa,
    this.activo = true, // Por defecto el usuario se crea activo
  });
}
