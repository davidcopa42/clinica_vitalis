import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Acceso a la base de datos local de la app.
class BaseDatosService {
  static Database? _baseDatos;

  /// Abre la base una sola vez y la reutiliza.
  Future<Database> get _db async {
    return _baseDatos ??= await _abrir();
  }

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), 'clinica_vitalis.db');
    return openDatabase(
      ruta,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE turnos (
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
    return db.insert('turnos', datos..remove('id'));
  }

  /// Devuelve las filas que cumplen la condición.
  Future<List<Map<String, Object?>>> consultar({
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await _db;
    return db.query('turnos', where: where, whereArgs: whereArgs);
  }

  /// Actualiza la fila con ese id.
  Future<void> actualizar(int id, Map<String, Object?> datos) async {
    final db = await _db;
    await db.update('turnos', datos, where: 'id = ?', whereArgs: [id]);
  }
}