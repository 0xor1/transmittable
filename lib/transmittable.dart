/**
 * author: Daniel Robinson http://github.com/0xor1
 */

/**
 * Data structures for de/serializing typed objects to and from strings
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
  registerCoreTypes();
  if(key.contains(new RegExp(r':'))){
    throw new InvalidTranKeyError(key);
  }else if(_tranTypesByKey.containsKey(key)){
    throw new DuplicateTranKeyError(key, type);
  }else if(_tranTypesByType.containsKey(type)){
    throw new DuplicateTranTypeError(type, key);
  }else{
    _tranTypesByKey[key] = _tranTypesByType[type] = new _TranType(key, type, toStr, fromStr);
  }
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

Map<Type, String> getRegisterdMappingsByType(){
  var map = new Map<Type, String>();
  _tranTypesByType.forEach((k, v) => map[k] = v._key);
  return map;
}

Map<String, Type> getRegisterdMappingsByKey(){
  var map = new Map<String, Type>();
  _tranTypesByKey.forEach((k, v) => map[k] = v._type);
  return map;
}

@proxy
class Transmittable{

  final Map<String, dynamic> _internal = new Map<String, dynamic>();

  Transmittable(){
    registerCoreTypes();
  }

  factory Transmittable.fromTranString(String s, [Transmittable tran]){
    registerCoreTypes();
    if(tran == null){
      tran = new Transmittable();
    }
    int start = 0;
    while(start < s.length){
      int end;
      List<String> parts = new List<String>(); //0 is name, 1 is key, 2 is data length, 3 is data
      for(var i = 0; i < 4; i++){
        end = i < 3 ? s.indexOf(':', start) : start + num.parse(parts[2]);
        parts.add(s.substring(start, end));
        start = i < 3 ? end + 1 : end;
      }
      var tranType = _tranTypesByKey[parts[1]];
      tran._internal[parts[0]] = tranType._fromStr(parts[3]);
    }
    return tran;
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
    keys.forEach((k){
      var v = _internal[k];
      strB.write('$k:${_getTranSectionFromValue(v)}');
    });
    return strB.toString();
  }
}

String _getTranSectionFromValue(dynamic v){
  //handle special/subtle types, datetime and duration are the only core types implemented so far that don't seem to have a problem
  Type type = v is num? num: v is bool? bool: v is String? String: v is List? List: v is Set? Set: v is Map? Map: v is RegExp? RegExp: v is Transmittable? Transmittable: reflect(v).type.reflectedType;
  if(!_tranTypesByType.containsKey(type)){
    throw new UnregisteredTranTypeError(type);
  }
  var tranType = _tranTypesByType[type];
  var tranStr = tranType._toStr(v);
  return '${tranType._key}:${tranStr.length}:$tranStr';
}

_checkTypeIsRegistered(dynamic v){
  if(v is num || v is bool || v is String || v is RegExp){
    return;
  }else if(v is List || v is Set){
    v.forEach((o) => _checkTypeIsRegistered(o));
    return;
  } else if(v is Map){
    v.forEach((k, v){
      _checkTypeIsRegistered(k);
      _checkTypeIsRegistered(v);
    });
  }else{
    Type type = reflect(v).type.reflectedType;
    if(!_tranTypesByType.containsKey(type)){
      throw new UnregisteredTranTypeError(type);
    }
  }
}


final Map<String, _TranType> _tranTypesByKey = new Map<String, _TranType>();
final Map<Type, _TranType> _tranTypesByType = new Map<Type, _TranType>();
bool _coreTypesRegistered = false;
void registerCoreTypes(){
  if(_coreTypesRegistered){return;}
  _coreTypesRegistered = true;
  registerTranType('n', num, (num n) => n.toString(), (String s) => num.parse(s));
  registerTranType('s', String, (String s) => s, (String s) => s);
  registerTranType('b', bool, (bool b) => b ? 't' : 'f', (String s) => s == 't' ? true : false);
  registerTranType('l', List, (List l) => _processIterableToString(l), (String s) => _processStringBackToListsAndSets(new List(), s));
  registerTranType('se', Set, (Set se) => _processIterableToString(se), (String s) => _processStringBackToListsAndSets(new Set(), s));
  registerTranType('m', Map, (Map m) => _processMapToString(m), (String s) => _processStringBackToMap(s));
  registerTranType('r', RegExp, (RegExp r){ var p = r.pattern; var c = r.isCaseSensitive? 't': 'f'; var m = r.isMultiLine? 't': 'f'; return '${p.length}:${p}$c$m'; }, (String s){ var start = s.indexOf(':') + 1; var end = start + num.parse(s.substring(0, start - 1)); var p = s.substring(start, end); var c = s.substring(end, end + 1) == 't'; var m = s.substring(end + 1, end + 2) == 't'; return new RegExp(p, caseSensitive: c, multiLine: m); });
  registerTranType('d', DateTime, (DateTime d) => d.toString(), (String s) => DateTime.parse(s));
  registerTranType('du', Duration, (Duration dur) => '${dur.inMilliseconds}', (String s) => new Duration(milliseconds: num.parse(s)));
  //adding in Transmittable here too
  registerTranType('t', Transmittable, (Transmittable t) => t.toTranString(), (String s) => new Transmittable.fromTranString(s));
}

dynamic _processStringBackToListsAndSets(dynamic col, String s){
  if(!(col is Set) && !(col is List)){ throw 'Expecting either List or Set only'; }
  int start = 0;
  while(start < s.length){
    int end;
    List<String> parts = new List<String>(); //0 is key, 1 is data length, 2 is data
    for(var i = 0; i < 3; i++){
      end = i < 2 ? s.indexOf(':', start) : start + num.parse(parts[1]);
      parts.add(s.substring(start, end));
      start = i < 2 ? end + 1 : end;
    }
    var tranType = _tranTypesByKey[parts[0]];
    col.add(tranType._fromStr(parts[2]));
  }
  return col;
}

String _processIterableToString(Iterable iter){
  var strB = new StringBuffer();
  iter.forEach((o) => strB.write(_getTranSectionFromValue(o)));
  return strB.toString();
}

Map<dynamic, dynamic> _processStringBackToMap(String s){
  Map<dynamic, dynamic> map = new Map();
  int start = 0;
  while(start < s.length){
    int end;
    var key;
    for(var i = 0; i < 2; i++){
      List<String> parts = new List<String>(); //0 is key, 1 is data length, 2 is data
      for(var j = 0; j < 3; j++){
        end = j < 2 ? s.indexOf(':', start) : start + num.parse(parts[1]);
        parts.add(s.substring(start, end));
        start = j < 2 ? end + 1 : end;
      }
      var tranType = _tranTypesByKey[parts[0]];
      if(i == 0){
        key = tranType._fromStr(parts[2]);
      }else{
        map[key] = tranType._fromStr(parts[2]);
      }
    }
  }
  return map;
}

String _processMapToString(Map<dynamic, dynamic> m){
  var strB = new StringBuffer();
  m.forEach((k, v){ strB.write(_getTranSectionFromValue(k)); strB.write(_getTranSectionFromValue(v)); });
  return strB.toString();
}