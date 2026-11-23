import 'package:clinica_vitalis/domain/models/borrador_sintomas.dart';
import 'package:clinica_vitalis/domain/models/evento_de_app.dart';
import 'package:clinica_vitalis/ui/core/bus_de_eventos.dart';
import 'package:clinica_vitalis/ui/sintomas/view_models/duracion_sintomas.dart';
import 'package:clinica_vitalis/ui/sintomas/view_models/sintomas_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_borrador_repository.dart';

void main() {
  late FakeBorradorRepository borradorRepository;
  late BusDeEventos busDeEventos;
  late SintomasViewModel viewModel;

  setUp(() {
    borradorRepository = FakeBorradorRepository();
    busDeEventos = BusDeEventos();
    viewModel = SintomasViewModel(
      borradorRepository: borradorRepository,
      busDeEventos: busDeEventos,
    );
  });

  tearDown(() => busDeEventos.cerrar());

  test('un sintoma de alarma o la intensidad maxima activan la alarma', () {
    expect(viewModel.tieneSignosAlarma, isFalse);

    viewModel.alternarSintoma('Dolor de pecho');
    expect(viewModel.tieneSignosAlarma, isTrue);

    viewModel
      ..alternarSintoma('Dolor de pecho')
      ..cambiarIntensidad(SintomasViewModel.intensidadDeAlarma);
    expect(viewModel.tieneSignosAlarma, isTrue);
  });

  test('cada cambio se guarda como borrador', () async {
    viewModel
      ..alternarSintoma('Fiebre')
      ..cambiarDuracion(DuracionSintomas.dosATresDias);
    await pumpEventQueue();

    expect(borradorRepository.borradorSintomas.sintomas, ['Fiebre']);
    expect(
      borradorRepository.borradorSintomas.duracion,
      DuracionSintomas.dosATresDias.valor,
    );
  });

  test('cargarBorrador restaura los datos guardados', () {
    borradorRepository.borradorSintomas = const BorradorSintomas(
      sintomas: ['Tos'],
      descripcion: 'Desde ayer',
      duracion: 'Más de una semana',
      intensidad: 4,
    );

    viewModel.cargarBorrador();

    expect(viewModel.sintomasSeleccionados, {'Tos'});
    expect(viewModel.descripcion, 'Desde ayer');
    expect(viewModel.duracion, DuracionSintomas.masDeUnaSemana);
    expect(viewModel.intensidad, 4);
  });

  test('registrar publica el evento y borra el borrador', () async {
    final eventos = <EventoDeApp>[];
    busDeEventos.eventos.listen(eventos.add);
    viewModel.alternarSintoma('Fiebre');

    await viewModel.registrarSintomas();
    await pumpEventQueue();

    expect(viewModel.estaRegistrado, isTrue);
    expect(borradorRepository.borradorSintomas.sintomas, isEmpty);
    final evento = eventos.single as SintomasRegistradosEvento;
    expect(evento.requiereAtencionUrgente, isFalse);
  });
}
