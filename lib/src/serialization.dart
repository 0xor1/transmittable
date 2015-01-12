/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

final List<ValueProcessor> _valueProcessors = new List<ValueProcessor>();
final List<dynamic> _uniqueValues = new List<dynamic>();

String _getTranSectionFromValue(dynamic v){
  v = _valueProcessor(v);
  v = _handleUniqueValues(v);
  var tranCodec = _getTranCodecForValue(v);
  var tranStr = tranCodec._encode(v);
  var strB = new StringBuffer();
  strB.write(tranCodec._key);
  strB.write(_TSD);
  strB.write(tranStr.length);
  strB.write(_TSD);
  strB.write(tranStr);
  return strB.toString();
}

_TranCodec _getTranCodecForValue(dynamic v){
  //handle special/subtle types, datetime and duration are the only core types implemented so far that don't seem to have a problem
  var codec = _tranCodecsByType[v.runtimeType];
  if(codec != null){
    return codec;
  }
  var type = v == null? null:
             v is int? int:
             v is double? double:
             v is num? num:
             v is bool? bool:
             v is String? String:
             v is List? List:
             v is Set? Set:
             v is Map? Map:
             v is RegExp? RegExp:
             v is Type? Type:
             v is Symbol? Symbol:
             throw new UnregisteredTypeError(v.runtimeType);
  return _tranCodecsByType[type];
}

dynamic _valueProcessor(dynamic v){
  for(var i = _valueProcessors.length - 1; i > -1; i--){
    var vpp = _valueProcessors[i];
    v = vpp == null? v: vpp(v);
  }
  return v;
}

dynamic _handleUniqueValues(dynamic v){
  var valIndex = _uniqueValues.indexOf(v);
  if(valIndex == -1){
    _uniqueValues.add(v);
    return v;
  }else{
    return new _InternalPointer(valIndex);
  }
}

void _addNestedToTranString(Transmittable tran, ValueProcessor preProcessor){
  if(_uniqueValues.contains(tran)){
    throw new UnresolvableNestedReferenceLoopError(tran);
  }else{
    _valueProcessors.add(preProcessor);
  }
}

void _removeNestedToTranString(){
  _valueProcessors.remove(_valueProcessors.last);
  if(_valueProcessors.length == 0){
    _uniqueValues.clear();
  }
}

String _processIterableToString(Iterable iter){
  var strB = new StringBuffer();
  iter.forEach((o) => strB.write(_getTranSectionFromValue(o)));
  return strB.toString();
}

String _processMapToString(Map<dynamic, dynamic> m){
  var strB = new StringBuffer();
  m.forEach((k, v){ strB.write(_getTranSectionFromValue(k)); strB.write(_getTranSectionFromValue(v)); });
  return strB.toString();
}

String _processTranToString(Transmittable t){
  return _processMapToString(t._internal);
}

String _processTypeToString(Type t){
  if(_tranCodecsByType.containsKey(t)){
    return _tranCodecsByType[t]._key;
  }else{
    throw new UnregisteredTypeError(t);
  }
}

String _processRegExpToString(RegExp r){
  var p = r.pattern;
  var c = r.isCaseSensitive? 't': 'f';
  var m = r.isMultiLine? 't': 'f';
  return '${p.length}$_TSD${p}$c$m';
}