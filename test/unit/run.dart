/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */
library transmittable.test.unit;

import 'package:transmittable/transmittable.dart';
import 'package:unittest/unittest.dart';
import 'test_lib/a.dart' as a;
import 'test_lib/b.dart' as b;

part 'core.dart';
part 'internal_pointer.dart';
part 'error.dart';


void main(){
  _registerTestTranTypes();
  _runCoreTests();
  _runInternalPointerTests();
  _runErrorTests();
}