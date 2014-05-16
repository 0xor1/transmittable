/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

class DuplicateTranTypeError{
  String get message => 'Type "$type" has already been registered with key "$key".';
  final String key;
  final Type type;
  final Map<Type, String> mapping = getRegisteredMappingsByType();
  const DuplicateTranTypeError(Type this.type, String this.key);
}