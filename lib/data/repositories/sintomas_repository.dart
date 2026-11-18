import 'package:clinica_vitalis/domain/models/borrador_sintomas.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda, carga y borra el borrador de síntomas en el dispositivo
/// (SharedPreferences). Es lo único que usa el ViewModel para eso.
class SintomasRepository {
  static const String _claveSintomas = 'borrador_sintomas_lista';
  static const String _claveDescripcion = 'borrador_sintomas_desc';
  static const String _claveDuracion = 'borrador_sintomas_duracion';
  static const String _claveIntensidad = 'borrador_sintomas_intensidad';

  /// Devuelve el borrador guardado, o null si no hay ninguno.
  ///
  /// Si falta algún dato, usa el valor por defecto de [BorradorSintomas].
  Future<BorradorSintomas?> cargarBorrador() async {
    final prefs = await SharedPreferences.getInstance();

    final sintomas = prefs.getStringList(_claveSintomas);
    final descripcion = prefs.getString(_claveDescripcion);
    final duracion = prefs.getString(_claveDuracion);
    final intensidad = prefs.getDouble(_claveIntensidad);

    final hayBorrador = sintomas != null ||
        descripcion != null ||
        duracion != null ||
        intensidad != null;
    if (!hayBorrador) return null;

    const porDefecto = BorradorSintomas();
    return BorradorSintomas(
      sintomas: sintomas ?? porDefecto.sintomas,
      descripcion: descripcion ?? porDefecto.descripcion,
      duracion: duracion ?? porDefecto.duracion,
      intensidad: intensidad ?? porDefecto.intensidad,
    );
  }

  /// Guarda el borrador, reemplazando el anterior.
  Future<void> guardarBorrador(BorradorSintomas borrador) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_claveSintomas, borrador.sintomas);
    await prefs.setString(_claveDescripcion, borrador.descripcion);
    await prefs.setString(_claveDuracion, borrador.duracion);
    await prefs.setDouble(_claveIntensidad, borrador.intensidad);
  }

  /// Borra el borrador, por ejemplo después de registrar los síntomas.
  Future<void> eliminarBorrador() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveSintomas);
    await prefs.remove(_claveDescripcion);
    await prefs.remove(_claveDuracion);
    await prefs.remove(_claveIntensidad);
  }
}
