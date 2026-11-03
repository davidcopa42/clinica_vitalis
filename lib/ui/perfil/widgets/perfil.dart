import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/perfil_provider.dart';

class PerfilScreen extends StatefulWidget {
  final String uid;

  const PerfilScreen({super.key, required this.uid});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PerfilProvider>().cargarPerfil(widget.uid);
    });
  }

  void _mostrarDialogoEdicion(BuildContext context, Map<String, dynamic> datosActuales) {
    final nombreController = TextEditingController(text: datosActuales['nombre']);
    final telefonoController = TextEditingController(text: datosActuales['telefono']);
    final obraSocialController = TextEditingController(text: datosActuales['obraSocial']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Perfil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre Completo'),
                ),
                TextField(
                  controller: telefonoController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: obraSocialController,
                  decoration: const InputDecoration(labelText: 'Obra Social'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<PerfilProvider>().actualizarPerfil(
                  widget.uid,
                  {
                    'nombre': nombreController.text,
                    'telefono': telefonoController.text,
                    'obraSocial': obraSocialController.text,
                  },
                );
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PerfilProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.perfilData == null
          ? const Center(child: Text('No hay datos de perfil.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${provider.perfilData!['nombre'] ?? '-'}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('Teléfono: ${provider.perfilData!['telefono'] ?? '-'}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('Obra Social: ${provider.perfilData!['obraSocial'] ?? '-'}',
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
      floatingActionButton: provider.perfilData != null && !provider.isLoading
          ? FloatingActionButton(
        onPressed: () => _mostrarDialogoEdicion(context, provider.perfilData!),
        child: const Icon(Icons.edit),
      )
          : null,
    );
  }
}