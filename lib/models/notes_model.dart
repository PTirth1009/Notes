import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
part 'notes_model.g.dart';

@HiveType(typeId: 0)
class NotesModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  Uint8List imageByte;

  @HiveField(3)
  String path;

  NotesModel(
      {required this.title,
      required this.description,
      required this.imageByte,
      required this.path});
}
