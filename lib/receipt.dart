import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:receipt_generator_client/bluetoothDevicesScreen/bluetoothDevicesScreen.dart';
import 'package:receipt_generator_client/utils.dart';


import 'components.dart';
import 'list.dart';

class receipt extends StatefulWidget {
  final receiptData element;
  final List<String> element_r;

  const receipt({Key? key, required this.element, required this.element_r})
      : super(key: key);

  @override
  State<receipt> createState() => _receiptState();
}

class _receiptState extends State<receipt> {
  // BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  Uint8List bytes = Uint8List.fromList([0]);

  @override
  Widget build(BuildContext context) {
    final GlobalKey globalKey = GlobalKey();

    DateTime today = DateTime.now();
    String date = "${today.day}-${today.month}-${today.year}";
    String time = "${today.hour}:${today.minute}";
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: components()
              .text("Receipt Invoice", FontWeight.bold, Colors.black, 20),
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 20),
                child: InkWell(
                  onTap: () async {
                    final bytes = await Utils.capture(globalKey);
                    setState(() {
                      this.bytes = bytes;
                    });
                    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => bluetoothDevicesScreen(),));
                  },
                  child: Icon(Icons.save),
                ))
          ],
        ),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          reverse: true,
          child: LayoutBuilder(builder: (context, constraints) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 500),
              child: Column(
                children: [
                  RepaintBoundary(
                    key: globalKey,
                    child: Center(
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                              // padding: EdgeInsets.only(top: 20, bottom: 20),
                              child: Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 8),
                                    components().text(
                                        widget.element_r[1],
                                        FontWeight.bold,
                                        Colors.black87,
                                        18),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    components().text(
                                        widget.element_r[2],
                                        FontWeight.normal,
                                        Colors.black45,
                                        10),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    components().text(
                                        widget.element_r[3],
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
                                          widget.element.customer_name,
                                          FontWeight.normal,
                                          Colors.black87,
                                          13),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      components().text(
                                          "Bill No : " + widget.element.bill_no,
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
                                          widget.element.date,
                                          FontWeight.normal,
                                          Colors.black45,
                                          11),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      components().text(widget.element.time,
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
                                ], rows: widget.element.items.map((e) => DataRow(cells: <DataCell>[
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
                              child: widget.element.addon_items.isNotEmpty ? DataTable(
                                headingRowHeight: 25,
                                dataRowHeight: 20,
                                columns: [
                                  DataColumn(label: components().text("Addon Items", FontWeight.bold, Colors.black, 12)),
                                  DataColumn(label: components().text("", FontWeight.bold, Colors.black, 11)),
                                  DataColumn(label: components().text("", FontWeight.bold, Colors.black, 11)),
                                ], rows: widget.element.addon_items.map((e) => DataRow(cells: <DataCell>[
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
                                    DataColumn(label: components().text(widget.element.subtotal.toString(), FontWeight.bold, Colors.black, 12)),
                                  ], rows: [
                                DataRow(cells: [
                                  DataCell(SizedBox(
                                    child: Text("CGST"),
                                    width: MediaQuery.of(context).size.width * 0.3,
                                  )),
                                  DataCell(SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.1,
                                    child: components().text(widget.element.cgst_percent, FontWeight.normal, Colors.black, 11),
                                  )),
                                  DataCell(SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.1,
                                    child: components().text(widget.element.cgst.toString(), FontWeight.normal, Colors.black, 11),
                                  )),
                                ]),
                                DataRow(cells: [
                                  DataCell(SizedBox(
                                    child: Text("SGST"),
                                    width: MediaQuery.of(context).size.width * 0.3,
                                  )),
                                  DataCell((SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.1,
                                    child: components().text(widget.element.sgst_percent, FontWeight.normal, Colors.black, 11),
                                  ))),
                                  DataCell(SizedBox(
                                    child: components().text(widget.element.sgst.toString(), FontWeight.normal, Colors.black, 11),
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
                                    child: components().text(widget.element.total.toString(), FontWeight.bold, Colors.black, 12),
                                  )),
                                ]),
                              ]
                              ),
                            ),
                            const Divider(
                                height: 1, color: Colors.grey, thickness: 1),
                            // Container(
                            //   padding:
                            //       EdgeInsets.only(left: 0, top: 5, right: 0),
                            //   // width: double.maxFinite,
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       components().text("Delivery Details",
                            //           FontWeight.normal, Colors.black87, 12),
                            //       const SizedBox(
                            //         height: 3,
                            //       ),
                            //       Row(
                            //           mainAxisAlignment:
                            //               MainAxisAlignment.spaceBetween,
                            //           children: [
                            //             components().text(
                            //                 "Dhairya Soni",
                            //                 FontWeight.normal,
                            //                 Colors.black45,
                            //                 11),
                            //             components().text(
                            //                 "1234567890",
                            //                 FontWeight.normal,
                            //                 Colors.black45,
                            //                 11),
                            //           ]),
                            //       const SizedBox(
                            //         height: 3,
                            //       ),
                            //       components().text(
                            //           "104, Ashirwad Appartment, Near Rajnagar Busstop, Paldi Ahmedabad",
                            //           FontWeight.normal,
                            //           Colors.black45,
                            //           11),
                            //       const SizedBox(
                            //         height: 3,
                            //       ),
                            //       components().text(
                            //           "Place it outside the door only",
                            //           FontWeight.normal,
                            //           Colors.black87,
                            //           12),
                            //     ],
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 5,
                            // ),
                            // Container(
                            //   // padding: EdgeInsets.only(left: 5, right: 5),
                            //   // width: double.maxFinite,
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       components().text("Delivery Person Info",
                            //           FontWeight.normal, Colors.black87, 12),
                            //       SizedBox(
                            //         height: 3,
                            //       ),
                            //       Row(
                            //           mainAxisAlignment:
                            //               MainAxisAlignment.spaceBetween,
                            //           children: [
                            //             components().text(
                            //                 "Rohan Shah",
                            //                 FontWeight.normal,
                            //                 Colors.black45,
                            //                 11),
                            //             components().text(
                            //                 "1234567890",
                            //                 FontWeight.normal,
                            //                 Colors.black45,
                            //                 11),
                            //           ]),
                            //       SizedBox(
                            //         height: 6,
                            //       ),
                            //       Align(
                            //         alignment: Alignment.bottomCenter,
                            //         child: components().text(
                            //             "Thank You for purchasing",
                            //             FontWeight.normal,
                            //             Colors.black87,
                            //             12),
                            //       )
                            //     ],
                            //   ),
                            // ),
                            // const DottedLine(
                            //   direction: Axis.horizontal,
                            //   dashColor: Colors.black,
                            //   dashGapColor: Colors.white,
                            //   dashGapLength: 2.0,
                            // ),
                            const SizedBox(
                              height: 2,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  bytes == "" ? Container() : buildImage(bytes)
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget buildImage(Uint8List bytes) =>
      bytes != null ? Image.memory(bytes) : Container();

  // Future<void> printDoc(date, time, bytes) async {
  //   final doc = pw.Document();
  //   // doc.addPage(pw.Page(
  //   //     pageFormat: PdfPageFormat.roll80,
  //   //     // PdfPageFormat(8 * PdfPageFormat.cm, 20 * PdfPageFormat.cm, marginAll: 0.5 * PdfPageFormat.cm),
  //   //     margin: pw.EdgeInsets.zero,
  //   //     build: (context) {
  //   //       return buildPrintableData(date, time, list);
  //   //     }));
  //   doc.addPage(pw.Page(
  //       margin: pw.EdgeInsets.zero,
  //       pageFormat: PdfPageFormat.roll80,
  //       build: (context) {
  //         return pw.Image(pw.MemoryImage(bytes));
  //       }));
  //
  //   List<LineText> list1 = [];
  //   String base64Image = base64Encode(bytes);
  //   list1.add(LineText(
  //     type: LineText.TYPE_IMAGE,
  //     x: 10,
  //     y: 10,
  //     content: base64Image,
  //   ));
  //
  //   // await GallerySaver.saveImage(bytes, toDcim: true);
  //
  //   // Map<String, dynamic> config = Map();
  //   // await bluetoothPrint.printReceipt(config,list1);
  //
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => bluetoothDevicesScreen(
  //                 list: list1,
  //                 bytes: bytes,
  //               )));
  //
  //   // Navigator.push(context,
  //   //     MaterialPageRoute(builder: (context) => previewScreen(doc:doc,list: list1,)));
  // }

  // Widget buildListWithScroll(List items, List qty, List price) {
  //   return Column(
  //     children: items.map((e) => buildList(e)).toList(),
  //   );
  // }

  Widget buildList(receiptsitems items) {
    return Container(
      padding: EdgeInsets.only(top: 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            // padding: EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                components().text(
                    items.items, FontWeight.normal, Colors.black, 12),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                components().text(items.qty,
                    FontWeight.normal, Colors.black, 12),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                components().text(items.price, FontWeight.normal,
                    Colors.black, 12),
              ],
            ),
          )
        ],
      ),
    );
  }
}
