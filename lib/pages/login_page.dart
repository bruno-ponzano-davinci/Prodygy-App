import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prodygy/components/my_button.dart';
import 'package:prodygy/components/my_texfield.dart';
import 'package:prodygy/pages/register_page.dart';
import 'package:prodygy/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void wrongEmailMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Correo electronico o contrasenia incorrectos'),
        );
      },
    );
  }

  void signUserIn(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      print("Intentando loggear");
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: usernameController.text,
        password: passwordController.text,
      );
      print("bien");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      wrongEmailMessage(context);
      print("FirebaseAuthException caught: ${e.code}");
      if (e.code == "wrong-password") {
        Navigator.pop(context);
        wrongEmailMessage(context);
        print("Wrong email or password");
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    usernameController.clear();
    passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Spacer(),
                Text(
                  "Hola! Bienvenido a Prodygy!",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 22,
                ),
                Text(
                  "Inicia sesión para continuar",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                /*     Spacer(),
              MyTextField(
                  controller: usernameController,
                  hintText: "Usuario",
                  obscureText: false,
                ),
                MyTextField(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),
                SizedBox(
                  height: 22,
                ),
                TextButton(
                  onPressed: () {
                    print("Forgot Clicked");
                  },
                  child: Text("Forgot Password?"),
                ),
                SizedBox(
                  height: 10,
                ),
                MyButton(
                  onTap: () => signUserIn(context),
                ),
*/
                Spacer(),

                ///   Text("Or sign in with:"),
                SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () {
                    AuthService()
                        .signInWithGoogle()
                        .then((user) {})
                        .catchError((error) {});
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/google.png',
                        width: 22,
                        height: 22,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text('Login with Google'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                /* Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("No tienes una cuenta?"),
                    TextButton(
                      onPressed: () {
                        // Navega a la página de registro cuando se hace clic en "Registrate!"
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        "Registrate!",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    )
                  ],
                ),*/
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
