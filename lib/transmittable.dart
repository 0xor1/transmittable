/**
 * author: Daniel Robinson http://github.com/0xor1
 */

/**
 * Data structures for de/serializing typed objects to and from strings
 */
library Transmittable;

import 'dart:mirrors';

part 'src/tran_codec.dart';
part 'src/registration.dart';
part 'src/serialization.dart';
part 'src/deserialization.dart';
part 'src/internal_pointer.dart';
part 'src/error/unresolvable_nested_reference_loop_error.dart';
part 'src/error/tran_registration_outside_of_namespace_error.dart';
part 'src/error/tran_method_error.dart';
part 'src/error/duplicate_tran_key_error.dart';
part 'src/error/duplicate_tran_type_error.dart';
part 'src/error/unregistered_tran_codec_error.dart';
part 'src/error/invalid_tran_key_error.dart';
part 'src/error/invalid_tran_namespace_error.dart';
part 'src/error/duplicate_tran_namespace_error.dart';
part 'src/error/nested_register_tran_types_call_error.dart';

const String TRAN_SECTION_DELIMITER = ':';
const String TSD = TRAN_SECTION_DELIMITER;

const String TRAN_NAMESPACE_DELIMITER = '.';
const String TND = TRAN_NAMESPACE_DELIMITER;

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

  Transmittable(){
    _registerTranTranTypes();
  }

  factory Transmittable.fromTranString(String s, [ValueProcessor postProcessor = null]){
    _registerTranTranTypes();
    dynamic v;
    try{
      _addNestedfromTranString(postProcessor);
      v = _getValueFromTranSection(s);
      _removeNestedfromTranString();
    }catch(ex){
      _collectionsWithInternalPointers.clear();
      _valueProcessors.clear();
      _uniqueValues.clear();
      throw ex;
    }
    return v;
  }

  String toTranString([ValueProcessor preProcessor = null]){
    String s;
    try{
      _addNestedToTranString(this, preProcessor);
      s = _getTranSectionFromValue(this);
      _removeNestedToTranString();
    }catch(ex){
      _valueProcessors.clear();
      _uniqueValues.clear();
      throw ex;
    }
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
}