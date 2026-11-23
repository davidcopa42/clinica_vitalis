import '../../domain/models/borrador_sintomas.dart';
import '../../domain/models/borrador_turno.dart';
import '../services/borrador_service.dart';
import 'borrador_repository.dart';

const _claveEspecialidad = 'borrador_especialidad';
const _claveProfesional = 'borrador_profesional';
const _claveFecha = 'borrador_fecha';
const _claveHorario = 'borrador_horario';

const _claveSintomas = 'borrador_sintomas_lista';
const _claveDescripcion = 'borrador_sintomas_desc';
const _claveDuracion = 'borrador_sintomas_duracion';
const _claveIntensidad = 'borrador_sintomas_intensidad';

/// Implementación de [BorradorRepository] que guarda los borradores en el
/// dispositivo mediante [BorradorService].
class BorradorRepositorioLocal implements BorradorRepository {
  BorradorRepositorioLocal({required BorradorService borradorService})
      : _servicio = borradorService;

  final BorradorService _servicio;

  @override
  Future<BorradorTurno> obtenerBorradorTurno() async {
    final fecha = await _servicio.leerTexto(_claveFecha);
    return BorradorTurno(
      especialidad: await _servicio.leerTexto(_claveEspecialidad),
      profesional: await _servicio.leerTexto(_claveProfesional),
      fecha: fecha == null ? null : DateTime.tryParse(fecha),
      horario: await _servicio.leerTexto(_claveHorario),
    );
  }

  @override
  Future<void> guardarBorradorTurno(BorradorTurno borrador) async {
    await _guardarOBorrar(_claveEspecialidad, borrador.especialidad);
    await _guardarOBorrar(_claveProfesional, borrador.profesional);
    await _guardarOBorrar(_claveFecha, borrador.fecha?.toIso8601String());
    await _guardarOBorrar(_claveHorario, borrador.horario);
  }

  @override
  Future<void> borrarBorradorTurno() async {
    await _servicio.borrar(_claveEspecialidad);
    await _servicio.borrar(_claveProfesional);
    await _servicio.borrar(_claveFecha);
    await _servicio.borrar(_claveHorario);
  }

  @override
  Future<BorradorSintomas> obtenerBorradorSintomas() async {
    return BorradorSintomas(
      sintomas: await _servicio.leerListaDeTextos(_claveSintomas),
      descripcion: await _servicio.leerTexto(_claveDescripcion),
      duracion: await _servicio.leerTexto(_claveDuracion),
      intensidad: await _servicio.leerDecimal(_claveIntensidad),
    );
  }

  @override
  Future<void> guardarBorradorSintomas(BorradorSintomas borrador) async {
    final sintomas = borrador.sintomas;
    final descripcion = borrador.descripcion;
    final duracion = borrador.duracion;
    final intensidad = borrador.intensidad;

    if (sintomas != null) {
      await _servicio.escribirListaDeTextos(_claveSintomas, sintomas);
    }
    if (descripcion != null) {
      await _servicio.escribirTexto(_claveDescripcion, descripcion);
    }
    if (duracion != null) {
      await _servicio.escribirTexto(_claveDuracion, duracion);
    }
    if (intensidad != null) {
      await _servicio.escribirDecimal(_claveIntensidad, intensidad);
    }
  }

  @override
  Future<void> borrarBorradorSintomas() async {
    await _servicio.borrar(_claveSintomas);
    await _servicio.borrar(_claveDescripcion);
    await _servicio.borrar(_claveDuracion);
    await _servicio.borrar(_claveIntensidad);
  }

  Future<void> _guardarOBorrar(String clave, String? valor) async {
    if (valor == null) {
      await _servicio.borrar(clave);
    } else {
      await _servicio.escribirTexto(clave, valor);
    }
  }
}
