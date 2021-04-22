

import 'package:ekaon/services/order.dart';
import 'package:rxdart/rxdart.dart';

class OrderListener{
  BehaviorSubject<List> _order = BehaviorSubject.seeded([]);
  Stream get stream$ => _order.stream;
  List get current => _order.value;

  updateAll({List nData})
  {
    nData.sort((b,a)=>int.parse(a['id'].toString()).compareTo(int.parse(b['id'].toString())));
    this._order.add(nData);
  }
//  sort(){
//    this.current.sort((b,a)=>int.parse(a['id'].toString()).compareTo(int.parse(b['id'].toString())));
//    _order.add(this.current);
//  }
  addNew({Map object})
  {
    this.current.add(object);
    this.current.sort((b,a)=>int.parse(a['id'].toString()).compareTo(int.parse(b['id'].toString())));
    this._order.add(this.current);
  }
  remove({int orderId})
  {
    List data = this.current;
    data.removeWhere((element) => element['id']== orderId);
    data.sort((b,a)=>int.parse(a['id'].toString()).compareTo(int.parse(b['id'].toString())));
    this._order.add(data);
    Order().remove(orderId: orderId);
  }
  updateStatus({int orderId, int status})
  {
    this.current.where((element) => element['id'] == orderId).toList()[0]['status'] = status;
//    Map selectedOrder = data.where((element) => element['id'] == orderId).toList()[0];
//    int _selectedOrderIndex = data.indexOf(selectedOrder);
//    data[_selectedOrderIndex]['status'] = status;
    this.current.sort((b,a)=>int.parse(a['id'].toString()).compareTo(int.parse(b['id'].toString())));
    this._order.add(this.current);
  }

}

OrderListener orderListener = OrderListener();