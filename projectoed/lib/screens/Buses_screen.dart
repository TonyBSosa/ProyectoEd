import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectoed/services/firestore.dart';

class BusesScreen extends StatefulWidget {
  final FirestoreService firestoreService;

  const BusesScreen({super.key, required this.firestoreService});

  @override
  _BusesScreenState createState() => _BusesScreenState();
}

class _BusesScreenState extends State<BusesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> zonas = ["Zona Sur", "Zona Este", "Zona Norte", "Zona Oeste"];

  // Mapa para asignar imágenes a cada hora
  final Map<String, String> imagenesPorHora = {
    '5:00': 'assets/images/bus1.jpg',
    '8:00': 'assets/images/bus2.jpg',
    '8:01': 'assets/images/bus3.jpg',
    '5:01': 'assets/images/bus4.jpg',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: zonas.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buses por Zona"),
        bottom: TabBar(
          controller: _tabController,
          tabs: zonas.map((zona) => Tab(text: zona)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: zonas.map((zona) {
          return _buildZonaScaffold(zona);
        }).toList(),
      ),
    );
  }

  Widget _buildZonaScaffold(String zona) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Indicador de carga
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No hay información disponible en la $zona"));
          }

          final notesList = snapshot.data!.docs;
          final pasajeros = notesList
              .map((document) => document.data() as Map<String, dynamic>)
              .where((data) => data['zona'] == zona)
              .toList();

          if (pasajeros.isEmpty) {
            return Center(child: Text("No hay pasajeros en la $zona"));
          }

          // Agrupar pasajeros por hora
          final Map<String, List<Map<String, dynamic>>> pasajerosPorHora = {};
          for (var pasajero in pasajeros) {
            final hora = pasajero['hora'];
            if (!pasajerosPorHora.containsKey(hora)) {
              pasajerosPorHora[hora] = [];
            }
            pasajerosPorHora[hora]!.add(pasajero);
          }

          // Crear una lista de tarjetas para cada hora
          return ListView(
            children: pasajerosPorHora.entries.map((entry) {
              final hora = entry.key;
              final pasajerosEnHora = entry.value;
              final imagenBus = imagenesPorHora[hora] ?? 'assets/images/default_bus.jpg'; // Imagen por defecto

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Text("Hora: $hora"),
                  children: [
                    Center(
                      child: Image.asset(
                        imagenBus,
                        width: 100, // Ancho más pequeño
                        height: 60, // Alto más pequeño
                        fit: BoxFit.cover, // Ajustar la imagen
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error); // Mostrar un ícono de error si la imagen no se carga
                        },
                      ),
                    ),
                    ...pasajerosEnHora.map((pasajero) {
                      return ListTile(
                        title: Text("${pasajero['nombre']} ${pasajero['apellido']}"),
                        subtitle: Text("Código: ${pasajero['codigo']}\nDirección: ${pasajero['direccion']}"),
                      );
                    }).toList(),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}