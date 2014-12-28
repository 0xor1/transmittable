#Transmittable [![Build Status](https://drone.io/github.com/0xor1/transmittable/status.png)](https://drone.io/github.com/0xor1/transmittable/latest)

Transmittable provides a simple way of transferring **named** and **typed**
properties across http connections whilst also giving the benefit of static type
checking during development.

##Registered Types

Transmittable can handle, **null**, **num**, **int**, **double**, **bool**, **String**, **DateTime**, **Duration**,
**RegExp**, **Type**, **Symbol**, **List**, **Set** and **Map** out of the box without any need for further 
effort on the users part.

## Registering new types

If you would like to add additional types to be transmittable or to be subtype
of Transmittable, there are two methods. The first method is to use a **Registrar**
function using the same pattern as below. `generateRegistrar`
returns a `Registrar` function which is then called to register all of the types:

```dart
// animal.dart registrar method
library animal;

void registerAnimalTranTypes = generateRegistrar(
  'Animal', 'a', [
    new TranRegistration.subtype(Cat, () => new Cat())
  ]);

class Cat extends Transmittable{
  String get name => get('name');
  void set name (String o){set('name', o);}
  int get age => get('age');
  void set age (int o){set('age', o);}
}
```

The Registrar method must be manually called on both the client side and the server
side. This is usually best achieved by both server and client side libraries
referencing a common library which contains this function.

The second method is to use inline **annotations** which is the preferred method as it removes
the need to add any initialization code to libraries using transmittable types. 

```dart
// animal.dart annotation method
@TranLib('animal', 'a')
library animal;

@TranSubtype('Cat', _CatConst)
class Cat extends Transmittable{
  String get name => get('name');
  void set name (String o){set('name', o);}
  int get age => get('age');
  void set age (int o){set('age', o);}
}
Cat _CatConst() => new Cat();
```

The example below uses the `animal.dart annotation method` library from above.
If it used the `animal.dart registrar method` the first line in `main` would
need to be `registerAnimalTranTypes();`, as this demonstrates using **annotations** removes
the need to add in initialization code.

```dart

import 'animal.dart';

void main(){
  
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

