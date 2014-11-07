/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

/// Thrown if a setter is called with the name _isTranLocked.
class ReservedPropertyNameError extends Error{
  String get message => '$_TL is a reserved property name.';
  ReservedPropertyNameError();
}