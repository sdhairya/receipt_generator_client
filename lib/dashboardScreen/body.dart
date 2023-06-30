import 'package:blue_print_pos/models/blue_device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:receipt_generator_client/bluetoothDevicesScreen/bluetoothDevicesScreen.dart';
import 'package:receipt_generator_client/generateReceipt/generateReceipt.dart';
import 'package:receipt_generator_client/loginScreen/loginScreen.dart';
import 'package:receipt_generator_client/printQueueScreen/printQueueScreen.dart';
import 'package:receipt_generator_client/receiptsList/receiptList.dart';
import 'package:receipt_generator_client/supabasehandler.dart';
import '../components.dart';

class body extends StatefulWidget {
  //
  final List<String> resturant;

  const body({Key? key, required this.resturant}) : super(key: key);

  @override
  State<body> createState() => _bodyState();
}

class _bodyState extends State<body> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isobscure = true;
  bool isLoading = false;
  bool _printerSelected = false;
  late BlueDevice printer;

  void _toggle() {
    setState(() {
      _isobscure = !_isobscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.resturant as List);
    return SafeArea(child: Scaffold(
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 100),
              child: Container(
                alignment: Alignment.topCenter,
                constraints:
                BoxConstraints(maxWidth: kIsWeb ? 500 : double.infinity),
                child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: double.infinity,
                              child: ListTile(
                                contentPadding: EdgeInsets.all(0),
                                dense: true,
                                horizontalTitleGap: double.infinity,
                                leading: components().text(widget.resturant[1],
                                    FontWeight.bold, Color(0xFF1D2A3A), 35),
                                trailing: IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Logout'),
                                            content: Text(
                                                "Are you sure you want to logout"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Cancel')),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pushReplacement(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              loginScreen(),
                                                        ));
                                                  },
                                                  child: Text('Ok'))
                                            ],
                                          ));
                                    },
                                    icon: Icon(
                                      Icons.logout,
                                      size: 28,
                                      color: Colors.black,
                                    )),
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          // InkWell(
                          //   child: Container(
                          //     decoration: BoxDecoration(
                          //         color: Colors.black12,
                          //         borderRadius: BorderRadius.circular(10)),
                          //     width: double.infinity,
                          //     padding: EdgeInsets.all(15),
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.center,
                          //       children: [
                          //         ListTile(
                          //           leading: Icon(Icons.print_outlined,
                          //               color: Colors.blue, size: 40),
                          //           title: components().text(_printerSelected ? printer.name.toString() : "Select Printer",
                          //               FontWeight.normal, Colors.black, 20),
                          //         )
                          //       ],
                          //     ),
                          //   ),
                          //   onTap: () async {
                          //     BlueDevice print = await Navigator.of(context).push(MaterialPageRoute(
                          //       builder: (context) => bluetoothDevicesScreen(),
                          //     ));
                          //     setState(() {
                          //       printer = print;
                          //       _printerSelected = true;
                          //     });
                          //   },
                          // ),
                          SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(10)),
                              width: double.infinity,
                              padding: EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt, color: Colors.blue, size: 50),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  components().text("View All Receipts",
                                      FontWeight.normal, Colors.black, 20),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => receiptList(
                                    resturant_id: int.parse(widget.resturant[0]),
                                    resturant: widget.resturant),
                              ));
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(10)),
                              width: double.infinity,
                              padding: EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long,
                                      color: Colors.blue, size: 50),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  components().text("New Receipt", FontWeight.normal,
                                      Colors.black, 20),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    generateReceipt(resturant: widget.resturant),
                              ));
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          // InkWell(
                          //   child: Container(
                          //     decoration: BoxDecoration(
                          //         color: Colors.black12,
                          //         borderRadius: BorderRadius.circular(10)),
                          //     width: double.infinity,
                          //     padding: EdgeInsets.all(15),
                          //     child: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.center,
                          //       children: [
                          //         Icon(Icons.query_builder_outlined,
                          //             color: Colors.blue, size: 50),
                          //         SizedBox(
                          //           height: 20,
                          //         ),
                          //         components().text("Printing Queue",
                          //             FontWeight.normal, Colors.black, 20),
                          //       ],
                          //     ),
                          //   ),
                          //   onTap: () {
                          //     Navigator.of(context).push(MaterialPageRoute(
                          //         builder: (context) => printQueueScreen(resturant: widget.resturant,printer: printer,)
                          //     ));
                          //   },
                          // ),
                        ],
                      ),
                    )),
              ),
            );
          },
        ),
      ),
    ));
  }
}
