import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';


class previewScreen extends StatelessWidget {

  final Uint8List bytes;

  const previewScreen(
      {Key? key,required this.bytes,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

          appBar: AppBar(
            leading: InkWell(
              child: Icon(Icons.arrow_back_ios_new),
              onTap: () {
              },
            ),
            actions: [
              Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: InkWell(
                      child: Icon(Icons.print),
                      onTap: () {
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (context) => bluetoothDevicesScreen(list: list, bytes: bytes,)));                  },
                        // child:
                        //
                      })),
            ],
          ),
          body: Image.memory(bytes)
          ),
    );
  }
}
