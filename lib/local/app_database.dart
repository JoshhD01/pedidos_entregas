import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tablas.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Pedidos, LineasPedido, ProductosCache])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_abrirConexion());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // SQLite no aplica las llaves foráneas si no se activan al abrir.
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _abrirConexion() {
  return LazyDatabase(() async {
    final directorio = await getApplicationDocumentsDirectory();
    final archivo = File(p.join(directorio.path, 'pedidos_entregas.sqlite'));
    return NativeDatabase.createInBackground(archivo);
  });
}
