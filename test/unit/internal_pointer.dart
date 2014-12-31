/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */
part of transmittable.test.unit;

class PotentialTranDisaster{
  Transmittable tran;
}

void _runInternalPointerTests(){
  group('Transmittable (InternalPointer test)', (){

    test('supports simple reference loops',(){
      var tran = new Transmittable();
      tran.set('tran', tran);
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.get('tran'), equals(reTran));
    });

    test('supports complex reference loops',(){
      var tran = new Transmittable();
      tran.set('aTran', tran);
      var aLongString = 'Hello World, This string should be quite long and easy to spot in the transmittable string.';
      tran.set('aLongString', aLongString);
      var map = new Map();
      tran.set('aMap', map);
      var list = new List();
      tran.set('aList', list);
      var set = new Set();
      tran.set('aSet', set);
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
      var reALongString = reTran.get('aLongString');
      var reMap = reTran.get('aMap');
      var reList = reTran.get('aList');
      var reSet = reTran.get('aSet');
      expect(reTran.get('aTran'), equals(reTran));
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
      tran.set('avertedDisaster', new PotentialTranDisaster()..tran = new Transmittable());
      tran.get('avertedDisaster').tran.set('tran', tran);
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.get('avertedDisaster') is PotentialTranDisaster, equals(true));
    });

  });
}