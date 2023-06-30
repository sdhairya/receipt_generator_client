import 'package:supabase/supabase.dart';

import 'list.dart';

class SupaBaseHandler {
  static String supabaseUrl = "https://xnibmxheuavdtnuliliq.supabase.co";
  static String supabaseKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhuaWJteGhldWF2ZHRudWxpbGlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE2NzIyMDc0MDQsImV4cCI6MTk4Nzc4MzQwNH0.WvDrnyCtEKAlJDV0mqTrNiXD2ZPQgyAeyoS5JOsWz-c";

  final client = SupabaseClient(supabaseUrl, supabaseKey);

  Future updatePrintStatus(String print_status, int bill_no) async {

    var response =
    await client
        .from('receipt_details')
        .update({ 'print_status': print_status })
        .match({ 'bill_no': bill_no });

    return response;


  }

  Future<List<receiptData>?> readreceiptData(int resturant_id) async {
    // print(resturant_id);
    var response_receipt = await client
        .from("receipt_details")
        .select(
            '''id, resturant_id, customer_name, billing_date, billing_time, items, addon_items,cgst_percent, sgst_percent, cgst, sgst, total, bill_no, subtotal''')
        .eq("resturant_id", resturant_id)
        .execute();
    List<receiptData> listReceipt = [];
    // print(response_receipt.data);
    final receipt_details = response_receipt.data as List;
    receipt_details
        .forEach((element) => listReceipt.add(getreceiptData(element)));

    if (listReceipt.isEmpty) {
      return null;
    }
    return listReceipt;
  }

  authUser(email, password) async {
    var response_resturant = await client.from("resturant_master").select(
        '''id, resturant_name, resturant_address, resturant_mobile, resturant_email, resturant_password''').match({
      "resturant_email": email,
      "resturant_password": password
    }).execute();
    // print(response_resturant.data);
    List response = response_resturant.data as List;
    List<String> resturant = [];
    if (response.isEmpty) {
      return null;
    }
    resturant.add(response[0]['id'].toString());
    resturant.add(response[0]['resturant_name'].toString());
    resturant.add(response[0]['resturant_address'].toString());
    resturant.add(response[0]['resturant_mobile'].toString());
    // print(resturant);
    return resturant;
  }

  Future insertData(
      resturant_id,
      customer_name,
      billing_date,
      billing_time,
      items,
      addon_items,
      cgst_percent,
      sgst_percent,
      cgst,
      sgst,
      total,
      bill_no,
      subtotal,
      print_status) async {
    // print(jsonEncode(items));

    var response = await client.from("receipt_details").insert({
      "customer_name": customer_name,
      "billing_date": billing_date,
      "billing_time": billing_time,
      "items": items,
      "addon_items": addon_items,
      "cgst_percent": cgst_percent.toString(),
      "sgst_percent": sgst_percent.toString(),
      "cgst": cgst.toString(),
      "sgst": sgst,
      "total": total,
      "bill_no": bill_no,
      "resturant_id": resturant_id,
      "subtotal": subtotal,
      "print_status": print_status
    }).execute();
    print(response.data);
  }

  parse_filterData(data) {
    List<receiptData> listReceipt = [];
    final receipt_details = data as List;
    receipt_details
        .forEach((element) => listReceipt.add(getreceiptData(element)));
    return listReceipt;
  }

  parse_filterDataResturants(data) {
    List<resturants> rest = [];
    List<resturants> listResturants = [];
    final rests = data as List;
    rests.forEach((element) => listResturants.add(getresturantData(element)));
    return listResturants;
  }

  Future<List<resturants>> readresturantData(id) async {
    var response_resturant = await client.from("resturant_master").select(
        '''id, resturant_name, resturant_address, resturant_mobile, resturant_email''').execute();
    final resturant_details = response_resturant.data as List;
    List<resturants> listresturants = [];
    resturant_details.forEach((e) => listresturants.add(getresturantData(e)));
    return listresturants;
  }

  resturants getresturantData(Map<String, dynamic> record) {
    resturants object = resturants(
        id: record['id'],
        resturant_name: record['resturant_name'],
        resturant_address: record['resturant_address'],
        resturant_mobile: record['resturant_mobile'],
        resturant_email: record['resturant_email']);

    return object;
  }

  receiptData getreceiptData(Map<String, dynamic> record) {
    receiptData object = receiptData(
        customer_name: record['customer_name'],
        date: record['billing_date'],
        time: record['billing_time'],
        cgst_percent: record['cgst_percent'].toString(),
        sgst_percent: record['sgst_percent'].toString(),
        cgst: record['cgst'].toString(),
        sgst: record['sgst'].toString(),
        total: record['total'].toString(),
        bill_no: record['bill_no'].toString(),
        subtotal: record['subtotal'].toString(),
        resturant_id: record['resturant_id'].toString(),
        items: getItemsList(record['items'], 'items'),
        addon_items: getItemsList(record['addon_items'], 'addon_items'));

    return object;
  }

  List<receiptsitems> getItemsList(records, String item) {
    List<receiptsitems> listitems = [];
    // print(records);
    if (records == null) return [];
    records.forEach((e) => listitems.add(getitems(e)));
    return listitems;
  }

  receiptsitems getitems(records) {
    receiptsitems object =
        receiptsitems(items: records[0], qty: records[1], price: records[2]);
    return object;
  }
}
