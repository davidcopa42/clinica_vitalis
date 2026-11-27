import 'data/repositories/auth_repository.dart';
import 'data/repositories/borrador_repository.dart';
import 'data/repositories/conectividad_repository.dart';
import 'data/repositories/historia_clinica_repository.dart';
import 'data/repositories/perfil_repository.dart';
import 'data/repositories/recordatorio_repository.dart';
import 'data/repositories/turno_repository.dart';
import 'data/services/bus_de_eventos.dart';

/// Repositorios y bus de eventos compartidos por toda la app.
///
/// Se arma una sola vez en `main.dart` y baja por constructor a quien
/// tenga que crear ViewModels. Expone solo contratos, nunca
/// implementaciones concretas.
class Dependencias {
  const Dependencias({
    required this.authRepository,
    required this.perfilRepository,
    required this.turnoRepository,
    required this.historiaClinicaRepository,
    required this.borradorRepository,
    required this.recordatorioRepository,
    required this.conectividadRepository,
    required this.busDeEventos,
  });

  final AuthRepository authRepository;
  final PerfilRepository perfilRepository;
  final TurnoRepository turnoRepository;
  final HistoriaClinicaRepository historiaClinicaRepository;
  final BorradorRepository borradorRepository;
  final RecordatorioRepository recordatorioRepository;
  final ConectividadRepository conectividadRepository;
  final BusDeEventos busDeEventos;
}
