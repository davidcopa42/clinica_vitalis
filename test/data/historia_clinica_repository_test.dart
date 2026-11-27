import 'package:clinica_vitalis/data/repositories/historia_clinica_repositorio_simulado.dart';
import 'package:clinica_vitalis/domain/models/registro_clinico.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HistoriaClinicaRepository (simulado)', () {
    test('devuelve 7 registros ordenados del mas reciente al mas antiguo',
        () async {
      final registros = await HistoriaClinicaRepositorioSimulado()
          .obtenerRegistros('paciente-1');

      expect(registros, hasLength(7));
      expect(registros.first.titulo, 'Hemograma completo');
      expect(registros.first.fecha, DateTime(2026, 10, 20));
      expect(registros.last.titulo, 'Perfil lipídico');
      for (var indice = 1; indice < registros.length; indice++) {
        expect(
          registros[indice - 1].fecha.isAfter(registros[indice].fecha),
          isTrue,
        );
      }
    });

    test('incluye los tres tipos de registro', () async {
      final registros = await HistoriaClinicaRepositorioSimulado()
          .obtenerRegistros('paciente-1');

      expect(
        registros.map((registro) => registro.tipo).toSet(),
        TipoRegistro.values.toSet(),
      );
    });

    test('con simularError lanza una excepcion', () async {
      await expectLater(
        HistoriaClinicaRepositorioSimulado(simularError: true)
            .obtenerRegistros('paciente-1'),
        throwsException,
      );
    });
  });
}
