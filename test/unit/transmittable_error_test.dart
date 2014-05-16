/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */
part of TransmittableTest;

class DumbyTypeA{}
class DumbyTypeB{}

void _runErrorTests(){
  group('Transmittable (error test)', (){

    test('doesnt support unregistered types', (){
      var tran = new Transmittable();
      tran.unreg = new UnregisteredType();
      expect(() => tran.toTranString(), throwsA(new isInstanceOf<UnregisteredTypeError>()));
    });

    test('doesnt allow duplicate keys within a namespace', (){
      expect(()=> registerTranTypes('Transmittable.ErrorTest1', 'tet1', (){
        registerTranCodec('a', DumbyTypeA, (_){}, (_){});
        registerTranCodec('a', DumbyTypeB, (_){}, (_){});
      }), throwsA(new isInstanceOf<DuplicateTranKeyError>()));
    });

    test('doesnt allow duplicate type registration', (){
      expect(()=> registerTranTypes('Transmittable.ErrorTest2', 'tet2', (){
        registerTranCodec('a', null, (_){}, (_){}); //null is already registered in core
      }), throwsA(new isInstanceOf<DuplicateTranTypeError>()));
    });

    test('doesnt allow keys to contain the $TSD character', (){
      expect(()=> registerTranTypes('Transmittable.ErrorTest3', 'tet3', (){
        registerTranCodec('a$TSD', null, (_){}, (_){});
      }), throwsA(new isInstanceOf<InvalidTranKeyError>()));
    });

    test('doesnt allow keys to contain the $TND character', (){
      expect(()=> registerTranTypes('Transmittable.ErrorTest4', 'tet4', (){
        registerTranCodec('a$TND', null, (_){}, (_){});
      }), throwsA(new isInstanceOf<InvalidTranKeyError>()));
    });

    test('doesnt allow namespaces to contain the $TSD character', (){
      expect(()=> registerTranTypes('Transmittable.ErrorTest5', 'tet5$TSD', (){
      }), throwsA(new isInstanceOf<InvalidTranNamespaceError>()));
    });

    test('doesnt allow namespaces to contain the $TND character', (){
      expect(()=> registerTranTypes('Transmittable.ErrorTest6', 'tet6$TND', (){
      }), throwsA(new isInstanceOf<InvalidTranNamespaceError>()));
    });

    test('doesnt allow nested calls to registerTranTypes', (){
      expect(()=> registerTranTypes('Transmittable.ErrorTest7', 'tet7', (){
        registerTranTypes('Transmittable.ErrorTest8', 'tet8', (){});
      }), throwsA(new isInstanceOf<NestedRegisterTranTypesCallError>()));
    });

    test('doesnt support methods', (){
      expect((){
        new Transmittable()..doStuff();
      }, throwsA(new isInstanceOf<TranMethodError>()));
    });

    test('doesnt allow duplicate namespaces', (){
      registerTranTypes('Transmittable.ErrorTest9', 'tet9', (){});
      expect(()=> registerTranTypes('Transmittable.ErrorTest9', 'tet9', (){
      }), throwsA(new isInstanceOf<DuplicateTranNamespaceError>()));
    });

    test('doesnt allow codecs to be registered outside of registerTranTypes', (){
      expect(()=> registerTranCodec('a', null, (_){}, (_){}),
          throwsA(new isInstanceOf<TranRegistrationOutsideOfNamespaceError>()));
    });

    test('doesnt allow subtypes to be registered outside of registerTranTypes', (){
      expect(()=> registerTranSubtype('a', Object),
          throwsA(new isInstanceOf<TranRegistrationOutsideOfNamespaceError>()));
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

  });
}