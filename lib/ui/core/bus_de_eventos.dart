import 'dart:async';

import '../../domain/models/evento_de_app.dart';

/// Canal de comunicacion desacoplada entre ViewModels mediante un Stream.
///
/// Se crea una sola instancia en `main.dart` y se inyecta por constructor.
class BusDeEventos {
  final StreamController<EventoDeApp> _controlador =
      StreamController<EventoDeApp>.broadcast();

  /// Eventos publicados; admite varios oyentes a la vez.
  Stream<EventoDeApp> get eventos => _controlador.stream;

  /// Publica un [evento] para todos los oyentes.
  void publicar(EventoDeApp evento) {
    if (_controlador.isClosed) return;
    _controlador.add(evento);
  }

  /// Cierra el canal. Despues de esto no se pueden publicar eventos.
  Future<void> cerrar() => _controlador.close();
}
