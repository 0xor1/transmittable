/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

/// Thrown when serializing a [Transmittable] to a tran string and one of the types
/// contained on the [Transmittable] object has not been registered.
class UnregisteredTypeError extends Error{
  String get message => 'Type "$type" has not been registered with registerTranType().';
  final Type type;
  UnregisteredTypeError(this.type);
}