import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadPage extends StatefulWidget {
  UploadPage({Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _tagsController;
  late TextEditingController _genreController;
  late TextEditingController _scaleController;
  late TextEditingController _bpmController;
  bool _termsAccepted = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _tagsController = TextEditingController();
    _genreController = TextEditingController();
    _scaleController = TextEditingController();
    _bpmController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagsController.dispose();
    _genreController.dispose();
    _scaleController.dispose();
    _bpmController.dispose();
    super.dispose();
  }

  Future<File?> getAudioFromGallery(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result != null) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<bool> uploadAudioForUser(File file) async {
    try {
      setState(() {
        _uploading = true;
      });

      final userId = FirebaseAuth.instance.currentUser?.uid;
      final storageRef = FirebaseStorage.instance.ref();
      final fileName = file.path.split("/").last;
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final uploadRef =
          storageRef.child("$userId/uploads/$timestamp-$fileName");
      final uploadTask = uploadRef.putFile(file);

      await uploadTask.whenComplete(() => null);

      final audioUrl = await uploadRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('audios').add({
        'userId': userId,
        'name': _nameController.text,
        'tags':
            _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
        'genre': _genreController.text,
        'scale': _scaleController.text,
        'bpm': _bpmController.text,
        'audioUrl': audioUrl,
        'timestamp': timestamp,
      });

      final metadata = SettableMetadata(
        customMetadata: {
          'name': _nameController.text,
          'tags': _tagsController.text,
          'genre': _genreController.text,
          'scale': _scaleController.text,
          'bpm': _bpmController.text,
        },
      );
      await uploadRef.updateMetadata(metadata);

      setState(() {
        _uploading = false;
      });

      return true;
    } catch (e) {
      print(e);

      setState(() {
        _uploading = false;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Subir Audio"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduce un nombre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _tagsController,
                  decoration: InputDecoration(labelText: 'Etiquetas'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduce al menos una etiqueta';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _genreController,
                  decoration: InputDecoration(labelText: 'Género'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, introduce un género';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _scaleController,
                  decoration: InputDecoration(labelText: 'Escala (opcional)'),
                ),
                TextFormField(
                  controller: _bpmController,
                  decoration: InputDecoration(labelText: 'BPM (opcional)'),
                ),
                SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: _termsAccepted,
                      onChanged: (value) {
                        setState(() {
                          _termsAccepted = value ?? false;
                        });
                      },
                    ),
                    Text(
                      'Acepto los términos y condiciones',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16),
                Center(
                  child: _uploading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate() &&
                                _termsAccepted) {
                              File? selectedAudio =
                                  await getAudioFromGallery(context);
                              if (selectedAudio != null) {
                                bool success =
                                    await uploadAudioForUser(selectedAudio);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Archivo subido con éxito')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Error al subir el archivo')),
                                  );
                                }
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Debes aceptar los términos y condiciones')),
                              );
                            }
                          },
                          child: Text('Subir audio'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
