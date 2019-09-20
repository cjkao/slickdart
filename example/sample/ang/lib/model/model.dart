class Hero {
  static int _nextId = 1;
  final int id;
  String name, power, mana;

  Hero(this.name, [this.power = '', this.mana = "0"]) : id = _nextId++;
}
