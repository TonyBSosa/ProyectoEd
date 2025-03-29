import 'package:flutter/material.dart';

final ThemeData mainTheme = ThemeData(
  primarySwatch: Colors.blue,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  scaffoldBackgroundColor: Colors.grey[100], // Fondo más suave para la pantalla
  appBarTheme: AppBarTheme(
    centerTitle: true,
    elevation: 2, // Elevación leve para darle un poco de sombra
    backgroundColor: Colors.blueAccent, // Un tono más vibrante para la barra de la app
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.w600, // Un título más destacado
      fontSize: 20,
      color: Colors.white,
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.black87, // Color de texto predeterminado más suave
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Colors.black54,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // Botones con bordes redondeados
    ),
    buttonColor: Colors.blueAccent, // Color de los botones
    textTheme: ButtonTextTheme.primary,
  ),
  iconTheme: IconThemeData(
    color: Colors.blueAccent, // Íconos con un color consistente
  ),
  cardTheme: CardTheme(
    elevation: 4, // Sombra en tarjetas
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // Bordes redondeados en las tarjetas
    ),
    color: Colors.white, // Fondo blanco para las tarjetas
  ),
);
