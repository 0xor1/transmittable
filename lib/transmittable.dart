/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

/// Data structures for de/serializing typed objects to and from strings
library transmittable;

@MirrorsUsed(targets: const[], override: '*')
import 'dart:mirrors';

part 'src/tran_codec.dart';
part 'src/registration.dart';
part 'src/serialization.dart';
part 'src/deserialization.dart';
part 'src/internal_pointer.dart';
part 'src/annotation.dart';
part 'src/error/unresolvable_nested_reference_loop_error.dart';
part 'src/error/duplicate_tran_type_error.dart';
part 'src/error/duplicate_tran_key_error.dart';
part 'src/error/unregistered_tran_codec_error.dart';
part 'src/error/invalid_tran_namespace_error.dart';
part 'src/error/duplicate_tran_namespace_error.dart';
part 'src/error/duplicate_tran_annotation_identifier_error.dart';

const String _TRAN_SECTION_DELIMITER = ':';
const String _TSD = _TRAN_SECTION_DELIMITER;

const String _READ_ONLY_PROPERTY_FLAG = '*';
const String _ROPF = _READ_ONLY_PROPERTY_FLAG;

/*
 * It is critical that _KEY_PIECES satisfies the following criteria:
 *  * Is constant - its values must never change in value or ordering
 *  * Does NOT contain the _TRAN_SECTION_DELIMITER
 *  * Does NOT contain the empty string
 *  * Does NOT contain any duplicated values
 */
const List<String> _KEY_PIECES = const [
  '1', '!', '2', '"', '3', '£', '4', r'$', '5', '%', '6', '^', '7', '&', '8', '*', '9', '(', '0', ')',
  'a', 'A', 'b', 'B', 'c', 'C', 'd', 'D', 'e', 'E', 'f', 'F', 'g', 'G', 'h', 'H', 'i', 'I', 'j', 'J',
  'k', 'K', 'l', 'L', 'm', 'M', 'n', 'N', 'o', 'O', 'p', 'P', 'q', 'Q', 'r', 'R', 's', 'S', 't', 'T',
  'u', 'U', 'v', 'V', 'w', 'W', 'x', 'X', 'y', 'Y', 'z', 'Z', r'\', '|', ',', '<', '.', '>', '/', '?',
  ';', "'", '@', '#', '~', '[', '{', ']', '}', '-', '_', '=', '+', '`', '¬'
];

/// The signature of a generic value processor function.
///
/// When de/serializing to/from tran string the value passed in
/// will be replaced by the value returned.
typedef dynamic ValueProcessor(dynamic value);

/// The signature for a Registrar function returned from [generateRegistrar].
///
/// When called it will register all the [TranRegistration]s passed into the
/// [generateRegistrar] call that created it.
typedef void Registrar();

Map<Type, String> get _registeredMappingsByType{
  var map = new Map<Type, String>();
  _tranCodecsByType.forEach((k, v) => map[k] = v._key);
  return map;
}

Map<String, Type> get _registeredMappingsByKey{
  var map = new Map<String, Type>();
  _tranCodecsByKey.forEach((k, v) => map[k] = v._type);
  return map;
}

/// An object that can be serialized in to a string and back into its self again
/// allowing named and typed properties to be sent across http connections.
class Transmittable{

  Map<String, dynamic> _internal = new Map<String, dynamic>();

  /// Creates a new plane Transmittable object.
  Transmittable(){
    _initTranRegistrations();
  }

  /// Creates a new Transmittable object based on the tranString passed in.
  factory Transmittable.fromTranString(String tranStr, [ValueProcessor postProcessor = null]){
    _initTranRegistrations();
    dynamic v;
    try{
      _addNestedfromTranString(postProcessor);
      v = _getValueFromTranSection(tranStr);
      _removeNestedfromTranString();
    }catch(ex){
      _collectionsWithInternalPointers.clear();
      _valueProcessors.clear();
      _uniqueValues.clear();
      throw ex;
    }
    return v;
  }

  /// Returns the string representation of this Transmittable object.
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

  dynamic get(String name) => _internal[name];

  dynamic set(String name, value) => _internal[name] = value;

  /// Clears the transmittable object wiping all properties and values.
  void clear() => _internal.clear();

  /// Iterates over each property on the Transmittable object with its associated value.
  void forEach(void func(name, value)) => _internal.forEach(func);
}