import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 1)
class Note {
  @HiveField(0)
  String title;
  @HiveField(1)
  String content;
  @HiveField(2)
  DateTime updatedAt;
  @HiveField(3)
  int index;

  Note({this.title, this.content, this.updatedAt, this.index});
}
