/**
 * author: Daniel Robinson http://github.com/0xor1
 */

part of Transmittable;

class NestedRegisterTranTypesCallError{
  String get message => 'A call to registerTranTypes is already in progress for "$currentNamespace", it is an illegal operation to registerTranTypes for "$nestedNamespace" at the same time.';
  final String currentNamespace;
  final String nestedNamespace;
  const NestedRegisterTranTypesCallError(String this.currentNamespace, this.nestedNamespace);
}