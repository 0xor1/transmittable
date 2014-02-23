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
    var strs = s.split(new RegExp('"|,'))..removeAt(0);
    return new Person._internal(strs[0], num.parse(strs[1]), num.parse(strs[2]));
  }

  String get toTranString => '"$name"$age,$socialSecurity';
  operator ==(other) => socialSecurity == other.socialSecurity;
  int get hashCode => socialSecurity.hashCode;
}


class UnRegisteredType{}


void main(){
  group('Transmittable', (){

    test('supports numbers',(){
      var tran = new Transmittable()
      ..num = 23;
      expect(tran.toTranString(), equals('num:23'));
    });

    test('supports bools',(){
      var tran = new Transmittable()
      ..bool = true;
      expect(tran.toTranString(), equals('bool:t'));
    });

    test('supports strings',(){
      var tran = new Transmittable()
      ..string = 'Hello World';
      expect(tran.toTranString(), equals('string:11:Hello World'));
    });

    test('supports datetimes',(){
      var tran = new Transmittable();
      var dt = tran.datetime = new DateTime.now();
      expect(tran.toTranString(), equals('datetime:dt:${dt.toString().length}:${dt.toString()}'));
    });

    test('supports durations',(){
      var tran = new Transmittable();
      var dur = tran.duration = new Duration(days:23, seconds: 4, milliseconds: 456);
      expect(tran.toTranString(), equals('duration:dur:${dur.inMilliseconds.toString().length}:${dur.inMilliseconds}'));
    });

    test('supports lists',(){
      var tran = new Transmittable();
      var dt = new DateTime.now();
      var dur = new Duration(days:147, seconds: 78, milliseconds: 2);
      tran.list = [12, "Hi", true, dt, dur];
      expect(tran.toTranString(), equals('list:[12,2:Hi,t,dt:${dt.toString().length}:${dt.toString()},dur:${dur.inMilliseconds.toString().length}:${dur.inMilliseconds}]'));
    });

    test('supports custom types',(){
      var tran = new Transmittable();
      var person = tran.person = new Person('Joe Bloggs', 23);
      var p = new Person.fromTranSring(person.toTranString);
      expect(tran.toTranString(), equals('person:p:16:"Joe Bloggs"23,0'));
    });

    test('doesnt support unregistered types', (){
      var tran = new Transmittable();
      expect(() => tran.unreg = new UnRegisteredType(), throwsA(new isInstanceOf<String>()));
    });

    test('supports nested transmittables', (){
      var tran = new Transmittable()
      ..num = 3
      ..tran = (new Transmittable()..str = "hi");
      expect(tran.toTranString(), equals('num:3,tran:{str:2:hi}'));
    });

  });
}