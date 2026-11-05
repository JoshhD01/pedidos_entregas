// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PedidosTable extends Pedidos with TableInfo<$PedidosTable, PedidoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PedidosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUidMeta = const VerificationMeta(
    'ownerUid',
  );
  @override
  late final GeneratedColumn<String> ownerUid = GeneratedColumn<String>(
    'owner_uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _direccionMeta = const VerificationMeta(
    'direccion',
  );
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
    'direccion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repartidorUidMeta = const VerificationMeta(
    'repartidorUid',
  );
  @override
  late final GeneratedColumn<String> repartidorUid = GeneratedColumn<String>(
    'repartidor_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codigoRecepcionMeta = const VerificationMeta(
    'codigoRecepcion',
  );
  @override
  late final GeneratedColumn<String> codigoRecepcion = GeneratedColumn<String>(
    'codigo_recepcion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoSyncMeta = const VerificationMeta(
    'estadoSync',
  );
  @override
  late final GeneratedColumn<String> estadoSync = GeneratedColumn<String>(
    'estado_sync',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDIENTE'),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerUid,
    direccion,
    estado,
    repartidorUid,
    codigoRecepcion,
    createdAt,
    updatedAt,
    estadoSync,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pedidos';
  @override
  VerificationContext validateIntegrity(
    Insertable<PedidoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_uid')) {
      context.handle(
        _ownerUidMeta,
        ownerUid.isAcceptableOrUnknown(data['owner_uid']!, _ownerUidMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerUidMeta);
    }
    if (data.containsKey('direccion')) {
      context.handle(
        _direccionMeta,
        direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta),
      );
    } else if (isInserting) {
      context.missing(_direccionMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('repartidor_uid')) {
      context.handle(
        _repartidorUidMeta,
        repartidorUid.isAcceptableOrUnknown(
          data['repartidor_uid']!,
          _repartidorUidMeta,
        ),
      );
    }
    if (data.containsKey('codigo_recepcion')) {
      context.handle(
        _codigoRecepcionMeta,
        codigoRecepcion.isAcceptableOrUnknown(
          data['codigo_recepcion']!,
          _codigoRecepcionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('estado_sync')) {
      context.handle(
        _estadoSyncMeta,
        estadoSync.isAcceptableOrUnknown(data['estado_sync']!, _estadoSyncMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PedidoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PedidoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_uid'],
      )!,
      direccion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direccion'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      repartidorUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repartidor_uid'],
      ),
      codigoRecepcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_recepcion'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      estadoSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_sync'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $PedidosTable createAlias(String alias) {
    return $PedidosTable(attachedDatabase, alias);
  }
}

class PedidoRow extends DataClass implements Insertable<PedidoRow> {
  /// UUID generado en el cliente: es el mismo id del documento en Firestore.
  final String id;

  /// Toda consulta local se filtra por este uid para no mezclar cuentas.
  final String ownerUid;
  final String direccion;

  /// `EstadoPedido.valor`.
  final String estado;
  final String? repartidorUid;

  /// Se genera una vez al crear el pedido. Reintentar no lo cambia.
  final String? codigoRecepcion;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// `EstadoSync.valor`.
  final String estadoSync;
  final String? lastError;
  const PedidoRow({
    required this.id,
    required this.ownerUid,
    required this.direccion,
    required this.estado,
    this.repartidorUid,
    this.codigoRecepcion,
    required this.createdAt,
    required this.updatedAt,
    required this.estadoSync,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_uid'] = Variable<String>(ownerUid);
    map['direccion'] = Variable<String>(direccion);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || repartidorUid != null) {
      map['repartidor_uid'] = Variable<String>(repartidorUid);
    }
    if (!nullToAbsent || codigoRecepcion != null) {
      map['codigo_recepcion'] = Variable<String>(codigoRecepcion);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['estado_sync'] = Variable<String>(estadoSync);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  PedidosCompanion toCompanion(bool nullToAbsent) {
    return PedidosCompanion(
      id: Value(id),
      ownerUid: Value(ownerUid),
      direccion: Value(direccion),
      estado: Value(estado),
      repartidorUid: repartidorUid == null && nullToAbsent
          ? const Value.absent()
          : Value(repartidorUid),
      codigoRecepcion: codigoRecepcion == null && nullToAbsent
          ? const Value.absent()
          : Value(codigoRecepcion),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      estadoSync: Value(estadoSync),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory PedidoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PedidoRow(
      id: serializer.fromJson<String>(json['id']),
      ownerUid: serializer.fromJson<String>(json['ownerUid']),
      direccion: serializer.fromJson<String>(json['direccion']),
      estado: serializer.fromJson<String>(json['estado']),
      repartidorUid: serializer.fromJson<String?>(json['repartidorUid']),
      codigoRecepcion: serializer.fromJson<String?>(json['codigoRecepcion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      estadoSync: serializer.fromJson<String>(json['estadoSync']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerUid': serializer.toJson<String>(ownerUid),
      'direccion': serializer.toJson<String>(direccion),
      'estado': serializer.toJson<String>(estado),
      'repartidorUid': serializer.toJson<String?>(repartidorUid),
      'codigoRecepcion': serializer.toJson<String?>(codigoRecepcion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'estadoSync': serializer.toJson<String>(estadoSync),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  PedidoRow copyWith({
    String? id,
    String? ownerUid,
    String? direccion,
    String? estado,
    Value<String?> repartidorUid = const Value.absent(),
    Value<String?> codigoRecepcion = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    String? estadoSync,
    Value<String?> lastError = const Value.absent(),
  }) => PedidoRow(
    id: id ?? this.id,
    ownerUid: ownerUid ?? this.ownerUid,
    direccion: direccion ?? this.direccion,
    estado: estado ?? this.estado,
    repartidorUid: repartidorUid.present
        ? repartidorUid.value
        : this.repartidorUid,
    codigoRecepcion: codigoRecepcion.present
        ? codigoRecepcion.value
        : this.codigoRecepcion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    estadoSync: estadoSync ?? this.estadoSync,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  PedidoRow copyWithCompanion(PedidosCompanion data) {
    return PedidoRow(
      id: data.id.present ? data.id.value : this.id,
      ownerUid: data.ownerUid.present ? data.ownerUid.value : this.ownerUid,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      estado: data.estado.present ? data.estado.value : this.estado,
      repartidorUid: data.repartidorUid.present
          ? data.repartidorUid.value
          : this.repartidorUid,
      codigoRecepcion: data.codigoRecepcion.present
          ? data.codigoRecepcion.value
          : this.codigoRecepcion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      estadoSync: data.estadoSync.present
          ? data.estadoSync.value
          : this.estadoSync,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PedidoRow(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('direccion: $direccion, ')
          ..write('estado: $estado, ')
          ..write('repartidorUid: $repartidorUid, ')
          ..write('codigoRecepcion: $codigoRecepcion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerUid,
    direccion,
    estado,
    repartidorUid,
    codigoRecepcion,
    createdAt,
    updatedAt,
    estadoSync,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PedidoRow &&
          other.id == this.id &&
          other.ownerUid == this.ownerUid &&
          other.direccion == this.direccion &&
          other.estado == this.estado &&
          other.repartidorUid == this.repartidorUid &&
          other.codigoRecepcion == this.codigoRecepcion &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.estadoSync == this.estadoSync &&
          other.lastError == this.lastError);
}

class PedidosCompanion extends UpdateCompanion<PedidoRow> {
  final Value<String> id;
  final Value<String> ownerUid;
  final Value<String> direccion;
  final Value<String> estado;
  final Value<String?> repartidorUid;
  final Value<String?> codigoRecepcion;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> estadoSync;
  final Value<String?> lastError;
  final Value<int> rowid;
  const PedidosCompanion({
    this.id = const Value.absent(),
    this.ownerUid = const Value.absent(),
    this.direccion = const Value.absent(),
    this.estado = const Value.absent(),
    this.repartidorUid = const Value.absent(),
    this.codigoRecepcion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PedidosCompanion.insert({
    required String id,
    required String ownerUid,
    required String direccion,
    required String estado,
    this.repartidorUid = const Value.absent(),
    this.codigoRecepcion = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.estadoSync = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerUid = Value(ownerUid),
       direccion = Value(direccion),
       estado = Value(estado),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PedidoRow> custom({
    Expression<String>? id,
    Expression<String>? ownerUid,
    Expression<String>? direccion,
    Expression<String>? estado,
    Expression<String>? repartidorUid,
    Expression<String>? codigoRecepcion,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? estadoSync,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerUid != null) 'owner_uid': ownerUid,
      if (direccion != null) 'direccion': direccion,
      if (estado != null) 'estado': estado,
      if (repartidorUid != null) 'repartidor_uid': repartidorUid,
      if (codigoRecepcion != null) 'codigo_recepcion': codigoRecepcion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (estadoSync != null) 'estado_sync': estadoSync,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PedidosCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerUid,
    Value<String>? direccion,
    Value<String>? estado,
    Value<String?>? repartidorUid,
    Value<String?>? codigoRecepcion,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? estadoSync,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return PedidosCompanion(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      direccion: direccion ?? this.direccion,
      estado: estado ?? this.estado,
      repartidorUid: repartidorUid ?? this.repartidorUid,
      codigoRecepcion: codigoRecepcion ?? this.codigoRecepcion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estadoSync: estadoSync ?? this.estadoSync,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerUid.present) {
      map['owner_uid'] = Variable<String>(ownerUid.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (repartidorUid.present) {
      map['repartidor_uid'] = Variable<String>(repartidorUid.value);
    }
    if (codigoRecepcion.present) {
      map['codigo_recepcion'] = Variable<String>(codigoRecepcion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (estadoSync.present) {
      map['estado_sync'] = Variable<String>(estadoSync.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PedidosCompanion(')
          ..write('id: $id, ')
          ..write('ownerUid: $ownerUid, ')
          ..write('direccion: $direccion, ')
          ..write('estado: $estado, ')
          ..write('repartidorUid: $repartidorUid, ')
          ..write('codigoRecepcion: $codigoRecepcion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LineasPedidoTable extends LineasPedido
    with TableInfo<$LineasPedidoTable, LineaPedidoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LineasPedidoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pedidoIdMeta = const VerificationMeta(
    'pedidoId',
  );
  @override
  late final GeneratedColumn<String> pedidoId = GeneratedColumn<String>(
    'pedido_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pedidos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreProductoMeta = const VerificationMeta(
    'nombreProducto',
  );
  @override
  late final GeneratedColumn<String> nombreProducto = GeneratedColumn<String>(
    'nombre_producto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioUnitarioMeta = const VerificationMeta(
    'precioUnitario',
  );
  @override
  late final GeneratedColumn<int> precioUnitario = GeneratedColumn<int>(
    'precio_unitario',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pedidoId,
    productoId,
    nombreProducto,
    cantidad,
    precioUnitario,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lineas_pedido';
  @override
  VerificationContext validateIntegrity(
    Insertable<LineaPedidoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pedido_id')) {
      context.handle(
        _pedidoIdMeta,
        pedidoId.isAcceptableOrUnknown(data['pedido_id']!, _pedidoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pedidoIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('nombre_producto')) {
      context.handle(
        _nombreProductoMeta,
        nombreProducto.isAcceptableOrUnknown(
          data['nombre_producto']!,
          _nombreProductoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreProductoMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
        _precioUnitarioMeta,
        precioUnitario.isAcceptableOrUnknown(
          data['precio_unitario']!,
          _precioUnitarioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioUnitarioMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {pedidoId, productoId},
  ];
  @override
  LineaPedidoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineaPedidoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pedidoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pedido_id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto_id'],
      )!,
      nombreProducto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_producto'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad'],
      )!,
      precioUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio_unitario'],
      )!,
    );
  }

  @override
  $LineasPedidoTable createAlias(String alias) {
    return $LineasPedidoTable(attachedDatabase, alias);
  }
}

class LineaPedidoRow extends DataClass implements Insertable<LineaPedidoRow> {
  final int id;

  /// Borrar el pedido borra sus líneas.
  final String pedidoId;
  final String productoId;
  final String nombreProducto;
  final int cantidad;
  final int precioUnitario;
  const LineaPedidoRow({
    required this.id,
    required this.pedidoId,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pedido_id'] = Variable<String>(pedidoId);
    map['producto_id'] = Variable<String>(productoId);
    map['nombre_producto'] = Variable<String>(nombreProducto);
    map['cantidad'] = Variable<int>(cantidad);
    map['precio_unitario'] = Variable<int>(precioUnitario);
    return map;
  }

  LineasPedidoCompanion toCompanion(bool nullToAbsent) {
    return LineasPedidoCompanion(
      id: Value(id),
      pedidoId: Value(pedidoId),
      productoId: Value(productoId),
      nombreProducto: Value(nombreProducto),
      cantidad: Value(cantidad),
      precioUnitario: Value(precioUnitario),
    );
  }

  factory LineaPedidoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineaPedidoRow(
      id: serializer.fromJson<int>(json['id']),
      pedidoId: serializer.fromJson<String>(json['pedidoId']),
      productoId: serializer.fromJson<String>(json['productoId']),
      nombreProducto: serializer.fromJson<String>(json['nombreProducto']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      precioUnitario: serializer.fromJson<int>(json['precioUnitario']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pedidoId': serializer.toJson<String>(pedidoId),
      'productoId': serializer.toJson<String>(productoId),
      'nombreProducto': serializer.toJson<String>(nombreProducto),
      'cantidad': serializer.toJson<int>(cantidad),
      'precioUnitario': serializer.toJson<int>(precioUnitario),
    };
  }

  LineaPedidoRow copyWith({
    int? id,
    String? pedidoId,
    String? productoId,
    String? nombreProducto,
    int? cantidad,
    int? precioUnitario,
  }) => LineaPedidoRow(
    id: id ?? this.id,
    pedidoId: pedidoId ?? this.pedidoId,
    productoId: productoId ?? this.productoId,
    nombreProducto: nombreProducto ?? this.nombreProducto,
    cantidad: cantidad ?? this.cantidad,
    precioUnitario: precioUnitario ?? this.precioUnitario,
  );
  LineaPedidoRow copyWithCompanion(LineasPedidoCompanion data) {
    return LineaPedidoRow(
      id: data.id.present ? data.id.value : this.id,
      pedidoId: data.pedidoId.present ? data.pedidoId.value : this.pedidoId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      nombreProducto: data.nombreProducto.present
          ? data.nombreProducto.value
          : this.nombreProducto,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineaPedidoRow(')
          ..write('id: $id, ')
          ..write('pedidoId: $pedidoId, ')
          ..write('productoId: $productoId, ')
          ..write('nombreProducto: $nombreProducto, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pedidoId,
    productoId,
    nombreProducto,
    cantidad,
    precioUnitario,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineaPedidoRow &&
          other.id == this.id &&
          other.pedidoId == this.pedidoId &&
          other.productoId == this.productoId &&
          other.nombreProducto == this.nombreProducto &&
          other.cantidad == this.cantidad &&
          other.precioUnitario == this.precioUnitario);
}

class LineasPedidoCompanion extends UpdateCompanion<LineaPedidoRow> {
  final Value<int> id;
  final Value<String> pedidoId;
  final Value<String> productoId;
  final Value<String> nombreProducto;
  final Value<int> cantidad;
  final Value<int> precioUnitario;
  const LineasPedidoCompanion({
    this.id = const Value.absent(),
    this.pedidoId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.nombreProducto = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnitario = const Value.absent(),
  });
  LineasPedidoCompanion.insert({
    this.id = const Value.absent(),
    required String pedidoId,
    required String productoId,
    required String nombreProducto,
    required int cantidad,
    required int precioUnitario,
  }) : pedidoId = Value(pedidoId),
       productoId = Value(productoId),
       nombreProducto = Value(nombreProducto),
       cantidad = Value(cantidad),
       precioUnitario = Value(precioUnitario);
  static Insertable<LineaPedidoRow> custom({
    Expression<int>? id,
    Expression<String>? pedidoId,
    Expression<String>? productoId,
    Expression<String>? nombreProducto,
    Expression<int>? cantidad,
    Expression<int>? precioUnitario,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pedidoId != null) 'pedido_id': pedidoId,
      if (productoId != null) 'producto_id': productoId,
      if (nombreProducto != null) 'nombre_producto': nombreProducto,
      if (cantidad != null) 'cantidad': cantidad,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
    });
  }

  LineasPedidoCompanion copyWith({
    Value<int>? id,
    Value<String>? pedidoId,
    Value<String>? productoId,
    Value<String>? nombreProducto,
    Value<int>? cantidad,
    Value<int>? precioUnitario,
  }) {
    return LineasPedidoCompanion(
      id: id ?? this.id,
      pedidoId: pedidoId ?? this.pedidoId,
      productoId: productoId ?? this.productoId,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pedidoId.present) {
      map['pedido_id'] = Variable<String>(pedidoId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (nombreProducto.present) {
      map['nombre_producto'] = Variable<String>(nombreProducto.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<int>(precioUnitario.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LineasPedidoCompanion(')
          ..write('id: $id, ')
          ..write('pedidoId: $pedidoId, ')
          ..write('productoId: $productoId, ')
          ..write('nombreProducto: $nombreProducto, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario')
          ..write(')'))
        .toString();
  }
}

class $ProductosCacheTable extends ProductosCache
    with TableInfo<$ProductosCacheTable, ProductoCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioReferenciaMeta = const VerificationMeta(
    'precioReferencia',
  );
  @override
  late final GeneratedColumn<int> precioReferencia = GeneratedColumn<int>(
    'precio_referencia',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    categoria,
    descripcion,
    precioReferencia,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductoCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descripcionMeta);
    }
    if (data.containsKey('precio_referencia')) {
      context.handle(
        _precioReferenciaMeta,
        precioReferencia.isAcceptableOrUnknown(
          data['precio_referencia']!,
          _precioReferenciaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioReferenciaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductoCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductoCacheRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      )!,
      precioReferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio_referencia'],
      )!,
    );
  }

  @override
  $ProductosCacheTable createAlias(String alias) {
    return $ProductosCacheTable(attachedDatabase, alias);
  }
}

class ProductoCacheRow extends DataClass
    implements Insertable<ProductoCacheRow> {
  final String id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final int precioReferencia;
  const ProductoCacheRow({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.precioReferencia,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nombre'] = Variable<String>(nombre);
    map['categoria'] = Variable<String>(categoria);
    map['descripcion'] = Variable<String>(descripcion);
    map['precio_referencia'] = Variable<int>(precioReferencia);
    return map;
  }

  ProductosCacheCompanion toCompanion(bool nullToAbsent) {
    return ProductosCacheCompanion(
      id: Value(id),
      nombre: Value(nombre),
      categoria: Value(categoria),
      descripcion: Value(descripcion),
      precioReferencia: Value(precioReferencia),
    );
  }

  factory ProductoCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductoCacheRow(
      id: serializer.fromJson<String>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      categoria: serializer.fromJson<String>(json['categoria']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      precioReferencia: serializer.fromJson<int>(json['precioReferencia']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombre': serializer.toJson<String>(nombre),
      'categoria': serializer.toJson<String>(categoria),
      'descripcion': serializer.toJson<String>(descripcion),
      'precioReferencia': serializer.toJson<int>(precioReferencia),
    };
  }

  ProductoCacheRow copyWith({
    String? id,
    String? nombre,
    String? categoria,
    String? descripcion,
    int? precioReferencia,
  }) => ProductoCacheRow(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    categoria: categoria ?? this.categoria,
    descripcion: descripcion ?? this.descripcion,
    precioReferencia: precioReferencia ?? this.precioReferencia,
  );
  ProductoCacheRow copyWithCompanion(ProductosCacheCompanion data) {
    return ProductoCacheRow(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      precioReferencia: data.precioReferencia.present
          ? data.precioReferencia.value
          : this.precioReferencia,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductoCacheRow(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('categoria: $categoria, ')
          ..write('descripcion: $descripcion, ')
          ..write('precioReferencia: $precioReferencia')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nombre, categoria, descripcion, precioReferencia);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductoCacheRow &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.categoria == this.categoria &&
          other.descripcion == this.descripcion &&
          other.precioReferencia == this.precioReferencia);
}

class ProductosCacheCompanion extends UpdateCompanion<ProductoCacheRow> {
  final Value<String> id;
  final Value<String> nombre;
  final Value<String> categoria;
  final Value<String> descripcion;
  final Value<int> precioReferencia;
  final Value<int> rowid;
  const ProductosCacheCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.categoria = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.precioReferencia = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductosCacheCompanion.insert({
    required String id,
    required String nombre,
    required String categoria,
    required String descripcion,
    required int precioReferencia,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nombre = Value(nombre),
       categoria = Value(categoria),
       descripcion = Value(descripcion),
       precioReferencia = Value(precioReferencia);
  static Insertable<ProductoCacheRow> custom({
    Expression<String>? id,
    Expression<String>? nombre,
    Expression<String>? categoria,
    Expression<String>? descripcion,
    Expression<int>? precioReferencia,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (categoria != null) 'categoria': categoria,
      if (descripcion != null) 'descripcion': descripcion,
      if (precioReferencia != null) 'precio_referencia': precioReferencia,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductosCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? nombre,
    Value<String>? categoria,
    Value<String>? descripcion,
    Value<int>? precioReferencia,
    Value<int>? rowid,
  }) {
    return ProductosCacheCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      descripcion: descripcion ?? this.descripcion,
      precioReferencia: precioReferencia ?? this.precioReferencia,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (precioReferencia.present) {
      map['precio_referencia'] = Variable<int>(precioReferencia.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosCacheCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('categoria: $categoria, ')
          ..write('descripcion: $descripcion, ')
          ..write('precioReferencia: $precioReferencia, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PedidosTable pedidos = $PedidosTable(this);
  late final $LineasPedidoTable lineasPedido = $LineasPedidoTable(this);
  late final $ProductosCacheTable productosCache = $ProductosCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pedidos,
    lineasPedido,
    productosCache,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pedidos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lineas_pedido', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PedidosTableCreateCompanionBuilder =
    PedidosCompanion Function({
      required String id,
      required String ownerUid,
      required String direccion,
      required String estado,
      Value<String?> repartidorUid,
      Value<String?> codigoRecepcion,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String> estadoSync,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$PedidosTableUpdateCompanionBuilder =
    PedidosCompanion Function({
      Value<String> id,
      Value<String> ownerUid,
      Value<String> direccion,
      Value<String> estado,
      Value<String?> repartidorUid,
      Value<String?> codigoRecepcion,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> estadoSync,
      Value<String?> lastError,
      Value<int> rowid,
    });

final class $$PedidosTableReferences
    extends BaseReferences<_$AppDatabase, $PedidosTable, PedidoRow> {
  $$PedidosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LineasPedidoTable, List<LineaPedidoRow>>
  _lineasPedidoRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lineasPedido,
    aliasName: 'pedidos__id__lineas_pedido__pedido_id',
  );

  $$LineasPedidoTableProcessedTableManager get lineasPedidoRefs {
    final manager = $$LineasPedidoTableTableManager(
      $_db,
      $_db.lineasPedido,
    ).filter((f) => f.pedidoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lineasPedidoRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PedidosTableFilterComposer
    extends Composer<_$AppDatabase, $PedidosTable> {
  $$PedidosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repartidorUid => $composableBuilder(
    column: $table.repartidorUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigoRecepcion => $composableBuilder(
    column: $table.codigoRecepcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> lineasPedidoRefs(
    Expression<bool> Function($$LineasPedidoTableFilterComposer f) f,
  ) {
    final $$LineasPedidoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineasPedido,
      getReferencedColumn: (t) => t.pedidoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineasPedidoTableFilterComposer(
            $db: $db,
            $table: $db.lineasPedido,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PedidosTableOrderingComposer
    extends Composer<_$AppDatabase, $PedidosTable> {
  $$PedidosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUid => $composableBuilder(
    column: $table.ownerUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repartidorUid => $composableBuilder(
    column: $table.repartidorUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigoRecepcion => $composableBuilder(
    column: $table.codigoRecepcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PedidosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PedidosTable> {
  $$PedidosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerUid =>
      $composableBuilder(column: $table.ownerUid, builder: (column) => column);

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get repartidorUid => $composableBuilder(
    column: $table.repartidorUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get codigoRecepcion => $composableBuilder(
    column: $table.codigoRecepcion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  Expression<T> lineasPedidoRefs<T extends Object>(
    Expression<T> Function($$LineasPedidoTableAnnotationComposer a) f,
  ) {
    final $$LineasPedidoTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lineasPedido,
      getReferencedColumn: (t) => t.pedidoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LineasPedidoTableAnnotationComposer(
            $db: $db,
            $table: $db.lineasPedido,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PedidosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PedidosTable,
          PedidoRow,
          $$PedidosTableFilterComposer,
          $$PedidosTableOrderingComposer,
          $$PedidosTableAnnotationComposer,
          $$PedidosTableCreateCompanionBuilder,
          $$PedidosTableUpdateCompanionBuilder,
          (PedidoRow, $$PedidosTableReferences),
          PedidoRow,
          PrefetchHooks Function({bool lineasPedidoRefs})
        > {
  $$PedidosTableTableManager(_$AppDatabase db, $PedidosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PedidosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PedidosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PedidosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerUid = const Value.absent(),
                Value<String> direccion = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String?> repartidorUid = const Value.absent(),
                Value<String?> codigoRecepcion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PedidosCompanion(
                id: id,
                ownerUid: ownerUid,
                direccion: direccion,
                estado: estado,
                repartidorUid: repartidorUid,
                codigoRecepcion: codigoRecepcion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                estadoSync: estadoSync,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerUid,
                required String direccion,
                required String estado,
                Value<String?> repartidorUid = const Value.absent(),
                Value<String?> codigoRecepcion = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String> estadoSync = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PedidosCompanion.insert(
                id: id,
                ownerUid: ownerUid,
                direccion: direccion,
                estado: estado,
                repartidorUid: repartidorUid,
                codigoRecepcion: codigoRecepcion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                estadoSync: estadoSync,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PedidosTable, PedidoRow>(table),
                  $$PedidosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({lineasPedidoRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (lineasPedidoRefs) db.lineasPedido],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (lineasPedidoRefs)
                    await $_getPrefetchedDataByColumns<
                      PedidoRow,
                      $PedidosTable,
                      LineaPedidoRow,
                      $LineasPedidoTable
                    >(
                      currentTable: table,
                      referencedTable: $$PedidosTableReferences
                          ._lineasPedidoRefsTable(db),
                      managerFromTypedResult: (p0) => $$PedidosTableReferences(
                        db,
                        table,
                        p0,
                      ).lineasPedidoRefs,
                      currentColumn: 'id',
                      referencedColumn: 'pedido_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PedidosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PedidosTable,
      PedidoRow,
      $$PedidosTableFilterComposer,
      $$PedidosTableOrderingComposer,
      $$PedidosTableAnnotationComposer,
      $$PedidosTableCreateCompanionBuilder,
      $$PedidosTableUpdateCompanionBuilder,
      (PedidoRow, $$PedidosTableReferences),
      PedidoRow,
      PrefetchHooks Function({bool lineasPedidoRefs})
    >;
typedef $$LineasPedidoTableCreateCompanionBuilder =
    LineasPedidoCompanion Function({
      Value<int> id,
      required String pedidoId,
      required String productoId,
      required String nombreProducto,
      required int cantidad,
      required int precioUnitario,
    });
typedef $$LineasPedidoTableUpdateCompanionBuilder =
    LineasPedidoCompanion Function({
      Value<int> id,
      Value<String> pedidoId,
      Value<String> productoId,
      Value<String> nombreProducto,
      Value<int> cantidad,
      Value<int> precioUnitario,
    });

final class $$LineasPedidoTableReferences
    extends BaseReferences<_$AppDatabase, $LineasPedidoTable, LineaPedidoRow> {
  $$LineasPedidoTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PedidosTable _pedidoIdTable(_$AppDatabase db) =>
      db.pedidos.createAlias('lineas_pedido__pedido_id__pedidos__id');

  $$PedidosTableProcessedTableManager get pedidoId {
    final $_column = $_itemColumn<String>('pedido_id')!;

    final manager = $$PedidosTableTableManager(
      $_db,
      $_db.pedidos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pedidoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LineasPedidoTableFilterComposer
    extends Composer<_$AppDatabase, $LineasPedidoTable> {
  $$LineasPedidoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnFilters(column),
  );

  $$PedidosTableFilterComposer get pedidoId {
    final $$PedidosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedidoId,
      referencedTable: $db.pedidos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedidosTableFilterComposer(
            $db: $db,
            $table: $db.pedidos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineasPedidoTableOrderingComposer
    extends Composer<_$AppDatabase, $LineasPedidoTable> {
  $$LineasPedidoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  $$PedidosTableOrderingComposer get pedidoId {
    final $$PedidosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedidoId,
      referencedTable: $db.pedidos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedidosTableOrderingComposer(
            $db: $db,
            $table: $db.pedidos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineasPedidoTableAnnotationComposer
    extends Composer<_$AppDatabase, $LineasPedidoTable> {
  $$LineasPedidoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<int> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => column,
  );

  $$PedidosTableAnnotationComposer get pedidoId {
    final $$PedidosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pedidoId,
      referencedTable: $db.pedidos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PedidosTableAnnotationComposer(
            $db: $db,
            $table: $db.pedidos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LineasPedidoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LineasPedidoTable,
          LineaPedidoRow,
          $$LineasPedidoTableFilterComposer,
          $$LineasPedidoTableOrderingComposer,
          $$LineasPedidoTableAnnotationComposer,
          $$LineasPedidoTableCreateCompanionBuilder,
          $$LineasPedidoTableUpdateCompanionBuilder,
          (LineaPedidoRow, $$LineasPedidoTableReferences),
          LineaPedidoRow,
          PrefetchHooks Function({bool pedidoId})
        > {
  $$LineasPedidoTableTableManager(_$AppDatabase db, $LineasPedidoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LineasPedidoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LineasPedidoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LineasPedidoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> pedidoId = const Value.absent(),
                Value<String> productoId = const Value.absent(),
                Value<String> nombreProducto = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<int> precioUnitario = const Value.absent(),
              }) => LineasPedidoCompanion(
                id: id,
                pedidoId: pedidoId,
                productoId: productoId,
                nombreProducto: nombreProducto,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String pedidoId,
                required String productoId,
                required String nombreProducto,
                required int cantidad,
                required int precioUnitario,
              }) => LineasPedidoCompanion.insert(
                id: id,
                pedidoId: pedidoId,
                productoId: productoId,
                nombreProducto: nombreProducto,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LineasPedidoTable, LineaPedidoRow>(table),
                  $$LineasPedidoTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pedidoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pedidoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pedidoId,
                                referencedTable: $$LineasPedidoTableReferences
                                    ._pedidoIdTable(db),
                                referencedColumn: $$LineasPedidoTableReferences
                                    ._pedidoIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LineasPedidoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LineasPedidoTable,
      LineaPedidoRow,
      $$LineasPedidoTableFilterComposer,
      $$LineasPedidoTableOrderingComposer,
      $$LineasPedidoTableAnnotationComposer,
      $$LineasPedidoTableCreateCompanionBuilder,
      $$LineasPedidoTableUpdateCompanionBuilder,
      (LineaPedidoRow, $$LineasPedidoTableReferences),
      LineaPedidoRow,
      PrefetchHooks Function({bool pedidoId})
    >;
typedef $$ProductosCacheTableCreateCompanionBuilder =
    ProductosCacheCompanion Function({
      required String id,
      required String nombre,
      required String categoria,
      required String descripcion,
      required int precioReferencia,
      Value<int> rowid,
    });
typedef $$ProductosCacheTableUpdateCompanionBuilder =
    ProductosCacheCompanion Function({
      Value<String> id,
      Value<String> nombre,
      Value<String> categoria,
      Value<String> descripcion,
      Value<int> precioReferencia,
      Value<int> rowid,
    });

class $$ProductosCacheTableFilterComposer
    extends Composer<_$AppDatabase, $ProductosCacheTable> {
  $$ProductosCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precioReferencia => $composableBuilder(
    column: $table.precioReferencia,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductosCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductosCacheTable> {
  $$ProductosCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precioReferencia => $composableBuilder(
    column: $table.precioReferencia,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductosCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductosCacheTable> {
  $$ProductosCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get precioReferencia => $composableBuilder(
    column: $table.precioReferencia,
    builder: (column) => column,
  );
}

class $$ProductosCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductosCacheTable,
          ProductoCacheRow,
          $$ProductosCacheTableFilterComposer,
          $$ProductosCacheTableOrderingComposer,
          $$ProductosCacheTableAnnotationComposer,
          $$ProductosCacheTableCreateCompanionBuilder,
          $$ProductosCacheTableUpdateCompanionBuilder,
          (
            ProductoCacheRow,
            BaseReferences<
              _$AppDatabase,
              $ProductosCacheTable,
              ProductoCacheRow
            >,
          ),
          ProductoCacheRow,
          PrefetchHooks Function()
        > {
  $$ProductosCacheTableTableManager(
    _$AppDatabase db,
    $ProductosCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductosCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<int> precioReferencia = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductosCacheCompanion(
                id: id,
                nombre: nombre,
                categoria: categoria,
                descripcion: descripcion,
                precioReferencia: precioReferencia,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nombre,
                required String categoria,
                required String descripcion,
                required int precioReferencia,
                Value<int> rowid = const Value.absent(),
              }) => ProductosCacheCompanion.insert(
                id: id,
                nombre: nombre,
                categoria: categoria,
                descripcion: descripcion,
                precioReferencia: precioReferencia,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductosCacheTable, ProductoCacheRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ProductosCacheTable,
                    ProductoCacheRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductosCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductosCacheTable,
      ProductoCacheRow,
      $$ProductosCacheTableFilterComposer,
      $$ProductosCacheTableOrderingComposer,
      $$ProductosCacheTableAnnotationComposer,
      $$ProductosCacheTableCreateCompanionBuilder,
      $$ProductosCacheTableUpdateCompanionBuilder,
      (
        ProductoCacheRow,
        BaseReferences<_$AppDatabase, $ProductosCacheTable, ProductoCacheRow>,
      ),
      ProductoCacheRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PedidosTableTableManager get pedidos =>
      $$PedidosTableTableManager(_db, _db.pedidos);
  $$LineasPedidoTableTableManager get lineasPedido =>
      $$LineasPedidoTableTableManager(_db, _db.lineasPedido);
  $$ProductosCacheTableTableManager get productosCache =>
      $$ProductosCacheTableTableManager(_db, _db.productosCache);
}
