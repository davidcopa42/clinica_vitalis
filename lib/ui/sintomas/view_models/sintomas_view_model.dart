import 'package:flutter/foundation.dart';

import '../../../data/repositories/borrador_repository.dart';
import '../../../domain/models/borrador_sintomas.dart';

class SintomasViewModel extends ChangeNotifier {
  SintomasViewModel({required BorradorRepository borradorRepository})
      : _borradorRepository = borradorRepository {
    _cargarBorrador();
  }

  final BorradorRepository _borradorRepository;

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

  /// Guarda el borrador actual al instante.
  Future<void> guardarBorrador() async {
    await _borradorRepository.guardarBorradorSintomas(
      BorradorSintomas(
        sintomas: _sintomasSeleccionados.toList(),
        descripcion: _descripcion,
        duracion: _duracion,
        intensidad: _intensidad,
      ),
    );
    debugPrint('Ciclo de vida - Borrador de síntomas guardado.');
  }

  /// Carga el borrador guardado al abrir la pantalla
  Future<void> _cargarBorrador() async {
    final borrador = await _borradorRepository.obtenerBorradorSintomas();
    final sintomasGuardados = borrador.sintomas;
    final descGuardada = borrador.descripcion;
    final duracionGuardada = borrador.duracion;
    final intensidadGuardada = borrador.intensidad;

    if (sintomasGuardados != null) {
      _sintomasSeleccionados.addAll(sintomasGuardados);
    }
    if (descGuardada != null) {
      _descripcion = descGuardada;
    }
    if (duracionGuardada != null) {
      _duracion = duracionGuardada;
    }
    if (intensidadGuardada != null) {
      _intensidad = intensidadGuardada;
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
    await _borradorRepository.borrarBorradorSintomas();
  }
}