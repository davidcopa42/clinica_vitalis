import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/borrador_repository.dart';
import '../../../domain/models/borrador_sintomas.dart';
import '../../../domain/models/evento_de_app.dart';
import '../../core/bus_de_eventos.dart';
import 'duracion_sintomas.dart';

/// Estado y comandos de la pantalla de registro de sintomas.
class SintomasViewModel extends ChangeNotifier {
  SintomasViewModel({
    required BorradorRepository borradorRepository,
    required BusDeEventos busDeEventos,
  })  : _borradorRepository = borradorRepository,
        _busDeEventos = busDeEventos;

  static const intensidadMinima = 1.0;
  static const intensidadMaxima = 10.0;

  /// Desde esta intensidad se recomienda ir a la guardia.
  static const intensidadDeAlarma = 9.0;

  static const sintomasDisponibles = [
    'Dolor de cabeza',
    'Fiebre',
    'Tos',
    'Dolor de garganta',
    'Dolor abdominal',
    'Mareos',
    'Náuseas',
    'Dolor muscular',
    ..._sintomasDeAlarma,
  ];

  static const _sintomasDeAlarma = [
    'Dolor de pecho',
    'Falta de aire',
    'Pérdida de conocimiento',
    'Sangrado abundante',
    'Dificultad para hablar o mover un lado del cuerpo',
  ];

  final BorradorRepository _borradorRepository;
  final BusDeEventos _busDeEventos;

  final Set<String> _sintomasSeleccionados = {};
  String _descripcion = '';
  DuracionSintomas _duracion = DuracionSintomas.hoy;
  double _intensidad = intensidadMinima;
  bool _estaRegistrado = false;

  Set<String> get sintomasSeleccionados =>
      Set.unmodifiable(_sintomasSeleccionados);
  String get descripcion => _descripcion;
  DuracionSintomas get duracion => _duracion;
  double get intensidad => _intensidad;
  bool get estaRegistrado => _estaRegistrado;

  /// Cantidad de pasos del selector de intensidad.
  int get divisionesIntensidad => (intensidadMaxima - intensidadMinima).round();

  String get intensidadEtiqueta => _intensidad.round().toString();

  String get intensidadTexto =>
      'Intensidad: $intensidadEtiqueta / ${intensidadMaxima.round()}';

  bool get tieneSignosAlarma =>
      _sintomasSeleccionados.any(_sintomasDeAlarma.contains) ||
      _intensidad >= intensidadDeAlarma;

  bool get muestraConfirmacion => _estaRegistrado && !tieneSignosAlarma;
  bool get muestraRegistroUrgente => _estaRegistrado && tieneSignosAlarma;
  bool get puedeSolicitarTurno => !tieneSignosAlarma;

  /// Restaura el borrador guardado, si existe.
  void cargarBorrador() {
    final borrador = _borradorRepository.obtenerBorradorSintomas();
    _sintomasSeleccionados
      ..clear()
      ..addAll(borrador.sintomas);
    _descripcion = borrador.descripcion ?? '';
    _duracion = DuracionSintomas.desdeValor(borrador.duracion);
    _intensidad = borrador.intensidad ?? intensidadMinima;
    notifyListeners();
  }

  /// Guarda el estado actual como borrador.
  Future<void> guardarBorrador() {
    return _borradorRepository.guardarBorradorSintomas(
      BorradorSintomas(
        sintomas: _sintomasSeleccionados.toList(),
        descripcion: _descripcion,
        duracion: _duracion.valor,
        intensidad: _intensidad,
      ),
    );
  }

  /// Agrega o quita [sintoma] de la seleccion.
  void alternarSintoma(String sintoma) {
    if (!_sintomasSeleccionados.remove(sintoma)) {
      _sintomasSeleccionados.add(sintoma);
    }
    _registrarCambio();
  }

  void cambiarDescripcion(String descripcion) {
    _descripcion = descripcion;
    _registrarCambio();
  }

  void cambiarDuracion(DuracionSintomas duracion) {
    _duracion = duracion;
    _registrarCambio();
  }

  void cambiarIntensidad(double intensidad) {
    _intensidad = intensidad;
    _registrarCambio();
  }

  /// Registra los sintomas, avisa al resto de la app y borra el borrador.
  Future<void> registrarSintomas() async {
    _estaRegistrado = true;
    notifyListeners();
    _busDeEventos.publicar(
      SintomasRegistradosEvento(requiereAtencionUrgente: tieneSignosAlarma),
    );
    await _borradorRepository.eliminarBorradorSintomas();
  }

  void _registrarCambio() {
    _estaRegistrado = false;
    notifyListeners();
    unawaited(guardarBorrador());
  }
}
