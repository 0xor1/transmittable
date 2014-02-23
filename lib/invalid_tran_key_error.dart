/**
 * author: Daniel Robinson http://github.com/0xor1
 */

part of Transmittable;

class InvalidTranKeyError{
  String get message => 'Key "$key" is invalid. Tran keys must not start with a number or contain any of the following characters ,:{}[]';
  final String key;
  InvalidTranKeyError(String this.key);
}