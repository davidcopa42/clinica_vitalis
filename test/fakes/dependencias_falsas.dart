import 'package:clinica_vitalis/data/repositories/borrador_repository.dart';
import 'package:clinica_vitalis/data/repositories/conectividad_repository.dart';
import 'package:clinica_vitalis/data/repositories/historia_clinica_repository.dart';
import 'package:clinica_vitalis/data/repositories/perfil_repository.dart';
import 'package:clinica_vitalis/data/services/bus_de_eventos.dart';
import 'package:clinica_vitalis/dependencias.dart';
import 'package:clinica_vitalis/domain/models/borrador_sintomas.dart';
import 'package:clinica_vitalis/domain/models/borrador_turno.dart';
import 'package:clinica_vitalis/domain/models/paciente.dart';
import 'package:clinica_vitalis/domain/models/registro_clinico.dart';

import 'fake_auth_repository.dart';
import 'fake_recordatorio_repository.dart';
import 'fake_turno_repository.dart';

/// Perfil en memoria, configurable.
class PerfilRepositoryFalso implements PerfilRepository {
  Paciente? paciente;

  @override
  Future<Paciente?> obtenerPerfil(String uid) async => paciente;

  @override
  Future<Map<String, dynamic>?> cargarPerfilUsuario(String uid) async =>
      paciente?.toMap();

  @override
  Future<void> guardarPerfil(
    String uid,
    Map<String, dynamic> datosPerfil,
  ) async {}
}

class HistoriaClinicaRepositoryFalso implements HistoriaClinicaRepository {
  @override
  Future<List<RegistroClinico>> obtenerRegistros(String pacienteUid) async =>
      [];
}

class BorradorRepositoryFalso implements BorradorRepository {
  @override
  Future<BorradorTurno> obtenerBorradorTurno() async => const BorradorTurno();

  @override
  Future<void> guardarBorradorTurno(BorradorTurno borrador) async {}

  @override
  Future<void> borrarBorradorTurno() async {}

  @override
  Future<BorradorSintomas> obtenerBorradorSintomas() async =>
      const BorradorSintomas();

  @override
  Future<void> guardarBorradorSintomas(BorradorSintomas borrador) async {}

  @override
  Future<void> borrarBorradorSintomas() async {}
}

class ConectividadRepositoryFalso implements ConectividadRepository {
  @override
  Stream<bool> get cambiosDeConexion => const Stream.empty();

  @override
  Future<bool> verificarConexion() async => true;
}

/// Dependencias con repositorios falsos y vacíos, para widget tests.
Dependencias crearDependenciasFalsas({
  FakeAuthRepository? auth,
  PerfilRepositoryFalso? perfiles,
  BusDeEventos? busDeEventos,
}) {
  return Dependencias(
    authRepository: auth ?? FakeAuthRepository(),
    perfilRepository: perfiles ?? PerfilRepositoryFalso(),
    turnoRepository: FakeTurnoRepository(),
    historiaClinicaRepository: HistoriaClinicaRepositoryFalso(),
    borradorRepository: BorradorRepositoryFalso(),
    recordatorioRepository: FakeRecordatorioRepository(),
    conectividadRepository: ConectividadRepositoryFalso(),
    busDeEventos: busDeEventos ?? BusDeEventos(),
  );
}
