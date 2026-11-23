import 'package:clinica_vitalis/data/repositories/historia_clinica_repository.dart';
import 'package:clinica_vitalis/domain/models/registro_clinico.dart';
import 'package:clinica_vitalis/ui/core/estado_carga.dart';
import 'package:clinica_vitalis/ui/historia_clinica/view_models/historia_clinica_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositorio falso que devuelve registros fijos sin demora.
class FakeHistoriaClinicaRepository implements HistoriaClinicaRepository {
  FakeHistoriaClinicaRepository(this.registros);

  final List<RegistroClinico> registros;
  final List<String> pacientesConsultados = [];
  Object? error;

  @override
  Future<List<RegistroClinico>> obtenerRegistros(String pacienteUid) async {
    pacientesConsultados.add(pacienteUid);
    if (error != null) throw error!;
    return List.of(registros);
  }
}

RegistroClinico crearRegistro(TipoRegistro tipo, String titulo) {
  return RegistroClinico(
    tipo: tipo,
    titulo: titulo,
    fecha: DateTime(2026, 10, 1),
    profesional: 'Dra. Laura Pérez',
    detalle: 'Detalle',
  );
}

void main() {
  final registros = [
    crearRegistro(TipoRegistro.analisis, 'Hemograma'),
    crearRegistro(TipoRegistro.receta, 'Receta'),
    crearRegistro(TipoRegistro.analisis, 'Glucemia'),
    crearRegistro(TipoRegistro.estudio, 'Radiografía'),
  ];

  late FakeHistoriaClinicaRepository repositorio;
  late HistoriaClinicaViewModel viewModel;

  List<String> titulos(List<RegistroClinico> lista) =>
      lista.map((registro) => registro.titulo).toList();

  setUp(() {
    repositorio = FakeHistoriaClinicaRepository(registros);
    viewModel = HistoriaClinicaViewModel(repositorio: repositorio);
  });

  tearDown(() => viewModel.dispose());

  group('cargar', () {
    test('empieza en estado inicial, sin registros ni filtro', () {
      expect(viewModel.estado, EstadoCarga.inicial);
      expect(viewModel.registros, isEmpty);
      expect(viewModel.filtro, isNull);
      expect(viewModel.mensajeError, isNull);
    });

    test('pasa por cargando y termina en exito con los registros', () async {
      final estados = <EstadoCarga>[];
      viewModel.addListener(() => estados.add(viewModel.estado));

      await viewModel.cargar('paciente-1');

      expect(estados, [EstadoCarga.cargando, EstadoCarga.exito]);
      expect(repositorio.pacientesConsultados, ['paciente-1']);
      expect(
        titulos(viewModel.registros),
        ['Hemograma', 'Receta', 'Glucemia', 'Radiografía'],
      );
    });

    test('si falla queda en error con mensaje', () async {
      repositorio.error = Exception('falla');

      await viewModel.cargar('paciente-1');

      expect(viewModel.estado, EstadoCarga.error);
      expect(viewModel.mensajeError, 'No se pudo cargar la historia clínica.');
    });

    test('reintentar vuelve a cargar el ultimo paciente', () async {
      repositorio.error = Exception('falla');
      await viewModel.cargar('paciente-1');
      repositorio.error = null;

      await viewModel.reintentar();

      expect(repositorio.pacientesConsultados, ['paciente-1', 'paciente-1']);
      expect(viewModel.estado, EstadoCarga.exito);
      expect(viewModel.mensajeError, isNull);
    });

    test('la lista de registros no se puede modificar desde afuera', () async {
      await viewModel.cargar('paciente-1');

      expect(
        () => viewModel.registros.add(registros.first),
        throwsUnsupportedError,
      );
    });
  });

  group('filtro', () {
    setUp(() => viewModel.cargar('paciente-1'));

    test('sin filtro registrosFiltrados devuelve todos', () {
      expect(titulos(viewModel.registrosFiltrados), hasLength(4));
    });

    test('con filtro devuelve solo los de ese tipo, en el mismo orden', () {
      viewModel.cambiarFiltro(TipoRegistro.analisis);

      expect(viewModel.filtro, TipoRegistro.analisis);
      expect(
        titulos(viewModel.registrosFiltrados),
        ['Hemograma', 'Glucemia'],
      );
    });

    test('cambiarFiltro notifica y null vuelve a mostrar todo', () {
      var notificaciones = 0;
      viewModel.addListener(() => notificaciones++);

      viewModel.cambiarFiltro(TipoRegistro.receta);
      viewModel.cambiarFiltro(null);

      expect(notificaciones, 2);
      expect(viewModel.registrosFiltrados, hasLength(4));
    });

    test('el filtro se mantiene despues de recargar', () async {
      viewModel.cambiarFiltro(TipoRegistro.estudio);

      await viewModel.cargar('paciente-1');

      expect(titulos(viewModel.registrosFiltrados), ['Radiografía']);
    });

    test('registrosFiltrados no se puede modificar, con o sin filtro', () {
      expect(
        () => viewModel.registrosFiltrados.clear(),
        throwsUnsupportedError,
      );

      viewModel.cambiarFiltro(TipoRegistro.analisis);

      expect(
        () => viewModel.registrosFiltrados.clear(),
        throwsUnsupportedError,
      );
    });
  });
}
