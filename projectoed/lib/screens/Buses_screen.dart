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
          if (snapshot.hasData) {
            final notesList = snapshot.data!.docs;
            final pasajeros = notesList
                .map((document) => document.data() as Map<String, dynamic>)
                .where((data) => data['zona'] == zona)
                .toList();

            if (pasajeros.isEmpty) {
              return Center(child: Text("No hay pasajeros en la $zona"));
            }

            return ListView(
              children: pasajeros.map((pasajero) {
                return ListTile(
                  title: Text("${pasajero['nombre']} ${pasajero['apellido']}"),
                  subtitle: Text("Código: ${pasajero['codigo']}\nDirección: ${pasajero['direccion']}\nHora: ${pasajero['hora']}"),
                );
              }).toList(),
            );
          } else {
            return const Center(child: Text("No hay información disponible."));
          }
        },
      ),
    );
  }
}