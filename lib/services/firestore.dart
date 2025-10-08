import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  // get collection of notes
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  // create a new note
  Future<DocumentReference<Object?>> addNote(String note) async {
    return await notes.add({'note': note, 'timestamp': Timestamp.now()});
  }

  // read a note from database
  Stream<QuerySnapshot> getNoteStream() {
    final notesStream =
        notes.orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  // update a note given a doc id
  Future<void> updateNote(String docId, String newNote) async {
    return await notes
        .doc(docId)
        .update({'note': newNote, 'timestamp': Timestamp.now()});
  }

  // delete a note in database given a doc id
  Future<void> deleteNote(String docId) async {
    return await notes.doc(docId).delete();
  }
}
