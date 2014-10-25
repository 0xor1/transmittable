/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

/// Thrown when an unresolvable nested reference loop is detected during serialization to tran string.
class UnresolvableNestedReferenceLoopError{
  String get message => 'transmittable.toTranString() method called in an illegal nested location';
  final Transmittable transmittable;
  const UnresolvableNestedReferenceLoopError(this.transmittable);
}