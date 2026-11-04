enum Rol {
  cliente('cliente'),
  operador('operador'),
  repartidor('repartidor');

  const Rol(this.valor);

  final String valor;

  /// Un rol desconocido es un error: nunca se asume un rol por defecto.
  static Rol fromValor(String valor) {
    for (final rol in values) {
      if (rol.valor == valor) return rol;
    }
    throw FormatException('Rol desconocido: $valor');
  }
}

/// Documento `perfiles/{uid}`. El uid es el de Firebase Authentication.
class Perfil {
  final String uid;
  final String nombre;
  final String email;
  final Rol rol;

  const Perfil({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  factory Perfil.fromFirestore(String uid, Map<String, dynamic> data) {
    try {
      return Perfil(
        uid: uid,
        nombre: data['nombre'] as String,
        email: data['email'] as String,
        rol: Rol.fromValor(data['rol'] as String),
      );
    } on TypeError {
      throw const FormatException('Perfil con formato inválido');
    }
  }

  Map<String, dynamic> toFirestore() => {
    'nombre': nombre,
    'email': email,
    'rol': rol.valor,
  };
}
