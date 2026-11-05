import 'package:flutter/material.dart';

import '../../core/errores.dart';
import '../../repositories/auth_repository.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthRepository authRepository;

  const LoginScreen({super.key, required this.authRepository});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (_cargando || !_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    try {
      await widget.authRepository.iniciarSesion(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Al iniciar sesión, la raíz de la app cambia de pantalla sola.
    } on AuthException catch (error) {
      _mostrarMensaje(error.mensaje);
    } catch (_) {
      _mostrarMensaje('No se pudo iniciar sesión. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _abrirRegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistroScreen(authRepository: widget.authRepository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos y Entregas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 24),
              Icon(Icons.delivery_dining, size: 72, color: colors.primary),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                enabled: !_cargando,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'Escribe tu correo'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                enabled: !_cargando,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) => (valor == null || valor.isEmpty)
                    ? 'Escribe tu contraseña'
                    : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _iniciarSesion,
                  child: Text(_cargando ? 'Ingresando...' : 'Ingresar'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _cargando ? null : _abrirRegistro,
                child: const Text('Crear una cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
