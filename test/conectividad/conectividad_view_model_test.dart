import 'dart:async';

import 'package:clinica_vitalis/data/repositories/conectividad_repository.dart';
import 'package:clinica_vitalis/ui/conectividad/view_models/conectividad_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositorio de conectividad falso controlado desde el test.
class FakeConectividadRepository implements ConectividadRepository {
  FakeConectividadRepository({this.redInicial = true});

  final bool redInicial;
  final StreamController<bool> controlador = StreamController<bool>();

  @override
  Stream<bool> get cambiosDeConexion => controlador.stream;

  @override
  Future<bool> verificarConexion() async => redInicial;
}

void main() {
  late FakeConectividadRepository repositorio;
  late ConectividadViewModel viewModel;
  late int notificaciones;
  var viewModelDescartado = false;

  Future<void> crearViewModel({bool redInicial = true}) async {
    repositorio = FakeConectividadRepository(redInicial: redInicial);
    viewModel = ConectividadViewModel(repositorio: repositorio);
    notificaciones = 0;
    viewModelDescartado = false;
    viewModel.addListener(() => notificaciones++);
    await pumpEventQueue();
  }

  tearDown(() async {
    if (!viewModelDescartado) viewModel.dispose();
    await repositorio.controlador.close();
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

    repositorio.controlador.add(false);
    await pumpEventQueue();
    expect(viewModel.hayConexion, isFalse);

    repositorio.controlador.add(true);
    await pumpEventQueue();
    expect(viewModel.hayConexion, isTrue);
    expect(notificaciones, 2);
  });

  test('un valor repetido no vuelve a notificar', () async {
    await crearViewModel();

    repositorio.controlador.add(true);
    repositorio.controlador.add(false);
    repositorio.controlador.add(false);
    await pumpEventQueue();

    expect(notificaciones, 1);
  });

  test('dispose cancela la suscripcion al stream', () async {
    await crearViewModel();
    expect(repositorio.controlador.hasListener, isTrue);

    viewModel.dispose();
    viewModelDescartado = true;
    await pumpEventQueue();

    expect(repositorio.controlador.hasListener, isFalse);
  });
}
