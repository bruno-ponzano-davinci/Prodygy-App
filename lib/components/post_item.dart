import 'package:flutter/material.dart';

class PostItem extends StatelessWidget {
  const PostItem({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                "temp/user1.png",
                width: 40,
                height: 40,
              ),
              SizedBox(
                width: 16,
              ),
              Text("Bruno Ponzano"),
            ],
          ),
        ],
      ),
    );
  }
}
