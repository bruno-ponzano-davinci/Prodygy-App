import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class DrumPage extends StatelessWidget {
  final List<String> selectedUrls;

  const DrumPage({Key? key, required this.selectedUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Batería Virtual")),
      body: GridView.builder(
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: selectedUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              AudioPlayer().play(UrlSource(selectedUrls[index]));
            },
            child: Card(
              child: Center(
                child: Text(" ${index + 1}"),
              ),
            ),
          );
        },
      ),
    );
  }
}
