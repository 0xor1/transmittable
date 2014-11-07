/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */
library transmittable.test.performance;

import 'package:transmittable/transmittable.dart';

void main(){
  var stopwatch = new Stopwatch();
  var tran = new Transmittable();
  var iterations = 10000000;

  var i = iterations;
  stopwatch.start();
  while(i-- > 0){
    tran.pi = 3.142;
  }
  stopwatch.stop();
  print('noSuchMethod setter operation called $iterations times took ${stopwatch.elapsed}');

  i = iterations;
  stopwatch.reset();
  stopwatch.start();
  while(i-- > 0){
    tran.set(#pi, 3.142);
  }
  stopwatch.stop();
  print('set() method called $iterations times with symbol took ${stopwatch.elapsed}');

  i = iterations;
  stopwatch.reset();
  stopwatch.start();
  while(i-- > 0){
    tran.set('pi', 3.142);
  }
  stopwatch.stop();
  print('set() method called $iterations times with string took ${stopwatch.elapsed}');

  i = iterations;
  stopwatch.reset();
  stopwatch.start();
  while(i-- > 0){
    var pi = tran.pi;
  }
  stopwatch.stop();
  print('noSuchMethod getter operation called $iterations times took ${stopwatch.elapsed}');

  i = iterations;
  stopwatch.reset();
  stopwatch.start();
  while(i-- > 0){
    var pi = tran.get(#pi);
  }
  stopwatch.stop();
  print('get() method called $iterations times with symbol took ${stopwatch.elapsed}');

  i = iterations;
  stopwatch.reset();
  stopwatch.start();
  while(i-- > 0){
    var pi = tran.get('pi');
  }
  stopwatch.stop();
  print('get() method called $iterations times with string took ${stopwatch.elapsed}');
}