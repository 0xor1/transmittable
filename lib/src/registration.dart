/*
 * author:  Daniel Robinson http://github.com/0xor1
 */

part of Transmittable;

/**
 * Register a [subtype] of Transmittable
 */
void registerTranSubtype(String key, Type subtype){
  ClassMirror cm = reflectClass(subtype);
  _registerTranCodec(key, subtype, true, _processTranToString, (String s) => _processStringBackToTran(cm.newInstance(const Symbol(''), new List<dynamic>()).reflectee, s));
}

/**
 * Registers a [type] with a given [key] to make it transmittable.
 */
void registerTranCodec(String key, Type type, TranEncode encode, TranDecode decode) =>_registerTranCodec(key, type, false, encode, decode);

void _registerTranCodec(String key, Type type, bool isTranSubtype, TranEncode encode, TranDecode decode){
  _registerTypes();
  if(key.contains(TD)){
    throw new InvalidTranKeyError(key);
  }else if(_tranCodecsByKey.containsKey(key)){
    throw new DuplicateTranKeyError(key, type);
  }else if(_tranCodecsByType.containsKey(type)){
    throw new DuplicateTranCodecError(type, key);
  }else{
    _tranCodecsByKey[key] = _tranCodecsByType[type] = new _TranCodec(key, type, isTranSubtype, encode, decode);
  }
}

/**
 * A function which takes an object of type [T] and returns
 * a [String] representation of that object.
 */
typedef String TranEncode<T>(T obj);

/**
 *  A function which takes a string representation of an
 *  object of type [T] and returns an instance of that object.
 */
typedef T TranDecode<T>(String str);

bool _typesRegistered = false;
void _registerTypes(){
  if(_typesRegistered){return;}
  _typesRegistered = true;
  registerTranCodec('_', null, (o)=> '', (s) => null);
  registerTranCodec(IPK, _InternalPointer, (_InternalPointer ip) => ip._uniqueValueIndex.toString(), (String s) => new _InternalPointer(int.parse(s)));
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
  registerTranCodec('du', Duration, (Duration dur) => dur.inMilliseconds.toString(), (String s) => new Duration(milliseconds: num.parse(s)));
  registerTranSubtype('tr', Transmittable);
}