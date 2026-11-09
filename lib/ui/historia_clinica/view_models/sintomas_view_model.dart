import 'package:flutter/foundation.dart';

/// Administra el registro de síntomas del paciente.
class SintomasViewModel extends ChangeNotifier {
  final List<String> sintomasDisponibles = [
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

  Set<String> get sintomasSeleccionados =>
      Set.unmodifiable(_sintomasSeleccionados);

  String _descripcion = '';
  String get descripcion => _descripcion;

  String _duracion = 'Hoy';
  String get duracion => _duracion;

  double _intensidad = 1;
  double get intensidad => _intensidad;

  bool _registrado = false;
  bool get registrado => _registrado;

  /// Síntomas que requieren atención inmediata.
  static const Set<String> _signosAlarma = {
    'Dolor de pecho',
    'Falta de aire',
    'Pérdida de conocimiento',
    'Sangrado abundante',
    'Dificultad para hablar o mover un lado del cuerpo',
  };

  /// Comprueba si existe algún signo de alarma.
  bool get tieneSignosAlarma {
    return _sintomasSeleccionados
            .any((sintoma) => _signosAlarma.contains(sintoma)) ||
        _intensidad >= 9;
  }

  /// Selecciona o deselecciona un síntoma.
  void cambiarSintoma(String sintoma) {
    if (_sintomasSeleccionados.contains(sintoma)) {
      _sintomasSeleccionados.remove(sintoma);
    } else {
      _sintomasSeleccionados.add(sintoma);
    }

    _registrado = false;
    notifyListeners();
  }

  /// Actualiza la descripción.
  void cambiarDescripcion(String valor) {
    _descripcion = valor;
    _registrado = false;
    notifyListeners();
  }

  /// Actualiza la duración.
  void cambiarDuracion(String valor) {
    _duracion = valor;
    _registrado = false;
    notifyListeners();
  }

  /// Actualiza la intensidad.
  void cambiarIntensidad(double valor) {
    _intensidad = valor;
    _registrado = false;
    notifyListeners();
  }

  /// Registra la información ingresada en el estado del ViewModel.
  void registrarSintomas() {
    _registrado = true;
    notifyListeners();
  }
}
