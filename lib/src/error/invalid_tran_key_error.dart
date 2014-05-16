/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

class InvalidTranKeyError{
  String get message => 'Key "$key" is invalid. Tran keys must not contain a "$TSD" or "$TND" character';
  final String key;
  InvalidTranKeyError(String this.key);
}