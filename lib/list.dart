import 'dart:ffi';

class receiptData {
  String customer_name = "";
  String date = "";
  String time = "";
  List<receiptsitems> items = [];
  List<receiptsitems> addon_items = [];
  String cgst_percent = "";
  String sgst_percent = "";
  String cgst = "";
  String sgst = "";
  String total = "";
  String bill_no = "";
  String resturant_id = "";
  String subtotal = "";

  receiptData(
      {required this.customer_name, required this.date, required this.time, required this.cgst_percent, required this.sgst_percent, required this.cgst, required this.sgst, required this.total, required this.bill_no, required this.resturant_id, required this.subtotal, required this.items, required this.addon_items});

  @override
  String toString() {
    return "$customer_name\n$date\n$time\n${items.toString()}\n${addon_items
        .toString()}\n${cgst_percent
        .toString()}\n${sgst_percent.toString()}\n${cgst
        .toString()}\n${sgst.toString()}\n${total
        .toString()}\n${bill_no.toString()}\n${resturant_id.toString()}\n$subtotal";
  }
}

class receiptsitems{

  String items = "";
  String qty = "";
  String price = "";

  receiptsitems(
      {required this.items, required this.qty, required this.price});

  @override
  String toString() {
    return "$items\n$qty\n$price";
  }
  factory receiptsitems.fromJson(List<dynamic> json){
    print(json.length);
    return receiptsitems(items: "items", qty: "qty", price: "price");
    // return EventDeptData(name: json['name'], logo: json['logo'], poster: json['poster']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['items'] = this.items;
    data['qty'] = this.qty;
    data['price'] = this.price;

    return data;
  }
}

class resturants{

  String id = "";
  String resturant_name = "";
  String resturant_address = "";
  String resturant_mobile = "";
  String resturant_email = "";

  resturants({
    required this.id, required this.resturant_name, required this.resturant_address, required this.resturant_mobile, required this.resturant_email
  });

  @override
  String toString() {
    return "$id\n$resturant_name\n$resturant_address\n$resturant_mobile\n$resturant_email";
  }


}