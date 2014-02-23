/**
 * author: Daniel Robinson http://github.com/0xor1
 */

part of Transmittable;

class TranMethodError{
  String get message => 'Methods are not transmittable, attempted invocation of method: $methodName';
  final String methodName;
  TranMethodError(String this.methodName);
}