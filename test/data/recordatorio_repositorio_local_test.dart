import 'dart:async';

import 'package:clinica_vitalis/data/repositories/recordatorio_repositorio_local.dart';
import 'package:clinica_vitalis/data/services/notificaciones_service.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:flutter_test/flutter_test.dart';

/// Servicio de notificaciones falso que registra lo que se le pide.
class FakeNotificacionesService implements NotificacionesService {
  final List<Turno> programados = [];
  final List<int> cancelados = [];
  bool permiso = true;
  String? payloadDeLanzamiento;
  int lanzamientosConsultados = 0;
  final StreamController<String?> controladorToques =
      StreamController<String?>.broadcast();

  @override
  Stream<String?> get toques => controladorToques.stream;

  @override
  Future<String?> obtenerPayloadDeLanzamiento() async {
    lanzamientosConsultados++;
    return payloadDeLanzamiento;
  }

  @override
  Future<void> inicializar() async {}

  @override
  Future<void> programarRecordatorio(Turno turno) async =>
      programados.add(turno);

  @override
  Future<void> cancelarRecordatorio(int turnoId) async =>
      cancelados.add(turnoId);

  @override
  Future<bool> pedirPermiso() async => permiso;
}

void main() {
  late FakeNotificacionesService servicio;
  late RecordatorioRepositorioLocal repositorio;

  final turno = Turno(
    id: 7,
    pacienteUid: 'paciente-1',
    especialidad: 'Cardiología',
    profesional: 'Dr. Juan Pérez',
    fecha: DateTime(2030, 3, 15),
    horario: '08:40',
  );

  setUp(() {
    servicio = FakeNotificacionesService();
    repositorio = RecordatorioRepositorioLocal(notificacionesService: servicio);
  });

  test('programarRecordatorio delega en el servicio con el mismo turno',
      () async {
    await repositorio.programarRecordatorio(turno);

    expect(servicio.programados, [turno]);
  });

  test('cancelarRecordatorio delega en el servicio con el id', () async {
    await repositorio.cancelarRecordatorio(7);

    expect(servicio.cancelados, [7]);
  });

  group('recordatorios tocados', () {
    test('sin toques no hay nada pendiente', () async {
      expect(await repositorio.consumirRecordatorioTocado(), isFalse);
    });

    test('un toque se avisa y se consume una sola vez', () async {
      var avisos = 0;
      repositorio.recordatoriosTocados.listen((_) => avisos++);

      servicio.controladorToques.add(NotificacionesService.payloadMisTurnos);
      await pumpEventQueue();

      expect(avisos, 1);
      expect(await repositorio.consumirRecordatorioTocado(), isTrue);
      expect(await repositorio.consumirRecordatorioTocado(), isFalse);
    });

    test('se recuerda aunque nadie escuche cuando se toca', () async {
      servicio.controladorToques.add(NotificacionesService.payloadMisTurnos);
      await pumpEventQueue();

      expect(await repositorio.consumirRecordatorioTocado(), isTrue);
    });

    test('ignora notificaciones con otro payload', () async {
      servicio.controladorToques.add('otra_cosa');
      await pumpEventQueue();

      expect(await repositorio.consumirRecordatorioTocado(), isFalse);
    });

    test(
        'si la app se abrio desde un recordatorio lo cuenta una sola vez '
        'y no vuelve a preguntar', () async {
      servicio.payloadDeLanzamiento = NotificacionesService.payloadMisTurnos;

      expect(await repositorio.consumirRecordatorioTocado(), isTrue);
      expect(await repositorio.consumirRecordatorioTocado(), isFalse);
      expect(servicio.lanzamientosConsultados, 1);
    });
  });

  test('pedirPermiso devuelve la respuesta del servicio', () async {
    expect(await repositorio.pedirPermiso(), isTrue);

    servicio.permiso = false;
    expect(await repositorio.pedirPermiso(), isFalse);
  });
}
