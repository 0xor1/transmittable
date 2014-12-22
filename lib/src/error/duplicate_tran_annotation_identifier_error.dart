/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

/// Thrown if the string key used when registering a type has already been used.
///
/// This Error should never get thrown, it is left in to help with debugging
/// if there is a bug in the Transmittable registration algorithm.
class DuplicatedTranAnnotationIdentifierError extends Error{
  String get message => 'Annotation identifier "identifier" is used more than once in "$fullNamespace".';
  final String fullNamespace;
  final String identifier;
  DuplicatedTranAnnotationIdentifierError(this.fullNamespace, this.identifier);
}