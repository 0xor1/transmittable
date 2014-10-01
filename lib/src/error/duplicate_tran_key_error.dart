/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

class DuplicateTranKeyError{
  String get message => 'Key "$key" has already been used.';
  final String key;
  Map<String, Type> get mapping => getRegisteredMappingsByKey();
  const DuplicateTranKeyError(this.key);
}