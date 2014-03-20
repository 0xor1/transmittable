/**
 * author: Daniel Robinson http://github.com/0xor1
 */

/**
 * Data structures for de/serializing typed objects to and from strings
 */
library Transmittable;

import 'dart:mirrors';
import 'package:bson/bson.dart' show ObjectId;

part 'src/tran_codec.dart';
part 'src/registration.dart';
part 'src/serialization.dart';
part 'tran_method_error.dart';
part 'duplicate_tran_key_error.dart';
part 'duplicate_tran_type_error.dart';
part 'unregistered_tran_codec_error.dart';
part 'invalid_tran_key_error.dart';

const String TRAN_DELIMITER = ':';
const String TD = TRAN_DELIMITER;

/*
 * A function to processes each value either before serialization
 * or after deserialization
 */
typedef dynamic ValueProcessor(dynamic value);

Map<Type, String> getRegisteredMappingsByType(){
  var map = new Map<Type, String>();
  _tranCodecsByType.forEach((k, v) => map[k] = v._key);
  return map;
}

Map<String, Type> getRegisteredMappingsByKey(){
  var map = new Map<String, Type>();
  _tranCodecsByKey.forEach((k, v) => map[k] = v._type);
  return map;
}

@proxy
class Transmittable{

  Map<String, dynamic> _internal = new Map<String, dynamic>();
  ObjectId _tranId;

  Transmittable(){
    _registerTypes();
    _tranId = new ObjectId();
  }

  factory Transmittable.fromTranString(String s, [ValueProcessor postProcessor = null]){
    _registerTypes();
    _valueProcessor = postProcessor;
    var v = _getValueFromTranSection(s);
    _valueProcessor = null;
    return v;
  }

  String toTranString([ValueProcessor preProcessor = null]){
    _valueProcessor = preProcessor;
    var s = _getTranSectionFromValue(this);
    _valueProcessor = null;
    return s;
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
      property = property.replaceAll("=", "");
      _internal[property] = inv.positionalArguments[0];
      return _internal[property];
    }

    super.noSuchMethod(inv);
  }

  void forEach(void f(k, v)) => _internal.forEach(f);
  void clear() => _internal.clear();
  bool operator ==(Transmittable other) => other._tranId == _tranId;
  int get hashCode => _tranId.hashCode;
}