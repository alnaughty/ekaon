class Verified {
  final int strength;
  Verified({this.strength});
  Verified.fromData(Map<String, dynamic> data)
      : strength = data['strength'];
  Map<String, dynamic> toJson() => {
    'strength' : strength
  };
}