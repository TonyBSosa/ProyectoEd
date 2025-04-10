import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Importa GoRouter
import 'package:projectoed/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

  String? selectedZona;
  TimeOfDay? selectedHora;
  final List<String> zonas = ["Zona Sur", "Zona Este", "Zona Norte", "Zona Oeste"];

  // Mapa para asignar imágenes a cada zona
  final Map<String, String> imagenesPorZona = {
    "Zona Sur": "assets/images/bus1.jpg",
    "Zona Este": "assets/images/bus2.jpg",
    "Zona Norte": "assets/images/bus3.jpg",
    "Zona Oeste": "assets/images/bus4.jpg",
  };

  // Pila para manejar las acciones de agregar, eliminar y editar
  final List<Map<String, dynamic>> pilaAcciones = [];

  // Función para agregar una nueva nota
  void openNoteBox({String? docID, Map<String, dynamic>? existingData}) {
    if (existingData != null) {
      // Si estamos editando un registro, inicializamos los campos con los datos existentes
      nombreController.text = existingData['nombre'];
      apellidoController.text = existingData['apellido'];
      codigoController.text = existingData['codigo'];
      selectedZona = existingData['zona'];
      direccionController.text = existingData['direccion'];
      selectedHora = TimeOfDay(
        hour: int.parse(existingData['hora'].split(":")[0]),
        minute: int.parse(existingData['hora'].split(":")[1]),
      );
    } else {
      // Limpiar los campos si estamos agregando un nuevo registro
      nombreController.clear();
      apellidoController.clear();
      codigoController.clear();
      direccionController.clear();
      selectedZona = null;
      selectedHora = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Agregar/Editar Información"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreController, decoration: const InputDecoration(labelText: "Nombre")),
              TextField(controller: apellidoController, decoration: const InputDecoration(labelText: "Apellido")),
              TextField(controller: codigoController, decoration: const InputDecoration(labelText: "Código de Empleado"), keyboardType: TextInputType.number),
              DropdownButtonFormField<String>(
                value: selectedZona,
                items: zonas.map((zona) => DropdownMenuItem(value: zona, child: Text(zona))).toList(),
                onChanged: (value) => setState(() => selectedZona = value),
                decoration: const InputDecoration(labelText: "Seleccione la Zona"),
              ),
              TextField(controller: direccionController, decoration: const InputDecoration(labelText: "Dirección")),
              ListTile(
                title: Text(selectedHora == null ? "Seleccionar Hora (5 PM - 8 PM)" : "Hora: ${selectedHora!.format(context)}"),
                onTap: () async {
                  final TimeOfDay? pickedHora = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 17, minute: 0),
                  );
                  if (pickedHora != null && pickedHora.hour >= 17 && pickedHora.hour <= 20) {
                    setState(() => selectedHora = pickedHora);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Seleccione una hora entre 5 PM y 8 PM.")));
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (nombreController.text.isEmpty || apellidoController.text.isEmpty || codigoController.text.isEmpty || selectedZona == null || direccionController.text.isEmpty || selectedHora == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Por favor, complete todos los campos.")));
                return;
              }
              Map<String, dynamic> data = {
                "nombre": nombreController.text,
                "apellido": apellidoController.text,
                "codigo": codigoController.text,
                "zona": selectedZona,
                "direccion": direccionController.text,
                "hora": "${selectedHora!.hour}:${selectedHora!.minute}",
              };

              // Si estamos editando, guardamos el estado previo en la pila antes de editar
              if (docID != null) {
                pilaAcciones.add({
                  'accion': 'editar',
                  'docID': docID,
                  'previousData': existingData,
                });
                firestoreService.updateNote(docID, data);
              } else {
                firestoreService.addNote(data);
                pilaAcciones.add({
                  'accion': 'agregar',
                  'data': data,
                });
              }

              nombreController.clear();
              apellidoController.clear();
              codigoController.clear();
              direccionController.clear();
              setState(() {
                selectedZona = null;
                selectedHora = null;
              });
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // Función para deshacer la última acción
  void deshacerAccion() {
    if (pilaAcciones.isNotEmpty) {
      setState(() {
        Map<String, dynamic> ultimaAccion = pilaAcciones.removeLast();  // Obtener y eliminar la última acción

        if (ultimaAccion['accion'] == 'agregar') {
          // Deshacer agregar (eliminar el último pasajero agregado)
          firestoreService.deleteNote(ultimaAccion['data']['docID']);
        } else if (ultimaAccion['accion'] == 'eliminar') {
          // Deshacer eliminar (recuperar los datos eliminados, necesitamos almacenarlos antes)
          firestoreService.addNote(ultimaAccion['data']);
        } else if (ultimaAccion['accion'] == 'editar') {
          // Deshacer edición (restaurar los datos previos antes de la edición)
          firestoreService.updateNote(ultimaAccion['docID'], ultimaAccion['previousData']);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No hay acciones para deshacer.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Información de Empleados"),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_bus),
            onPressed: () {
              // Navegar a la pantalla de buses usando GoRouter
              context.go('/buses', extra: firestoreService);
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestoreService.getNotesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List notesList = snapshot.data!.docs;
                      return Column(
                        children: notesList.map((document) {
                          String docID = document.id;
                          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                          final String imagenZona = imagenesPorZona[data['zona']] ?? 'assets/images/default_bus.jpg';

                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: Image.asset(imagenZona, width: 50, height: 50, fit: BoxFit.cover),
                              title: Text("${data['nombre']} ${data['apellido']}"),
                              subtitle: Text("Código: ${data['codigo']}\nZona: ${data['zona']}\nDirección: ${data['direccion']}\nHora: ${data['hora']}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(onPressed: () => openNoteBox(docID: docID, existingData: data), icon: const Icon(Icons.settings)),
                                  IconButton(onPressed: () {
                                    firestoreService.deleteNote(docID);
                                    pilaAcciones.add({
                                      'accion': 'eliminar',
                                      'data': data,
                                    });
                                  }, icon: const Icon(Icons.delete)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    } else {
                      return const Center(child: Text("No hay información disponible."));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: deshacerAccion,
            child: const Icon(Icons.undo),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: openNoteBox,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
