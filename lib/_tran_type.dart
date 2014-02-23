/**
 * author: Daniel Robinson http://github.com/0xor1
 */

part of Transmittable;

class _TranType{

  final String _key;
  final Type _type;
  final ToTranString _toStr;
  final FromTranString _fromStr;

  _TranType(String this._key, Type this._type, ToTranString this._toStr, FromTranString this._fromStr){
    _registerAdditionalCoreTypes();
    if(_tranTypesByKey.containsKey(_key)){
      throw new DuplicateTranKeyType(_key, _type);
    }else if(_tranTypesByType.containsKey(_type)){
      throw new DuplicateTranTypeError(_type, _key);
    }else{
      _tranTypesByKey[_key] = _tranTypesByType[_type] = this;
    }
  }
}