import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Comment extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  const Comment(
      {super.key, required this.text, required this.user, required this.time});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(bottom: 5),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text),
            Row(
              children: [
                Text(
                  user,
                  style: TextStyle(color: Colors.grey[400]),
                ),
                Text(" ", style: TextStyle(color: Colors.grey[400])),
                Text(time, style: TextStyle(color: Colors.grey[400]))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
