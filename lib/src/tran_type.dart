/**
 * author: Daniel Robinson http://github.com/0xor1
 */

part of Transmittable;

class _TranType{
  final String _key;
  final Type _type;
  final ToTranString _toStr;
  final FromTranString _fromStr;
  const _TranType(String this._key, Type this._type, ToTranString this._toStr, FromTranString this._fromStr);
}