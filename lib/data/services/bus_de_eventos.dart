import 'dart:async';

import '../../domain/models/evento_de_app.dart';

/// Bus de eventos para la comunicación desacoplada entre módulos.
///
/// Se crea una sola instancia en `main.dart` y se inyecta por constructor
/// a quien necesite publicar o escuchar eventos.
class BusDeEventos {
  // Controlador de stream tipo broadcast (permite múltiples oyentes)
  final StreamController<EventoDeApp> _controlador =
      StreamController<EventoDeApp>.broadcast();

  /// Expone el stream para que los widgets o ViewModels puedan escucharlo.
  Stream<EventoDeApp> get stream => _controlador.stream;

  /// Publica un nuevo evento en el Stream.
  void publicar(EventoDeApp evento) {
    if (!_controlador.isClosed) {
      _controlador.add(evento);
    }
  }

  /// Cierra el controlador. (Se usaría solo si la app se destruye por completo).
  void dispose() {
    _controlador.close();
  }
}
