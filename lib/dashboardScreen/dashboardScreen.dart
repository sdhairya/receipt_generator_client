import 'package:flutter/material.dart';

import 'body.dart';


class dashboardScreen extends StatefulWidget {

  final List<String> resturant;

  const dashboardScreen({Key? key, required this.resturant}) : super(key: key);

  @override
  State<dashboardScreen> createState() => _dashboardScreenState();
}

class _dashboardScreenState extends State<dashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return body(resturant: widget.resturant,);
  }
}
