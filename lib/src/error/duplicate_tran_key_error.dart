/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

/// Thrown if the string key used when registering a type has already been used.
///
/// This Error should never get thrown, it is left in to help with debugging
/// if there is a bug in the Transmittable registration algorithm.
class DuplicateTranKeyError extends Error{
  String get message => 'Key "$key" has already been used.';
  final String key;
  final Map<String, Type> existingMappings = _registeredMappingsByKey;
  DuplicateTranKeyError(this.key);
}