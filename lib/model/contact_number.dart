class ContactNumber {
  int id;
  final String number;
  ContactNumber({this.number, this.id});
  ContactNumber.fromData(Map<String, dynamic> data) :
        id = data['id'],
        number = data['number'];
  Map<String, dynamic> toJson() => {
    'id' : id,
    'number' : number
  };
}