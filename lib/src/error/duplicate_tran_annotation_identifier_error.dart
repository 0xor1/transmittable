/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

class DuplicatedTranAnnotationIdentifierError extends Error{
  String get message => 'Annotation identifier "identifier" is used more than once in "$fullNamespace".';
  final String fullNamespace;
  final String identifier;
  DuplicatedTranAnnotationIdentifierError(this.fullNamespace, this.identifier);
}