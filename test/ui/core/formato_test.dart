import 'package:clinica_vitalis/ui/core/formato.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('formatearFecha', () {
    test('usa dd/mm/aaaa con ceros a la izquierda', () {
      expect(formatearFecha(DateTime(2026, 11, 5)), '05/11/2026');
      expect(formatearFecha(DateTime(1990, 1, 31)), '31/01/1990');
    });

    test('ignora la hora', () {
      expect(formatearFecha(DateTime(2026, 3, 15, 23, 59)), '15/03/2026');
    });

    test('da lo mismo que DateFormat dd/MM/yyyy en el rango del calendario',
        () {
      final formatoIntl = DateFormat('dd/MM/yyyy');
      final fechas = [
        DateTime(1900, 1, 1),
        DateTime(1999, 12, 31),
        DateTime(2000, 2, 29),
        DateTime(2026, 7, 9),
      ];

      for (final fecha in fechas) {
        expect(formatearFecha(fecha), formatoIntl.format(fecha));
      }
    });
  });
}
