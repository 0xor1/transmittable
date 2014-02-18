library TransmittableTest;

import 'package:transmittable/transmittable.dart';
import 'package:unittest/unittest.dart';


bool _registeredTransmittableTypes = false;
void _registerTransmittableTypes(){
  if(_registeredTransmittableTypes){return;}
  _registeredTransmittableTypes = true;
  registerTransmittableType('p', Person, (p)=>p.toTranString, (s)=>new Person.fromTranSring(s));
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
      expect(tran.toJson(), equals('{num:23}'));
    });

    test('supports bools',(){
      var tran = new Transmittable()
      ..bool = true;
      expect(tran.toJson(), equals('{bool:true}'));
    });

    test('supports strings',(){
      var tran = new Transmittable()
      ..string = 'Hello World';
      expect(tran.toJson(), equals('{string:"Hello World"}'));
    });

    test('supports datetimes',(){
      var tran = new Transmittable();
      var dt = tran.datetime = new DateTime.now();
      expect(tran.toJson(), equals('{datetime:{dt:${dt.toString()}}}'));
    });

    test('supports durations',(){
      var tran = new Transmittable();
      var dur = tran.duration = new Duration(days:23, seconds: 4, milliseconds: 456);
      expect(tran.toJson(), equals('{duration:{dur:${dur.inMilliseconds}}}'));
    });

    test('supports lists',(){
      var tran = new Transmittable();
      var dt = new DateTime.now();
      var dur = new Duration(days:147, seconds: 78, milliseconds: 2);
      tran.list = [12, "Hi", true, dt, dur];
      expect(tran.toJson(), equals('{list:[12,"Hi",true,{dt:${dt.toString()}},{dur:${dur.inMilliseconds}}]}'));
    });

    test('supports custom types',(){
      var tran = new Transmittable();
      var person = tran.person = new Person('Joe Bloggs', 23);
      var p = new Person.fromTranSring(person.toTranString);
      expect(tran.toJson(), equals('{person:{p:"Joe Bloggs"23,0}}'));
    });

    test('doesnt support unregistered types', (){
      var tran = new Transmittable();
      expect(() => tran.unreg = new UnRegisteredType(), throwsA(new isInstanceOf<String>()));
    });

  });
}