import 'dart:async';
import 'dart:convert';

import 'package:blue_print_pos/blue_print_pos.dart';
import 'package:blue_print_pos/models/blue_device.dart';
import 'package:blue_print_pos/models/connection_status.dart';
import 'package:blue_print_pos/receipt/receipt.dart';
import 'package:blue_print_pos/receipt/receipt_section_text.dart';
import 'package:blue_print_pos/receipt/receipt_text_size_type.dart';
import 'package:blue_print_pos/receipt/receipt_text_style_type.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:receipt_generator_client/bluetoothDevicesScreen/bluetoothDevicesScreen.dart';
import 'package:receipt_generator_client/generateReceipt/generateReceipt.dart';
import 'package:receipt_generator_client/previewScreen.dart';
import 'package:receipt_generator_client/printable_data.dart';
import 'package:receipt_generator_client/receipt.dart';
import 'package:receipt_generator_client/supabasehandler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components.dart';
import 'package:receipt_generator_client/list.dart';

import '../receiptsList/receiptList.dart';
import '../utils.dart';

class body extends StatefulWidget {
  final List<String> resturant;
  // final BlueDevice printer;

  const body({Key? key, required this.resturant})
      : super(key: key);

  @override
  State<body> createState() => _bodyState();
}

class _bodyState extends State<body> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _itemnameController = TextEditingController();
  final TextEditingController _itemqtyController = TextEditingController();
  final TextEditingController _itempriceController = TextEditingController();
  final TextEditingController _cgstController = TextEditingController();
  final TextEditingController _sgstController = TextEditingController();
  List<receiptsitems> items = [];
  List<receiptsitems> addon_items = [];
  List<receiptData> receipts = [];
  List<List<String>> addon_item = [];
  List<List<String>> item = [];
  String total_price = "";
  double sub_total = 0;
  double total = 0;
  double cgst = 0;
  double sgst = 0;
  bool isLoading = false;
  final BluePrintPos _bluePrint = BluePrintPos.instance;
  Uint8List bytes = Uint8List.fromList([0]);
  var html = "";

  @override
  void initState() {
    // _connectDevice();
    super.initState();
  }

  // Future<void> _connectDevice() async {
  //   await _bluePrint.connect(widget.printer).then((ConnectionStatus status) {
  //     if (status == ConnectionStatus.connected) {
  //       print("Connected");
  //       print(_bluePrint.isConnected.toString());
  //     } else if (status == ConnectionStatus.timeout) {
  //       print("Not Connected");
  //     } else {
  //       if (kDebugMode) {
  //         print('$runtimeType - something wrong');
  //       }
  //     }
  //   });
  // }
  //
  // void _onDisconnectDevice() {
  //   _bluePrint.disconnect().then((ConnectionStatus status) {
  //     if (status == ConnectionStatus.disconnect) {
  //       setState(() {});
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final GlobalKey globalKey = GlobalKey();
    DateTime today = DateTime.now();
    String date = "${today.day}-${today.month}-${today.year}";
    String time = "${today.hour}:${today.minute}";

    return SafeArea(child: Scaffold(
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 100),
              child: Container(
                alignment: Alignment.center,
                constraints:
                    BoxConstraints(maxWidth: kIsWeb ? 500 : double.infinity),
                child: Center(
                    child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        visualDensity: VisualDensity.compact,
                        contentPadding: EdgeInsets.all(0),
                        leading: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.arrow_back_ios_new)),
                        title: components().text("New Receipt", FontWeight.bold,
                            Color(0xFF1D2A3A), 28),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //       color: Colors.black12,
                      //       borderRadius: BorderRadius.circular(10)),
                      //   width: double.infinity,
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       ListTile(
                      //         leading: Icon(Icons.print_outlined,
                      //             color: Colors.blue, size: 35),
                      //         title: components().text(widget.printer.name,
                      //             FontWeight.normal, Colors.black, 20),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      ListTile(
                        enabled: true,
                        tileColor: Color(0xFF1D2A3A),
                        contentPadding: EdgeInsets.all(10),
                        visualDensity: VisualDensity.compact,
                        leading: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            components().text(
                                "Date", FontWeight.normal, Colors.white, 16),
                            components()
                                .text(date, FontWeight.bold, Colors.white, 22)
                          ],
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            components().text(
                                "Time", FontWeight.normal, Colors.white, 16),
                            components()
                                .text(time, FontWeight.bold, Colors.white, 22)
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      components().text("Customer Name", FontWeight.normal,
                          Colors.black26, 16),
                      components().textField("Enter Customer Name",
                          TextInputType.name, _nameController),
                      const SizedBox(
                        height: 20,
                      ),
                      components().text("Customer Mobile Number",
                          FontWeight.normal, Colors.black26, 16),
                      components().textField("Enter Customer Mobile",
                          TextInputType.phone, _numberController),
                      Container(
                        padding: EdgeInsets.only(top: 1, bottom: 1),
                        child: DataTable(
                          columns: [
                            DataColumn(
                                label: components().text("Items",
                                    FontWeight.bold, Colors.black, 18)),
                            DataColumn(
                                label: components().text(
                                    "Qty", FontWeight.bold, Colors.black, 18)),
                            DataColumn(
                                label: components().text("Price",
                                    FontWeight.bold, Colors.black, 18)),
                          ],
                          rows: items
                              .map((e) => DataRow(cells: <DataCell>[
                                    DataCell(SizedBox(
                                      child: Text(e.items),
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    )),
                                    DataCell(SizedBox(
                                      child: Text(e.qty),
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                    )),
                                    DataCell(SizedBox(
                                      child: Text(e.price),
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                    )),
                                  ]))
                              .toList(),
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey, thickness: 1),
                      Container(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFF1D2A3A),
                            padding: EdgeInsets.all(3),
                            textStyle: const TextStyle(fontSize: 20),
                            shape: StadiumBorder(),
                            enableFeedback: true,
                          ),
                          child: Icon(Icons.add),
                          onPressed: () {
                            openDialog();
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 1, bottom: 1),
                        child: DataTable(
                          columns: [
                            DataColumn(
                                label: components().text("Addon Items",
                                    FontWeight.bold, Colors.black, 18)),
                            DataColumn(
                                label: components().text(
                                    "", FontWeight.bold, Colors.black, 18)),
                            DataColumn(
                                label: components().text(
                                    "", FontWeight.bold, Colors.black, 18)),
                          ],
                          rows: addon_items
                              .map((e) => DataRow(cells: <DataCell>[
                                    DataCell(SizedBox(
                                      child: Text(e.items),
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                    )),
                                    DataCell(SizedBox(
                                      child: Text(e.qty),
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                    )),
                                    DataCell(SizedBox(
                                      child: Text(e.price),
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                    )),
                                  ]))
                              .toList(),
                        ),
                      ),
                      const Divider(
                          height: 1, color: Colors.grey, thickness: 1),
                      Container(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFF1D2A3A),
                            padding: EdgeInsets.all(3),
                            textStyle: const TextStyle(fontSize: 20),
                            shape: StadiumBorder(),
                            enableFeedback: true,
                          ),
                          child: Icon(Icons.add),
                          onPressed: () {
                            addonDialog();
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 1, bottom: 1),
                        child: DataTable(dividerThickness: 0, columns: [
                          DataColumn(
                              label: components().text("Sub Total",
                                  FontWeight.normal, Colors.black, 18)),
                          DataColumn(
                              label: components()
                                  .text("", FontWeight.bold, Colors.black, 18)),
                          DataColumn(
                              label: components().text(sub_total.toString(),
                                  FontWeight.bold, Colors.black, 18)),
                        ], rows: [
                          DataRow(cells: [
                            DataCell(SizedBox(
                              child: Text("CGST"),
                              width: MediaQuery.of(context).size.width * 0.3,
                            )),
                            DataCell(SizedBox(
                              width: MediaQuery.of(context).size.width * 0.1,
                              child: TextField(
                                onChanged: (text) {
                                  setState(() {
                                    cgst = (sub_total *
                                            double.parse(
                                                _cgstController.text)) /
                                        100.toDouble();
                                    total = sub_total + cgst + sgst;
                                  });
                                },
                                keyboardType: TextInputType.number,
                                controller: _cgstController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black54)),
                                  hintText: "cgst",
                                ),
                              ),
                            )),
                            DataCell(SizedBox(
                              width: MediaQuery.of(context).size.width * 0.1,
                              child: components().text(cgst.toString(),
                                  FontWeight.normal, Colors.black, 16),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(SizedBox(
                              child: Text("SGST"),
                              width: MediaQuery.of(context).size.width * 0.3,
                            )),
                            DataCell((SizedBox(
                              width: MediaQuery.of(context).size.width * 0.1,
                              child: TextField(
                                onChanged: (text) {
                                  setState(() {
                                    sgst = (sub_total *
                                            double.parse(
                                                _sgstController.text)) /
                                        100.toDouble();
                                    total = sub_total + sgst + cgst;
                                  });
                                },
                                keyboardType: TextInputType.number,
                                controller: _sgstController,
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black54)),
                                  hintText: "sgst",
                                ),
                              ),
                            ))),
                            DataCell(SizedBox(
                              child: components().text(sgst.toString(),
                                  FontWeight.normal, Colors.black, 16),
                              width: MediaQuery.of(context).size.width * 0.1,
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(SizedBox(
                              child: components().text(
                                  "Total", FontWeight.bold, Colors.black, 22),
                              width: MediaQuery.of(context).size.width * 0.3,
                            )),
                            DataCell(SizedBox(
                                width: MediaQuery.of(context).size.width * 0.1,
                                child: Text(""))),
                            DataCell(SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: components().text(total.toString(),
                                  FontWeight.bold, Colors.black, 22),
                            )),
                          ]),
                        ]),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFF1D2A3A),
                            padding: EdgeInsets.all(3),
                            textStyle: TextStyle(fontSize: 20),
                            minimumSize: Size.fromHeight(50),
                            shape: StadiumBorder(),
                            enableFeedback: true,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  backgroundColor: Colors.transparent,
                                )
                              : const Text('Submit'),
                          onPressed: () async {
                            // final controller = ScreenshotController();
                            // final bytes = await controller.captureFromWidget(Material(
                            //   child: buildReceipt(receiptData(
                            //     customer_name: _nameController.text,
                            //     date: date,
                            //     time: time,
                            //     cgst_percent: _cgstController.text,
                            //     sgst_percent: _sgstController.text,
                            //     cgst: cgst.toString(),
                            //     sgst: sgst.toString(),
                            //     total: total.toString(),
                            //     bill_no: "123",
                            //     resturant_id: "1",
                            //     subtotal: sub_total.toString(),
                            //     items: items,
                            //     addon_items: addon_items),
                            //     widget.resturant),));
                            // setState(() {
                            //   this.bytes = bytes;
                            // });
                            SharedPreferences _prefs = await SharedPreferences.getInstance();
                            int bill_no = _prefs.getInt("billNo")! + 1;
                            if (isLoading) return;
                            setState(() => isLoading = true);
                            await SupaBaseHandler().insertData(
                                widget.resturant[0],
                                _nameController.text,
                                date,
                                time,
                                item,
                                addon_item,
                                _cgstController.text,
                                _sgstController.text,
                                cgst,
                                sgst,
                                total,
                                bill_no,
                                sub_total,
                              "Pending"
                            );
                            // await _connectDevice();
                            // print(_bluePrint.isConnected.toString());
                            // await _onPrintReceipt(
                            //     receiptData(
                            //         customer_name: _nameController.text,
                            //         date: date,
                            //         time: time,
                            //         cgst_percent: _cgstController.text,
                            //         sgst_percent: _sgstController.text,
                            //         cgst: cgst.toString(),
                            //         sgst: sgst.toString(),
                            //         total: total.toString(),
                            //         bill_no: "123",
                            //         resturant_id: "1",
                            //         subtotal: sub_total.toString(),
                            //         items: items,
                            //         addon_items: addon_items),
                            //     widget.resturant);
                            // _onDisconnectDevice();
                            // await SupaBaseHandler().updatePrintStatus("Printed", bill_no);
                            _prefs.setInt("billNo", bill_no);
                            // cgst = 0;
                            // sgst = 0;
                            // sub_total = 0;
                            // total = 0;
                            // // _nameController.clear();
                            // item.clear();
                            // items.clear();
                            // addon_items.clear();
                            // addon_item.clear();
                            // _numberController.clear();
                            // _itemnameController.clear();
                            // _itemqtyController.clear();
                            // _itempriceController.clear();
                            // _cgstController.clear();
                            // _sgstController.clear();
                            setState(() => isLoading = false);
                            // Navigator.of(context).pop();
                          },
                        ),
                      ),
                      // bytes == "" ? Container() : buildImage(bytes)
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

  Widget buildImage(Uint8List bytes) =>
      bytes != null ? Image.memory(bytes) : Container();

  Widget buildReceipt(receiptData element, List<String> element_r){
    return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              // padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 8),
                    components().text(
                        element_r[1],
                        FontWeight.bold,
                        Colors.black87,
                        18),
                    const SizedBox(
                      height: 5,
                    ),
                    components().text(
                        element_r[2],
                        FontWeight.normal,
                        Colors.black45,
                        10),
                    const SizedBox(
                      height: 3,
                    ),
                    components().text(
                        element_r[3],
                        FontWeight.normal,
                        Colors.black45,
                        10),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Divider(
                height: 0, color: Colors.grey, thickness: 1),
            Container(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              // width: double.maxFinite,
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      components().text(
                          element.customer_name,
                          FontWeight.normal,
                          Colors.black87,
                          13),
                      SizedBox(
                        height: 2,
                      ),
                      components().text(
                          "Bill No : " + element.bill_no,
                          FontWeight.normal,
                          Colors.black87,
                          13)
                    ],
                  ),
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      components().text(
                          element.date,
                          FontWeight.normal,
                          Colors.black45,
                          11),
                      SizedBox(
                        height: 2,
                      ),
                      components().text(element.time,
                          FontWeight.normal, Colors.black45, 11)
                    ],
                  ),
                ],
              ),
            ),
            Divider(
                height: 1, color: Colors.grey, thickness: 1),
            Container(
              padding: EdgeInsets.only(top: 1, bottom: 1),
              child: DataTable(
                dataRowHeight: 20,
                headingRowHeight: 25,
                columns: [
                  DataColumn(label: components().text("Items", FontWeight.bold, Colors.black, 11)),
                  DataColumn(label: components().text("Qty", FontWeight.bold, Colors.black, 11)),
                  DataColumn(label: components().text("Price", FontWeight.bold, Colors.black, 11)),
                ], rows: element.items.map((e) => DataRow(cells: <DataCell>[
                DataCell(SizedBox(
                  child: Text(e.items),
                  width: MediaQuery.of(context).size.width * 0.3,
                )),
                DataCell(SizedBox(
                  child: Text(e.qty),
                  width: MediaQuery.of(context).size.width * 0.1,
                )),
                DataCell(SizedBox(
                  child: Text(e.price),
                  width: MediaQuery.of(context).size.width * 0.1,
                )),
              ])).toList(),
              ),
            ),
            Divider(
                height: 1, color: Colors.grey, thickness: 1),
            Container(
              child: element.addon_items.isNotEmpty ? DataTable(
                headingRowHeight: 25,
                dataRowHeight: 20,
                columns: [
                  DataColumn(label: components().text("Addon Items", FontWeight.bold, Colors.black, 12)),
                  DataColumn(label: components().text("", FontWeight.bold, Colors.black, 11)),
                  DataColumn(label: components().text("", FontWeight.bold, Colors.black, 11)),
                ], rows: element.addon_items.map((e) => DataRow(cells: <DataCell>[
                DataCell(SizedBox(
                  child: Text(e.items),
                  width: MediaQuery.of(context).size.width * 0.3,
                )),
                DataCell(SizedBox(
                  child: Text(e.qty),
                  width: MediaQuery.of(context).size.width * 0.1,
                )),
                DataCell(SizedBox(
                  child: Text(e.price),
                  width: MediaQuery.of(context).size.width * 0.1,
                )),

              ])).toList(),
              ) : Container(),
            ),
            const Divider(
                height: 1, color: Colors.grey, thickness: 1),
            Container(
              child: DataTable(
                  dataRowHeight: 20,
                  headingRowHeight: 25,
                  dividerThickness: 0,
                  columns: [
                    DataColumn(label: components().text("Sub Total", FontWeight.normal, Colors.black, 12)),
                    DataColumn(label: components().text("", FontWeight.bold, Colors.black, 12)),
                    DataColumn(label: components().text(element.subtotal.toString(), FontWeight.bold, Colors.black, 12)),
                  ], rows: [
                DataRow(cells: [
                  DataCell(SizedBox(
                    child: Text("CGST"),
                    width: MediaQuery.of(context).size.width * 0.3,
                  )),
                  DataCell(SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: components().text(element.cgst_percent, FontWeight.normal, Colors.black, 11),
                  )),
                  DataCell(SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: components().text(element.cgst.toString(), FontWeight.normal, Colors.black, 11),
                  )),
                ]),
                DataRow(cells: [
                  DataCell(SizedBox(
                    child: Text("SGST"),
                    width: MediaQuery.of(context).size.width * 0.3,
                  )),
                  DataCell((SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: components().text(element.sgst_percent, FontWeight.normal, Colors.black, 11),
                  ))),
                  DataCell(SizedBox(
                    child: components().text(element.sgst.toString(), FontWeight.normal, Colors.black, 11),
                    width: MediaQuery.of(context).size.width * 0.1,
                  )),
                ]),
                DataRow(cells: [
                  DataCell(SizedBox(
                    child: components().text("Total", FontWeight.bold, Colors.black, 12),
                    width: MediaQuery.of(context).size.width * 0.3,
                  )),
                  DataCell(SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: Text("")
                  )),
                  DataCell(SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: components().text(element.total.toString(), FontWeight.bold, Colors.black, 12),
                  )),
                ]),
              ]
              ),
            ),
            const Divider(
                height: 1, color: Colors.grey, thickness: 1),
          ],
        )

    ;
  }

  Future<void> _onPrintReceipt(
      receiptData element, List<String> element_r) async {
    final ReceiptSectionText receiptSecondText = ReceiptSectionText();
    receiptSecondText.addImage(base64.encode(bytes));
    await _bluePrint.printReceiptImage(bytes);
  }

  Future openDialog() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: components()
                .text("Add Item", FontWeight.bold, Colors.black, 18),
            content: Container(
              // height: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  components()
                      .text("Item Name", FontWeight.normal, Colors.black26, 16),
                  components().textField(
                      "Item Name", TextInputType.name, _itemnameController),
                  SizedBox(
                    height: 20,
                  ),
                  components()
                      .text("Item Qty", FontWeight.normal, Colors.black26, 16),
                  components().textField("Enter Item Qty", TextInputType.number,
                      _itemqtyController),
                  SizedBox(
                    height: 20,
                  ),
                  components().text(
                      "Item Price", FontWeight.normal, Colors.black26, 16),
                  components().textField("Enter item Price",
                      TextInputType.number, _itempriceController),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF1D2A3A),
                    padding: EdgeInsets.all(3),
                    textStyle: TextStyle(fontSize: 18),
                    minimumSize: Size.fromHeight(40),
                    shape: StadiumBorder(),
                    enableFeedback: true,
                  ),
                  onPressed: () {
                    setState(() {
                      total_price = (int.parse(_itemqtyController.text) *
                              int.parse(_itempriceController.text))
                          .toString();
                      sub_total = sub_total +
                          (int.parse(_itemqtyController.text) *
                              int.parse(_itempriceController.text));
                      // sgst = ((sub_total*100)/2.5);
                      item.add([
                        _itemnameController.text.toString(),
                        _itemqtyController.text.toString(),
                        total_price.toString()
                      ]);
                      items.add(receiptsitems(
                          items: _itemnameController.text,
                          qty: _itemqtyController.text,
                          price: total_price));
                      _itemnameController.clear();
                      _itempriceController.clear();
                      _itemqtyController.clear();
                    });
                    // print(item);
                    Navigator.pop(context);
                  },
                  child: Text("Submit"))
            ],
          ));

  Future addonDialog() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: components()
                .text("Add Item", FontWeight.bold, Colors.black, 18),
            content: Container(
              // height: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  components()
                      .text("Item Name", FontWeight.normal, Colors.black26, 16),
                  components().textField(
                      "Item Name", TextInputType.name, _itemnameController),
                  SizedBox(
                    height: 20,
                  ),
                  components()
                      .text("Item Qty", FontWeight.normal, Colors.black26, 16),
                  components().textField("Enter Item Qty", TextInputType.number,
                      _itemqtyController),
                  SizedBox(
                    height: 20,
                  ),
                  components().text(
                      "Item Price", FontWeight.normal, Colors.black26, 16),
                  components().textField("Enter item Price",
                      TextInputType.number, _itempriceController),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF1D2A3A),
                    padding: EdgeInsets.all(3),
                    textStyle: TextStyle(fontSize: 18),
                    minimumSize: Size.fromHeight(40),
                    shape: StadiumBorder(),
                    enableFeedback: true,
                  ),
                  onPressed: () {
                    setState(() {
                      total_price = (int.parse(_itemqtyController.text) *
                              int.parse(_itempriceController.text))
                          .toString();
                      sub_total = sub_total +
                          (int.parse(_itemqtyController.text) *
                              int.parse(_itempriceController.text));
                      addon_item.add([
                        _itemnameController.text.toString(),
                        _itemqtyController.text.toString(),
                        total_price.toString()
                      ]);
                      addon_items.add(receiptsitems(
                          items: _itemnameController.text,
                          qty: _itemqtyController.text,
                          price: total_price));
                      _itemnameController.clear();
                      _itempriceController.clear();
                      _itemqtyController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Submit"))
            ],
          ));
}
