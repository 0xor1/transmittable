/*
 * author:  Daniel Robinson http://github.com/0xor1
 */

part of Transmittable;

final Map<String, String> _namespaces = new Map<String, String>();
String _currentNamespace = null;

/**
 * Register a group of [Transmittable] types inside a [namespace].
 * [namespace] is the string that will be used when [Transmittable.toTranString]
 * is called. [namespaceFull] can be any string value, however it is recommended
 * the name of the package and, if appropriate, library are included, this is to
 * help with debugging if namespace clashes do occur.
 */
void registerTranTypes(String namespaceFull, String namespace, void registerTypes()){
  try{
    if(_currentNamespace != null){
      throw new NestedRegisterTranTypesCallError(_currentNamespace, namespace);
    }
    var illegalPattern = new RegExp('[$TSD$TND]');
    if(namespace.contains(illegalPattern)){
      throw new InvalidTranNamespaceError(namespace);
    }
    if(_namespaces.keys.contains(namespace)){
      throw new DuplicateTranNamespaceError(namespace, namespaceFull);
    }
    _namespaces[namespace] = namespaceFull;
    _currentNamespace = namespace;
    registerTypes();
  }finally{
    _currentNamespace = null;
  }
}

/**
 * Register a [subtype] of [Transmittable].
 * Calls to this function can only be made inside the last argument of [registerTranTypes].
 * This is to ensure all [key]-[subtype] registrations are properly namespaced.
 */
void registerTranSubtype(String key, Type subtype){
  ClassMirror cm = reflectClass(subtype);
  _registerTranCodec(key, subtype, true, _processTranToString, (String s) => _processStringBackToTran(cm.newInstance(const Symbol(''), new List<dynamic>()).reflectee, s));
}

/**
 * Registers a [type] with a given [key] to make it transmittable.
 * Calls to this function can only be made inside the last argument of [registerTranTypes].
 * This is to ensure all [key]-[type] registrations are properly namespaced.
 */
void registerTranCodec(String key, Type type, TranEncode encode, TranDecode decode) =>_registerTranCodec(key, type, false, encode, decode);

void _registerTranCodec(String key, Type type, bool isTranSubtype, TranEncode encode, TranDecode decode){
  if(_currentNamespace == null){
    throw new TranRegistrationOutsideOfNamespaceError(key, type);
  }
  _registerTranTypes();
  var illegalPattern = new RegExp('[$TSD$TND]');
  if(key.contains(illegalPattern)){
    throw new InvalidTranKeyError(key);
  }else{
    key = '$_currentNamespace.$key';
  }
  if(_tranCodecsByKey.containsKey(key)){
    throw new DuplicateTranKeyError(key, type);
  }else if(_tranCodecsByType.containsKey(type)){
    throw new DuplicateTranTypeError(type, key);
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

bool _registeredTranTypes = false;
void _registerTranTypes(){
  if(_registeredTranTypes){ return; }
  _registeredTranTypes = true;
  registerTranTypes('Transmittable', '', (){
    registerTranCodec('_', null, (o)=> '', (s) => null);
    registerTranCodec(IPK, _InternalPointer, (_InternalPointer ip) => ip._uniqueValueIndex.toString(), (String s) => new _InternalPointer(int.parse(s)));
    registerTranCodec('a', num, (num n) => n.toString(), (String s) => num.parse(s));
    registerTranCodec('b', int, (int i) => i.toString(), (String s) => int.parse(s));
    registerTranCodec('c', double, (double f) => f.toString(), (String s) => double.parse(s));
    registerTranCodec('d', String, (String s) => s, (String s) => s);
    registerTranCodec('e', bool, (bool b) => b ? 't' : 'f', (String s) => s == 't' ? true : false);
    registerTranCodec('f', List, _processIterableToString, (String s) => _processStringBackToListOrSet(new List(), s));
    registerTranCodec('g', Set, _processIterableToString, (String s) => _processStringBackToListOrSet(new Set(), s));
    registerTranCodec('h', Map, _processMapToString, _processStringBackToMap);
    registerTranCodec('i', RegExp, _processRegExpToString, _processStringBackToRegExp);
    registerTranCodec('j', Type, (Type t) => _processTypeToString(t),(String s) => _tranCodecsByKey[s]._type);
    registerTranCodec('k', DateTime, (DateTime d) => d.toString(), (String s) => DateTime.parse(s));
    registerTranCodec('l', Duration, (Duration dur) => dur.inMilliseconds.toString(), (String s) => new Duration(milliseconds: num.parse(s)));
    registerTranCodec('m', Symbol, (Symbol sy) => MirrorSystem.getName(sy), (String s) => MirrorSystem.getSymbol(s)); //TODO will this cause problems if multiple libraries have the same identifiers
    registerTranSubtype('n', Transmittable);
  });

}