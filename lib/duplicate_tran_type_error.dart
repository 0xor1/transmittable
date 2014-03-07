/**
 * author: Daniel Robinson http://github.com/0xor1
 */

part of Transmittable;

class DuplicateTranCodecError{
  String get message => 'Type "$type" has already been registered with key "$key".';
  final String key;
  final Type type;
  final Map<Type, String> mapping = getRegisterdMappingsByType();
  const DuplicateTranCodecError(Type this.type, String this.key);
}