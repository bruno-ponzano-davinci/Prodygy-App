import 'package:flutter/material.dart';
import 'package:prodygy/components/app_bar.dart';
import 'package:prodygy/components/app_text_field.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ToolBar(
        title: "Editar Perfil",
        actions: [],
      ),
      body: Column(
        children: [
          AppTextField(hint: "Primer Nombre"),
          AppTextField(hint: "Apellido"),
        ],
      ),
    );
  }
}
