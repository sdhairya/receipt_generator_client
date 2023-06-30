import 'package:blue_print_pos/models/blue_device.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'body.dart';

class generateReceipt extends StatefulWidget {
  final List<String> resturant;
  // BlueDevice printer;

  generateReceipt({Key? key, required this.resturant,})
      : super(key: key);

  @override
  State<generateReceipt> createState() => _generateReceiptState();
}

class _generateReceiptState extends State<generateReceipt> {

  @override
  void initState() {
    _getBillnumber();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return body(
      resturant: widget.resturant,
    );
  }

  _getBillnumber() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var _billNo = _prefs.getInt("billNo") ?? "";

    if(_billNo == ""){
      _prefs.setInt("billNo", 1);
    }

  }

}
