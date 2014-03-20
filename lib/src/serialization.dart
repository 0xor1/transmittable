/**
 * author: Daniel Robinson  http://github.com/0xor1
 */

part of Transmittable;

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

Transmittable _processStringBackToTran(Transmittable t, String s){
  var index = s.indexOf(TD);
  t._tranId = new ObjectId.fromHexString(s.substring(0, index));
  return t.._internal = _processStringBackToMap(s.substring(index + 1));
}

String _processTranToString(Transmittable t){
  return '${t._tranId.toHexString()}$TD${_processMapToString(t._internal)}';
}

String _processTypeToString(Type t){
  if(_tranCodecsByType.containsKey(t)){
    return _tranCodecsByType[t]._key;
  }else{
    throw new UnregisteredTranCodecError(t);
  }
}

RegExp _processStringBackToRegExp(String s){
  var start = s.indexOf(TD) + 1;
  var end = start + num.parse(s.substring(0, start - 1));
  var p = s.substring(start, end);
  var c = s.substring(end, end + 1) == 't';
  var m = s.substring(end + 1, end + 2) == 't';
  return new RegExp(p, caseSensitive: c, multiLine: m);
}

String _processRegExpToString(RegExp r){
  var p = r.pattern;
  var c = r.isCaseSensitive? 't': 'f';
  var m = r.isMultiLine? 't': 'f';
  return '${p.length}$TD${p}$c$m';
}