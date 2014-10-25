/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */
part of TransmittableTest;

class DumbyTypeA{}
class DumbyTypeB{}

void _runErrorTests(){
  group('Transmittable (error test)', (){

    test('KEY_PIECES doesn\'t allow changes to itself', (){
      expect(() => KEY_PIECES.remove('a'), throwsA(new isInstanceOf<UnsupportedError>()));
      expect(() => KEY_PIECES.add('a'), throwsA(new isInstanceOf<UnsupportedError>()));
    });

    test('doesn\'t support unregistered types', (){
      var tran = new Transmittable();
      tran.unreg = new UnregisteredType();
      expect(() => tran.toTranString(), throwsA(new isInstanceOf<UnregisteredTypeError>()));
    });

    test('doesn\'t allow duplicate type registration', (){
      expect(()=> generateRegistrar('Transmittable.ErrorTest2', 'tet2', [
        new TranRegistration.codec(null, (_){}, (_){}) //null is already registered in core
      ])(), throwsA(new isInstanceOf<DuplicateTranTypeError>()));
    });

    test('doesn\'t allow namespaces to contain the $TSD character', (){
      expect(()=> generateRegistrar('Transmittable.ErrorTest5', 'tet5$TSD', []),
          throwsA(new isInstanceOf<InvalidTranNamespaceError>()));
    });

    test('doesn\'t support methods', (){
      expect((){
        new Transmittable()..doStuff();
      }, throwsA(new isInstanceOf<TranMethodError>()));
    });

    test('doesn\'t allow duplicate namespaces', (){
      generateRegistrar('Transmittable.ErrorTest9', 'tet9', []);
      expect(()=> generateRegistrar('Transmittable.ErrorTest9', 'tet9', []), throwsA(new isInstanceOf<DuplicateTranNamespaceError>()));
    });

    test('correctly detects the creation of unresolvable nested reference loops (1)', (){
      var tran = new Transmittable();
      tran.disaster = new PotentialTranDisaster()..tran = tran;
      expect(() => tran.toTranString(), throwsA(new isInstanceOf<UnresolvableNestedReferenceLoopError>()));
    });

    test('correctly detects the creation of unresolvable nested reference loops (2)', (){
      var tran = new Transmittable();
      tran.tran = new Transmittable();
      tran.disaster = new PotentialTranDisaster()..tran = tran.tran;
      expect(() => tran.toTranString(), throwsA(new isInstanceOf<UnresolvableNestedReferenceLoopError>()));
    });

    test('doesn\'t support setters when the Transmittable is locked', (){
      var tran = new Transmittable()
      ..pi = 3.142;
      tran.lock();
      expect(() => tran.pi = 2.718, throwsA(new isInstanceOf<TransmittableLockedError>()));
    });

    test('doesn\'t support clear when the Transmittable is locked', (){
      var tran = new Transmittable()
      ..pi = 3.142;
      tran.lock();
      expect(() => tran.clear(), throwsA(new isInstanceOf<TransmittableLockedError>()));
    });

  });
}