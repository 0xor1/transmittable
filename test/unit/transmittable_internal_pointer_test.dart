/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */
part of TransmittableTest;

class PotentialTranDisaster{
  Transmittable tran;
}

void _runInternalPointerTests(){
  group('Transmittable (InternalPointer test)', (){

    test('supports simple reference loops',(){
      var tran = new Transmittable();
      tran.tran = tran;
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.tran, equals(reTran));
    });

    test('supports complex reference loops',(){
      var tran = new Transmittable();
      tran.tran = tran;
      var aLongString = tran.aLongString = 'Hello World, This string should be quite long and easy to spot in the transmittable string.';
      var map = tran.map = new Map();
      var list = tran.list = new List();
      var set = tran.set = new Set();
      map['tran'] = tran;
      map['aLongString'] = aLongString;
      map['map'] = map;
      map['list'] = list;
      map['set'] = set;
      list.add(tran);
      list.add(aLongString);
      list.add(map);
      list.add(list);
      list.add(set);
      set.add(tran);
      set.add(aLongString);
      set.add(map);
      set.add(list);
      set.add(set);
      var tranStr = tran.toTranString();
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      var reALongString = reTran.aLongString;
      var reMap = reTran.map;
      var reList = reTran.list;
      var reSet = reTran.set;
      expect(reTran.tran, equals(reTran));
      expect(reALongString, equals(aLongString));
      expect(reMap is Map, equals(true));
      expect(reList is List, equals(true));
      expect(reSet is Set, equals(true));
      expect(reMap['tran'], equals(reTran));
      expect(reMap['aLongString'], equals(aLongString));
      expect(reMap['map'], equals(reMap));
      expect(reMap['list'], equals(reList));
      expect(reMap['set'], equals(reSet));
      expect(reList[0], equals(reTran));
      expect(reList[1], equals(aLongString));
      expect(reList[2], equals(reMap));
      expect(reList[3], equals(reList));
      expect(reList[4], equals(reSet));
      expect(reSet.contains(reTran), equals(true));
      expect(reSet.contains(aLongString), equals(true));
      expect(reSet.contains(reMap), equals(true));
      expect(reSet.contains(reList), equals(true));
      expect(reSet.contains(reSet), equals(true));
    });

    test('supports non-dangerous nested toTranString calls', (){
      var tran = new Transmittable();
      tran.avertedDisaster = new PotentialTranDisaster()..tran = new Transmittable();
      tran.avertedDisaster.tran.tran = tran;
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.avertedDisaster is PotentialTranDisaster, equals(true));
    });

  });
}