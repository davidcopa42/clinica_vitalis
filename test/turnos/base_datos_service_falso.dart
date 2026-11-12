import 'package:clinica_vitalis/data/services/base_datos_service.dart';

/// Base de datos en memoria para los tests.
///
/// Reemplaza a SQLite: guarda las filas en una lista y entiende
/// condiciones simples del tipo 'columna = ? AND otra = ?'.
class BaseDatosServiceFalso implements BaseDatosService {
  final List<Map<String, Object?>> _filas = [];
  int _ultimoId = 0;

  @override
  Future<int> insertar(Map<String, Object?> datos) async {
    _ultimoId++;
    _filas.add({...datos, 'id': _ultimoId});
    return _ultimoId;
  }

  @override
  Future<List<Map<String, Object?>>> consultar({
    String? where,
    List<Object?>? whereArgs,
  }) async {
    if (where == null) return List.of(_filas);

    // 'profesional = ? AND fecha = ?' -> ['profesional', 'fecha']
    final columnas = where
        .split(' AND ')
        .map((condicion) => condicion.split('=').first.trim())
        .toList();

    return _filas.where((fila) {
      for (var i = 0; i < columnas.length; i++) {
        if (fila[columnas[i]] != whereArgs![i]) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<void> actualizar(int id, Map<String, Object?> datos) async {
    final indice = _filas.indexWhere((fila) => fila['id'] == id);
    if (indice != -1) _filas[indice] = {..._filas[indice], ...datos};
  }
}
