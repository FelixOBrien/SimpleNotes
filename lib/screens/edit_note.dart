import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';

class EditNote extends StatefulWidget {
  final Note note;
  EditNote({this.note});

  @override
  _EditNoteState createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  final TextEditingController noteController = TextEditingController();
  Note newNote;
  @override
  void initState() {
    newNote = widget.note;
    noteController.text = newNote.content;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          child: Icon(Icons.arrow_back_ios),
          onTap: () {
            saveNote(noteController.text);
            Navigator.pop(context, newNote);
          },
        ),
        title: Text((newNote.title.length > 0) ? newNote.title : "Empty Note"),
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: TextField(
          controller: noteController,
          decoration: InputDecoration(border: InputBorder.none),
          onChanged: (value) => saveNote(value),
          autofocus: true,
          autocorrect: true,
          maxLines: 99999,
        ),
      ),
    );
  }

  void saveNote(String value) {
    //Update the note here
    //Title should equal everything before the first line break or the first 15 characters
    setState(() {
      if (value.length == 0) {
        newNote.title = "Empty Note";
      } else if (value.length >= 15) {
        newNote.title =
            (value.substring(0, 14).replaceAll(RegExp(r'[\n\s]+'), ""));
      } else {
        newNote.title = value.replaceAll(RegExp(r"[\n\s]+"), "");
      }
      newNote.content = value;
      newNote.updatedAt = DateTime.now();
    });
  }
}

const CircleSpinner = CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation(Colors.blue),
);
