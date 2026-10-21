import 'package:cupcake/coins/abstract/amount.dart';

class ZcashAmount implements Amount {
  @override
  int get amount => 0;

  @override
  String toString() => '$amount';
}
