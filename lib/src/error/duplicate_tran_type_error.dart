/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

/// Thrown if an attempt is made to register a type which is already registered.
class DuplicateTranTypeError extends Error{
  String get message => 'Type "$type" has already been registered.';
  final Type type;
  final Map<Type, String> existingMappings = _registeredMappingsByType;
  DuplicateTranTypeError(this.type);
}