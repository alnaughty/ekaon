import 'package:flutter/material.dart';

class CartDetailsPage extends StatefulWidget {
  final Map cartDetail;
  final int index;
  CartDetailsPage({Key key, @required this.index, @required this.cartDetail}) : super(key : key);
  @override
  _CartDetailsPageState createState() => _CartDetailsPageState();
}

class _CartDetailsPageState extends State<CartDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
