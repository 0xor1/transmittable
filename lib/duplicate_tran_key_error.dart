/**
 * author: Daniel Robinson http://github.com/0xor1
 */

part of Transmittable;

class DuplicateTranKeyError{
  String get message => 'Key "$key" has already been registered with type "$type".';
  final String key;
  final Type type;
  DuplicateTranKeyError(String this.key, Type this.type);
}