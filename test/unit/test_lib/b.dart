/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */
@TranLib(
    'transmittable/transmittable.test.unit.b',
    'ttub')
library transmittable.test.unit.b;

import 'package:transmittable/transmittable.dart';

@TranCodec('A', _AToString, _AFromString)
class A{
}
String _AToString(A a) => '';
A _AFromString(String a) => new A();

@TranSubtype('B', _BConst)
class B extends Transmittable{
  A get a => get('a');
  void set a (A a){ set('a', a); }
}
B _BConst() => new B();