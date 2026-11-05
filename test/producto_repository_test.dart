import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedidos_entregas/core/errores.dart';
import 'package:pedidos_entregas/core/formato.dart';
import 'package:pedidos_entregas/local/app_database.dart';
import 'package:pedidos_entregas/local/producto_local_data_source.dart';
import 'package:pedidos_entregas/models/producto.dart';
import 'package:pedidos_entregas/remote/producto_remote_data_source.dart';
import 'package:pedidos_entregas/repositories/producto_repository.dart';
import 'package:pedidos_entregas/services/producto_service.dart';

const hamburguesa = Producto(
  id: 'p001',
  nombre: 'Hamburguesa',
  categoria: 'Comida',
  descripcion: 'Con queso',
  precioReferencia: 18000,
);
const brownie = Producto(
  id: 'p008',
  nombre: 'Brownie',
  categoria: 'Postres',
  descripcion: 'Chocolate',
  precioReferencia: 5500,
);

class FakeService implements ProductoService {
  List<Producto> productos = const [];
  ApiException? error;

  @override
  Future<List<Producto>> obtenerProductos() async {
    if (error != null) throw error!;
    return productos;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRemote implements ProductoRemoteDataSource {
  final documentos = <String, Map<String, dynamic>>{};

  @override
  Future<Map<String, dynamic>?> obtener(String id) async => documentos[id];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late FakeService service;
  late FakeRemote remote;
  late ProductoRepositoryImpl repositorio;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = FakeService();
    remote = FakeRemote();
    repositorio = ProductoRepositoryImpl(
      service: service,
      local: ProductoLocalDataSource(db),
      remote: remote,
    );
  });

  tearDown(() => db.close());

  test('con conexión devuelve el catálogo sin aviso y guarda copia', () async {
    service.productos = const [hamburguesa, brownie];

    final resultado = await repositorio.obtenerCatalogo();

    expect(resultado.productos, hasLength(2));
    expect(resultado.avisoCopiaLocal, isNull);
    final copia = await ProductoLocalDataSource(db).obtenerTodos();
    expect(copia.map((p) => p.id), containsAll(['p001', 'p008']));
  });

  test('si falla HTTP devuelve la copia guardada con aviso', () async {
    service.productos = const [hamburguesa];
    await repositorio.obtenerCatalogo();

    service.error = const ApiException('Sin conexión a internet.');
    final resultado = await repositorio.obtenerCatalogo();

    expect(resultado.productos.single.nombre, 'Hamburguesa');
    expect(resultado.avisoCopiaLocal, 'Sin conexión a internet.');
  });

  test('si falla HTTP y no hay copia, lanza el error', () {
    service.error = const ApiException('Sin conexión a internet.');

    expect(repositorio.obtenerCatalogo(), throwsA(isA<ApiException>()));
  });

  test('un producto retirado no queda en la copia', () async {
    service.productos = const [hamburguesa, brownie];
    await repositorio.obtenerCatalogo();

    service.productos = const [brownie];
    await repositorio.obtenerCatalogo();

    final copia = await ProductoLocalDataSource(db).obtenerTodos();
    expect(copia.map((p) => p.id), ['p008']);
  });

  test('un catálogo vacío deja la copia vacía y no da aviso', () async {
    service.productos = const [hamburguesa];
    await repositorio.obtenerCatalogo();

    service.productos = const [];
    final resultado = await repositorio.obtenerCatalogo();

    expect(resultado.productos, isEmpty);
    expect(resultado.avisoCopiaLocal, isNull);
  });

  test('obtenerOperativo lee precio y stock vigentes', () async {
    remote.documentos['p001'] = {
      'nombre': 'Hamburguesa',
      'precio': 19000,
      'stock': 3,
    };

    final operativo = await repositorio.obtenerOperativo('p001');

    expect(operativo!.precio, 19000);
    expect(operativo.stock, 3);
  });

  test('obtenerOperativo devuelve null si no existe', () async {
    expect(await repositorio.obtenerOperativo('p999'), isNull);
  });

  group('formatearPrecio', () {
    test('separa los miles con punto', () {
      expect(formatearPrecio(18000), r'$ 18.000 COP');
      expect(formatearPrecio(5500), r'$ 5.500 COP');
      expect(formatearPrecio(1234567), r'$ 1.234.567 COP');
    });

    test('no agrega punto a números pequeños', () {
      expect(formatearPrecio(900), r'$ 900 COP');
      expect(formatearPrecio(0), r'$ 0 COP');
    });
  });
}
