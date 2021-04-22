import 'dart:math';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/discount.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/ticket_clipper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class AddDiscountPage extends StatefulWidget {
  Map toEdit;
  AddDiscountPage({Key key, this.toEdit}) : super(key : key);
  @override
  _AddDiscountPageState createState() => _AddDiscountPageState();
}

class _AddDiscountPageState extends State<AddDiscountPage> {
  bool _isPercentage = true;
  TextEditingController _controller = new TextEditingController();
  TextEditingController _minSpend = new TextEditingController();
  TextEditingController _code = new TextEditingController();
  Color _chosenColor = Colors.black26;
  bool _isLoading  = false;
  DateTime _validity;
  void changeColor(Color color) {
    print(color);
    setState(() => _chosenColor = color);
  }
  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  int nextInt(int min, int max) => min + _rnd.nextInt((max + 1) - min);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.toEdit != null){
      setState(() {
        _controller.text = widget.toEdit['value'].toString();
        _minSpend.text = widget.toEdit['on_reach'].toString();
        _code.text = widget.toEdit['code'].toString();
        _chosenColor = StringFormatter(string: widget.toEdit['color']).stringToColor();
        _validity = DateTime.parse(widget.toEdit['valid_until'].toString());
        if(widget.toEdit['type'].toString() == "1"){
          _isPercentage = true;
        }else{
          _isPercentage = false;
        }
      });
    }else{
      setState(() {
        _code.text = "${getRandomString(nextInt(5, 12))}";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.black
              ),
              title: Text("New Discount",style: TextStyle(
                color: Colors.black
              ),),
            ),
            body: Container(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10,top: 20),
                    child: Text("Code : *",style: TextStyle(
                        color: Colors.black,
                        fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 4 : 4.2),
                        fontWeight: FontWeight.bold
                    ),),
                  ),

                  Container(
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: MyWidgets().customTextField(
                                controller: _code,
                                label: "Code",
                                color: kPrimaryColor,
                                type: TextInputType.text
                            ),
                          ),
                          IconButton(
                            onPressed: (){
                              setState(() {
                                _code.text = "${getRandomString(nextInt(5, 12))}";
                              });
                            },
                            tooltip: "Generate random strings",
                            icon: Container(
                              width: 25,
                              height: 25,
                              child: Image.asset("assets/images/random.png"),
                            ),
                          )
                        ],
                      )
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10,top: 20),
                    child: Text("Discount Type : *",style: TextStyle(
                      color: Colors.black,
                        fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 4 : 4.2),
                      fontWeight: FontWeight.bold
                    ),),
                  ),
                  Container(
                    width: double.infinity,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: _isPercentage ? Colors.transparent : Colors.grey[900]),
                              color: _isPercentage ? kPrimaryColor : Colors.transparent
                            ),
                            child: FlatButton(
                              padding: const EdgeInsets.all(10),
                              onPressed: ()=>setState(()=> _isPercentage = true),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: "%",
                                  style: TextStyle(
                                    color: _isPercentage ? Colors.white : Colors.grey[900],
                                    fontWeight: FontWeight.w700,
                                    fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 4 : 4.2)
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "\nPercentage",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3.9 : 4.1)
                                      )
                                    ),
                                    TextSpan(
                                        text: "\nBy selecting this you can reduce customer's payment by percentage",
                                        style: TextStyle(
                                          color: _isPercentage ? Colors.white54 : Colors.black54,
                                            fontWeight: FontWeight.w400,
                                            fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3.3 : 3)
                                        )
                                    )
                                  ]
                                ),
                              ),
                            )
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: !_isPercentage ? kPrimaryColor : Colors.transparent,
                                border: Border.all(color: !_isPercentage ? Colors.transparent : Colors.grey[900]),
                              ),
                              child: FlatButton(
                                padding: const EdgeInsets.all(10),
                                onPressed: ()=>setState(()=> _isPercentage = false),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      text: "₱",
                                      style: TextStyle(
                                          color: !_isPercentage ? Colors.white : Colors.grey[900],
                                          fontWeight: FontWeight.w700,
                                          fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 4 : 4.2)
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: "\nAmount",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3.9 : 4.1)
                                            )
                                        ),
                                        TextSpan(
                                            text: "\nBy selecting this you can reduce customer's payment by amount",
                                            style: TextStyle(
                                                color: !_isPercentage ? Colors.white54 : Colors.black54,
                                                fontWeight: FontWeight.w400,
                                                fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3.3 : 3)
                                            )
                                        )
                                      ]
                                  ),
                                ),
                              )
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10,top: 20),
                    child: Text("${_isPercentage ? "Percent" : "Amount"} : *",style: TextStyle(
                        color: Colors.black,
                        fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 4 : 4.2),
                        fontWeight: FontWeight.bold
                    ),),
                  ),

                  Container(
                    width: double.infinity,
                    child: MyWidgets().customTextField(
                      controller: _controller,
                      label: "Value",
                      color: kPrimaryColor,
                      type: TextInputType.number
                    )
                  ),


                  _isPercentage && _controller.text.isNotEmpty && double.parse(_controller.text) >= 100 ? Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: double.infinity,
                    child: Text("Warning : This voucher will make everything free.",style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.red
                    ),),
                  ) : Container(),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10,top: 20),
                    child: Text("Minimum Spend : *",style: TextStyle(
                        color: Colors.black,
                        fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 4 : 4.2),
                        fontWeight: FontWeight.bold
                    ),),
                  ),

                  Container(
                      width: double.infinity,
                      child: MyWidgets().customTextField(
                          controller: _minSpend,
                          label: "Value",
                          color: kPrimaryColor,
                          type: TextInputType.number
                      )
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10,top: 20),
                    child: Text("Valid until : *",style: TextStyle(
                        color: Colors.black,
                        fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 4 : 4.2),
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                  Container(
                    width: double.infinity,
                    child: OutlineButton(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      highlightedBorderColor: kPrimaryColor.withOpacity(0.5),
                      borderSide: BorderSide(
                        color: kPrimaryColor
                      ),
                      onPressed: () async {
                        DateTime picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(Duration(days: 20)),
                            firstDate: DateTime.now().add(Duration(days: 15)),
                            lastDate: DateTime.now().add(Duration(days: 366)),
                          builder: (context,child) => Theme(
                            data: Theme.of(context).copyWith(
                              primaryColor: kPrimaryColor,
                              colorScheme: ColorScheme.dark(
                                primary: kPrimaryColor,
                                onPrimary: Colors.black,
                                surface: kPrimaryColor,
                                onSurface: Colors.black,
                              ),
                              dialogBackgroundColor:Colors.white,
                              unselectedWidgetColor: Colors.black,
                            ),
                            child: child,
                          )
                        );
                        print(picked);
                        if(picked != _validity){
                          setState(() {
                            _validity = picked;
                          });
                        }
                      },
                      child: Center(
                        child: Text("${_validity == null ? "Choose date" : "${DateFormat('MMMM dd, yyyy').format(_validity)}"}",style: TextStyle(
                          color: kPrimaryColor
                        ),),
                      ),
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10,top: 20),
                    child: Text("Display :",style: TextStyle(
                        color: Colors.black,
                        fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 4 : 4.2),
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10,top: 5),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text("Color :",style: TextStyle(
                              color: Colors.black,
                              fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3.2 : 3.5),
                              fontWeight: FontWeight.w600
                          ),),
                        ),
                        FlatButton(
                          onPressed: (){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  titlePadding: const EdgeInsets.all(0.0),
                                  contentPadding: const EdgeInsets.all(0.0),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                      pickerColor: _chosenColor,
                                      onColorChanged: changeColor,
                                      colorPickerWidth: 300.0,
                                      pickerAreaHeightPercent: 1,
                                      enableAlpha: true,
                                      displayThumbColor: true,
                                      showLabel: true,
                                      paletteType: PaletteType.hsv,
                                      pickerAreaBorderRadius: const BorderRadius.only(
                                        topLeft: const Radius.circular(2.0),
                                        topRight: const Radius.circular(2.0),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          padding: const EdgeInsets.all(0),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 20,
                                height: 20,
                                color: _chosenColor,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Icon(Icons.edit,color: Colors.black,)
                            ],
                          ),
                        )
                      ],
                    )
                  ),
                  Container(
                    width: double.infinity,
                    child: TicketWidget(
                        height: Percentage().calculate(num: scrh,percent: 15),
                        onPressed: (){},
                        color: _chosenColor,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15), percent: 15),vertical: 10),
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                height: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60),
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        alignment: AlignmentDirectional.centerStart,
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: RichText(
                                                textAlign: TextAlign.left,
                                                text: TextSpan(
                                                    text: "${_controller.text.isEmpty ? "00" : "${_controller.text}"}",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60),percent: scrw > 700 ? 68 : 70)
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                          text: "${_isPercentage ? "%" : "₱"} OFF",
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.w500,
                                                              fontSize:Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60),percent: scrw > 700 ? 18 : 20)
                                                          )
                                                      )
                                                    ]
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: kPrimaryColor,
                                                borderRadius: BorderRadius.circular(5)
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                              child: Text("APPLY",style: TextStyle(
                                                color: Colors.white
                                              ),),
                                            ),
                                          ],
                                        )
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      child: Text(_validity == null ? "Unspecified" : "Valid until ${DateFormat('MMM. dd').format(_validity)}",style: TextStyle(
                                          fontSize: Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60),percent: scrw > 700 ? 13 : 15)
                                      ),),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    )
                                  ],
                                ),
                              ),
                              brokenLines(count: 15,height: 3.5,color: Colors.grey[200]),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Container(
                                    width: double.infinity,
                                    child: Text("Min spend ₱${_minSpend.text.isEmpty ? "0.00" : "${double.parse(_minSpend.text).toStringAsFixed(2)}"}",style: TextStyle(
                                        fontSize: Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60),percent: scrw > 700 ? 13 : 15)
                                    ),),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    height: 60,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                      ),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        if(_code.text.isNotEmpty && _controller.text.isNotEmpty && _minSpend.text.isNotEmpty && _validity != null){
                          setState(() {
                            _isLoading = true;
                          });
                          if(widget.toEdit != null){
                            print("UPDATE!");
                            await Discount().update(
                                code: _code.text,
                                amount: _controller.text,
                                minSpend: _minSpend.text,
                                validity: _validity,
                                isPercentage: _isPercentage,
                                color: _chosenColor,
                                id: int.parse(widget.toEdit['id'].toString())).whenComplete(() => setState(()=> _isLoading = false));
                          }else{
                            await Discount().add(
                                code: _code.text,
                                amount: _controller.text,
                                minSpend: _minSpend.text,
                                validity: _validity,
                                isPercentage: _isPercentage,
                                color: _chosenColor
                            ).whenComplete(() => setState(()=> _isLoading = false));
                          }
                          Navigator.of(context).pop();
                        }else{
                          Fluttertoast.showToast(msg: "Please do not leave required fields empty");
                        }
                      },
                      child: Center(
                        child: Text(widget.toEdit != null ? "Update" : "Submit",style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),

          _isLoading ? MyWidgets().loader() : Container()
        ],
      ),
    );
  }
}
