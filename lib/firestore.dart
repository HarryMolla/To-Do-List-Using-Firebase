

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  final CollectionReference notes = FirebaseFirestore.instance.collection('notes');

//CREAT: Add new note
  Future<void> addNote (String note) async {
   await notes.add({
    'note': note,
    'timestamp':Timestamp.now()
  });
}

//READ: get note from database
Stream<QuerySnapshot> getNotesStream(){
final notesStream=notes.orderBy('timestamp', descending: true).snapshots();
return notesStream;
}

//UPDATE: update a note given a note ID
Future<void> upadatNote(String docID, String newNote){
return notes.doc(docID).update({
  'note': newNote,
  'timestamp': Timestamp.now()
});
}
//DELETE: delete a note given a note ID
Future deleteNote(String docID){
  return notes.doc(docID).delete(
  );
}
}

