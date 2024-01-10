import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_db_flutter/models/notes_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:hive_db_flutter/boxs/box.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' as XFiles;
// import 'package:share/share.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  List<Color> colors = [
    Colors.purple,
    Colors.black38,
    Colors.green,
    Colors.blue,
    Colors.red
  ];
  var image;
  Random random = Random(3);
  XFile? personPreview, file;
  Uint8List? personlogoBytes, imageByte;
  List<String> imagePaths = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: ValueListenableBuilder<Box<NotesModel>>(
        valueListenable: Boxes.getData().listenable(),
        builder: (context, box, _) {
          var data = box.values.toList().cast<NotesModel>();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
                itemCount: box.length,
                reverse: true,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  print(data);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      color: colors[random.nextInt(4)],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.memory(data[index].imageByte, height: 35),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  data[index].title.toString(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                                Spacer(),
                                InkWell(
                                    onTap: () {
                                      delete(data[index]);
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    )),
                                SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                    onTap: () {
                                      _editDialog(
                                          data[index],
                                          data[index].title.toString(),
                                          data[index].description.toString(),
                                          data[index].imageByte);
                                    },
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                    )),
                                SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                    onTap: () async {
                                      await XFiles.Share.shareXFiles(
                                          text: data[index].title.toString() +
                                              data[index]
                                                  .description
                                                  .toString(),
                                          [
                                            XFile(
                                              data[index].path,
                                              bytes: data[index].imageByte,
                                            )
                                          ]);
                                      // await Share.shareFiles(
                                      //   [File(data[index].path).toString()],
                                      //   text:
                                      //       data[index].description.toString(),
                                      //   subject: data[index].title.toString(),
                                      // );
                                    },
                                    child: Icon(
                                      Icons.share,
                                      color: Colors.white,
                                    )),
                              ],
                            ),
                            Text(
                              data[index].description.toString(),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _showMyDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void delete(NotesModel notesModel) async {
    await notesModel.delete();
  }

  Future<void> _editDialog(NotesModel notesModel, String title,
      String description, Uint8List imgbyt) async {
    titleController.text = title;
    descriptionController.text = description;

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, state) {
            return AlertDialog(
              title: Text('Edit NOTES'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        final imagePicker = ImagePicker();
                        personPreview = await imagePicker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (personPreview != null) {
                          personlogoBytes = await personPreview!.readAsBytes();
                          state(
                            () {
                              setState(() {
                                imagePaths.add(personPreview!.path);
                                imageByte = personlogoBytes;
                              });
                            },
                          );
                        }

                        print("ImagePath $imagePaths");
                        print("pickImagePath ${personPreview!.path}");

                        // FilePickerResult? result =
                        //     await FilePicker.platform.pickFiles(
                        //   type: FileType.image,
                        //   withData: true,
                        // );
                        // if (result != null) {
                        //   state(
                        //     () {
                        //       setState(() {
                        //         personPreview =
                        //             File(result.files.single.path ?? '');
                        //       });
                        //     },
                        //   );
                        //   personlogoBytes = await result.files.first.bytes;
                        //}
                      },
                      child: Center(
                          child: personlogoBytes != null
                              ? Image.memory(
                                  personlogoBytes!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      "assets/imageNotFound.png",
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.fill,
                                    );
                                  },
                                )
                              : Image.memory(
                                  imgbyt,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      "assets/imageNotFound.png",
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.fill,
                                    );
                                  },
                                )),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                          hintText: 'Enter title',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                          hintText: 'Enter description',
                          border: OutlineInputBorder()),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () async {
                      notesModel.title = titleController.text.toString();
                      notesModel.description =
                          descriptionController.text.toString();
                      notesModel.imageByte = personlogoBytes!;
                      notesModel.path = personPreview!.path;
                      notesModel.save();
                      state(
                        () {
                          setState(() {
                            descriptionController.clear();
                            titleController.clear();
                            personPreview = null;
                            personlogoBytes = null;
                            imageByte = null;
                            // box.

                            Navigator.pop(context);
                          });
                        },
                      );
                    },
                    child: Text('Edit')),
              ],
            );
          });
        });
  }

  Future<Uint8List?> _pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Uint8List imageBytes = await image.readAsBytes();
      return imageBytes;
    } else {
      return null;
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, state) {
            return AlertDialog(
              title: Text('Add NOTES'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    personlogoBytes != null
                        ? Center(
                            child: CircleAvatar(
                                radius: 50,
                                child: ClipOval(
                                    child: Image.memory(
                                  personlogoBytes!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ))),
                          )
                        : InkWell(
                            onTap: () async {
                              // FilePickerResult? result =
                              //     await FilePicker.platform.pickFiles(
                              //         type: FileType.image, withData: true);
                              final imagePicker = ImagePicker();
                              personPreview = await imagePicker.pickImage(
                                source: ImageSource.gallery,
                              );
                              personlogoBytes =
                                  await personPreview!.readAsBytes();
                              state(
                                () {
                                  if (personPreview != null) {}
                                  setState(() {
                                    imagePaths.add(personPreview!.path);
                                    imageByte = personlogoBytes;
                                  });
                                },
                              );
                              // }
                            },
                            child: Center(
                              child: imageByte != null
                                  ? Image.memory(
                                      imageByte!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          "assets/imageNotFound.png",
                                          height: 70,
                                          width: 70,
                                          fit: BoxFit.fill,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      "assets/imageNotFound.png",
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.fill,
                                    ),
                            ),
                          ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                          hintText: 'Enter title',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                          hintText: 'Enter description',
                          border: OutlineInputBorder()),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      final data = NotesModel(
                          title: titleController.text,
                          description: descriptionController.text,
                          imageByte: personlogoBytes ?? Uint8List(0),
                          path: imagePaths[0].toString());

                      final box = Boxes.getData();
                      box.add(data);

                      // data.save() ;
                      state(
                        () {
                          setState(() {
                            titleController.clear();
                            descriptionController.clear();
                            personPreview = null;
                            personlogoBytes = null;
                            imageByte = null;
                            // box.
                            imagePaths = [];
                            Navigator.pop(context);
                          });
                        },
                      );
                    },
                    child: Text('Add')),
              ],
            );
          });
        });
  }
}
