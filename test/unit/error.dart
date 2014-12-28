/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */
part of transmittable.test.unit;

class DumbyTypeA{}
class DumbyTypeB{}

void _runErrorTests(){
  group('Transmittable (error test)', (){

    test('doesn\'t support unregistered types', (){
      var tran = new Transmittable();
      tran.set('unreg', new UnregisteredType());
      expect(() => tran.toTranString(), throwsA(new isInstanceOf<UnregisteredTypeError>()));
    });

    test('doesn\'t allow duplicate type registration', (){
      expect(()=> generateRegistrar('Transmittable.ErrorTest2', 'tet2', [
        new TranRegistration.codec(null, (_){}, (_){}) //null is already registered in core
      ])(), throwsA(new isInstanceOf<DuplicateTranTypeError>()));
    });

    test('DuplicateTranTypeError contains the existingMappings', (){
      try{
        generateRegistrar('Transmittable.ErrorTest3', 'tet3', [
          new TranRegistration.codec(null, (_){}, (_){}) //null is already registered in core
        ])();
      }catch(ex){
        expect((ex as DuplicateTranTypeError).existingMappings[null] is String, equals(true));
      }
    });

    test('doesn\'t allow namespaces to contain the _TRAN_SECTION_DELIMITER character', (){
      expect(()=> generateRegistrar('Transmittable.ErrorTest5', 'tet5:', []),
          throwsA(new isInstanceOf<InvalidTranNamespaceError>()));
    });

    test('doesn\'t allow duplicate namespaces', (){
      generateRegistrar('Transmittable.ErrorTest9', 'tet9', []);
      expect(()=> generateRegistrar('Transmittable.ErrorTest9', 'tet9', []), throwsA(new isInstanceOf<DuplicateTranNamespaceError>()));
    });

    test('correctly detects the creation of unresolvable nested reference loops (1)', (){
      var tran = new Transmittable();
      tran.set('disaster', new PotentialTranDisaster()..tran = tran);
      expect(() => tran.toTranString(), throwsA(new isInstanceOf<UnresolvableNestedReferenceLoopError>()));
    });

    test('correctly detects the creation of unresolvable nested reference loops (2)', (){
      var tran = new Transmittable();
      tran.set('tran', new Transmittable());
      tran.set('disaster', new PotentialTranDisaster()..tran = tran.get('tran'));
      expect(() => tran.toTranString(), throwsA(new isInstanceOf<UnresolvableNestedReferenceLoopError>()));
    });

  });
}