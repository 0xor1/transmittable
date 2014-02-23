/**
 * author: Daniel Robinson http://github.com/0xor1
 */

part of Transmittable;

class UnregisteredTranTypeError{
  String get message => 'Type "$type" has not been registered with registerTranType().';
  final Type type;
  UnregisteredTranTypeError(Type this.type);
}