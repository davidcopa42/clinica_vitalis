import 'package:clinica_vitalis/data/repositories/borrador_repository.dart';
import 'package:clinica_vitalis/domain/models/borrador_sintomas.dart';
import 'package:clinica_vitalis/domain/models/borrador_turno.dart';

/// [BorradorRepository] en memoria para los tests.
class FakeBorradorRepository implements BorradorRepository {
  FakeBorradorRepository({
    this.borradorTurno = const BorradorTurno(),
    this.borradorSintomas = const BorradorSintomas(),
  });

  BorradorTurno borradorTurno;
  BorradorSintomas borradorSintomas;

  @override
  BorradorTurno obtenerBorradorTurno() => borradorTurno;

  @override
  Future<void> guardarBorradorTurno(BorradorTurno borrador) async =>
      borradorTurno = borrador;

  @override
  Future<void> eliminarBorradorTurno() async =>
      borradorTurno = const BorradorTurno();

  @override
  BorradorSintomas obtenerBorradorSintomas() => borradorSintomas;

  @override
  Future<void> guardarBorradorSintomas(BorradorSintomas borrador) async =>
      borradorSintomas = borrador;

  @override
  Future<void> eliminarBorradorSintomas() async =>
      borradorSintomas = const BorradorSintomas();
}
