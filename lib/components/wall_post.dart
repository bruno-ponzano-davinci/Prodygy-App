import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prodygy/components/comment.dart';
import 'package:prodygy/components/comment_button.dart';
import 'package:prodygy/components/delete_button.dart';
import 'package:prodygy/components/like_button.dart';
import 'package:prodygy/helper/helper_methods.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef =
        FirebaseFirestore.instance.collection("User Posts").doc(widget.postId);

    if (isLiked) {
      postRef.update({
        "Likes": FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      postRef.update({
        "Likes": FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  void addComent(String commentText) {
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now(),
    });
  }

  final _commentTextController = TextEditingController();

  void showCommentDialog() {
    showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            title: Text("Agregue un comentario"),
            content: TextField(
              controller: _commentTextController,
              decoration: InputDecoration(hintText: "Escribe un comentario..."),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _commentTextController.clear();
                },
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  addComent(_commentTextController.text);
                  Navigator.pop(context);
                  _commentTextController.clear();
                },
                child: Text("Comentar"),
              ),
            ],
          )),
    );
  }

  void deletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Borrar Post"),
        content: const Text("Seguro que quieres Borrar el post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              final commentDocs = await FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .get();

              for (var doc in commentDocs.docs) {
                await FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postId)
                    .collection("Comments")
                    .doc(doc.id)
                    .delete();
              }
              FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .delete()
                  .then((value) => print("Post Borrado"));
              Navigator.pop(context);
            },
            child: const Text("Borrar Post"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(width: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(widget.message)
                ],
              ),
            ),
            if (widget.user == currentUser.email)
              DeleteButton(onTap: deletePost),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                LikeButton(isLiked: isLiked, onTap: toggleLike),
                Text(widget.likes.length.toString()),
              ],
            ),
            const SizedBox(
              height: 10,
              width: 10,
            ),
            Column(
              children: [
                CommentButton(
                  onTap: showCommentDialog,
                ),
                // Mostrar el número de comentarios aquí
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("User Posts")
                      .doc(widget.postId)
                      .collection("Comments")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    return Text(snapshot.data!.docs.length.toString());
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("User Posts")
              .doc(widget.postId)
              .collection("Comments")
              .orderBy("CommentTime", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: snapshot.data!.docs.map((doc) {
                final commentData = doc.data() as Map<String, dynamic>;
                return Comment(
                    text: commentData["CommentText"],
                    user: commentData["CommentedBy"],
                    time: formatData(commentData["CommentTime"]));
              }).toList(),
            );
          },
        ),
      ]),
    );
  }
}
