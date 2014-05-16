/**
 * author: Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

class InvalidTranNamespaceError{
  String get message => 'Namespace "$namespace" is invalid. Tran namespaces must not contain a "$TSD" or "$TND" character.';
  final String namespace;
  InvalidTranNamespaceError(String this.namespace);
}