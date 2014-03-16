library TransmittableTest;

import 'package:transmittable/transmittable.dart';
import 'package:unittest/unittest.dart';


bool _registeredTranCodecs = false;
void _registerTransmittableTypes(){
  if(_registeredTranCodecs){return;}
  _registeredTranCodecs = true;
  registerTranCodec('p', Person, (p)=>p.toTranString, (s)=>new Person.fromTranSring(s));
  registerTranSubtype('cat', Cat);
}

class UnregisteredType{}

class Person{

  static int ssSrc = 0;

  String name;
  int age;
  final int socialSecurity;

  Person(this.name, this.age):socialSecurity = ssSrc++{
    _registerTransmittableTypes();
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

void main(){
  group('Transmittable', (){

    test('supports null',(){
      var tran = new Transmittable()
      ..aNull = null;
      var tranStr = tran.toTranString();
      expect(tranStr, equals('tr:aNull:_:0:'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.aNull, equals(null));
    });

    test('supports numbers',(){
      var tran = new Transmittable()
      ..pos = 23
      ..neg = -3;
      var tranStr = tran.toTranString();
      expect(tranStr, equals('tr:pos:n:2:23neg:n:2:-3'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.pos, equals(23));
      expect(reTran.neg, equals(-3));
    });

    test('supports bools',(){
      var tran = new Transmittable()
      ..t = true
      ..f = false;
      var tranStr = tran.toTranString();
      expect(tranStr, equals('tr:t:b:1:tf:b:1:f'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.t, equals(true));
      expect(reTran.f, equals(false));
    });

    test('supports strings',(){
      var tran = new Transmittable()
      ..str1 = 'Hello World'
      ..str2 = 'Hi';
      var tranStr = tran.toTranString();
      expect(tranStr, equals('tr:str1:s:11:Hello Worldstr2:s:2:Hi'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.str1, equals('Hello World'));
      expect(reTran.str2, equals('Hi'));
    });

    test('supports datetimes',(){
      var tran = new Transmittable();
      var dt = tran.datetime = new DateTime.now();
      var tranStr = tran.toTranString();
      expect(tranStr, equals('tr:datetime:d:23:${dt.toString()}'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.datetime, equals(dt));
    });

    test('supports durations',(){
      var tran = new Transmittable();
      var dur = tran.duration = new Duration(days:23, seconds: 4, milliseconds: 456);
      var tranStr = tran.toTranString();
      expect(tranStr, equals('tr:duration:du:${dur.inMilliseconds.toString().length}:${dur.inMilliseconds}'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.duration, equals(dur));
    });

    test('supports lists',(){
      var tran = new Transmittable();
      var dt = new DateTime.now();
      var dur = new Duration(days:147, seconds: 78, milliseconds: 2);
      tran.list = [12, 'Hi', true, dt, dur];
      var tranStr = tran.toTranString();
      expect(tranStr, equals('tr:list:l:62:n:2:12s:2:Hib:1:td:23:${dt.toString()}du:${dur.inMilliseconds.toString().length}:${dur.inMilliseconds}'));
      var reTran = new Transmittable.fromTranString(tranStr);
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
      var tranStr = tran.toTranString();
      expect(tranStr, equals('tr:set:se:62:n:2:12s:2:Hib:1:td:23:${dt.toString()}du:${dur.inMilliseconds.toString().length}:${dur.inMilliseconds}'));
      var reTran = new Transmittable.fromTranString(tranStr);
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
      var tranStr = tran.toTranString();
      expect(tranStr, equals('tr:map:m:124:n:2:12n:2:12s:2:His:2:Hib:1:tb:1:fd:23:${dt.toString()}d:23:${dt.toString()}du:${dur.inMilliseconds.toString().length}:${dur.inMilliseconds}du:${dur.inMilliseconds.toString().length}:${dur.inMilliseconds}'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.map[12], equals(12));
      expect(reTran.map['Hi'], equals('Hi'));
      expect(reTran.map[true], equals(false));
      expect(reTran.map[dt], equals(dt));
      expect(reTran.map[dur], equals(dur));
    });

    test('supports regexp',(){
      var tran = new Transmittable();
      tran.regexp = new RegExp(r'^[a-z]\n', caseSensitive: false, multiLine: true);
      var tranStr = tran.toTranString();
      expect(tranStr, equals(r'tr:regexp:r:12:8:^[a-z]\nft'));
    });

    test('supports custom types',(){
      var tran = new Transmittable();
      var person = tran.person = new Person('Joe Bloggs', 23);
      var tranStr = tran.toTranString();
      expect(tranStr, equals('tr:person:p:15:Joe Bloggs,23,0'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.person, equals(person));

    });

    test('supports nested transmittables', (){
      var tran = new Transmittable()
      ..tran = (new Transmittable()..str = 'hi');
      var tranStr = tran.toTranString();
      expect(tranStr, equals('tr:tran:tr:13:tr:str:s:2:hi'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.tran.str, equals('hi'));
    });

    test('supports types', (){
      var tran = new Transmittable()
      ..string = String
      ..int = int
      ..double = double;
      var tranStr = tran.toTranString();
      expect(tranStr, equals('tr:string:t:1:sint:t:1:idouble:t:1:f'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.string, equals(String));
      expect(reTran.int, equals(int));
      expect(reTran.double, equals(double));
    });

    test('doesnt support unregistered types', (){
      var tran = new Transmittable();
      tran.unreg = new UnregisteredType();
      expect(() => tran.toTranString(), throwsA(new isInstanceOf<UnregisteredTranCodecError>()));
    });

    test('supports pre-processing of values at encode time', (){
      var tran = new Transmittable()
      ..unreg = new UnregisteredType()
      ..aNum = 1;
      var tranStr = tran.toTranString((v) => v is UnregisteredType? 'foundAnUnregisteredType!!': v);
      expect(tranStr, 'tr:unreg:s:25:foundAnUnregisteredType!!aNum:n:1:1');
    });

    test('supports dynamic Transmittable type creation', (){
      var cat = new Cat()
      ..name = 'Felix'
      ..age = 3;
      var tranStr = cat.toTranString();
      expect(tranStr, 'cat:name:s:5:Felixage:n:1:3');
      var reCat = new Transmittable.fromTranString(tranStr);
      expect(reCat is Cat, true);
    });

  });
}