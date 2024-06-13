import 'package:flutter/material.dart';

class AudioCard extends StatelessWidget {
  final String name;
  final String genre;
  final String bpm;
  final String scale;
  final List<String> tags;
  final void Function()? onPressed;
  final void Function()? onDeletePressed; // Agregado

  const AudioCard({
    Key? key,
    required this.name,
    required this.genre,
    required this.bpm,
    required this.scale,
    required this.tags,
    this.onPressed,
    this.onDeletePressed, // Agregado
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (genre.isNotEmpty) Text('Genre: $genre'),
            if (bpm.isNotEmpty) Text('BPM: $bpm'),
            if (scale.isNotEmpty) Text('Scale: $scale'),
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Tags: ${tags.join(', ')}'),
            ),
          ],
        ),
        trailing: Row(
          // Cambiado
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onPressed,
              icon: Icon(Icons.play_circle_fill),
              color: Theme.of(context).primaryColor,
              iconSize: 36,
            ),
            IconButton(
              // Agregado
              onPressed: onDeletePressed,
              icon: Icon(Icons.cancel),
              color: Colors.black,
              iconSize: 36,
            ),
          ],
        ),
      ),
    );
  }
}
