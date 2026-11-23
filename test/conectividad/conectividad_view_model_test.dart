import 'dart:async';

import 'package:clinica_vitalis/data/services/conectividad_service.dart';
import 'package:clinica_vitalis/ui/conectividad/view_models/conectividad_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Servicio de conectividad falso controlado desde el test.
class FakeServicioDeConectividad implements ServicioDeConectividad {
  FakeServicioDeConectividad({this.redInicial = true});

  final bool redInicial;
  final StreamController<bool> controlador = StreamController<bool>();

  @override
  Stream<bool> get cambios => controlador.stream;

  @override
  Future<bool> hayRed() async => redInicial;
}

void main() {
  late FakeServicioDeConectividad servicio;
  late ConectividadViewModel viewModel;
  late int notificaciones;
  var viewModelDescartado = false;

  Future<void> crearViewModel({bool redInicial = true}) async {
    servicio = FakeServicioDeConectividad(redInicial: redInicial);
    viewModel = ConectividadViewModel(servicio: servicio);
    notificaciones = 0;
    viewModelDescartado = false;
    viewModel.addListener(() => notificaciones++);
    await pumpEventQueue();
  }

  tearDown(() async {
    if (!viewModelDescartado) viewModel.dispose();
    await servicio.controlador.close();
  });

  test('con red al arrancar hay conexion y no notifica', () async {
    await crearViewModel();

    expect(viewModel.hayConexion, isTrue);
    expect(notificaciones, 0);
  });

  test('sin red al arrancar pasa a sin conexion y notifica', () async {
    await crearViewModel(redInicial: false);

    expect(viewModel.hayConexion, isFalse);
    expect(notificaciones, 1);
  });

  test('sigue los cambios del stream', () async {
    await crearViewModel();

    servicio.controlador.add(false);
    await pumpEventQueue();
    expect(viewModel.hayConexion, isFalse);

    servicio.controlador.add(true);
    await pumpEventQueue();
    expect(viewModel.hayConexion, isTrue);
    expect(notificaciones, 2);
  });

  test('un valor repetido no vuelve a notificar', () async {
    await crearViewModel();

    servicio.controlador.add(true);
    servicio.controlador.add(false);
    servicio.controlador.add(false);
    await pumpEventQueue();

    expect(notificaciones, 1);
  });

  test('dispose cancela la suscripcion al stream', () async {
    await crearViewModel();
    expect(servicio.controlador.hasListener, isTrue);

    viewModel.dispose();
    viewModelDescartado = true;
    await pumpEventQueue();

    expect(servicio.controlador.hasListener, isFalse);
  });
}
