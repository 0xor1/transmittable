/**
 * author: Daniel Robinson http://github.com/0xor1
 */

part of Transmittable;

class UnregisteredTranCodecError{
  String get message => 'Type "$type" has not been registered with registerTranType().';
  final Type type;
  const UnregisteredTranCodecError(Type this.type);
}