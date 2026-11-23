import 'package:shared_preferences/shared_preferences.dart';

/// Acceso directo a SharedPreferences.
class PreferenciasService {
  PreferenciasService({required SharedPreferences preferencias})
      : _preferencias = preferencias;

  final SharedPreferences _preferencias;

  /// Lee un texto guardado, o null si no existe.
  String? leerTexto(String clave) => _preferencias.getString(clave);

  /// Lee una lista de textos guardada, o null si no existe.
  List<String>? leerListaTexto(String clave) =>
      _preferencias.getStringList(clave);

  /// Lee un numero decimal guardado, o null si no existe.
  double? leerDecimal(String clave) => _preferencias.getDouble(clave);

  /// Guarda un texto.
  Future<void> guardarTexto(String clave, String valor) =>
      _preferencias.setString(clave, valor);

  /// Guarda una lista de textos.
  Future<void> guardarListaTexto(String clave, List<String> valor) =>
      _preferencias.setStringList(clave, valor);

  /// Guarda un numero decimal.
  Future<void> guardarDecimal(String clave, double valor) =>
      _preferencias.setDouble(clave, valor);

  /// Elimina el valor guardado en [clave].
  Future<void> eliminar(String clave) => _preferencias.remove(clave);
}
