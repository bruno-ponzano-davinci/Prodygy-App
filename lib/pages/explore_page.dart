import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prodygy/pages/drum_page.dart';
import 'package:flutter/services.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final TextEditingController _searchController = TextEditingController();
  Future<List<DocumentSnapshot>>? _futureData;
  Set<String> selectedUrls = Set<String>();

  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  @override
  void initState() {
    super.initState();
    _futureData = getData();
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> notifyMediaStore(File file) async {
    MethodChannel channel = MethodChannel('flutter.native/helper');
    try {
      await channel.invokeMethod('notifyMediaStore', {'path': file.path});
    } catch (e) {
      print("Error notifying media store: $e");
    }
  }

  Future<void> downloadFile(String url, String fileName) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final file = File('${directory.path}/$fileName');
        final storageRef = FirebaseStorage.instance.refFromURL(url);
        final downloadTask = storageRef.writeToFile(file);

        await downloadTask.whenComplete(() {
          print("Download completed: ${file.path}");
          notifyMediaStore(file);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Downloaded: $fileName")),
          );
        }).catchError((e) {
          print("Download error: $e");
        });
      }
    } catch (e) {
      print("Error downloading file: $e");
    }
  }

  Future<void> downloadSelectedAudios() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    for (String url in selectedUrls) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('audios')
            .where('audioUrl', isEqualTo: url)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          DocumentSnapshot doc = snapshot.docs.first;
          String fileName = doc['name'] + '.mp3';
          await downloadFile(url, fileName);

          await FirebaseFirestore.instance.collection('downloads').add({
            'userId': userId,
            'name': doc['name'],
            'audioUrl': url,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        } else {
          print("No metadata found for URL: $url");
        }
      } catch (e) {
        print("Error fetching metadata: $e");
      }
    }
  }

  Future<List<DocumentSnapshot>> getData({String? searchText}) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<QuerySnapshot> snapshots = [];

    if (searchText != null && searchText.isNotEmpty) {
      snapshots.add(await firestore
          .collection('audios')
          .where('name', isEqualTo: searchText)
          .get());
      snapshots.add(await firestore
          .collection('audios')
          .where('genre', isEqualTo: searchText)
          .get());
      snapshots.add(await firestore
          .collection('audios')
          .where('tags', arrayContains: searchText)
          .get());

      try {
        int bpmSearch = int.parse(searchText);
        snapshots.add(await firestore
            .collection('audios')
            .where('bpm', isEqualTo: bpmSearch)
            .get());
      } catch (_) {}

      try {
        int scaleSearch = int.parse(searchText);
        snapshots.add(await firestore
            .collection('audios')
            .where('scale', isEqualTo: scaleSearch)
            .get());
      } catch (_) {}
    } else {
      snapshots.add(await firestore.collection('audios').get());
    }

    Set<DocumentSnapshot> mergedResults = {};
    for (var snapshot in snapshots) {
      mergedResults.addAll(snapshot.docs);
    }

    return mergedResults.toList();
  }

  void toggleSelection(String url) {
    setState(() {
      if (selectedUrls.contains(url)) {
        selectedUrls.remove(url);
      } else {
        selectedUrls.add(url);
      }
    });
  }

  void _filterData() {
    setState(() {
      _futureData = getData(searchText: _searchController.text);
    });
  }

  void navigateToDrumPage(BuildContext context) {
    if (selectedUrls.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                DrumPage(selectedUrls: selectedUrls.toList())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Porfavor seleccione 1 audio o mas"),
      ));
    }
  }

  void playAudio(String url) async {
    await audioPlayer.play(UrlSource(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explorar Sonidos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Sonidos',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _filterData,
                ),
              ),
              onSubmitted: (_) => _filterData(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: _futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var data =
                          snapshot.data![index].data() as Map<String, dynamic>;
                      bool isSelected = selectedUrls.contains(data['audioUrl']);
                      return Card(
                        elevation: 5,
                        margin: EdgeInsets.all(8),
                        color: Colors.grey[300],
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          title: Text(data['name'],
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          leading: IconButton(
                            icon: Icon(isSelected
                                ? Icons.check_circle
                                : Icons.check_circle_outline),
                            onPressed: () => toggleSelection(data['audioUrl']),
                          ),
                          onTap: () => toggleSelection(data['audioUrl']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data['genre'] != null &&
                                  data['genre'].isNotEmpty)
                                Text('Genero: ${data['genre']}'),
                              if (data['bpm'] != null)
                                Text('BPM: ${data['bpm']}'),
                              if (data['scale'] != null)
                                Text('Escala: ${data['scale']}'),
                              if (data['tags'] != null &&
                                  data['tags'].isNotEmpty)
                                Text('Tags: ${data['tags'].join(', ')}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.play_circle_fill,
                                color: Theme.of(context).primaryColor,
                                size: 36),
                            onPressed: () => playAudio(data['audioUrl']),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else {
                  return Center(child: Text("No se encontro ningun sonido"));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showOptions(context),
        child: Icon(Icons.more_vert),
      ),
    );
  }

  void showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.music_note),
                title: Text('Ir a la batería virtual'),
                onTap: () {
                  Navigator.pop(context);
                  navigateToDrumPage(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.download),
                title: Text('Descargar los audios seleccionados'),
                onTap: () {
                  Navigator.pop(context);
                  downloadSelectedAudios();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
