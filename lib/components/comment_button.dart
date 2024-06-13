import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CommentButton extends StatelessWidget {
  final void Function()? onTap;
  const CommentButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        Icons.comment,
        color: Colors.grey,
      ),
    );
  }
}
