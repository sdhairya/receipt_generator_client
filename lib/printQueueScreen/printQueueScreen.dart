import 'package:blue_print_pos/models/blue_device.dart';
import 'package:flutter/material.dart';

import '../components.dart';
import 'body.dart';

class printQueueScreen extends StatefulWidget {
  final List<String> resturant;
  final BlueDevice printer;
  const printQueueScreen({Key? key, required this.resturant, required this.printer}) : super(key: key);

  @override
  State<printQueueScreen> createState() => _printQueueScreenState();
}

class _printQueueScreenState extends State<printQueueScreen> {
  @override
  Widget build(BuildContext context) {
    final data = Future(() => null);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: components()
            .text("Receipts", FontWeight.bold, Colors.white, 20),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20),
              child: InkWell(
                onTap: () async {
                  setState(() {
                  });
                  // printDoc(date, time, bytes);

                },
                child: Icon(Icons.save),
              ))
        ],
      ),
      body: FutureBuilder(
        future: data,
        builder: (context, snapshot) {
          // print(data);
            return body(resturant: widget.resturant,printer: widget.printer,);
            
        },
      ),
    );

  }
}
