#Transmittable [![Build Status](https://drone.io/github.com/0xor1/transmittable/status.png)](https://drone.io/github.com/0xor1/transmittable/latest)

Transmittable provides a simple way of transferring **named** and **typed**
properties across http connections whilst also giving the benefit of static type
checking during development.

##How To Use:

Extend off of **Transmittable** to make an object transmittable accross a http 
connection, then explicitly implement an interface for this object, but do not 
implement any of the interfaces getters/setters which you would like to transmit.
It is a requirement that classes extending off **Transmittable** implement a 
default constructor, meaning it is not a named constructor and it takes no arguments.

```dart
void registerAnimalTranTypes = generateRegistrar(
  'Animal', 'a', [
    new TranRegistration.subtype(Cat, () => new Cat())
  ]);

class Cat extends Transmittable implements ICat{}
abstract class ICat{
  String name;
  int age;
}

void main(){

  registerAnimalTranTypes();
  
  Cat c1 = new Cat()
  ..name = 'felix'
  ..age = 3;
  var tranStr = c1.toTranString(); // turn this cat into a transmittable string
  
  // send down http connection and then deserialise back into the cat object
  
  Cat c2 = new Transmittable.fromTranString(tranStr);
  print(c2 is Cat) // true
  print(c2.name); // felix
  print(c2.age); // 3
}
```

##Registered Types

Transmittable can handle, **null**, **int**, **bool**, **String**, **DateTime**, **Duration**,
**RegExp**, **Symbol**, **List**, **Set** and **Map** out of the box without any need for further 
effort on the users part.

If you would like to add additional types to be transmittable or to be subtype
of Transmittable simply register them using the same pattern as below:

```dart
void _registerTranTranTypes = generateRegistrar(
    'transmittable', '', [
    new TranRegistration.codec(null, (o)=> '', (s) => null),
    new TranRegistration.codec(_InternalPointer, (_InternalPointer ip) => ip._uniqueValueIndex.toString(), (String s) => new _InternalPointer(int.parse(s))),
    new TranRegistration.codec(num, (num n) => n.toString(), (String s) => num.parse(s)),
    new TranRegistration.codec(int, (int i) => i.toString(), (String s) => int.parse(s)),
    new TranRegistration.codec(double, (double f) => f.toString(), (String s) => double.parse(s)),
    new TranRegistration.codec(String, (String s) => s, (String s) => s),
    new TranRegistration.codec(bool, (bool b) => b ? 't' : 'f', (String s) => s == 't' ? true : false),
    new TranRegistration.codec(List, _processIterableToString, (String s) => _processStringBackToListOrSet(new List(), s)),
    new TranRegistration.codec(Set, _processIterableToString, (String s) => _processStringBackToListOrSet(new Set(), s)),
    new TranRegistration.codec(Map, _processMapToString, _processStringBackToMap),
    new TranRegistration.codec(RegExp, _processRegExpToString, _processStringBackToRegExp),
    new TranRegistration.codec(Type, (Type t) => _processTypeToString(t),(String s) => _tranCodecsByKey[s]._type),
    new TranRegistration.codec(DateTime, (DateTime d) => d.toString(), (String s) => DateTime.parse(s)),
    new TranRegistration.codec(Duration, (Duration dur) => dur.inMilliseconds.toString(), (String s) => new Duration(milliseconds: num.parse(s))),
    new TranRegistration.codec(Symbol, (Symbol sy) => MirrorSystem.getName(sy), (String s) => MirrorSystem.getSymbol(s)),
    new TranRegistration.subtype(Transmittable, () => new Transmittable())
  ]);
```
Remember this method call must be made on both the client side and the server
side. This is usually best achieved by both server and client side libraries
referencing a common interface library which contains this method.