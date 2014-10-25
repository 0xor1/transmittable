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
part 'src/error/unresolvable_nested_reference_loop_error.dart';
part 'src/error/tran_method_error.dart';
part 'src/error/duplicate_tran_type_error.dart';
part 'src/error/duplicate_tran_key_error.dart';
part 'src/error/unregistered_tran_codec_error.dart';
part 'src/error/invalid_tran_namespace_error.dart';
part 'src/error/duplicate_tran_namespace_error.dart';
part 'src/error/transmittable_locked_error.dart';

/// The string which marks the boundary between sections of a transmittable string key:length:data.
/// Made public for unit testing purposes.
const String TRAN_SECTION_DELIMITER = ':';

/// The abbreviated name of [TRAN_SECTION_DELIMITER] for brevity and convenience.
/// Made public for unit testing purposes.
const String TSD = TRAN_SECTION_DELIMITER;

/// The list of strings which are used to generate type keys when registering transmittable types.
/// Made public for unit testing purposes.
const List<String> KEY_PIECES = const [
  '1', '!', '2', '"', '3', '£', '4', r'$', '5', '%', '6', '^', '7', '&', '8', '*', '9', '(', '0', ')',
  'a', 'A', 'b', 'B', 'c', 'C', 'd', 'D', 'e', 'E', 'f', 'F', 'g', 'G', 'h', 'H', 'i', 'I', 'j', 'J',
  'k', 'K', 'l', 'L', 'm', 'M', 'n', 'N', 'o', 'O', 'p', 'P', 'q', 'Q', 'r', 'R', 's', 'S', 't', 'T',
  'u', 'U', 'v', 'V', 'w', 'W', 'x', 'X', 'y', 'Y', 'z', 'Z', r'\', '|', ',', '<', '.', '>', '/', '?',
  ';', "'", '@', '#', '~', '[', '{', ']', '}', '-', '_', '=', '+', '`', '¬'
];

typedef dynamic ValueProcessor(dynamic value);

typedef void Registrar();

/// Returns the types that have already been registered and the string keys associated with them.
Map<Type, String> getRegisteredMappingsByType(){
  var map = new Map<Type, String>();
  _tranCodecsByType.forEach((k, v) => map[k] = v._key);
  return map;
}

/// Returns the keys that have already been used in registrations and the types associated with them.
Map<String, Type> getRegisteredMappingsByKey(){
  var map = new Map<String, Type>();
  _tranCodecsByKey.forEach((k, v) => map[k] = v._type);
  return map;
}

/// An object that can be serialized in to a string and back into its self again.
@proxy
class Transmittable{

  Map<String, dynamic> _internal = new Map<String, dynamic>();

  /// Creates a new plane Transmittable object.
  Transmittable(){
    _registerTranTranTypes();
  }

  /// Creates a new Transmittable object which is identical to the one which was used to create the string argument.
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

  /// Locks the Transmittable object such that calling a setter, or clear, on it will
  /// throw a [TransmittableLockedError], this is an irreversible process.
  void lock(){
    _internal['_locked'] = true;
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
      if(_internal['_locked'] == true){
        throw new TransmittableLockedError(MirrorSystem.getName(inv.memberName));
      }
      property = property.replaceAll("=", "");
      _internal[property] = inv.positionalArguments[0];
      return _internal[property];
    }

    super.noSuchMethod(inv);
  }

  /// Iterates over each property on the Transmittable object with its associated value.
  void forEach(void func(property, value)) => _internal.forEach(f);

  /// Clears the transmittable object wiping all properties and values.
  void clear(){
    if(_internal['_locked'] == true){
      throw new TransmittableLockedError('clear');
    }
    _internal.clear();
  }
}