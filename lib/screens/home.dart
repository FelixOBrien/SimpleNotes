import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'edit_note.dart';
import 'package:notes/models/note.dart';
import 'package:timeago/timeago.dart' as Timeago;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = true;
  Box<Note> _notes;
  List<Note> _sortedNotes = [];
  @override
  void initState() {
    openBox();
    super.initState();
  }

  void openBox() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteAdapter());
    var tempBox = await Hive.openBox<Note>("notes");
    _sortedNotes = tempBox.values.toList();
    _sortedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    setState(() {
      _notes = tempBox;
      _sortedNotes = _sortedNotes;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: (isLoading)
            ? Container(
                child: SizedBox(
                  child: CircleSpinner,
                  height: 100,
                  width: 100,
                ),
                alignment: Alignment.center,
              )
            : Container(
                child: (_notes != null && _notes.isNotEmpty)
                    ? ListView.builder(
                        itemCount: _notes.length,
                        itemBuilder: (context, int index) {
                          Note note = _sortedNotes[index];
                          return Dismissible(
                            key: Key(note.updatedAt.toString()),
                            background: Container(
                              color: Colors.red,
                              child: Text(
                                "Delete",
                                style: TextStyle(color: Colors.white),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              alignment: Alignment.centerRight,
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (DismissDirection d) {
                              setState(() {
                                _notes.deleteAt(note.index);
                                _sortedNotes.removeAt(index);
                              });
                            },
                            child: GestureDetector(
                              onTap: () async {
                                Note editedNote = await Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return EditNote(
                                    note: note,
                                  );
                                }));

                                editedNote.title =
                                    (editedNote.title.length == 0)
                                        ? "Empty Note"
                                        : editedNote.title;
                                setState(() {
                                  _notes.putAt(editedNote.index, editedNote);
                                  _sortedNotes = _notes.values.toList();
                                  _sortedNotes.sort((a, b) =>
                                      b.updatedAt.compareTo(a.updatedAt));
                                });
                              },
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    title: Text(note.title),
                                    subtitle:
                                        Text(Timeago.format(note.updatedAt)),
                                  ),
                                  Divider(
                                    height: 0,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          "You don't have any notes",
                          style: TextStyle(fontSize: 25.0),
                        ),
                      ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //Create new note
          Note note = await Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return EditNote(
              note: Note(
                  title: "",
                  content: "",
                  updatedAt: DateTime.now(),
                  index: _notes.length),
            );
          }));

          if (note.title == "") {
            note.title = "Empty Note";
          }
          setState(() {
            _notes.add(note);
            _sortedNotes = _notes.values.toList();
            _sortedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

const CircleSpinner = CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation(Colors.blue),
  strokeWidth: 5,
);
