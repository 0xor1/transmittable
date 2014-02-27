library TransmittableTest;

import 'package:transmittable/transmittable.dart';
import 'package:unittest/unittest.dart';


bool _registeredTransmittableTypes = false;
void _registerTransmittableTypes(){
  if(_registeredTransmittableTypes){return;}
  _registeredTransmittableTypes = true;
  registerTranType('p', Person, (p)=>p.toTranString, (s)=>new Person.fromTranSring(s));
}


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


class UnRegisteredType{}


void main(){
  group('Transmittable', (){

    test('supports numbers',(){
      var tran = new Transmittable()
      ..pos = 23
      ..neg = -3;
      var tranStr = tran.toTranString();
      expect(tranStr, equals('pos:n:2:23neg:n:2:-3'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.pos, equals(23));
      expect(reTran.neg, equals(-3));
    });

    test('supports bools',(){
      var tran = new Transmittable()
      ..t = true
      ..f = false;
      var tranStr = tran.toTranString();
      expect(tranStr, equals('t:b:1:tf:b:1:f'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.t, equals(true));
      expect(reTran.f, equals(false));
    });

    test('supports strings',(){
      var tran = new Transmittable()
      ..str1 = 'Hello World'
      ..str2 = 'Hi';
      var tranStr = tran.toTranString();
      expect(tranStr, equals('str1:s:11:Hello Worldstr2:s:2:Hi'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.str1, equals('Hello World'));
      expect(reTran.str2, equals('Hi'));
    });

    test('supports datetimes',(){
      var tran = new Transmittable();
      var dt = tran.datetime = new DateTime.now();
      var tranStr = tran.toTranString();
      expect(tranStr, equals('datetime:d:23:${dt.toString()}'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.datetime, equals(dt));
    });

    test('supports durations',(){
      var tran = new Transmittable();
      var dur = tran.duration = new Duration(days:23, seconds: 4, milliseconds: 456);
      var tranStr = tran.toTranString();
      expect(tranStr, equals('duration:du:${dur.inMilliseconds.toString().length}:${dur.inMilliseconds}'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.duration, equals(dur));
    });

    test('supports lists',(){
      var tran = new Transmittable();
      var dt = new DateTime.now();
      var dur = new Duration(days:147, seconds: 78, milliseconds: 2);
      tran.list = [12, 'Hi', true, dt, dur];
      var tranStr = tran.toTranString();
      expect(tranStr, equals('list:l:62:n:2:12s:2:Hib:1:td:23:${dt.toString()}du:${dur.inMilliseconds.toString().length}:${dur.inMilliseconds}'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.list[0], equals(12));
      expect(reTran.list[1], equals('Hi'));
      expect(reTran.list[2], equals(true));
      expect(reTran.list[3], equals(dt));
      expect(reTran.list[4], equals(dur));
    });

    test('supports custom types',(){
      var tran = new Transmittable();
      var person = tran.person = new Person('Joe Bloggs', 23);
      var tranStr = tran.toTranString();
      expect(tranStr, equals('person:p:15:Joe Bloggs,23,0'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.person, equals(person));

    });

    test('supports nested transmittables', (){
      var tran = new Transmittable()
      ..tran = (new Transmittable()..str = 'hi');
      var tranStr = tran.toTranString();
      expect(tranStr, equals('tran:t:10:str:s:2:hi'));
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.tran.str, equals('hi'));
    });

    test('doesnt support unregistered types', (){
      var tran = new Transmittable();
      expect(() => tran.unreg = new UnRegisteredType(), throwsA(new isInstanceOf<UnregisteredTranTypeError>()));
    });

  });
}