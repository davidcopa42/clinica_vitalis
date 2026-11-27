import 'dart:async';

import 'package:clinica_vitalis/data/repositories/conectividad_repositorio_local.dart';
import 'package:clinica_vitalis/data/services/conectividad_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Servicio de conectividad falso controlado desde el test.
class FakeConectividadService implements ConectividadService {
  final StreamController<bool> controlador = StreamController<bool>();
  bool red = true;

  @override
  Stream<bool> get cambios => controlador.stream;

  @override
  Future<bool> hayRed() async => red;
}

void main() {
  late FakeConectividadService servicio;
  late ConectividadRepositorioLocal repositorio;

  setUp(() {
    servicio = FakeConectividadService();
    repositorio = ConectividadRepositorioLocal(conectividadService: servicio);
  });

  // Sin await: close() no termina si el stream nunca tuvo oyente.
  tearDown(() {
    servicio.controlador.close();
  });

  test('verificarConexion devuelve lo que informa el servicio', () async {
    expect(await repositorio.verificarConexion(), isTrue);

    servicio.red = false;

    expect(await repositorio.verificarConexion(), isFalse);
  });

  test('cambiosDeConexion reenvia los cambios del servicio', () async {
    final valores = <bool>[];
    final suscripcion = repositorio.cambiosDeConexion.listen(valores.add);

    servicio.controlador
      ..add(false)
      ..add(true);
    await pumpEventQueue();
    await suscripcion.cancel();

    expect(valores, [false, true]);
  });
}
