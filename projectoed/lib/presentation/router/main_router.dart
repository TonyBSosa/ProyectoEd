 import 'package:go_router/go_router.dart';
 import 'package:projectoed/screens/home_page.dart';
import 'package:projectoed/screens/login_screen.dart';
import 'package:projectoed/screens/register_screen.dart';

final GoRouter mainRouter = GoRouter(
  initialLocation: '/login', // Ruta inicial
  routes: [
    GoRoute(
      path: '/login', // Ruta de login
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/register', // Ruta de registro
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: '/home', // Ruta de la pantalla de inicio
      builder: (context, state) => HomePage(),
    ),
  ],
);
 
 
     