/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */
part of TransmittableTest;

bool _testTranTypesRegistered = false;
void _registerTestTranTypes(){
  if(_testTranTypesRegistered){return;}
  _testTranTypesRegistered = true;
  registerTranTypes('Transmittable.TransmittableTest', 't', (){
    registerTranCodec('a', Person, (p)=> p.toTranString, (s)=> new Person.fromTranSring(s));
    registerTranCodec('b', PotentialTranDisaster, (ptd)=> ptd.tran.toTranString((v) => v is int && v == 2? 'replaced 2': v), (s) => new PotentialTranDisaster()..tran = new Transmittable.fromTranString(s, (v) => v == 'replaced 2'? 2: v));
    registerTranSubtype('c', Cat);
  });
}

class UnregisteredType{}

class Person{

  static int ssSrc = 0;

  String name;
  int age;
  final int socialSecurity;

  Person(this.name, this.age):socialSecurity = ssSrc++{
    _registerTestTranTypes();
  }

  Person._internal(this.name, this.age, this.socialSecurity);

  factory Person.fromTranSring(String s){
    var strs = s.split(',');
    return new Person._internal(strs[0], num.parse(strs[1]), num.parse(strs[2]));
  }

  String get toTranString => '$name,$age,$socialSecurity';
  operator ==(other) => socialSecurity == other.socialSecurity;
  int get hashCode => socialSecurity.hashCode;
}

class Cat extends Transmittable implements ICat{}
abstract class ICat{
  String name;
  int age;
}

void _runCoreTests(){
  group('Transmittable (core test)', (){

    test('supports null',(){
      var tran = new Transmittable()
      ..aNull = null;
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.aNull, equals(null));
    });

    test('supports numbers',(){
      var tran = new Transmittable()
      ..pos = 23
      ..neg = -3;
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.pos, equals(23));
      expect(reTran.neg, equals(-3));
    });

    test('supports bools',(){
      var tran = new Transmittable()
      ..t = true
      ..f = false;
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.t, equals(true));
      expect(reTran.f, equals(false));
    });

    test('supports strings',(){
      var tran = new Transmittable()
      ..str1 = 'Hello World'
      ..str2 = 'Hi';
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.str1, equals('Hello World'));
      expect(reTran.str2, equals('Hi'));
    });

    test('supports datetimes',(){
      var tran = new Transmittable();
      var dt = tran.datetime = new DateTime.now();
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.datetime, equals(dt));
    });

    test('supports durations',(){
      var tran = new Transmittable();
      var dur = tran.duration = new Duration(days:23, seconds: 4, milliseconds: 456);
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.duration, equals(dur));
    });

    test('supports lists',(){
      var tran = new Transmittable();
      var dt = new DateTime.now();
      var dur = new Duration(days:147, seconds: 78, milliseconds: 2);
      tran.list = [12, 'Hi', true, dt, dur];
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.list[0], equals(12));
      expect(reTran.list[1], equals('Hi'));
      expect(reTran.list[2], equals(true));
      expect(reTran.list[3], equals(dt));
      expect(reTran.list[4], equals(dur));
    });

    test('supports sets',(){
      var tran = new Transmittable();
      var dt = new DateTime.now();
      var dur = new Duration(days:147, seconds: 78, milliseconds: 2);
      var contents = [12, 'Hi', true, dt, dur];
      tran.set = new Set()..addAll(contents);
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.set.containsAll(contents), equals(true));
    });

    test('supports maps',(){
      var tran = new Transmittable();
      var dt = new DateTime.now();
      var dur = new Duration(days:147, seconds: 78, milliseconds: 2);
      tran.map = new Map<dynamic, dynamic>()
      ..[12] = 12
      ..['Hi'] = 'Hi'
      ..[true] = false
      ..[dt] = dt
      ..[dur] = dur;
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.map[12], equals(12));
      expect(reTran.map['Hi'], equals('Hi'));
      expect(reTran.map[true], equals(false));
      expect(reTran.map[dt], equals(dt));
      expect(reTran.map[dur], equals(dur));
    });

    test('supports regexps',(){
      var tran = new Transmittable();
      tran.regexp = new RegExp(r'^[a-z]\n', caseSensitive: false, multiLine: true);
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(tran.toTranString().contains(r'^[a-z]\n'), equals(true));
    });

    test('supports symbols',(){
      var tran = new Transmittable();
      tran.symbol = const Symbol("YO");
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.symbol, equals(tran.symbol));
    });

    test('supports custom types',(){
      var tran = new Transmittable();
      var person = tran.person = new Person('Joe Bloggs', 23);
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.person, equals(person));

    });

    test('supports nested transmittables', (){
      var tran = new Transmittable()
      ..tran = (new Transmittable()..str = 'hi');
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.tran.str, equals('hi'));
    });

    test('supports types', (){
      var tran = new Transmittable()
      ..string = String
      ..int = int
      ..double = double;
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.string, equals(String));
      expect(reTran.int, equals(int));
      expect(reTran.double, equals(double));
    });

    test('supports pre/post-processing of values at encode/decode time', (){
      var tran = new Transmittable()
      ..unreg = new UnregisteredType()
      ..aNum = 1;
      var tranStr = tran.toTranString((v) => v is UnregisteredType? 'foundAnUnregisteredType!!': v);
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.unreg, equals('foundAnUnregisteredType!!'));
      var reTranWithPostProcessing = new Transmittable.fromTranString(tranStr, (v) => v == 'foundAnUnregisteredType!!'? tran.unreg: v);
      expect(reTranWithPostProcessing.unreg, equals(tran.unreg));
    });

    test('supports nested pre/post processing of values at encode/decode time', (){
      var tran = new Transmittable()
      ..one = 1
      ..two = 2
      ..nested = new PotentialTranDisaster();
      tran.nested.tran = new Transmittable()
      ..one = 1
      ..two = 2;
      var tranStr = tran.toTranString((v) => v is int? v * 100: v);
      var retran = new Transmittable.fromTranString(tranStr);
      expect(retran.one, equals(100));
      expect(retran.two, equals(200));
      expect(retran.nested.tran.one, equals(100));
      expect(retran.nested.tran.two, equals(2));
    });

    test('supports dynamic Transmittable type creation', (){
      var cat = new Cat()
      ..name = 'Felix'
      ..age = 3;
      var reCat = new Transmittable.fromTranString(cat.toTranString());
      expect(reCat is Cat, true);
    });

  });
}