/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

/// Thrown if a call to [generateRegistrar] is made with the same shortNamespace argument.
class DuplicateTranNamespaceError extends Error{
  String get message => 'Namespace "$shortNamespace" has already been registered.';
  final String shortNamespace;
  final String fullNamespace;
  final Map<String, String> registeredNamespaces = _namespaces;
  DuplicateTranNamespaceError(this.shortNamespace, this.fullNamespace);
}