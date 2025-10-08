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
  // update a note given a doc id
  // delete a note in database given a doc id
}
