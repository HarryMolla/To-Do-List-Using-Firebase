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
  String? deletedNoteID;
  String? deletedNoteText;
  void openNoteBox(
      {String? docID, String? existingText, bool isUpdate = false}) {
    if (existingText != null) {
      textController.text = existingText;
    } else {
      textController.clear(); // Clear if no existing text
    }
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(controller: textController),
              actions: [
                // Add Button
                ElevatedButton(
                    style: ButtonStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                        backgroundColor: WidgetStatePropertyAll(Colors.green)),
                    onPressed: () {
                      if (textController.text.trim().isNotEmpty) {
                        if (docID == null) {
                          firestoreService.addNote(textController.text);
                        } else {
                          firestoreService.upadatNote(
                              docID, textController.text);
                        }
                        textController.clear();
                        Navigator.pop(context);
                      } else {
                        // Optionally show a message or do nothing if text is empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Note cannot be empty!'),
                          ),
                        );
                      }
                    },
                    child: Text(isUpdate ? 'UPDATE' : 'ADD',
                        style: TextStyle(color: Colors.white))),
              ],
            ));
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
                String docID = document.id;
                //get note from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];
                //display as list tail
                return ListTile(
                  trailing: PopupMenuButton<int>(
                    onSelected: (value) {
                      if (value == 1) {
                        openNoteBox(
                            docID: docID,
                            existingText: noteText,
                            isUpdate: true);
                      } else if (value == 2) {
                        deletedNoteID = docID;
                        deletedNoteText = noteText;
                        firestoreService.deleteNote(docID);
                        snackBarShow();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<int>(value: 1, child: Text('Update')),
                      PopupMenuItem<int>(value: 2, child: Text('Delete')),
                    ],
                    icon: Icon(Icons.more_vert),
                  ),
                  title: Text(noteText),
                );
              },
            );
          }
          //if there is no data return
          else {
            return Text('No date');
          }
        },
      ),
    );
  }

  void snackBarShow() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You Just Delete the note'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            if (deletedNoteID != null && deletedNoteText != null) {
              firestoreService.addNote(deletedNoteText!);
              deletedNoteID = null; // Clear the stored ID
              deletedNoteText = null; // Clear the stored text
            }
          },
        ),
      ),
    );
  }
}
