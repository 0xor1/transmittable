/**
 * author: Daniel Robinson http://github.com/0xor1
 */

part of Transmittable;

class TranRegistrationOutsideOfNamespaceError{
  String get message => 'Calls to registerTranCodec and registerTranSubtype must only be made from within the second parameter of registerTranTypes.';
  final String key;
  final Type type;
  const TranRegistrationOutsideOfNamespaceError(String this.key, Type this.type);
}