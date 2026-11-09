import 'package:flutter/foundation.dart';

class SintomasViewModel extends ChangeNotifier {
  final List<String> _sintomasDisponibles = [
    'Dolor de cabeza',
    'Fiebre',
    'Tos',
    'Dolor de garganta',
    'Dolor abdominal',
    'Mareos',
    'Náuseas',
    'Dolor muscular',
    'Dolor de pecho',
    'Falta de aire',
    'Pérdida de conocimiento',
    'Sangrado abundante',
    'Dificultad para hablar o mover un lado del cuerpo',
  ];

  final Set<String> _sintomasSeleccionados = {};

  final Set<String> _sintomasAlarma = {
    'Dolor de pecho',
    'Falta de aire',
    'Pérdida de conocimiento',
    'Sangrado abundante',
    'Dificultad para hablar o mover un lado del cuerpo',
  };

  String _descripcion = '';
  String _duracion = 'Hoy';
  double _intensidad = 1;
  bool _registrado = false;

  List<String> get sintomasDisponibles =>
      List.unmodifiable(_sintomasDisponibles);

  Set<String> get sintomasSeleccionados =>
      Set.unmodifiable(_sintomasSeleccionados);

  String get descripcion => _descripcion;
  String get duracion => _duracion;
  double get intensidad => _intensidad;
  bool get registrado => _registrado;

  bool get tieneSignosAlarma {
    return _sintomasSeleccionados.any(_sintomasAlarma.contains) ||
        _intensidad >= 9;
  }

  void cambiarSintoma(String sintoma) {
    if (_sintomasSeleccionados.contains(sintoma)) {
      _sintomasSeleccionados.remove(sintoma);
    } else {
      _sintomasSeleccionados.add(sintoma);
    }

    _registrado = false;
    notifyListeners();
  }

  void cambiarDescripcion(String descripcion) {
    _descripcion = descripcion;
    _registrado = false;
    notifyListeners();
  }

  void cambiarDuracion(String duracion) {
    _duracion = duracion;
    _registrado = false;
    notifyListeners();
  }

  void cambiarIntensidad(double intensidad) {
    _intensidad = intensidad;
    _registrado = false;
    notifyListeners();
  }

  void registrarSintomas() {
    _registrado = true;
    notifyListeners();
  }
}
