import 'package:cloud_firestore/cloud_firestore.dart';

// Estados por los que puede pasar un préstamo
enum EstadoPrestamo { activo, devuelto, vencido }

class Prestamo {
  String id;
  String usuarioNombre;
  String recursoNombre;
  String recursoIcono;
  String? salon;
  String? equipo;
  List<String> accesorios;
  DateTime fechaPrestamo;
  DateTime fechaDevolucion;
  EstadoPrestamo estado;

  Prestamo({
    String? id,
    required this.usuarioNombre,
    required this.recursoNombre,
    required this.recursoIcono,
    this.salon,
    this.equipo,
    this.accesorios = const [],
    required this.fechaPrestamo,
    required this.fechaDevolucion,
    this.estado = EstadoPrestamo.activo,
  }) : id = id ?? 'pre_${fechaPrestamo.millisecondsSinceEpoch}';

  String get fechaPrestamoStr =>
      '${fechaPrestamo.day.toString().padLeft(2, '0')}/${fechaPrestamo.month.toString().padLeft(2, '0')}/${fechaPrestamo.year}';

  String get fechaDevolucionStr =>
      '${fechaDevolucion.day.toString().padLeft(2, '0')}/${fechaDevolucion.month.toString().padLeft(2, '0')}/${fechaDevolucion.year}';

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'usuarioNombre': usuarioNombre,
    'recursoNombre': recursoNombre,
    'recursoIcono': recursoIcono,
    'salon': salon,
    'equipo': equipo,
    'accesorios': accesorios,
    'fechaPrestamo': fechaPrestamo.toIso8601String(),
    'fechaDevolucion': fechaDevolucion.toIso8601String(),
    'estado': estado.name,
  };

  factory Prestamo.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Prestamo(
      id: d['id'] as String? ?? doc.id,
      usuarioNombre: d['usuarioNombre'] as String,
      recursoNombre: d['recursoNombre'] as String,
      recursoIcono: d['recursoIcono'] is String && (d['recursoIcono'] as String).isNotEmpty
          ? d['recursoIcono'] as String : 'inventory_2',
      salon: d['salon'] as String?,
      equipo: d['equipo'] as String?,
      accesorios: (d['accesorios'] as List).cast<String>(),
      fechaPrestamo: DateTime.parse(d['fechaPrestamo'] as String),
      fechaDevolucion: DateTime.parse(d['fechaDevolucion'] as String),
      estado: EstadoPrestamo.values.firstWhere(
          (e) => e.name == d['estado'],
          orElse: () => EstadoPrestamo.activo),
    );
  }
}
