 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectoed/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Servicio de Firestore
  final FirestoreService firestoreService = FirestoreService();

  // Controladores de texto para los campos de entrada
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController horaController = TextEditingController();

  // Variables para almacenar la selección de zona y hora
  String? selectedZona;
  TimeOfDay? selectedHora;

  // Lista de zonas disponibles
  final List<String> zonas = ["Zona Sur", "Zona Este", "Zona Norte", "Zona Oeste"];

  // Abrir un cuadro de diálogo para agregar o editar una nota
  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Agregar Información"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo para nombre
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              // Campo para apellido
              TextField(
                controller: apellidoController,
                decoration: const InputDecoration(labelText: "Apellido"),
              ),
              // Campo para código de empleado
              TextField(
                controller: codigoController,
                decoration: const InputDecoration(labelText: "Código de Empleado"),
                keyboardType: TextInputType.number,
              ),
              // Lista desplegable para seleccionar la zona
              DropdownButtonFormField<String>(
                value: selectedZona,
                items: zonas.map((zona) {
                  return DropdownMenuItem(
                    value: zona,
                    child: Text(zona),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedZona = value;
                  });
                },
                decoration: const InputDecoration(labelText: "Seleccione la Zona"),
              ),
              // Campo para la dirección
              TextField(
                controller: direccionController,
                decoration: const InputDecoration(labelText: "Dirección"),
              ),
              // Botón para seleccionar la hora
              ListTile(
                title: Text(
                  selectedHora == null
                      ? "Seleccionar Hora (5 PM - 8 PM)"
                      : "Hora: ${selectedHora!.format(context)}",
                ),
                onTap: () async {
                  // Mostrar el selector de hora
                  final TimeOfDay? pickedHora = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: 17, minute: 0), // Hora inicial: 5 PM
                    initialEntryMode: TimePickerEntryMode.input,
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                        child: child!,
                      );
                    },
                  );

                  // Validar que la hora esté entre 5 PM y 8 PM
                  if (pickedHora != null &&
                      pickedHora.hour >= 17 &&
                      pickedHora.hour <= 20) {
                    setState(() {
                      selectedHora = pickedHora;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Por favor, seleccione una hora entre 5 PM y 8 PM."),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Validar que todos los campos estén completos
              if (nombreController.text.isEmpty ||
                  apellidoController.text.isEmpty ||
                  codigoController.text.isEmpty ||
                  selectedZona == null ||
                  direccionController.text.isEmpty ||
                  selectedHora == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Por favor, complete todos los campos."),
                  ),
                );
                return;
              }

              // Crear un mapa con la información
              Map<String, dynamic> data = {
                "nombre": nombreController.text,
                "apellido": apellidoController.text,
                "codigo": codigoController.text,
                "zona": selectedZona,
                "direccion": direccionController.text,
                "hora": "${selectedHora!.hour}:${selectedHora!.minute}",
              };

              // Agregar o actualizar la nota en Firestore
              if (docID == null) {
                firestoreService.addNote(data as Map<String, dynamic>);
              } else {
                firestoreService.updateNote(docID, data as Map<String, dynamic>);
              }

              // Limpiar los campos y cerrar el cuadro de diálogo
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Información de Empleados")),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox, // Abrir el cuadro de diálogo para agregar información
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(), // Obtener el flujo de datos desde Firestore
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            // Mostrar la lista de información
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = notesList[index];
                String docID = document.id;
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                // Mostrar cada elemento en una tarjeta
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text("${data['nombre']} ${data['apellido']}"),
                    subtitle: Text(
                        "Código: ${data['codigo']}\nZona: ${data['zona']}\nDirección: ${data['direccion']}\nHora: ${data['hora']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón para editar
                        IconButton(
                          onPressed: () => openNoteBox(docID: docID),
                          icon: const Icon(Icons.settings),
                        ),
                        // Botón para eliminar
                        IconButton(
                          onPressed: () => firestoreService.deleteNote(docID),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No hay información disponible."));
          }
        },
      ),
    );
  }
}