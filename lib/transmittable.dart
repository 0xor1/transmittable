/**
 * author: Daniel Robinson http://github.com/0xor1
 */

/**
 * Data structures for serializing/deserializing typed objects
 */
library Transmittable;

import 'dart:mirrors';

part '_tran_type.dart';
part 'tran_method_error.dart';
part 'duplicate_tran_key_error.dart';
part 'duplicate_tran_type_error.dart';
part 'unregistered_tran_type_error.dart';
part 'invalid_tran_key_error.dart';

/**
 * Registers a [type] with a given [key] to make it transmittable.
 */
void registerTranType(String key, Type type, ToTranString toStr, FromTranString fromStr){
  _registerAdditionalCoreTypes();
  if(key.contains(new RegExp(r'^\d|,|:|{|}|[|]'))){
    throw new InvalidTranKeyError(key);
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
      throw new TranMethodError(MirrorSystem.getName(inv.memberName));
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
      Type type = reflect(v).type.reflectedType;
      var tranType = _tranTypesByType[type]; //NOTE: will probably require to handle derived types i.e. if a subtype wants to be converted this should be able to find the registered super type.
      var tranStr = tranType._toStr(v);
      return '${tranType._key}:${tranStr.length}:$tranStr';
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
        throw new UnregisteredTranTypeError(type);
      }
    }
  }
}