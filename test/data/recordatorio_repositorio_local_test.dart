import 'package:clinica_vitalis/data/repositories/recordatorio_repositorio_local.dart';
import 'package:clinica_vitalis/data/services/notificaciones_service.dart';
import 'package:clinica_vitalis/domain/models/turno.dart';
import 'package:flutter_test/flutter_test.dart';

/// Servicio de notificaciones falso que registra lo que se le pide.
class FakeNotificacionesService implements NotificacionesService {
  final List<Turno> programados = [];
  final List<int> cancelados = [];

  @override
  Future<void> inicializar() async {}

  @override
  Future<void> programarRecordatorio(Turno turno) async =>
      programados.add(turno);

  @override
  Future<void> cancelarRecordatorio(int turnoId) async =>
      cancelados.add(turnoId);
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
}
