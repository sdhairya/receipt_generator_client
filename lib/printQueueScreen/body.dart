import 'dart:convert';
import 'dart:typed_data';

import 'package:blue_print_pos/blue_print_pos.dart';
import 'package:blue_print_pos/models/blue_device.dart';
import 'package:blue_print_pos/models/connection_status.dart';
import 'package:blue_print_pos/receipt/receipt_section_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:supabase/supabase.dart';

import '../components.dart';
import '../list.dart';
import '../receipt.dart';
import '../supabasehandler.dart';

class body extends StatefulWidget {
  // final List<receiptData> resturants_receipt;
  // // final resturants resturant;
  // final String resturant_id;
  final List<String> resturant;
  final BlueDevice printer;

  const body({Key? key, required this.resturant, required this.printer})
      : super(key: key);

  @override
  State<body> createState() => _bodyState();
}

class _bodyState extends State<body> {
  @override
  void initState() {
    super.initState();
  }

  List<receiptData> receiptdata = [];
  List<receiptData> resturants_receipt = [];
  Uint8List bytes = Uint8List.fromList([0]);
  List<int> billNo = [];
  int n = 0;
  final BluePrintPos _bluePrint = BluePrintPos.instance;

  @override
  Widget build(BuildContext context) {
    SupaBaseHandler()
        .client
        .from("receipt_details")
        .stream(primaryKey: ['id'])
        .eq("print_status", "Pending")
        .listen((List<Map<String, dynamic>> data) async {
          setState(() {
            resturants_receipt = SupaBaseHandler().parse_filterData(data);
          });
          // buildListWithScroll(resturants_receipt);
        });

    if (resturants_receipt.isEmpty) {
      setState(() {
        billNo = [];
      });
    } else if (resturants_receipt.isNotEmpty) {
      buildReceiptImage(resturants_receipt);
    }
    return buildListWithScroll(resturants_receipt);
  }

  Future<void> buildReceiptImage(List<receiptData> receipts) async {
    print("HELLO");
    print(receiptdata.length);
    if (billNo.contains(int.parse(receipts[0].bill_no))) {
    } else {
      for (var e in receipts) {
        final controller = ScreenshotController();
        final bytes = await controller.captureFromWidget(
            Material(child: buildReceipt(e, widget.resturant)));
        setState(() {
          this.bytes = bytes;
        });

        setState(() {
          billNo.add(int.parse(e.bill_no));
        });
        print(e.bill_no);
        await _connectDevice();
        await _onPrintReceipt(e, widget.resturant);
        _onDisconnectDevice();
        await SupaBaseHandler()
            .updatePrintStatus("Printed", int.parse(e.bill_no));
      }

    }

  }

  Future<void> _connectDevice() async {
    await _bluePrint.connect(widget.printer).then((ConnectionStatus status) {
      if (status == ConnectionStatus.connected) {
        print("Connected");
        print(_bluePrint.isConnected.toString());
      } else if (status == ConnectionStatus.timeout) {
        print("Not Connected");
      } else {
        if (kDebugMode) {
          print('$runtimeType - something wrong');
        }
      }
    });
  }

  void _onDisconnectDevice() {
    _bluePrint.disconnect().then((ConnectionStatus status) {
      if (status == ConnectionStatus.disconnect) {
        setState(() {});
      }
    });
  }

  Widget buildReceipt(receiptData element, List<String> element_r) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          // padding: EdgeInsets.only(top: 20, bottom: 20),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 8),
                components()
                    .text(element_r[1], FontWeight.bold, Colors.black87, 18),
                const SizedBox(
                  height: 5,
                ),
                components()
                    .text(element_r[2], FontWeight.normal, Colors.black45, 10),
                const SizedBox(
                  height: 3,
                ),
                components()
                    .text(element_r[3], FontWeight.normal, Colors.black45, 10),
                SizedBox(height: 8),
              ],
            ),
          ),
        ),
        Divider(height: 0, color: Colors.grey, thickness: 1),
        Container(
          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
          // width: double.maxFinite,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  components().text(element.customer_name, FontWeight.normal,
                      Colors.black87, 13),
                  SizedBox(
                    height: 2,
                  ),
                  components().text("Bill No : " + element.bill_no,
                      FontWeight.normal, Colors.black87, 13)
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  components().text(
                      element.date, FontWeight.normal, Colors.black45, 11),
                  SizedBox(
                    height: 2,
                  ),
                  components()
                      .text(element.time, FontWeight.normal, Colors.black45, 11)
                ],
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey, thickness: 1),
        Container(
          padding: EdgeInsets.only(top: 1, bottom: 1),
          child: DataTable(
            dataRowHeight: 20,
            headingRowHeight: 25,
            columns: [
              DataColumn(
                  label: components()
                      .text("Items", FontWeight.bold, Colors.black, 11)),
              DataColumn(
                  label: components()
                      .text("Qty", FontWeight.bold, Colors.black, 11)),
              DataColumn(
                  label: components()
                      .text("Price", FontWeight.bold, Colors.black, 11)),
            ],
            rows: element.items
                .map((e) => DataRow(cells: <DataCell>[
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
                    ]))
                .toList(),
          ),
        ),
        Divider(height: 1, color: Colors.grey, thickness: 1),
        Container(
          child: element.addon_items.isNotEmpty
              ? DataTable(
                  headingRowHeight: 25,
                  dataRowHeight: 20,
                  columns: [
                    DataColumn(
                        label: components().text(
                            "Addon Items", FontWeight.bold, Colors.black, 12)),
                    DataColumn(
                        label: components()
                            .text("", FontWeight.bold, Colors.black, 11)),
                    DataColumn(
                        label: components()
                            .text("", FontWeight.bold, Colors.black, 11)),
                  ],
                  rows: element.addon_items
                      .map((e) => DataRow(cells: <DataCell>[
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
                          ]))
                      .toList(),
                )
              : Container(),
        ),
        const Divider(height: 1, color: Colors.grey, thickness: 1),
        Container(
          child: DataTable(
              dataRowHeight: 20,
              headingRowHeight: 25,
              dividerThickness: 0,
              columns: [
                DataColumn(
                    label: components().text(
                        "Sub Total", FontWeight.normal, Colors.black, 12)),
                DataColumn(
                    label: components()
                        .text("", FontWeight.bold, Colors.black, 12)),
                DataColumn(
                    label: components().text(element.subtotal.toString(),
                        FontWeight.bold, Colors.black, 12)),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(SizedBox(
                    child: Text("CGST"),
                    width: MediaQuery.of(context).size.width * 0.3,
                  )),
                  DataCell(SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: components().text(element.cgst_percent,
                        FontWeight.normal, Colors.black, 11),
                  )),
                  DataCell(SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: components().text(element.cgst.toString(),
                        FontWeight.normal, Colors.black, 11),
                  )),
                ]),
                DataRow(cells: [
                  DataCell(SizedBox(
                    child: Text("SGST"),
                    width: MediaQuery.of(context).size.width * 0.3,
                  )),
                  DataCell((SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: components().text(element.sgst_percent,
                        FontWeight.normal, Colors.black, 11),
                  ))),
                  DataCell(SizedBox(
                    child: components().text(element.sgst.toString(),
                        FontWeight.normal, Colors.black, 11),
                    width: MediaQuery.of(context).size.width * 0.1,
                  )),
                ]),
                DataRow(cells: [
                  DataCell(SizedBox(
                    child: components()
                        .text("Total", FontWeight.bold, Colors.black, 12),
                    width: MediaQuery.of(context).size.width * 0.3,
                  )),
                  DataCell(SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: Text(""))),
                  DataCell(SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: components().text(element.total.toString(),
                        FontWeight.bold, Colors.black, 12),
                  )),
                ]),
              ]),
        ),
        const Divider(height: 1, color: Colors.grey, thickness: 1),
      ],
    );
  }

  Future<void> _onPrintReceipt(
      receiptData element, List<String> element_r) async {
    final ReceiptSectionText receiptSecondText = ReceiptSectionText();
    receiptSecondText.addImage(base64.encode(bytes));
    await _bluePrint.printReceiptImage(bytes);
  }

  Widget buildListWithScroll(List<receiptData> receipts) {
    return Column(
      children: receipts.map((e) => buildList(e)).toList(),
    );
  }

  Widget buildList(receiptData element) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 10, bottom: 10, left: 15),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
          border: Border.all(width: 1),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          components().text("Bill No: " + element.bill_no, FontWeight.normal,
              Colors.black54, 18),
          SizedBox(
            height: 6,
          ),
          components().text("Customer Name: " + element.customer_name,
              FontWeight.normal, Colors.black87, 20)
        ],
      ),
    );
  }
}
