/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

/// Thrown if a non existing method is invoked on a [Transmittable] object
class TranMethodError extends Error{
  String get message => 'Methods are not transmittable, attempted invocation of method: $methodName';
  final String methodName;
  TranMethodError(this.methodName);
}