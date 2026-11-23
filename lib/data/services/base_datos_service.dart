import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Acceso a la base de datos SQLite local de la app.
class BaseDatosService {
  static const nombreArchivo = 'clinica_vitalis.db';
  static const versionEsquema = 1;
  static const tablaTurnos = 'turnos';

  Database? _baseDatos;

  /// Abre la base una sola vez y reutiliza la conexion.
  Future<Database> get _db async => _baseDatos ??= await _abrir();

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), nombreArchivo);
    return openDatabase(
      ruta,
      version: versionEsquema,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE $tablaTurnos (
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

  /// Inserta una fila en turnos y devuelve el id que le asigno SQLite.
  Future<int> insertar(Map<String, Object?> datos) async {
    final db = await _db;
    return db.insert(tablaTurnos, Map.of(datos)..remove('id'));
  }

  /// Devuelve las filas de turnos que cumplen la condicion.
  Future<List<Map<String, Object?>>> consultar({
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await _db;
    return db.query(tablaTurnos, where: where, whereArgs: whereArgs);
  }

  /// Actualiza la fila de turnos con ese [id].
  Future<void> actualizar(int id, Map<String, Object?> datos) async {
    final db = await _db;
    await db.update(tablaTurnos, datos, where: 'id = ?', whereArgs: [id]);
  }
}
