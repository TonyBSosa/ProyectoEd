import 'package:go_router/go_router.dart';
import 'package:projectoed/screens/home_page.dart';

final mainRouter= GoRouter( 
  initialLocation : '/',
  routes: [
    GoRoute(path: '/',
    builder: (context, state) => const HomePage())

  ]
  
);