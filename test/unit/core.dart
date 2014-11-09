/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */
part of transmittable.test.unit;

void _runCoreTests(){
  group('Transmittable (core test)', (){

    test('supports null',(){
      var tran = new Transmittable()
      ..aNull = null;
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.aNull, equals(null));
    });

    test('supports numbers',(){
      var tran = new Transmittable()
      ..pos = 23
      ..neg = -3;
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.pos, equals(23));
      expect(reTran.neg, equals(-3));
    });

    test('supports bools',(){
      var tran = new Transmittable()
      ..t = true
      ..f = false;
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.t, equals(true));
      expect(reTran.f, equals(false));
    });

    test('supports strings',(){
      var tran = new Transmittable()
      ..str1 = 'Hello World'
      ..str2 = 'Hi';
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.str1, equals('Hello World'));
      expect(reTran.str2, equals('Hi'));
    });

    test('supports datetimes',(){
      var tran = new Transmittable();
      var dt = tran.datetime = new DateTime.now();
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.datetime, equals(dt));
    });

    test('supports durations',(){
      var tran = new Transmittable();
      var dur = tran.duration = new Duration(days:23, seconds: 4, milliseconds: 456);
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.duration, equals(dur));
    });

    test('supports lists',(){
      var tran = new Transmittable();
      var dt = new DateTime.now();
      var dur = new Duration(days:147, seconds: 78, milliseconds: 2);
      tran.list = [12, 'Hi', true, dt, dur];
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.list[0], equals(12));
      expect(reTran.list[1], equals('Hi'));
      expect(reTran.list[2], equals(true));
      expect(reTran.list[3], equals(dt));
      expect(reTran.list[4], equals(dur));
    });

    test('supports sets',(){
      var tran = new Transmittable();
      var dt = new DateTime.now();
      var dur = new Duration(days:147, seconds: 78, milliseconds: 2);
      var contents = [12, 'Hi', true, dt, dur];
      tran.aSet = new Set()..addAll(contents);
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.aSet.containsAll(contents), equals(true));
    });

    test('supports maps',(){
      var tran = new Transmittable();
      var dt = new DateTime.now();
      var dur = new Duration(days:147, seconds: 78, milliseconds: 2);
      tran.map = new Map<dynamic, dynamic>()
      ..[12] = 12
      ..['Hi'] = 'Hi'
      ..[true] = false
      ..[dt] = dt
      ..[dur] = dur;
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.map[12], equals(12));
      expect(reTran.map['Hi'], equals('Hi'));
      expect(reTran.map[true], equals(false));
      expect(reTran.map[dt], equals(dt));
      expect(reTran.map[dur], equals(dur));
    });

    test('supports regexps',(){
      var tran = new Transmittable();
      tran.regexp = new RegExp(r'^[a-z]\n', caseSensitive: false, multiLine: true);
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(tran.toTranString().contains(r'^[a-z]\n'), equals(true));
    });

    test('supports symbols',(){
      var tran = new Transmittable();
      tran.symbol = const Symbol("YO");
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.symbol, equals(tran.symbol));
    });

    test('supports custom types',(){
      var tran = new Transmittable();
      var person = tran.person = new Person('Joe Bloggs', 23);
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.person, equals(person));

    });

    test('supports nested transmittables', (){
      var tran = new Transmittable()
      ..tran = (new Transmittable()..str = 'hi');
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.tran.str, equals('hi'));
    });

    test('supports types', (){
      var tran = new Transmittable()
      ..string = String
      ..int = int
      ..double = double;
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.string, equals(String));
      expect(reTran.int, equals(int));
      expect(reTran.double, equals(double));
    });

    test('supports pre/post-processing of values at encode/decode time', (){
      var tran = new Transmittable()
      ..unreg = new UnregisteredType()
      ..aNum = 1;
      var tranStr = tran.toTranString((v) => v is UnregisteredType? 'foundAnUnregisteredType!!': v);
      var reTran = new Transmittable.fromTranString(tranStr);
      expect(reTran.unreg, equals('foundAnUnregisteredType!!'));
      var reTranWithPostProcessing = new Transmittable.fromTranString(tranStr, (v) => v == 'foundAnUnregisteredType!!'? tran.unreg: v);
      expect(reTranWithPostProcessing.unreg, equals(tran.unreg));
    });

    test('supports nested pre/post processing of values at encode/decode time', (){
      var tran = new Transmittable()
      ..one = 1
      ..two = 2
      ..nested = new PotentialTranDisaster();
      tran.nested.tran = new Transmittable()
      ..one = 1
      ..two = 2;
      var tranStr = tran.toTranString((v) => v is int? v * 100: v);
      var retran = new Transmittable.fromTranString(tranStr);
      expect(retran.one, equals(100));
      expect(retran.two, equals(200));
      expect(retran.nested.tran.one, equals(100));
      expect(retran.nested.tran.two, equals(2));
    });

    test('supports dynamic Transmittable type creation', (){
      var cat = new Cat()
      ..name = 'Felix'
      ..age = 3;
      var reCat = new Transmittable.fromTranString(cat.toTranString());
      expect(reCat is Cat, true);
    });

    test('supports getters when the Transmittable is locked', (){
      var tran = new Transmittable()
      ..pi = 3.142;
      tran.lock();
      expect(tran.pi, equals(3.142));
    });

    test('supports clearing of all properties and values', (){
      var tran = new Transmittable()
      ..pi = 3.142;
      tran.clear();
      expect(tran.pi, equals(null));
    });

    test('supports setting properties via set method using string name', (){
      var tran = new Transmittable()
      ..set('pi', 3.142);
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.pi, equals(3.142));
    });

    test('supports setting properties via set method using symbol name', (){
      var tran = new Transmittable()
      ..set(#pi, 3.142);
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.pi, equals(3.142));
    });

    test('supports getting properties via get method using string name', (){
      var tran = new Transmittable()
      ..pi = 3.142;
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.get('pi'), equals(3.142));
    });

    test('supports getting properties via get method using symbol name', (){
      var tran = new Transmittable()
      ..pi = 3.142;
      var reTran = new Transmittable.fromTranString(tran.toTranString());
      expect(reTran.get(#pi), equals(3.142));
    });

    test('registering more types than the number of _KEY_PIECES doesn\'t result in an error', (){
      int registerCount = 0;
      var registerTranCodecWithCounterIncrement = (Type type, TranEncode encode, TranDecode decode){
        registerCount++;
        return new TranRegistration.codec(type, encode, decode);
      };
      // for this unit test to remain valid it must contain more registrations than the number of keys in _KEY_PIECES
      Registrar registerALotOfCodecs = generateRegistrar('transmittable.key_pieces_test', 'tkpt', [
        registerTranCodecWithCounterIncrement(AA, (o) => '', (s) => new AA()),
        registerTranCodecWithCounterIncrement(AB, (o) => '', (s) => new AB()),
        registerTranCodecWithCounterIncrement(AC, (o) => '', (s) => new AC()),
        registerTranCodecWithCounterIncrement(AD, (o) => '', (s) => new AD()),
        registerTranCodecWithCounterIncrement(AE, (o) => '', (s) => new AE()),
        registerTranCodecWithCounterIncrement(AF, (o) => '', (s) => new AF()),
        registerTranCodecWithCounterIncrement(AG, (o) => '', (s) => new AG()),
        registerTranCodecWithCounterIncrement(AH, (o) => '', (s) => new AH()),
        registerTranCodecWithCounterIncrement(AI, (o) => '', (s) => new AI()),
        registerTranCodecWithCounterIncrement(AJ, (o) => '', (s) => new AJ()),
        registerTranCodecWithCounterIncrement(AK, (o) => '', (s) => new AK()),
        registerTranCodecWithCounterIncrement(AL, (o) => '', (s) => new AL()),
        registerTranCodecWithCounterIncrement(AM, (o) => '', (s) => new AM()),
        registerTranCodecWithCounterIncrement(AN, (o) => '', (s) => new AN()),
        registerTranCodecWithCounterIncrement(AO, (o) => '', (s) => new AO()),
        registerTranCodecWithCounterIncrement(AP, (o) => '', (s) => new AP()),
        registerTranCodecWithCounterIncrement(AQ, (o) => '', (s) => new AQ()),
        registerTranCodecWithCounterIncrement(AR, (o) => '', (s) => new AR()),
        registerTranCodecWithCounterIncrement(AS, (o) => '', (s) => new AS()),
        registerTranCodecWithCounterIncrement(AT, (o) => '', (s) => new AT()),
        registerTranCodecWithCounterIncrement(AU, (o) => '', (s) => new AU()),
        registerTranCodecWithCounterIncrement(AV, (o) => '', (s) => new AV()),
        registerTranCodecWithCounterIncrement(AW, (o) => '', (s) => new AW()),
        registerTranCodecWithCounterIncrement(AX, (o) => '', (s) => new AX()),
        registerTranCodecWithCounterIncrement(AY, (o) => '', (s) => new AY()),
        registerTranCodecWithCounterIncrement(AZ, (o) => '', (s) => new AZ()),
        registerTranCodecWithCounterIncrement(BA, (o) => '', (s) => new BA()),
        registerTranCodecWithCounterIncrement(BB, (o) => '', (s) => new BB()),
        registerTranCodecWithCounterIncrement(BC, (o) => '', (s) => new BC()),
        registerTranCodecWithCounterIncrement(BD, (o) => '', (s) => new BD()),
        registerTranCodecWithCounterIncrement(BE, (o) => '', (s) => new BE()),
        registerTranCodecWithCounterIncrement(BF, (o) => '', (s) => new BF()),
        registerTranCodecWithCounterIncrement(BG, (o) => '', (s) => new BG()),
        registerTranCodecWithCounterIncrement(BH, (o) => '', (s) => new BH()),
        registerTranCodecWithCounterIncrement(BI, (o) => '', (s) => new BI()),
        registerTranCodecWithCounterIncrement(BJ, (o) => '', (s) => new BJ()),
        registerTranCodecWithCounterIncrement(BK, (o) => '', (s) => new BK()),
        registerTranCodecWithCounterIncrement(BL, (o) => '', (s) => new BL()),
        registerTranCodecWithCounterIncrement(BM, (o) => '', (s) => new BM()),
        registerTranCodecWithCounterIncrement(BN, (o) => '', (s) => new BN()),
        registerTranCodecWithCounterIncrement(BO, (o) => '', (s) => new BO()),
        registerTranCodecWithCounterIncrement(BP, (o) => '', (s) => new BP()),
        registerTranCodecWithCounterIncrement(BQ, (o) => '', (s) => new BQ()),
        registerTranCodecWithCounterIncrement(BR, (o) => '', (s) => new BR()),
        registerTranCodecWithCounterIncrement(BS, (o) => '', (s) => new BS()),
        registerTranCodecWithCounterIncrement(BT, (o) => '', (s) => new BT()),
        registerTranCodecWithCounterIncrement(BU, (o) => '', (s) => new BU()),
        registerTranCodecWithCounterIncrement(BV, (o) => '', (s) => new BV()),
        registerTranCodecWithCounterIncrement(BW, (o) => '', (s) => new BW()),
        registerTranCodecWithCounterIncrement(BX, (o) => '', (s) => new BX()),
        registerTranCodecWithCounterIncrement(BY, (o) => '', (s) => new BY()),
        registerTranCodecWithCounterIncrement(BZ, (o) => '', (s) => new BZ()),
        registerTranCodecWithCounterIncrement(CA, (o) => '', (s) => new CA()),
        registerTranCodecWithCounterIncrement(CB, (o) => '', (s) => new CB()),
        registerTranCodecWithCounterIncrement(CC, (o) => '', (s) => new CC()),
        registerTranCodecWithCounterIncrement(CD, (o) => '', (s) => new CD()),
        registerTranCodecWithCounterIncrement(CE, (o) => '', (s) => new CE()),
        registerTranCodecWithCounterIncrement(CF, (o) => '', (s) => new CF()),
        registerTranCodecWithCounterIncrement(CG, (o) => '', (s) => new CG()),
        registerTranCodecWithCounterIncrement(CH, (o) => '', (s) => new CH()),
        registerTranCodecWithCounterIncrement(CI, (o) => '', (s) => new CI()),
        registerTranCodecWithCounterIncrement(CJ, (o) => '', (s) => new CJ()),
        registerTranCodecWithCounterIncrement(CK, (o) => '', (s) => new CK()),
        registerTranCodecWithCounterIncrement(CL, (o) => '', (s) => new CL()),
        registerTranCodecWithCounterIncrement(CM, (o) => '', (s) => new CM()),
        registerTranCodecWithCounterIncrement(CN, (o) => '', (s) => new CN()),
        registerTranCodecWithCounterIncrement(CO, (o) => '', (s) => new CO()),
        registerTranCodecWithCounterIncrement(CP, (o) => '', (s) => new CP()),
        registerTranCodecWithCounterIncrement(CQ, (o) => '', (s) => new CQ()),
        registerTranCodecWithCounterIncrement(CR, (o) => '', (s) => new CR()),
        registerTranCodecWithCounterIncrement(CS, (o) => '', (s) => new CS()),
        registerTranCodecWithCounterIncrement(CT, (o) => '', (s) => new CT()),
        registerTranCodecWithCounterIncrement(CU, (o) => '', (s) => new CU()),
        registerTranCodecWithCounterIncrement(CV, (o) => '', (s) => new CV()),
        registerTranCodecWithCounterIncrement(CW, (o) => '', (s) => new CW()),
        registerTranCodecWithCounterIncrement(CX, (o) => '', (s) => new CX()),
        registerTranCodecWithCounterIncrement(CY, (o) => '', (s) => new CY()),
        registerTranCodecWithCounterIncrement(CZ, (o) => '', (s) => new CZ()),
        registerTranCodecWithCounterIncrement(DA, (o) => '', (s) => new DA()),
        registerTranCodecWithCounterIncrement(DB, (o) => '', (s) => new DB()),
        registerTranCodecWithCounterIncrement(DC, (o) => '', (s) => new DC()),
        registerTranCodecWithCounterIncrement(DD, (o) => '', (s) => new DD()),
        registerTranCodecWithCounterIncrement(DE, (o) => '', (s) => new DE()),
        registerTranCodecWithCounterIncrement(DF, (o) => '', (s) => new DF()),
        registerTranCodecWithCounterIncrement(DG, (o) => '', (s) => new DG()),
        registerTranCodecWithCounterIncrement(DH, (o) => '', (s) => new DH()),
        registerTranCodecWithCounterIncrement(DI, (o) => '', (s) => new DI()),
        registerTranCodecWithCounterIncrement(DJ, (o) => '', (s) => new DJ()),
        registerTranCodecWithCounterIncrement(DK, (o) => '', (s) => new DK()),
        registerTranCodecWithCounterIncrement(DL, (o) => '', (s) => new DL()),
        registerTranCodecWithCounterIncrement(DM, (o) => '', (s) => new DM()),
        registerTranCodecWithCounterIncrement(DN, (o) => '', (s) => new DN()),
        registerTranCodecWithCounterIncrement(DO, (o) => '', (s) => new DO()),
        registerTranCodecWithCounterIncrement(DP, (o) => '', (s) => new DP()),
        registerTranCodecWithCounterIncrement(DQ, (o) => '', (s) => new DQ()),
        registerTranCodecWithCounterIncrement(DR, (o) => '', (s) => new DR()),
        registerTranCodecWithCounterIncrement(DS, (o) => '', (s) => new DS()),
        registerTranCodecWithCounterIncrement(DT, (o) => '', (s) => new DT()),
        registerTranCodecWithCounterIncrement(DU, (o) => '', (s) => new DU()),
        registerTranCodecWithCounterIncrement(DV, (o) => '', (s) => new DV()),
        registerTranCodecWithCounterIncrement(DW, (o) => '', (s) => new DW()),
        registerTranCodecWithCounterIncrement(DX, (o) => '', (s) => new DX()),
        registerTranCodecWithCounterIncrement(DY, (o) => '', (s) => new DY()),
        registerTranCodecWithCounterIncrement(DZ, (o) => '', (s) => new DZ()),
      ]);
      registerALotOfCodecs();
    });
  });
}

Registrar _registerTestTranTypes = generateRegistrar('transmittable.test', 'tt', [
    new TranRegistration.codec(Person, (p)=> p.toTranString, (s)=> new Person.fromTranSring(s)),
    new TranRegistration.codec(PotentialTranDisaster, (ptd)=> ptd.tran.toTranString((v) => v is int && v == 2? 'replaced 2': v), (s) => new PotentialTranDisaster()..tran = new Transmittable.fromTranString(s, (v) => v == 'replaced 2'? 2: v)),
    new TranRegistration.subtype(Cat, () => new Cat())
  ]);


class UnregisteredType{}

class Person{

  static int ssSrc = 0;

  String name;
  int age;
  final int socialSecurity;

  Person(this.name, this.age):socialSecurity = ssSrc++{
    _registerTestTranTypes();
  }

  Person._internal(this.name, this.age, this.socialSecurity);

  factory Person.fromTranSring(String s){
    var strs = s.split(',');
    return new Person._internal(strs[0], num.parse(strs[1]), num.parse(strs[2]));
  }

  String get toTranString => '$name,$age,$socialSecurity';
  operator ==(other) => socialSecurity == other.socialSecurity;
  int get hashCode => socialSecurity.hashCode;
}

class Cat extends Transmittable{
  String get name => get('name');
  void set name (String o) => set('name', o);
  int get age => get('age');
  void set age (int o) => set('age', o);
}

class AA{}
class AB{}
class AC{}
class AD{}
class AE{}
class AF{}
class AG{}
class AH{}
class AI{}
class AJ{}
class AK{}
class AL{}
class AM{}
class AN{}
class AO{}
class AP{}
class AQ{}
class AR{}
class AS{}
class AT{}
class AU{}
class AV{}
class AW{}
class AX{}
class AY{}
class AZ{}
class BA{}
class BB{}
class BC{}
class BD{}
class BE{}
class BF{}
class BG{}
class BH{}
class BI{}
class BJ{}
class BK{}
class BL{}
class BM{}
class BN{}
class BO{}
class BP{}
class BQ{}
class BR{}
class BS{}
class BT{}
class BU{}
class BV{}
class BW{}
class BX{}
class BY{}
class BZ{}
class CA{}
class CB{}
class CC{}
class CD{}
class CE{}
class CF{}
class CG{}
class CH{}
class CI{}
class CJ{}
class CK{}
class CL{}
class CM{}
class CN{}
class CO{}
class CP{}
class CQ{}
class CR{}
class CS{}
class CT{}
class CU{}
class CV{}
class CW{}
class CX{}
class CY{}
class CZ{}
class DA{}
class DB{}
class DC{}
class DD{}
class DE{}
class DF{}
class DG{}
class DH{}
class DI{}
class DJ{}
class DK{}
class DL{}
class DM{}
class DN{}
class DO{}
class DP{}
class DQ{}
class DR{}
class DS{}
class DT{}
class DU{}
class DV{}
class DW{}
class DX{}
class DY{}
class DZ{}