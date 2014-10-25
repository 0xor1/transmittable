/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

/// Thrown if a call to [generateRegistrar] is made with a namespace containing the [TRAN_SECTION_DELIMITER].
class InvalidTranNamespaceError{
  String get message => 'Namespace "$namespace" is invalid. Tran namespaces must not contain a "$TSD" character.';
  final String namespace;
  InvalidTranNamespaceError(this.namespace);
}