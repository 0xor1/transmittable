/**
 * author: Daniel Robinson  http://github.com/0xor1
 */
library TransmittableTest;

import 'package:transmittable/transmittable.dart';
import 'package:unittest/unittest.dart';

part 'transmittable_core_test.dart';
part 'transmittable_internal_pointer_test.dart';
part 'transmittable_error_test.dart';


void main(){
  _registerTestTranTypes();
  _runCoreTests();
  _runInternalPointerTests();
  _runErrorTests();
}