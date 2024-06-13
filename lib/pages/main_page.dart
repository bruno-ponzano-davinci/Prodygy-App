import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prodygy/pages/explore_page.dart';
import 'package:prodygy/pages/home_page.dart';
import 'package:prodygy/pages/post_page.dart';
import 'package:prodygy/pages/profile_page.dart';
import 'package:prodygy/pages/uploadAudio_page.dart';

class MainPage extends StatefulWidget {
  MainPage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "svg/heart-svgrepo-com.svg",
              width: 24.0,
              height: 24.0,
            ),
            label: "Posts",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "svg/add-circle-svgrepo-com.svg",
              width: 24.0,
              height: 24.0,
            ),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "svg/drum-svgrepo-com.svg",
              width: 24.0,
              height: 24.0,
            ),
            label: "Sonidos",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("svg/ic_user.svg"),
            label: "Perfil",
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.amber,
      ),
    );
  }

  final List<Widget> pages = [
    PostPage(),
    UploadPage(),
    ExplorePage(),
    ProfilePage(),
  ];
}
