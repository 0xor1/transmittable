/**
 * author: Daniel Robinson http://github.com/0xor1
 */

library Transmittable;

import 'dart:mirrors';

/**
 * Register custom types with a given [String] [key] to make it transmittable.
 */
void registerTransmittableType(String key, Type type, ToTransmittableString toString, FromTransmittableString fromString){
  new _TransmittableType(key, type, toString, fromString);
}

/**
 * Signature for a function which takes an object of type [T] and returns
 * a [String] representation of that object.
 */
typedef String ToTransmittableString<T>(T obj);

/**
 *  Signature for a function which takes a string representation of an
 *  object of type [T] and returns an instance of that object.
 */
typedef T FromTransmittableString<T>(String str);


class _TransmittableType{

  static final Map<String, _TransmittableType> _stringIndex = new Map<String, _TransmittableType>();
  static final Map<Type, _TransmittableType> _typeIndex = new Map<Type, _TransmittableType>();
  static bool _coreTypesHaveBeenRegistered = false;
  static void _registerCoreTypes(){
    if(_coreTypesHaveBeenRegistered){return;}
    _coreTypesHaveBeenRegistered = true;
    registerTransmittableType('dt', DateTime, (DateTime dt) => dt.toString(), (String dt) => DateTime.parse(dt));
    registerTransmittableType('dur', Duration, (Duration dur) => '${dur.inMilliseconds}', (String dur) => new Duration(milliseconds: num.parse(dur)));
    //TODO add more core types as seems appropriate
  }

  final String _key;
  final Type _type;
  final ToTransmittableString _toString;
  final FromTransmittableString _fromString;

  _TransmittableType(String this._key, Type this._type, ToTransmittableString this._toString, FromTransmittableString this._fromString){
    _registerCoreTypes();
    if(_stringIndex.containsKey(_key)){
      throw 'Key "$_key" has already been registered with type "$_type".';
    }else if(_typeIndex.containsKey(_type)){
      throw 'Type "$_type" has already been registered with key "$_key".';
    }else{
      _stringIndex[_key] = _typeIndex[_type] = this;
    }
  }
}

@proxy
class Transmittable{

  static List<Type> getRegisterdTypes(){
    return [num, bool, String, List]..addAll(_TransmittableType._typeIndex.keys);
  }

  static List<String> getRegisterdKeys(){
    return _TransmittableType._stringIndex.keys;
  }

  final Map<String, dynamic> _internal = new Map<String, dynamic>();

  Transmittable(){
    _TransmittableType._registerCoreTypes();
  }

  Transmittable.fromTransmittableString(String str){
    _TransmittableType._registerCoreTypes();
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

  String toJson(){
    String json = '{';
    _internal.forEach((k, v){
      json = '$json$k:${_convertValueToString(v)},';
    });
    //cut off the last comma
    json = json.substring(0, json.length - 1);
    return '$json}';
  }

  String _convertValueToString(dynamic v){
    String str;
    if(v is num || v is bool){
      str = v.toString();
    }else if(v is String){
      str = '"$v"';
    }else if(v is List){
      str = '[';
      v.forEach((o){
        str = '$str${_convertValueToString(o)},';
      });
      //cut off last comma
      str = str.substring(0,str.length - 1);
      str = '$str]';
    }else{
      //custom type, requires the user to have register a transmittable type converter methods
      Type type = reflect(v).type.reflectedType;
      var tranType = _TransmittableType._typeIndex[type]; //NOTE: will probably require to handle derived types i.e. if a subtype wants to be converted this should be able to find the registered super type.
      if(tranType == null){
        throw 'Type "${type}" has not been register with registerTransmittableType().';
      }else{
        str = '{${tranType._key}:${tranType._toString(v)}}';
      }
    }
    return str;
  }

  _checkTypeIsRegistered(dynamic v){
    if(v is num || v is bool || v is String){
      return;
    }else if(v is List){
      v.forEach((o) => _checkTypeIsRegistered(o));
      return;
    }else{
      Type type = reflect(v).type.reflectedType;
      if(_TransmittableType._typeIndex.containsKey(type) == false){
        throw 'Type "$type" is not registerd.';
      }
    }
  }
}