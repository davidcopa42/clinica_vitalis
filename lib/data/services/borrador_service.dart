import 'package:shared_preferences/shared_preferences.dart';

/// Acceso directo a [SharedPreferences] para guardar borradores.
///
/// Devuelve valores crudos por clave y no guarda estado entre llamadas.
class BorradorService {
  Future<String?> leerTexto(String clave) async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getString(clave);
  }

  Future<List<String>?> leerListaDeTextos(String clave) async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getStringList(clave);
  }

  Future<double?> leerDecimal(String clave) async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getDouble(clave);
  }

  Future<void> escribirTexto(String clave, String valor) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(clave, valor);
  }

  Future<void> escribirListaDeTextos(String clave, List<String> valor) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setStringList(clave, valor);
  }

  Future<void> escribirDecimal(String clave, double valor) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setDouble(clave, valor);
  }

  Future<void> borrar(String clave) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove(clave);
  }
}
