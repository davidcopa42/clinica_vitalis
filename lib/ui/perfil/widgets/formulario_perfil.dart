import 'package:flutter/material.dart';

import '../../core/dimensiones.dart';
import '../../core/obras_sociales.dart';
import '../../core/validadores.dart';
import '../../core/widgets/boton_principal.dart';
import '../../core/widgets/campo_formulario.dart';
import '../../core/widgets/mensaje_error.dart';
import '../view_models/formulario_perfil_view_model.dart';
import 'controladores_perfil.dart';

/// Formulario de datos personales y de cobertura del paciente.
class FormularioPerfil extends StatelessWidget {
  const FormularioPerfil({
    super.key,
    required this.claveFormulario,
    required this.controladores,
    required this.viewModel,
    required this.textoBoton,
    required this.onElegirFecha,
    required this.onGuardar,
  });

  final GlobalKey<FormState> claveFormulario;
  final ControladoresPerfil controladores;
  final FormularioPerfilViewModel viewModel;
  final String textoBoton;
  final VoidCallback onElegirFecha;
  final VoidCallback onGuardar;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Form(
          key: claveFormulario,
          child: Column(
            children: [
              CampoFormulario(
                controlador: controladores.nombre,
                etiqueta: 'Nombre',
                icono: Icons.person,
                validador: Validadores.requerido(),
              ),
              const SizedBox(height: Dimensiones.separacion),
              CampoFormulario(
                controlador: controladores.apellido,
                etiqueta: 'Apellido',
                icono: Icons.person_outline,
                validador: Validadores.requerido(),
              ),
              const SizedBox(height: Dimensiones.separacion),
              CampoFormulario(
                controlador: controladores.dni,
                etiqueta: 'DNI',
                icono: Icons.badge,
                tipoTeclado: TextInputType.number,
                validador: Validadores.dni,
              ),
              const SizedBox(height: Dimensiones.separacion),
              CampoFormulario(
                controlador: controladores.fechaNacimiento,
                etiqueta: 'Fecha de Nacimiento',
                icono: Icons.calendar_today,
                soloLectura: true,
                onTap: onElegirFecha,
                validador: Validadores.requerido(),
              ),
              const SizedBox(height: Dimensiones.separacion),
              CampoFormulario(
                controlador: controladores.telefono,
                etiqueta: 'Teléfono de contacto',
                icono: Icons.phone,
                tipoTeclado: TextInputType.phone,
                validador: Validadores.telefono,
              ),
              const SizedBox(height: Dimensiones.separacion),
              DropdownButtonFormField<String>(
                key: ValueKey(viewModel.obraSocial),
                initialValue: viewModel.obraSocial,
                decoration: const InputDecoration(
                  labelText: 'Obra Social / Prepaga',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services),
                ),
                items: [
                  for (final obraSocial in ObrasSociales.disponibles)
                    DropdownMenuItem(
                      value: obraSocial,
                      child: Text(obraSocial),
                    ),
                ],
                onChanged: viewModel.seleccionarObraSocial,
              ),
              const SizedBox(height: Dimensiones.separacion),
              if (viewModel.requiereNumeroAfiliado) ...[
                CampoFormulario(
                  controlador: controladores.numeroAfiliado,
                  etiqueta: 'Número de Afiliado',
                  icono: Icons.credit_card,
                  validador: Validadores.requerido(),
                ),
                const SizedBox(height: Dimensiones.separacion),
              ],
              if (viewModel.tieneError)
                MensajeError(mensaje: viewModel.mensajeError ?? ''),
              const SizedBox(height: Dimensiones.separacionChica),
              BotonPrincipal(
                texto: textoBoton,
                estaCargando: viewModel.estaGuardando,
                onPressed: onGuardar,
              ),
            ],
          ),
        );
      },
    );
  }
}
