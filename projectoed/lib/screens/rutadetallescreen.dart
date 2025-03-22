import 'package:flutter/material.dart';

class RutaDetalleScreen extends StatelessWidget {
  final String ruta;
  final Map<String, String> imagenesPorRuta = {
    'Ruta 1': 'assets/images/bus1.jpg',
    'Ruta 2': 'assets/images/bus2.jpg',
    'Ruta 3': 'assets/images/bus3.jpg',
    'Ruta 4': 'assets/images/bus4.jpg',
  };

  RutaDetalleScreen({required this.ruta});

  @override
  Widget build(BuildContext context) {
    final String imagen = imagenesPorRuta[ruta] ?? 'assets/images/default_bus.jpg';

    return Scaffold(
      appBar: AppBar(title: Text("Detalles de $ruta")),
      body: Column(
        children: [
          Image.asset(imagen, width: double.infinity, height: 200, fit: BoxFit.cover),
          const SizedBox(height: 20),
          Text(
            "Información de la $ruta",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Aquí puedes mostrar más detalles sobre la ruta seleccionada, como horarios, paradas, etc.",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}