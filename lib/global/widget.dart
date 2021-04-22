import 'dart:ui';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:flutter/material.dart';

class MyWidgets {
  TextFormField textFormField({String label, TextEditingController controller, Function onTap, Function onChange, TextInputType type}) {
    return TextFormField(
      controller: controller,
      onTap: onTap,
      cursorColor: kPrimaryColor,
      onChanged: onChange,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
        ),
        suffixIcon: IconButton(
          onPressed: () => controller.clear(),
          icon: Icon(Icons.clear),
        )
      ),
    );
  }
  TextFormField passwordText({Function onTap, TextEditingController controller, bool obscurity, Function onView, String label, TextInputType type}) {
    return TextFormField(
      controller: controller,
      onTap: onTap,
      obscureText: obscurity,
      cursorColor: kPrimaryColor,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
        ),
          suffixIcon: IconButton(
            onPressed: onView,
            icon: Icon(obscurity ? Icons.visibility : Icons.visibility_off),
          )
      ),
    );
  }
  RaisedButton button({Function pressed, Widget child, Color color = kPrimaryColor}) {
    return RaisedButton(
      color: color,
      elevation: 0,
      onPressed: pressed,
      child: Center(
        child: child,
      ),
    );
  }
  loader() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaY: 4,sigmaX: 4),
      child: Container(
        color: Colors.white.withOpacity(0.4),
        child: Center(
          child: Image.asset("assets/images/loader.gif"),
        ),
      ),
    );
  }
  Theme customTextField({String label, TextEditingController controller, Function onTap, Function onChange, TextInputType type, Color color}){
    return Theme(
      data: ThemeData(
        primaryColor: color
      ),
      child: TextFormField(
        style: TextStyle(color: color),
        autofocus: true,
        controller: controller,
        onTap: onTap,
        cursorColor: color,
        maxLines: type == TextInputType.multiline ? null : 1,
        onChanged: onChange,
        keyboardType: type,
        decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            suffixIcon: IconButton(
              onPressed: () => controller.clear(),
              icon: Icon(Icons.clear),
            )
        ),
      ),
    );
  }
  TextFormField searchField({String label, TextEditingController controller, Function onTap, Function onChange, TextInputType type, Function onClear}) {
    return TextFormField(
      controller: controller,
      onTap: onTap,
      cursorColor: kPrimaryColor,
      onChanged: onChange,
      keyboardType: type,
      decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          suffixIcon: IconButton(
            onPressed: onClear,
            icon: Icon(Icons.clear),
          )
      ),
    );
  }
  Widget loginCard(Orientation orientation) => Container(
    width: Percentage().calculate(),
  );
  Widget iconWithBadge({Image image, Color badgeColor, int count}) {
    return Container(
        width: 25,
        height: 25,
        child: Stack(
          children: <Widget>[
            Container(
              width: 25,
              height: 25,
              child: Center(
                child: image
              ),
            ),
            count > 0 ? Container(
              width: 25,
              height: 25,
              alignment: AlignmentDirectional.topEnd,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(1000),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white,
                          spreadRadius: 2
                      )
                    ]
                ),
                child: Center(
                  child: Text("$count",style: TextStyle(
                      color: Colors.white,
                      fontSize: (9.0 - count.toString().length)
                  ),),
                ),
              ),
            ) : Container()
          ],
        )
    );
  }
  errorBuilder(context, {String error}) {
    return Material(
      child: Container(
        width: double.infinity,
        height: scrh,
        color: Colors.white,
        child: Column(
          children: [
            AppBar(
              title: Text("Error",style: TextStyle(
                color: Colors.black
              ),),
              iconTheme: IconThemeData(
                color: Colors.black
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            Container(
              child: Image.asset("assets/images/error.png"),
            ),
            const SizedBox(
              height: 10,
            ),
            Text("Oops! Something went wrong",style: TextStyle(
              fontSize: Theme.of(context).textTheme.headline6.fontSize
            ),textAlign: TextAlign.center,),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("A problem has occurred while we are processing your request, please contact the developer",style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                color: Colors.grey
              ),textAlign: TextAlign.center,),
            ),
            error == null ? Container() : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text("$error"),
            )
          ],
        ),
      ),
    );
  }
}