import 'package:flutter/material.dart';

import '../components.dart';
import '../list.dart';
import '../supabasehandler.dart';
import 'body.dart';

class receiptList extends StatefulWidget {

  final int resturant_id;
  // final resturant;
  final List<String> resturant;

  const receiptList(
      {Key? key, required this.resturant_id, required this.resturant})
      : super(key: key);

  @override
  State<receiptList> createState() => _receiptListState();
}

class _receiptListState extends State<receiptList> {

  List<receiptData> receiptdata = [];
  List<receiptData> resturants_receipt = [];
  bool isloading = true;

  @override
  void initState() {
    receiptdata.clear();
    resturants_receipt.clear();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // print(resturants_receipt);
    bool isDataFound = true;
    final data = SupaBaseHandler().readreceiptData(widget.resturant_id).then((value) {
      setState(() {
        // print(value);
        if(value == null){
          isDataFound = false;
        }
        resturants_receipt = value!;
        isDataFound = true;

      });
    });


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
                },
                child: Icon(Icons.save),
              ))
        ],
      ),
      body: FutureBuilder(
        future: data,
        builder: (context, snapshot) {
          // print(data);
          if (resturants_receipt.isNotEmpty) {
            return body(
              resturant_id: widget.resturant_id.toString(),resturant: widget.resturant,);
          }
          else if(isDataFound == false){
            return Center(child: components().text("No Data Found", FontWeight.bold, Colors.black, 28),);
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );

  }
}
