import 'package:clinica_vitalis/data/repositories/sintomas_repository.dart';
import 'package:clinica_vitalis/domain/models/borrador_sintomas.dart';
import 'package:flutter/foundation.dart';

class SintomasViewModel extends ChangeNotifier {
  SintomasViewModel({SintomasRepository? repositorio})
      : _repositorio = repositorio ?? SintomasRepository() {
    _cargarBorrador();
  }

  final SintomasRepository _repositorio;

  static const List<String> _sintomasDisponibles = [
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

  static const Set<String> _sintomasAlarma = {
    'Dolor de pecho',
    'Falta de aire',
    'Pérdida de conocimiento',
    'Sangrado abundante',
    'Dificultad para hablar o mover un lado del cuerpo',
  };

  final Set<String> _sintomasSeleccionados = {};

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

  /// Guarda el borrador actual al instante en el dispositivo.
  Future<void> guardarBorrador() async {
    await _repositorio.guardarBorrador(
      BorradorSintomas(
        sintomas: _sintomasSeleccionados.toList(),
        descripcion: _descripcion,
        duracion: _duracion,
        intensidad: _intensidad,
      ),
    );
    debugPrint('Ciclo de vida - Borrador de síntomas guardado.');
  }

  /// Carga el borrador guardado al abrir la pantalla.
  Future<void> _cargarBorrador() async {
    final borrador = await _repositorio.cargarBorrador();

    if (borrador != null) {
      _sintomasSeleccionados.addAll(borrador.sintomas);
      _descripcion = borrador.descripcion;
      _duracion = borrador.duracion;
      _intensidad = borrador.intensidad;
    }
    notifyListeners();
  }

  /// Refresca o sincroniza datos al volver al frente (onResume)
  Future<void> refrescar() async {
    debugPrint('Ciclo de vida - App retomada en Síntomas.');
    await _cargarBorrador();
  }

  void cambiarSintoma(String sintoma) {
    if (_sintomasSeleccionados.contains(sintoma)) {
      _sintomasSeleccionados.remove(sintoma);
    } else {
      _sintomasSeleccionados.add(sintoma);
    }

    _registrado = false;
    notifyListeners();
    guardarBorrador();
  }

  void cambiarDescripcion(String descripcion) {
    _descripcion = descripcion;
    _registrado = false;
    notifyListeners();
    guardarBorrador();
  }

  void cambiarDuracion(String duracion) {
    _duracion = duracion;
    _registrado = false;
    notifyListeners();
    guardarBorrador();
  }

  void cambiarIntensidad(double intensidad) {
    _intensidad = intensidad;
    _registrado = false;
    notifyListeners();
    guardarBorrador();
  }

  Future<void> registrarSintomas() async {
    _registrado = true;
    notifyListeners();

    // Limpiamos el borrador al registrarse con éxito
    await _repositorio.eliminarBorrador();
  }
}
