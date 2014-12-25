/**
 * Author:  Daniel Robinson http://github.com/0xor1
 */

part of transmittable;

class TranLib{
  final String fullNamespace;
  final String shortNamespace;
  const TranLib(this.fullNamespace, this.shortNamespace);
}

class TranCodec{
  final String identifier;
  final TranEncode encode;
  final TranDecode decode;
  const TranCodec(this.identifier, this.encode, this.decode);
}

class TranSubtype{
  final String identifier;
  final TranConstructor constructor;
  const TranSubtype(this.identifier, this.constructor);
}

class TypeWithTranMeta<T>{
  final Type type;
  final T tranMeta;
  const TypeWithTranMeta(this.type, this.tranMeta);
}

// in this method we check to ensure that no annotation string id is
// duplicated within a library so the sort on the keys is not ambiguous
// we then use a manual for loop instead of a foreach when generating the
// final regs list to ensure that the ordering is guaranteed to be the same
// in all environments.
bool _tranRegistrationsInitialised = false;
void _initTranRegistrations(){

  if(_tranRegistrationsInitialised) return;
  _tranRegistrationsInitialised = true;

  _registerTranTranTypes();

  //get all libs labeled as TranLibs
  var tranLibs = new Map<LibraryMirror, TranLib>();
  var libs = currentMirrorSystem().libraries;

  libs.forEach((uri, lib){

    lib.metadata.forEach((metaMirror){

      var meta = metaMirror.reflectee;
      if(meta.runtimeType == TranLib){
        tranLibs[lib] = meta;
      }

    });

  });

  tranLibs.forEach((lib, tranLib){
    var codecs = new Map<String, TypeWithTranMeta<TranCodec>>();
    var subtypes = new Map<String, TypeWithTranMeta<TranSubtype>>();

    lib.declarations.forEach((symbol, dec){
      if(dec is! ClassMirror) return;

      dec.metadata.forEach((metaMirror){

        var meta = metaMirror.reflectee;
        if(meta.runtimeType == TranSubtype){
          if(subtypes.containsKey(meta.identifier))
            throw new DuplicatedTranAnnotationIdentifierError(tranLib.fullNamespace, meta.identifier);
          subtypes[meta.identifier] = new TypeWithTranMeta(dec.reflectedType, meta);
        }else if(meta.runtimeType == TranCodec){
          if(codecs.containsKey(meta.identifier))
            throw new DuplicatedTranAnnotationIdentifierError(tranLib.fullNamespace, meta.identifier);
          codecs[meta.identifier] = new TypeWithTranMeta(dec.reflectedType, meta);
        }

      });
    });

    var sortedCodecIds = codecs.keys.toList()..sort((a, b) => a.compareTo(b));
    var sortedSubtypeIds = subtypes.keys.toList()..sort((a, b) => a.compareTo(b));
    var regs = new List<TranRegistration>();

    for(var i = 0; i < sortedCodecIds.length; i++){
      var typeWithMeta = codecs[sortedCodecIds[i]];
      regs.add(new TranRegistration.codec(typeWithMeta.type, typeWithMeta.tranMeta.encode, typeWithMeta.tranMeta.decode));
    }

    for(var i = 0; i < sortedSubtypeIds.length; i++){
      var typeWithMeta = subtypes[sortedSubtypeIds[i]];
      regs.add(new TranRegistration.subtype(typeWithMeta.type, typeWithMeta.tranMeta.constructor));
    }

    var registrar = generateRegistrar(tranLib.fullNamespace, tranLib.shortNamespace, regs);
    registrar();
  });
}