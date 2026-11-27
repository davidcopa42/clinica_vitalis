import 'package:flutter/material.dart';

import '../../../domain/models/registro_clinico.dart';
import 'detalle_registro_screen.dart';
import 'filtro_tipos_registro.dart';
import 'tarjeta_registro.dart';

/// Filtro por tipo y lista de registros de la historia clínica.
class ListaRegistros extends StatelessWidget {
  const ListaRegistros({
    super.key,
    required this.registros,
    required this.filtro,
    required this.alCambiarFiltro,
  });

  final List<RegistroClinico> registros;
  final TipoRegistro? filtro;
  final ValueChanged<TipoRegistro?> alCambiarFiltro;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FiltroTiposRegistro(filtro: filtro, alCambiar: alCambiarFiltro),
        Expanded(
          child: registros.isEmpty
              ? const Center(
                  child: Text('No hay registros para este filtro.'),
                )
              : ListView.builder(
                  itemCount: registros.length,
                  itemBuilder: (context, index) {
                    final registro = registros[index];
                    return TarjetaRegistro(
                      registro: registro,
                      alTocar: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetalleRegistroScreen(registro: registro),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
