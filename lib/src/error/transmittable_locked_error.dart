/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

/// Thrown if a setter or clear() is invoked on a [Transmittable] object after it has been locked.
class TransmittableLockedError extends Error{
  String get message => 'The Transmittable object is locked, calling any Setter on this object is an error.';
  final String setter;
  TransmittableLockedError(this.setter);
}