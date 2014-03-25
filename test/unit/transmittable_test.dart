/**
 * author: Daniel Robinson  http://github.com/0xor1
 */
library TransmittableTest;

import 'package:transmittable/transmittable.dart';
import 'package:unittest/unittest.dart';

part 'transmittable_standard_test.dart';
part 'transmittable_internal_pointer_test.dart';


void main(){
  _runStandardTests();
  _runInternalPointerTests();
}