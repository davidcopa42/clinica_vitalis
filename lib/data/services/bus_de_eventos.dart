import 'dart:async';
import '../../domain/evento_de_app.dart';

/// Bus de eventos global para la comunicación desacoplada mediante Streams.
class BusDeEventos {
  // Patrón Singleton para usar la misma instancia en toda la app
  static final BusDeEventos _instancia = BusDeEventos._interno();
  factory BusDeEventos() => _instancia;
  BusDeEventos._interno();

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

// Instancia global accesible desde cualquier archivo
final busDeEventos = BusDeEventos();