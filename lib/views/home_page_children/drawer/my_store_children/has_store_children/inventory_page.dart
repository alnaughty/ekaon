import 'dart:io';
import 'dart:math';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/services/inventory_helper.dart';
import 'package:ekaon/services/order.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class PieChartData {
  final String product;
  final double total;
  final quantity;
  final Color color;

  PieChartData({this.product, this.total, this.color, this.quantity});
}
class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
//  List<charts.Series> seriesList;
  List<charts.Series<PieChartData, dynamic>> _seriesPieDataList = [];
  List<charts.Series<PieChartData, dynamic>> _seriesPieDataListTotal = [];
  bool animate = true;
  DateTime chosenDate = DateTime.now();
  List toGraph;
  DateTime maxDate;
  List _orderData;
//  List fGraph;
  getData() async {
    setState(() {
      _orderData = null;
    });
    await Order().orderDate(storeId: myStoreDetails['id'],date: chosenDate.toString().split(" ")[0]).then((value) async {
      if(value != null){
        setState(() {
          toGraph = null;
          _seriesPieDataList.clear();
          _seriesPieDataListTotal.clear();
          _orderData = value;
          toGraph = InventoryHelper(data: _orderData).traverse();
          print(toGraph);
          List<PieChartData> pieData = [];
          List<PieChartData> pieDataTotal = [];
          for(var data in toGraph){
            pieData.add(new PieChartData(product: data['name'], quantity: data['quantity'], total: double.parse(data['total'].toString()), color: Colors.primaries[Random().nextInt(Colors.primaries.length)]));
            pieDataTotal.add(new PieChartData(product: data['name'], quantity: data['quantity'], total: double.parse(data['total'].toString()), color: Colors.primaries[Random().nextInt(Colors.primaries.length)]));
          }
          _seriesPieDataList.add(
              charts.Series(
                  data: pieData,
                  domainFn: (PieChartData data, _) => '${data.product} = ${data.quantity}',
                  measureFn: (PieChartData data, _) => data.quantity,
                  colorFn: (PieChartData data, _) => charts.ColorUtil.fromDartColor(data.color),
                  id: "Daily sales",
                  labelAccessorFn: (PieChartData data, _) => '${data.quantity}'
              )
          );
          _seriesPieDataListTotal.add(
              charts.Series(
                  data: pieDataTotal,
                  domainFn: (PieChartData data, _) => '${data.product} = ${data.total.toStringAsFixed(2)}',
                  measureFn: (PieChartData data, _) => data.total,
                  colorFn: (PieChartData data, _) => charts.ColorUtil.fromDartColor(data.color),
                  id: "Daily sales",
                  labelAccessorFn: (PieChartData data, _) => '${data.total.toStringAsFixed(2)}'
              )
          );
        });
        print("GRAPH : $toGraph");

//        if(value != null){
//          _seriesPieDataList.clear();
//        }
//        if(value != null){
//          setState(() {
//            toGraph = InventoryHelper(data: orderData).getProductIds();
////            fGraph = InventoryHelper(data: orderData).getProductIds();
//            if(toGraph.length > 0){
//              if(chosenDate == DateTime.now()){
//                maxDate = DateTime.now();
//              }else{
////                maxDate = DateTime.parse(formattedString)
//                print("calculating");
//                maxDate = DateTime.parse("${chosenDate.toString().split(" ")[0]} ${InventoryHelper().getStatistical(toGraph,type: 'time', statType: 2).toString().split(' ')[1]}");
//              }
//              print("DATE : $maxDate");
//              graphResult = InventoryHelper().getGraph(data : toGraph, date: maxDate);
//            }
//          });
//        }
//        .then((val) {
//
//        });

      }
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    SystemChrome.setPreferredOrientations([
//      DeviceOrientation.landscapeLeft,
//      DeviceOrientation.landscapeRight
//    ]);
    getData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: Platform.isIOS,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Sales Statistics",style: TextStyle(
          color: Colors.black54
        ),),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.black54
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.date_range), onPressed: () async {
            DatePicker.showDatePicker(
              context,
              minTime: DateTime(2020,01,01),
              maxTime: DateTime.now(),
              onConfirm: (date){
                print(date);
                print("Now : ${date.toString().split(" ")[0] == chosenDate.toString().split(" ")[0]}");
                if(date != null && date.toString().split(" ")[0] != chosenDate.toString().split(" ")[0]){
                  setState(() {
                    chosenDate = date;
                  });
                  getData();
                }
              }
            );
          })
        ],
      ),
      body: Container(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: double.infinity,
              child: Text(
                  DateFormat('MMMM dd, yyyy').format(chosenDate) == DateFormat('MMMM dd, yyyy').format(DateTime.now()) ? "Today" : "${DateFormat('MMMM dd, yyyy').format(chosenDate)}",
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.headline6.fontSize,
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                 children: [
                   Container(
                     child: Text("Quantity"),
                   ),
                   Container(
                     width: double.infinity,
                     height: Percentage().calculate(num: scrh, percent: 50),
                     child: toGraph == null ? Center(
                       child: CircularProgressIndicator(
                         valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                       ),
                     ) : toGraph.length == 0 || _seriesPieDataList.length == 0 ? Center(
                       child: Text("No recorded data"),
                     ) : new charts.PieChart(
                         _seriesPieDataList,
                         animate: true,
                         animationDuration: Duration(milliseconds: 500),
                         behaviors: [
                           charts.DatumLegend(
                             outsideJustification: charts.OutsideJustification.endDrawArea,
                             horizontalFirst: false,
                             desiredMaxRows: 2,
                             cellPadding: const EdgeInsets.symmetric(vertical: 5),
                             entryTextStyle: charts.TextStyleSpec(
                                 color: charts.MaterialPalette.black,
                                 fontSize: 11
                             ),
                           ),
                         ],
                         defaultRenderer: new charts.ArcRendererConfig(
                             arcWidth: 100,
                             arcRendererDecorators: [
                               new charts.ArcLabelDecorator(
                                   labelPosition: charts.ArcLabelPosition.inside
                               )
                             ]
                         )
                     ),
                   )
                 ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    Container(
                      child: Text("Total"),
                    ),
                    Container(
                      width: double.infinity,
                      height: Percentage().calculate(num: scrh, percent: 50),
                      child: toGraph == null ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                        ),
                      ) :toGraph.length == 0 || _seriesPieDataListTotal.length == 0 ? Center(
                        child: Text("No recorded data"),
                      ) : new charts.PieChart(
                          _seriesPieDataListTotal,
                          animate: true,
                          animationDuration: Duration(milliseconds: 500),
                          behaviors: [
                            charts.DatumLegend(
                              outsideJustification: charts.OutsideJustification.endDrawArea,
                              horizontalFirst: false,
                              desiredMaxRows: 2,
                              cellPadding: const EdgeInsets.symmetric(vertical: 5),
                              entryTextStyle: charts.TextStyleSpec(
                                  color: charts.MaterialPalette.black,
                                  fontSize: 11
                              ),
                            ),
                          ],
                          defaultRenderer: new charts.ArcRendererConfig(
                              arcWidth: 100,
                              arcRendererDecorators: [
                                new charts.ArcLabelDecorator(
                                    labelPosition: charts.ArcLabelPosition.inside
                                )
                              ]
                          )
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
//      body: Container(
//        child: charts.LineChart(
//            seriesList,
//          defaultRenderer: new charts.LineRendererConfig(includeArea: true, stacked: true),
//          animate: animate,
//        ),
//      )
    );
  }
  chosenDateCalendarView(DateTime date) => Container(
    width: double.infinity,
    height: Percentage().calculate(num: scrh,percent: 20),
    child: Center(
      child: Container(
        width: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 20),percent: 95),
        height: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 20),percent: 95),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kPrimaryColor)
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5),
              height: Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 20),percent: 95),percent: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                color: kPrimaryColor
              ),
              child: FittedBox(
                child: Text("${DateFormat('MMMM').format(date).replaceAll("", " ").substring(0,6).toUpperCase()}",style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700
                ),),
              ),
            ),
            Container(
              width: double.infinity,
              height: Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 20),percent: 95),percent: 20),
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: FittedBox(
                child: Text("${DateFormat('EEEE').format(date)}",style: TextStyle(
                  color: kPrimaryColor
                ),),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                child: FittedBox(
                  child: Text("${DateFormat('d').format(date)}",style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: kPrimaryColor
                  ),),
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}
