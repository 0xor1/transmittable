/**
 * author: Daniel Robinson http://github.com/0xor1
 */

/**
 * Data structures for serializing/deserializing typed objects
 */
library Transmittable;

import 'dart:mirrors';

/**
 * Registers custom types with a given [String] [key] to make it transmittable.
 */
void registerTranType(String key, Type type, ToTranString toStr, FromTranString fromStr){
  _registerAdditionalCoreTypes();
  if(key.contains(new RegExp(r'^\d|,|:|{|}|[|]'))){
    throw 'Key "$key" invalid, it may not start with a number or contain any of the following characters ,:{}[]';
  }
  new _TranType(key, type, toStr, fromStr);
}

/**
 * Signature for a function which takes an object of type [T] and returns
 * a [String] representation of that object.
 */
typedef String ToTranString<T>(T obj);

/**
 *  Signature for a function which takes a string representation of an
 *  object of type [T] and returns an instance of that object.
 */
typedef T FromTranString<T>(String str);

final Map<String, _TranType> _tranTypesByKey = new Map<String, _TranType>();
final Map<Type, _TranType> _tranTypesByType = new Map<Type, _TranType>();
bool _additionalCoreTypesRegistered = false;
void _registerAdditionalCoreTypes(){
  if(_additionalCoreTypesRegistered){return;}
  _additionalCoreTypesRegistered = true;
  registerTranType('dt', DateTime, (DateTime dt) => dt.toString(), (String dt) => DateTime.parse(dt));
  registerTranType('dur', Duration, (Duration dur) => '${dur.inMilliseconds}', (String dur) => new Duration(milliseconds: num.parse(dur)));
  //TODO add more core types as seems appropriate
}

class _TranType{

  final String _key;
  final Type _type;
  final ToTranString _toStr;
  final FromTranString _fromStr;

  _TranType(String this._key, Type this._type, ToTranString this._toStr, FromTranString this._fromStr){
    _registerAdditionalCoreTypes();
    if(_tranTypesByKey.containsKey(_key)){
      throw 'Key "$_key" has already been registered with type "$_type".';
    }else if(_tranTypesByType.containsKey(_type)){
      throw 'Type "$_type" has already been registered with key "$_key".';
    }else{
      _tranTypesByKey[_key] = _tranTypesByType[_type] = this;
    }
  }
}

@proxy
class Transmittable{

  static List<Type> getRegisterdTypes(){
    return [num, bool, String, List]..addAll(_tranTypesByType.keys);
  }

  static List<String> getRegisterdKeys(){
    return _tranTypesByKey.keys;
  }

  final Map<String, dynamic> _internal = new Map<String, dynamic>();

  Transmittable(){
    _registerAdditionalCoreTypes();
  }

  Transmittable.fromTranString(String str){
    _registerAdditionalCoreTypes();
    //TODO
  }

  noSuchMethod(Invocation inv){

    if(inv.isMethod){
      throw 'Methods are not transmittable.';
    }

    int positionalArgs = (inv.positionalArguments != null) ? inv.positionalArguments.length : 0;
    String property = MirrorSystem.getName(inv.memberName);

    if(inv.isGetter && (positionalArgs == 0)){
      if(_internal.containsKey(property)) {
        return _internal[property];
      }
      return null;
    }else if(inv.isSetter && positionalArgs == 1){
      _checkTypeIsRegistered(inv.positionalArguments[0]);
      property = property.replaceAll("=", "");
      _internal[property] = inv.positionalArguments[0];
      return _internal[property];
    }

    super.noSuchMethod(inv);
  }

  String toTranString(){
    var strB = new StringBuffer();
    var keys = _internal.keys;
    var len = keys.length;
    keys.forEach((k){
      var v = _internal[k];
      strB.write('$k:${_getValueString(v)}');
      if(k != keys.last){
        strB.write(',');
      }
    });
    return strB.toString();
  }

  String _getValueString(dynamic v){
    if(v is num){
      return v.toString();
    }else if(v is bool){
      return v.toString().substring(0,1);
    }else if(v is String){
      return '${v.length}:$v';
    }else if(v is List){
      var strB = new StringBuffer();
      strB.write('[');
      var len = v.length;
      v.forEach((i){
        strB.write(_getValueString(i));
        if(i != v.last){
          strB.write(',');
        }
      });
      return (strB..write(']')).toString();
    }else if(v is Transmittable){
      return '{${v.toTranString()}}';
    }else{
      //custom type, requires the user to have register a transmittable type converter methods
      Type type = reflect(v).type.reflectedType;
      var tranType = _tranTypesByType[type]; //NOTE: will probably require to handle derived types i.e. if a subtype wants to be converted this should be able to find the registered super type.
      if(tranType == null){
        throw 'Type "${type}" has not been registered with registerTranType().';
      }else{
        var tranStr = tranType._toStr(v);
        return '${tranType._key}:${tranStr.length}:$tranStr';
      }
    }
  }

  _checkTypeIsRegistered(dynamic v){
    if(v is num || v is bool || v is String || v is Transmittable){
      return;
    }else if(v is List){
      v.forEach((o) => _checkTypeIsRegistered(o));
      return;
    }else{
      Type type = reflect(v).type.reflectedType;
      if(_tranTypesByType.containsKey(type) == false){
        throw 'Type "$type" is not registerd.';
      }
    }
  }
}