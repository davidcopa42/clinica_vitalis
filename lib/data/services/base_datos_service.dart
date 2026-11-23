import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Acceso a la base de datos local de la app.
class BaseDatosService {
  static const _nombreArchivo = 'clinica_vitalis.db';
  static const _versionEsquema = 1;
  static const _tablaTurnos = 'turnos';

  static Database? _baseDatos;

  /// Abre la base una sola vez y la reutiliza.
  Future<Database> get _db async {
    return _baseDatos ??= await _abrir();
  }

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), _nombreArchivo);
    return openDatabase(
      ruta,
      version: _versionEsquema,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $_tablaTurnos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            paciente_uid TEXT NOT NULL,
            especialidad TEXT NOT NULL,
            profesional TEXT NOT NULL,
            fecha TEXT NOT NULL,
            horario TEXT NOT NULL,
            estado TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Inserta una fila y devuelve el id que le asignó SQLite.
  Future<int> insertar(Map<String, Object?> datos) async {
    final db = await _db;
    return db.insert(_tablaTurnos, datos..remove('id'));
  }

  /// Devuelve las filas que cumplen la condición.
  Future<List<Map<String, Object?>>> consultar({
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await _db;
    return db.query(_tablaTurnos, where: where, whereArgs: whereArgs);
  }

  /// Actualiza la fila con ese id.
  Future<void> actualizar(int id, Map<String, Object?> datos) async {
    final db = await _db;
    await db.update(_tablaTurnos, datos, where: 'id = ?', whereArgs: [id]);
  }
}
