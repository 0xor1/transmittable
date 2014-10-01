/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

class DuplicateTranTypeError{
  String get message => 'Type "$type" has already been registered.';
  final Type type;
  Map<Type, String> get mapping => getRegisteredMappingsByType();
  const DuplicateTranTypeError(this.type);
}