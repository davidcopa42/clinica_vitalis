import 'package:clinica_vitalis/domain/models/registro_clinico.dart';
import 'package:clinica_vitalis/ui/historia_clinica/view_models/textos_registro_clinico.dart';
import 'package:flutter_test/flutter_test.dart';

RegistroClinico crearRegistro(TipoRegistro tipo, DateTime fecha) {
  return RegistroClinico(
    tipo: tipo,
    titulo: 'Título',
    fecha: fecha,
    profesional: 'Dra. Laura Pérez',
    detalle: 'Detalle',
  );
}

void main() {
  test('fechaTexto usa d/m/aaaa sin ceros a la izquierda', () {
    expect(
      crearRegistro(TipoRegistro.analisis, DateTime(2026, 9, 5)).fechaTexto,
      '5/9/2026',
    );
    expect(
      crearRegistro(TipoRegistro.analisis, DateTime(2026, 10, 20)).fechaTexto,
      '20/10/2026',
    );
  });

  test('resumenTexto pone profesional y fecha en dos lineas', () {
    expect(
      crearRegistro(TipoRegistro.receta, DateTime(2026, 9, 5)).resumenTexto,
      'Dra. Laura Pérez\n5/9/2026',
    );
  });

  test('tipoTexto nombra cada tipo en singular', () {
    final fecha = DateTime(2026);
    expect(crearRegistro(TipoRegistro.analisis, fecha).tipoTexto, 'Análisis');
    expect(crearRegistro(TipoRegistro.estudio, fecha).tipoTexto, 'Estudio');
    expect(crearRegistro(TipoRegistro.receta, fecha).tipoTexto, 'Receta');
  });
}
