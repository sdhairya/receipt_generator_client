import "package:flutter/material.dart";

class components extends StatelessWidget {
  const components({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Text text(String data, FontWeight fontWeight, Color color, double fontsize) {
    return Text(
      data,
      style: TextStyle(
          fontWeight: fontWeight,
          color: color,
          fontSize: fontsize),
    );
  }

  TextField textField(String hint, TextInputType type, TextEditingController controller) {
    return  TextField(
      keyboardType: type,
      controller: controller,
      decoration: InputDecoration(
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black54)
        ),
        hintText: hint,
      ),
    );
  }

}
