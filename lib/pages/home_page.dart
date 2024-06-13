import 'package:flutter/material.dart';
import 'package:prodygy/components/app_bar.dart';
import 'package:prodygy/components/post_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ToolBar(
        title: "Home",
        actions: [],
      ),
      body: ListView(
        children: mockUsersFromServer(),
      ),
    );
  }

  List<Widget> mockUsersFromServer() {
    List<Widget> users = [];
    for (var i = 0; i < 12; i++) {
      users.add(PostItem());
    }
    return users;
  }
}
