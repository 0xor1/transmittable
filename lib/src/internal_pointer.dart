/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

class _InternalPointer{
  final int _uniqueValueIndex;
  const _InternalPointer(int this._uniqueValueIndex);
  dynamic resolve() => _uniqueValues[_uniqueValueIndex];
}