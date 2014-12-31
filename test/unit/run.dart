/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */
library transmittable.test.unit;

import 'package:transmittable/transmittable.dart';
import 'package:unittest/unittest.dart';

part 'core.dart';
part 'internal_pointer.dart';
part 'error.dart';


void main(){
  _registerTestTranTypes();
  _runCoreTests();
  _runInternalPointerTests();
  _runErrorTests();
}