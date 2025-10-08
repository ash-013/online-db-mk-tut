import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:online_db_mk/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _noteController = TextEditingController();
  final FirestoreServices _firestoreServices = FirestoreServices();
  void openNoteBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: _noteController,
          decoration: const InputDecoration(hintText: 'Enter your note here'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _firestoreServices.addNote(_noteController.text);
              Navigator.of(context).pop();
              _noteController.clear();
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              HapticFeedback.vibrate();
              openNoteBox();
            },
            child: const Icon(Icons.add)),
        body: StreamBuilder(
            stream: _firestoreServices.getNoteStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong!'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No notes available!'));
              }
              final notes = snapshot.data!.docs;
              return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return ListTile(
                        title: Text(note['note']),
                        subtitle: Text(note['timestamp'].toDate().toString()),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // update note button
                            IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  _noteController.text = note['note'];
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Edit Note'),
                                      content: TextField(
                                        controller: _noteController,
                                        decoration: const InputDecoration(
                                            hintText: 'Enter your note here'),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            _firestoreServices.updateNote(
                                                note.id, _noteController.text);
                                            Navigator.of(context).pop();
                                            _noteController.clear();
                                          },
                                          child: const Text(
                                            'Update',
                                            style:
                                                TextStyle(color: Colors.green),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            // delete note button
                            IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  HapticFeedback.vibrate();
                                  _firestoreServices.deleteNote(note.id);
                                }),
                          ],
                        ));
                  });
            }));
  }
}
