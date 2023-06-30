import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

import '../components.dart';
import '../list.dart';
import '../receipt.dart';
import '../supabasehandler.dart';

class body extends StatefulWidget {

  // final List<receiptData> resturants_receipt;
  // final resturants resturant;
  final String resturant_id;
  final List<String> resturant;
  const body({Key? key, required this.resturant_id, required this.resturant}) : super(key: key);

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

  final _stream = SupaBaseHandler().client.from("receipt_details").stream(primaryKey: ['id']).eq("resturant_id", 1);

  @override
  Widget build(BuildContext context) {
    SupaBaseHandler().client.from("receipt_details").stream(primaryKey: ['id']).eq("resturant_id", int.parse(widget.resturant_id)).listen((List<Map<String, dynamic>> data) {
        setState(() {
          resturants_receipt = SupaBaseHandler().parse_filterData(data);
        });

      // buildListWithScroll(resturants_receipt);
    });
    return buildListWithScroll(resturants_receipt);

  }

  print(List<receiptData> receipts){

    for(var e in receipts){

    }

  }

  Widget buildListWithScroll(List<receiptData> receipts) {
    return Column(
      children: receipts.map((e) => buildList(e)).toList(),
    );
  }

  Widget buildList(receiptData element) {
    return
      InkWell(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 15),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(border: Border.all(width: 1),borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            components().text(
                "Bill No: "+element.bill_no, FontWeight.normal, Colors.black54, 18),
            SizedBox(height: 6,),

            components().text("Customer Name: "+element.customer_name, FontWeight.normal, Colors.black87, 20)

          ],
        ),
      ),
      onTap: () {
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => receiptList(resturant_id: widget.resturantsdata.indexOf(element)+1,)));

        Navigator.push(context,
            MaterialPageRoute(builder: (context) => receipt(element: element, element_r: widget.resturant)));
      },
    )
    ;
  }

}
