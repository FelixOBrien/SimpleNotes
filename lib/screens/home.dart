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
  Box<Note> _notes;
  @override
  void initState() {
    openBox();
    super.initState();
  }

  void openBox() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteAdapter());
    _notes = await Hive.openBox<Note>("notes");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Container(
          child: (_notes != null && _notes.isNotEmpty)
              ? ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, int index) {
                    Note note = _notes.getAt(index);
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
                          _notes.deleteAt(index);
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
                          editedNote.title = (editedNote.title.length == 0)
                              ? "Empty Note"
                              : editedNote.title;
                          setState(() {
                            _notes.putAt(index, editedNote);
                          });
                        },
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text(note.title),
                              subtitle: Text(Timeago.format(note.updatedAt)),
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
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
