import 'package:projectoed/firebase_options.dart';
 
 import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projectoed/presentation/router/main_router.dart';
import 'package:projectoed/presentation/styles/main_theme.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
} 

class MyApp extends       StatelessWidget {
  const MyApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return   MaterialApp.router (
      routerConfig: mainRouter,
      theme: mainTheme,

      debugShowCheckedModeBanner: false,
     );
  }
}
