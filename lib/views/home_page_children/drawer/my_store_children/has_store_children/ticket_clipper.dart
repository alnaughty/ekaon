import 'package:ekaon/services/percentage.dart';
import 'package:flutter/material.dart';

class TicketClip extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = Percentage().calculate(num: size.height,percent: 45);
    Path path = Path();
    path.lineTo(0, Percentage().calculate(num: size.height,percent: 55));
    path.arcToPoint(Offset(0,size.height-radius/2.2),clockwise: true,radius: Radius.circular(10),largeArc: false);
//    path.quadraticBezierTo(radius/1.3, Percentage().calculate(num: size.height,percent: 65), 0, Percentage().calculate(num: size.height,percent: 80));
//    path.lineTo(0, size.height-radius/2);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height-radius/2.2);
    path.arcToPoint(Offset(size.width,Percentage().calculate(num: size.height,percent: 55)),clockwise: true,radius: Radius.circular(10),largeArc: false);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Widget TicketWidget({Function onPressed, double height = 100, @required Widget child, Color color = Colors.black26})=>ClipPath(
  clipper: TicketClip(),
  child: FlatButton(
    onPressed: onPressed,
    padding: const EdgeInsets.all(0),
    child: Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fitWidth,
          image: AssetImage("assets/images/paper.jpg")
        )
      ),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color,width: 1.5),
          color: color,
        ),
        child: child,
      )
    ),
  ),
);

Widget brokenLines({@required int count, double width = 10, double height = 5, double radius = 0, Color color = Colors.grey}) => Container(
  width: double.infinity,
  height: height,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      for(var x = 0;x < count;x++)...{
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: color
          ),
        )
      }
    ],
  ),
);