import 'package:flutter/material.dart';

class FormularioPerfil extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController apellidoController;
  final TextEditingController dniController;
  final TextEditingController fechaNacimientoController;
  final TextEditingController telefonoController;
  final String obraSocialValue;
  final ValueChanged<String?> onObraSocialChanged;
  final TextEditingController numeroAfiliadoController;
  final VoidCallback onTapFecha;
  final VoidCallback onGuardar;
  final bool isLoading;
  final String textoBoton;

  const FormularioPerfil({
    super.key,
    required this.formKey,
    required this.nombreController,
    required this.apellidoController,
    required this.dniController,
    required this.fechaNacimientoController,
    required this.telefonoController,
    required this.obraSocialValue,
    required this.onObraSocialChanged,
    required this.numeroAfiliadoController,
    required this.onTapFecha,
    required this.onGuardar,
    this.isLoading = false,
    this.textoBoton = 'Guardar Cambios',
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Nombre
          TextFormField(
            controller: nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 16),

          // Apellido
          TextFormField(
            controller: apellidoController,
            decoration: const InputDecoration(
              labelText: 'Apellido',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 16),

          // DNI (7 u 8 dígitos)
          TextFormField(
            controller: dniController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'DNI',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese su DNI';
              }
              if (!RegExp(r'^\d{7,8}$').hasMatch(value)) {
                return 'Debe tener 7 u 8 dígitos';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Fecha de Nacimiento (Solo lectura, abre el DatePicker)
          TextFormField(
            controller: fechaNacimientoController,
            readOnly: true,
            onTap: onTapFecha,
            decoration: const InputDecoration(
              labelText: 'Fecha de Nacimiento',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 16),

          // Teléfono (8 a 15 dígitos)
          TextFormField(
            controller: telefonoController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono de contacto',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese su teléfono';
              }
              if (!RegExp(r'^\d{8,15}$').hasMatch(value)) {
                return 'Debe tener entre 8 y 15 dígitos';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Obra Social (Dropdown)
          DropdownButtonFormField<String>(
            initialValue: obraSocialValue,
            decoration: const InputDecoration(
              labelText: 'Obra Social / Prepaga',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.medical_services),
            ),
            items: const [
              DropdownMenuItem(value: 'Particular', child: Text('Particular')),
              DropdownMenuItem(value: 'OSDE', child: Text('OSDE')),
              DropdownMenuItem(
                  value: 'Swiss Medical', child: Text('Swiss Medical')),
              DropdownMenuItem(value: 'Galeno', child: Text('Galeno')),
              DropdownMenuItem(value: 'PAMI', child: Text('PAMI')),
              DropdownMenuItem(value: 'IOMA', child: Text('IOMA')),
              DropdownMenuItem(value: 'Otra', child: Text('Otra')),
            ],
            onChanged: onObraSocialChanged,
          ),
          const SizedBox(height: 16),

          // Número de Afiliado (Solo aparece si no es Particular)
          if (obraSocialValue != 'Particular')
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextFormField(
                controller: numeroAfiliadoController,
                decoration: const InputDecoration(
                  labelText: 'Número de Afiliado',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Requerido' : null,
              ),
            ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : onGuardar,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(textoBoton, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
