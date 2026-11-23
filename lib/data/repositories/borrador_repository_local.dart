import '../../domain/models/borrador_sintomas.dart';
import '../../domain/models/borrador_turno.dart';
import '../services/preferencias_service.dart';
import 'borrador_repository.dart';

/// Implementacion de [BorradorRepository] sobre [PreferenciasService].
class BorradorRepositoryLocal implements BorradorRepository {
  BorradorRepositoryLocal({required PreferenciasService preferenciasService})
      : _preferencias = preferenciasService;

  static const claveEspecialidad = 'borrador_especialidad';
  static const claveProfesional = 'borrador_profesional';
  static const claveFecha = 'borrador_fecha';
  static const claveHorario = 'borrador_horario';
  static const claveSintomas = 'borrador_sintomas_lista';
  static const claveDescripcion = 'borrador_sintomas_desc';
  static const claveDuracion = 'borrador_sintomas_duracion';
  static const claveIntensidad = 'borrador_sintomas_intensidad';

  final PreferenciasService _preferencias;

  @override
  BorradorTurno obtenerBorradorTurno() {
    return BorradorTurno(
      especialidad: _preferencias.leerTexto(claveEspecialidad),
      profesional: _preferencias.leerTexto(claveProfesional),
      fecha: DateTime.tryParse(_preferencias.leerTexto(claveFecha) ?? ''),
      horario: _preferencias.leerTexto(claveHorario),
    );
  }

  @override
  Future<void> guardarBorradorTurno(BorradorTurno borrador) async {
    await _guardarOEliminar(claveEspecialidad, borrador.especialidad);
    await _guardarOEliminar(claveProfesional, borrador.profesional);
    await _guardarOEliminar(claveFecha, borrador.fecha?.toIso8601String());
    await _guardarOEliminar(claveHorario, borrador.horario);
  }

  @override
  Future<void> eliminarBorradorTurno() async {
    await _preferencias.eliminar(claveEspecialidad);
    await _preferencias.eliminar(claveProfesional);
    await _preferencias.eliminar(claveFecha);
    await _preferencias.eliminar(claveHorario);
  }

  @override
  BorradorSintomas obtenerBorradorSintomas() {
    return BorradorSintomas(
      sintomas: _preferencias.leerListaTexto(claveSintomas) ?? const [],
      descripcion: _preferencias.leerTexto(claveDescripcion),
      duracion: _preferencias.leerTexto(claveDuracion),
      intensidad: _preferencias.leerDecimal(claveIntensidad),
    );
  }

  @override
  Future<void> guardarBorradorSintomas(BorradorSintomas borrador) async {
    await _preferencias.guardarListaTexto(claveSintomas, borrador.sintomas);
    await _guardarOEliminar(claveDescripcion, borrador.descripcion);
    await _guardarOEliminar(claveDuracion, borrador.duracion);
    final intensidad = borrador.intensidad;
    if (intensidad == null) {
      await _preferencias.eliminar(claveIntensidad);
    } else {
      await _preferencias.guardarDecimal(claveIntensidad, intensidad);
    }
  }

  @override
  Future<void> eliminarBorradorSintomas() async {
    await _preferencias.eliminar(claveSintomas);
    await _preferencias.eliminar(claveDescripcion);
    await _preferencias.eliminar(claveDuracion);
    await _preferencias.eliminar(claveIntensidad);
  }

  Future<void> _guardarOEliminar(String clave, String? valor) async {
    if (valor == null) {
      await _preferencias.eliminar(clave);
    } else {
      await _preferencias.guardarTexto(clave, valor);
    }
  }
}
