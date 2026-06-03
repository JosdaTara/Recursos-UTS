import 'package:cloud_firestore/cloud_firestore.dart';

// Categorías para clasificar y filtrar los recursos
enum CategoriaRecurso { todos, equipos, cables, otros }

class Recurso {
  String nombre;
  String icono;
  int total;
  int disponible;
  CategoriaRecurso categoria;
  String? codigoBarras;
  List<String> accesoriosIncluidos;

  Recurso({
    required this.nombre,
    required this.icono,
    required this.total,
    required this.disponible,
    this.categoria = CategoriaRecurso.otros,
    this.codigoBarras,
    this.accesoriosIncluidos = const [],
  });

  double get porcentajeDisponible => total > 0 ? disponible / total : 0;

  Map<String, dynamic> toFirestore() => {
    'nombre': nombre,
    'icono': icono,
    'total': total,
    'disponible': disponible,
    'categoria': categoria.name,
    'codigoBarras': codigoBarras,
    'accesoriosIncluidos': accesoriosIncluidos,
  };

  factory Recurso.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Recurso(
      nombre: d['nombre'] as String,
      icono: d['icono'] is String && (d['icono'] as String).isNotEmpty
          ? d['icono'] as String : 'inventory_2',
      total: d['total'] as int,
      disponible: d['disponible'] as int,
      categoria: CategoriaRecurso.values.firstWhere(
          (c) => c.name == d['categoria'],
          orElse: () => CategoriaRecurso.otros),
      codigoBarras: d['codigoBarras'] as String?,
      accesoriosIncluidos: (d['accesoriosIncluidos'] as List).cast<String>(),
    );
  }
}
