import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firestore.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

final TextEditingController textController = TextEditingController();
final FirestoreService firestoreService = FirestoreService();

class _MyAppState extends State<MyApp> {
  void openNoteBox({String? docID}){
    showDialog(
      context: context,
      builder: (context) =>
        AlertDialog(
          content: TextField(
            controller: textController
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (docID==null) {
                  firestoreService.addNote(textController.text);
                }
                else{
                  firestoreService.upadatNote(docID, textController.text);
                }
                //firestoreService.addNote(textController.text);
                textController.clear();
                Navigator.pop(context);
              },
              child: Text('Add'),
            )
          ],
        )
      
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To Do'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          //if we have date, get all docs
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;
            //display as list view
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                //get each individual document 
                DocumentSnapshot document = notesList[index];
                String docID= document.id;
                //get note from each doc
                Map<String, dynamic> data=document.data() as Map<String, dynamic>;
                String noteText = data ['note'];
                //display as list tail
                return ListTile(
                  trailing: IconButton(
                    onPressed: () {
                      openNoteBox(docID: docID);
                    },
                    icon: Icon(Icons.threed_rotation),
                  ),
                  title: Text(noteText),
                );
              },
            );
          } 
          //if there is no data return
          else{
            return Text('No date');

          }
        },
      ),
    );
  }
}