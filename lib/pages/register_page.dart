import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prodygy/pages/main_page.dart';
import 'package:prodygy/services/auth_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserUp(BuildContext context) async {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      _showAlertDialog(context, 'Correo electrónico incorrecto');
      return;
    }

    if (password.length < 6) {
      _showAlertDialog(
          context, 'La contraseña debe tener al menos 6 caracteres');
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'username': emailController.text.split('@')[0],
        'bio': 'Empty bio'
      });

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      emailController.clear();
      passwordController.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );

      _showAlertDialog(context, 'Cuenta creada correctamente');
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          _showAlertDialog(
              context, 'Ya hay una cuenta con este correo electrónico.');
        } else {
          _showAlertDialog(context, 'Error al crear la cuenta: ${e.message}');
        }
      } else {
        _showAlertDialog(context, 'Error desconocido: $e');
      }
    }
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Alerta'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void signInWithGoogle(BuildContext context) async {
    try {
      UserCredential userCredential = await AuthService().signInWithGoogle();

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'username': userCredential.user!.email!.split('@')[0],
        'bio': 'Empty bio'
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } catch (e) {
      _showAlertDialog(context, 'Error al iniciar sesión con Google: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => signUserUp(context),
              child: Text('Registrarse'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => signInWithGoogle(context),
              child: Text('Registrarse con Google'),
            ),
          ],
        ),
      ),
    );
  }
}
