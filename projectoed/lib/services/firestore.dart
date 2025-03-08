import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Referencia a la colección 'notes' en Firestore
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  // Crear: agregar una nueva nota con la información completa
  Future<void> addNote(Map<String, dynamic> data) {
    return notes.add({
      'nombre': data['nombre'], // Nombre
      'apellido': data['apellido'], // Apellido
      'codigo': data['codigo'], // Código de empleado
      'zona': data['zona'], // Zona seleccionada
      'direccion': data['direccion'], // Dirección
      'hora': data['hora'], // Hora seleccionada
      'timestamp': Timestamp.now(), // Marca de tiempo
    });
  }

  // Leer: obtener el flujo de notas desde la base de datos
  Stream<QuerySnapshot> getNotesStream() {
    final notesStream =
        notes.orderBy('timestamp', descending: true).snapshots(); // Ordenar por timestamp
    return notesStream;
  }

  // Actualizar: actualizar una nota dado su ID
  Future<void> updateNote(String docID, Map<String, dynamic> newData) {
    return notes.doc(docID).update({
      'nombre': newData['nombre'], // Actualizar nombre
      'apellido': newData['apellido'], // Actualizar apellido
      'codigo': newData['codigo'], // Actualizar código de empleado
      'zona': newData['zona'], // Actualizar zona
      'direccion': newData['direccion'], // Actualizar dirección
      'hora': newData['hora'], // Actualizar hora
      'timestamp': Timestamp.now(), // Actualizar marca de tiempo
    });
  }

  // Eliminar: eliminar una nota dado su ID
  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }
}