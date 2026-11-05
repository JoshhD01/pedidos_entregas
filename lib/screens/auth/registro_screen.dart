import 'package:flutter/material.dart';

import '../../core/errores.dart';
import '../../repositories/auth_repository.dart';

class RegistroScreen extends StatefulWidget {
  final AuthRepository authRepository;

  const RegistroScreen({super.key, required this.authRepository});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (_cargando || !_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);
    try {
      await widget.authRepository.registrar(
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Se cierra para que se vea la pantalla de inicio que la raíz ya cambió.
      if (mounted) Navigator.pop(context);
    } on AuthException catch (error) {
      _mostrarMensaje(error.mensaje);
    } catch (_) {
      _mostrarMensaje('No se pudo crear la cuenta. Inténtalo de nuevo.');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear una cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                enabled: !_cargando,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'Escribe tu nombre'
                    : null,
              ),
              const SizedBox(height: 16),
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
                    ? 'Escribe una contraseña'
                    : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _registrar,
                  child: Text(_cargando ? 'Creando cuenta...' : 'Crear cuenta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
