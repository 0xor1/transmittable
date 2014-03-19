/**
 * author: Daniel Robinson http://github.com/0xor1
 */

/**
 * Data structures for de/serializing typed objects to and from strings
 */
library Transmittable;

import 'dart:mirrors';

part 'src/tran_codec.dart';
part 'tran_method_error.dart';
part 'duplicate_tran_key_error.dart';
part 'duplicate_tran_type_error.dart';
part 'unregistered_tran_codec_error.dart';
part 'invalid_tran_key_error.dart';

const String TRAN_DELIMITER = ':';
const String TD = TRAN_DELIMITER;

/**
 * Register a [tranSubtype]
 */
void registerTranSubtype(String key, Type subtype){
  ClassMirror cm = reflectClass(subtype);
  registerTranCodec(key, subtype, _processTranToString, (String s) => _processStringBackToTran(cm.newInstance(const Symbol(''), new List<dynamic>()).reflectee, s));
}
/**
 * Registers a [type] with a given [key] to make it transmittable.
 */
void registerTranCodec(String key, Type type, TranEncode encode, TranDecode decode){
  _registerCoreTypes();
  if(key.contains(TD)){
    throw new InvalidTranKeyError(key);
  }else if(_tranCodecsByKey.containsKey(key)){
    throw new DuplicateTranKeyError(key, type);
  }else if(_tranCodecsByType.containsKey(type)){
    throw new DuplicateTranCodecError(type, key);
  }else{
    _tranCodecsByKey[key] = _tranCodecsByType[type] = new _TranCodec(key, type, encode, decode);
  }
}

/**
 * Signature for a function which takes an object of type [T] and returns
 * a [String] representation of that object.
 */
typedef String TranEncode<T>(T obj);

/**
 *  Signature for a function which takes a string representation of an
 *  object of type [T] and returns an instance of that object.
 */
typedef T TranDecode<T>(String str);

typedef dynamic ValueProcessor(dynamic value);

Map<Type, String> getRegisterdMappingsByType(){
  var map = new Map<Type, String>();
  _tranCodecsByType.forEach((k, v) => map[k] = v._key);
  return map;
}

Map<String, Type> getRegisterdMappingsByKey(){
  var map = new Map<String, Type>();
  _tranCodecsByKey.forEach((k, v) => map[k] = v._type);
  return map;
}

@proxy
class Transmittable{

  Map<String, dynamic> _internal = new Map<String, dynamic>();

  Transmittable(){
    _registerCoreTypes();
  }

  factory Transmittable.fromTranString(String s, [ValueProcessor postProcessor = null]){
    _registerCoreTypes();
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
}

final Set<dynamic> _values = new Set<dynamic>();

ValueProcessor _valueProcessor = null;

String _getTranSectionFromValue(dynamic v){
  if(_valueProcessor != null){ v = _valueProcessor(v); }
  //handle special/subtle types, datetime and duration are the only core types implemented so far that don't seem to have a problem
  Type type = v == null? null: v is num? num: v is bool? bool: v is String? String: v is List? List: v is Set? Set: v is Map? Map: v is RegExp? RegExp: v is Type? Type: reflect(v).type.reflectedType;
  if(!_tranCodecsByType.containsKey(type)){
    throw new UnregisteredTranCodecError(type);
  }
  var tranCodec = _tranCodecsByType[type];
  var tranStr = tranCodec._encode(v);
  return '${tranCodec._key}$TD${tranStr.length}$TD$tranStr';
}

dynamic _getValueFromTranSection(String s){
  var idx1 = s.indexOf(TD);
  var idx2 = s.indexOf(TD, idx1 + 1);
  var key = s.substring(0, idx1);
  var v = _tranCodecsByKey[key]._decode(s.substring(idx2 + 1));
  if(_valueProcessor != null){ v = _valueProcessor(v); }
  return v;
}

final Map<String, _TranCodec> _tranCodecsByKey = new Map<String, _TranCodec>();
final Map<Type, _TranCodec> _tranCodecsByType = new Map<Type, _TranCodec>();
bool _coreTypesRegistered = false;
void _registerCoreTypes(){
  if(_coreTypesRegistered){return;}
  _coreTypesRegistered = true;
  registerTranCodec('_', null, (o)=> '', (s) => null);
  registerTranCodec('n', num, (num n) => n.toString(), (String s) => num.parse(s));
  registerTranCodec('i', int, (int i) => i.toString(), (String s) => int.parse(s));
  registerTranCodec('f', double, (double f) => f.toString(), (String s) => double.parse(s));
  registerTranCodec('s', String, (String s) => s, (String s) => s);
  registerTranCodec('b', bool, (bool b) => b ? 't' : 'f', (String s) => s == 't' ? true : false);
  registerTranCodec('l', List, _processIterableToString, (String s) => _processStringBackToListOrSet(new List(), s));
  registerTranCodec('se', Set, _processIterableToString, (String s) => _processStringBackToListOrSet(new Set(), s));
  registerTranCodec('m', Map, _processMapToString, _processStringBackToMap);
  registerTranCodec('r', RegExp, _processRegExpToString, _processStringBackToRegExp);
  registerTranCodec('t', Type, (Type t) => _processTypeToString(t),(String s) => _tranCodecsByKey[s]._type);
  registerTranCodec('d', DateTime, (DateTime d) => d.toString(), (String s) => DateTime.parse(s));
  registerTranCodec('du', Duration, (Duration dur) => '${dur.inMilliseconds}', (String s) => new Duration(milliseconds: num.parse(s)));
  registerTranSubtype('tr', Transmittable);
}

dynamic _processStringBackToListOrSet(dynamic col, String s){
  if(!(col is Set) && !(col is List)){ throw 'Expecting either List or Set only'; }
  int start = 0;
  while(start < s.length){
    int end;
    List<String> parts = new List<String>(); //0 is key, 1 is data length, 2 is data
    for(var i = 0; i < 3; i++){
      end = i < 2 ? s.indexOf(TD, start) : start + num.parse(parts[1]);
      parts.add(s.substring(start, end));
      start = i < 2 ? end + 1 : end;
    }
    var tranCodec = _tranCodecsByKey[parts[0]];
    col.add(tranCodec._decode(parts[2]));
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
        end = j < 2 ? s.indexOf(TD, start) : start + num.parse(parts[1]);
        parts.add(s.substring(start, end));
        start = j < 2 ? end + 1 : end;
      }
      var tranCodec = _tranCodecsByKey[parts[0]];
      if(i == 0){
        key = tranCodec._decode(parts[2]);
      }else{
        map[key] = tranCodec._decode(parts[2]);
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

String _processTranToString(Transmittable t){
  return _processMapToString(t._internal);
}

Transmittable _processStringBackToTran(Transmittable t, String s){
  return t.._internal = _processStringBackToMap(s);
}

String _processTypeToString(Type t){
  if(_tranCodecsByType.containsKey(t)){
    return _tranCodecsByType[t]._key;
  }else{
    throw new UnregisteredTranCodecError(t);
  }
}

String _processRegExpToString(RegExp r){
  var p = r.pattern;
  var c = r.isCaseSensitive? 't': 'f';
  var m = r.isMultiLine? 't': 'f';
  return '${p.length}$TD${p}$c$m';
}

RegExp _processStringBackToRegExp(String s){
  var start = s.indexOf(TD) + 1;
  var end = start + num.parse(s.substring(0, start - 1));
  var p = s.substring(start, end);
  var c = s.substring(end, end + 1) == 't';
  var m = s.substring(end + 1, end + 2) == 't';
  return new RegExp(p, caseSensitive: c, multiLine: m);
}