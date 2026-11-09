import 'package:shared_preferences/shared_preferences.dart';

import '../models/filtro_pedidos.dart';

/// Preferencias del dispositivo. No guarda datos del negocio.
abstract class PreferenciasRepository {
  /// Null si nunca se eligió o el valor guardado no es válido.
  Future<FiltroPedidos?> leerFiltroMisPedidos();

  Future<void> guardarFiltroMisPedidos(FiltroPedidos filtro);
}

class PreferenciasRepositoryImpl implements PreferenciasRepository {
  static const claveFiltro = 'filtro_mis_pedidos';

  final SharedPreferencesAsync prefs;

  PreferenciasRepositoryImpl(this.prefs);

  @override
  Future<FiltroPedidos?> leerFiltroMisPedidos() async =>
      FiltroPedidos.fromValor(await prefs.getString(claveFiltro));

  @override
  Future<void> guardarFiltroMisPedidos(FiltroPedidos filtro) =>
      prefs.setString(claveFiltro, filtro.valor);
}
