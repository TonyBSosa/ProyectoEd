import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projectoed/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void register() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      User? user = await _authService.registerUser(email, password);
      if (user != null) {
        // Mostrar mensaje de registro completado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registro completado")),
        );

        // Regresar a la pantalla de login
        GoRouter.of(context).go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error en el registro")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Correo electrónico"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: register,
              child: const Text("Registrarse"),
            ),
            TextButton(
              onPressed: () {
                // Navegar a la pantalla de login
                GoRouter.of(context).go('/login');
              },
              child: const Text("¿Ya tienes cuenta? Inicia sesión aquí"),
            ),
          ],
        ),
      ),
    );
  }
}