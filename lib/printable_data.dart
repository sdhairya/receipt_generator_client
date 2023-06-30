//
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:receipt_generator_client/utils.dart';
//
// import 'components.dart';
// import 'list.dart';
//
// Widget buildReceipt(receiptData element, List<String> element_r){
//   return Column(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Container(
//         // padding: EdgeInsets.only(top: 20, bottom: 20),
//         child: Center(
//           child: Column(
//             children: [
//               SizedBox(height: 8),
//               components().text(
//                   element_r[1],
//                   FontWeight.bold,
//                   Colors.black87,
//                   18),
//               const SizedBox(
//                 height: 5,
//               ),
//               components().text(
//                   element_r[2],
//                   FontWeight.normal,
//                   Colors.black45,
//                   10),
//               const SizedBox(
//                 height: 3,
//               ),
//               components().text(
//                   element_r[3],
//                   FontWeight.normal,
//                   Colors.black45,
//                   10),
//               SizedBox(height: 8),
//             ],
//           ),
//         ),
//       ),
//       Divider(
//           height: 0, color: Colors.grey, thickness: 1),
//       Container(
//         padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
//         // width: double.maxFinite,
//         child: Row(
//           mainAxisAlignment:
//           MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment:
//               CrossAxisAlignment.start,
//               children: [
//                 components().text(
//                     element.customer_name,
//                     FontWeight.normal,
//                     Colors.black87,
//                     13),
//                 SizedBox(
//                   height: 2,
//                 ),
//                 components().text(
//                     "Bill No : " + element.bill_no,
//                     FontWeight.normal,
//                     Colors.black87,
//                     13)
//               ],
//             ),
//             Column(
//               crossAxisAlignment:
//               CrossAxisAlignment.start,
//               children: [
//                 components().text(
//                     element.date,
//                     FontWeight.normal,
//                     Colors.black45,
//                     11),
//                 SizedBox(
//                   height: 2,
//                 ),
//                 components().text(element.time,
//                     FontWeight.normal, Colors.black45, 11)
//               ],
//             ),
//           ],
//         ),
//       ),
//       Divider(
//           height: 1, color: Colors.grey, thickness: 1),
//       Container(
//         padding: EdgeInsets.only(top: 1, bottom: 1),
//         child: DataTable(
//           dataRowHeight: 20,
//           headingRowHeight: 25,
//           columns: [
//             DataColumn(label: components().text("Items", FontWeight.bold, Colors.black, 11)),
//             DataColumn(label: components().text("Qty", FontWeight.bold, Colors.black, 11)),
//             DataColumn(label: components().text("Price", FontWeight.bold, Colors.black, 11)),
//           ], rows: element.items.map((e) => DataRow(cells: <DataCell>[
//           DataCell(SizedBox(
//             child: Text(e.items),
//             width: MediaQuery.of(context).size.width * 0.3,
//           )),
//           DataCell(SizedBox(
//             child: Text(e.qty),
//             width: MediaQuery.of(context).size.width * 0.1,
//           )),
//           DataCell(SizedBox(
//             child: Text(e.price),
//             width: MediaQuery.of(context).size.width * 0.1,
//           )),
//         ])).toList(),
//         ),
//       ),
//       Divider(
//           height: 1, color: Colors.grey, thickness: 1),
//       Container(
//         child: element.addon_items.isNotEmpty ? DataTable(
//           headingRowHeight: 25,
//           dataRowHeight: 20,
//           columns: [
//             DataColumn(label: components().text("Addon Items", FontWeight.bold, Colors.black, 12)),
//             DataColumn(label: components().text("", FontWeight.bold, Colors.black, 11)),
//             DataColumn(label: components().text("", FontWeight.bold, Colors.black, 11)),
//           ], rows: element.addon_items.map((e) => DataRow(cells: <DataCell>[
//           DataCell(SizedBox(
//             child: Text(e.items),
//             width: MediaQuery.of(context).size.width * 0.3,
//           )),
//           DataCell(SizedBox(
//             child: Text(e.qty),
//             width: MediaQuery.of(context).size.width * 0.1,
//           )),
//           DataCell(SizedBox(
//             child: Text(e.price),
//             width: MediaQuery.of(context).size.width * 0.1,
//           )),
//
//         ])).toList(),
//         ) : Container(),
//       ),
//       const Divider(
//           height: 1, color: Colors.grey, thickness: 1),
//       Container(
//         child: DataTable(
//             dataRowHeight: 20,
//             headingRowHeight: 25,
//             dividerThickness: 0,
//             columns: [
//               DataColumn(label: components().text("Sub Total", FontWeight.normal, Colors.black, 12)),
//               DataColumn(label: components().text("", FontWeight.bold, Colors.black, 12)),
//               DataColumn(label: components().text(element.subtotal.toString(), FontWeight.bold, Colors.black, 12)),
//             ], rows: [
//           DataRow(cells: [
//             DataCell(SizedBox(
//               child: Text("CGST"),
//               width: MediaQuery.of(context).size.width * 0.3,
//             )),
//             DataCell(SizedBox(
//               width: MediaQuery.of(context).size.width * 0.1,
//               child: components().text(element.cgst_percent, FontWeight.normal, Colors.black, 11),
//             )),
//             DataCell(SizedBox(
//               width: MediaQuery.of(context).size.width * 0.1,
//               child: components().text(element.cgst.toString(), FontWeight.normal, Colors.black, 11),
//             )),
//           ]),
//           DataRow(cells: [
//             DataCell(SizedBox(
//               child: Text("SGST"),
//               width: MediaQuery.of(context).size.width * 0.3,
//             )),
//             DataCell((SizedBox(
//               width: MediaQuery.of(context).size.width * 0.1,
//               child: components().text(element.sgst_percent, FontWeight.normal, Colors.black, 11),
//             ))),
//             DataCell(SizedBox(
//               child: components().text(element.sgst.toString(), FontWeight.normal, Colors.black, 11),
//               width: MediaQuery.of(context).size.width * 0.1,
//             )),
//           ]),
//           DataRow(cells: [
//             DataCell(SizedBox(
//               child: components().text("Total", FontWeight.bold, Colors.black, 12),
//               width: MediaQuery.of(context).size.width * 0.3,
//             )),
//             DataCell(SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.1,
//                 child: Text("")
//             )),
//             DataCell(SizedBox(
//               width: MediaQuery.of(context).size.width * 0.1,
//               child: components().text(element.total.toString(), FontWeight.bold, Colors.black, 12),
//             )),
//           ]),
//         ]
//         ),
//       ),
//       const Divider(
//           height: 1, color: Colors.grey, thickness: 1),
//     ],
//   )
//
//   ;
// }
//
