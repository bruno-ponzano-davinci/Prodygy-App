import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import GoogleSignIn package
import 'package:prodygy/components/audio_card.dart';
import 'package:prodygy/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userCollection = FirebaseFirestore.instance.collection("Users");
  late Stream<QuerySnapshot> audioStream;
  final AudioPlayer audioPlayer = AudioPlayer();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    audioStream = FirebaseFirestore.instance
        .collection("audios")
        .where('userId', isEqualTo: currentUser.uid)
        .snapshots();
  }

  void playAudio(String url) async {
    await audioPlayer.play(UrlSource(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              signUserOut(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return ListView(
              children: [
                SizedBox(height: 50),
                CircleAvatar(
                  backgroundImage: NetworkImage(currentUser.photoURL ?? ''),
                  radius: 36,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.transparent,
                  child: Align(
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: Image.network(
                        currentUser.photoURL ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text("Mi información"),
                ),
                MyTextBox(
                  text: userData["username"],
                  sectionName: "Nombre de usuario",
                  onPressed: () => editField(context, 'username'),
                ),
                MyTextBox(
                  text: userData["bio"],
                  sectionName: "Biografia",
                  onPressed: () => editField(context, 'bio'),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text(
                    "Mis archivos subidos",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: audioStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final List<DocumentSnapshot> documents =
                          snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final data =
                              documents[index].data() as Map<String, dynamic>;
                          return Column(
                            children: [
                              AudioCard(
                                name: data['name'],
                                genre: data['genre'],
                                bpm: data['bpm'],
                                scale: data['scale'],
                                tags: List<String>.from(data['tags']),
                                onPressed: () => playAudio(data['audioUrl']),
                                onDeletePressed: () async {
                                  bool confirmDelete = await deleteAudioDialog(
                                      context, documents[index].id);
                                  if (confirmDelete) {
                                    print("Archivo eliminado");
                                  } else {
                                    print("Eliminación cancelada");
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("Error: ${snapshot.error}"),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("error${snapshot.error}"),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Future<void> editField(BuildContext context, String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (builder) => AlertDialog(
        title: Text("edit " + field),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: "Ingrese un nuevo $field",
            hintStyle: TextStyle(color: Colors.grey[300]),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue),
            child: Text("Cambiar " + field),
          ),
        ],
      ),
    );

    if (newValue.trim().length > 0) {
      await userCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  void signUserOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      print("Cerrar sesión");
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }

  Future<bool> deleteAudioDialog(
      BuildContext context, String documentId) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Eliminar archivo"),
          content: Text("¿Estás seguro de que deseas eliminar este archivo?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("audios")
                    .doc(documentId)
                    .delete();
                print("Archivo eliminado correctamente.");
                Navigator.of(context).pop(true);
              },
              child: Text("Eliminar"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      return result;
    } else {
      return false;
    }
  }
}
