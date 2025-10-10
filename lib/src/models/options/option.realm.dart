// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'option.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Options extends _Options with RealmEntity, RealmObjectBase, RealmObject {
  Options(
    int id,
    int numberOfSections,
    double skillWeight,
    double genderWeight,
    double waitedWeight,
    double playedWeight,
    double playedWithWeight,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'numberOfSections', numberOfSections);
    RealmObjectBase.set(this, 'skillWeight', skillWeight);
    RealmObjectBase.set(this, 'genderWeight', genderWeight);
    RealmObjectBase.set(this, 'waitedWeight', waitedWeight);
    RealmObjectBase.set(this, 'playedWeight', playedWeight);
    RealmObjectBase.set(this, 'playedWithWeight', playedWithWeight);
  }

  Options._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => RealmObjectBase.set(this, 'id', value);

  @override
  int get numberOfSections =>
      RealmObjectBase.get<int>(this, 'numberOfSections') as int;
  @override
  set numberOfSections(int value) =>
      RealmObjectBase.set(this, 'numberOfSections', value);

  @override
  double get skillWeight =>
      RealmObjectBase.get<double>(this, 'skillWeight') as double;
  @override
  set skillWeight(double value) =>
      RealmObjectBase.set(this, 'skillWeight', value);

  @override
  double get genderWeight =>
      RealmObjectBase.get<double>(this, 'genderWeight') as double;
  @override
  set genderWeight(double value) =>
      RealmObjectBase.set(this, 'genderWeight', value);

  @override
  double get waitedWeight =>
      RealmObjectBase.get<double>(this, 'waitedWeight') as double;
  @override
  set waitedWeight(double value) =>
      RealmObjectBase.set(this, 'waitedWeight', value);

  @override
  double get playedWeight =>
      RealmObjectBase.get<double>(this, 'playedWeight') as double;
  @override
  set playedWeight(double value) =>
      RealmObjectBase.set(this, 'playedWeight', value);

  @override
  double get playedWithWeight =>
      RealmObjectBase.get<double>(this, 'playedWithWeight') as double;
  @override
  set playedWithWeight(double value) =>
      RealmObjectBase.set(this, 'playedWithWeight', value);

  @override
  Stream<RealmObjectChanges<Options>> get changes =>
      RealmObjectBase.getChanges<Options>(this);

  @override
  Stream<RealmObjectChanges<Options>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Options>(this, keyPaths);

  @override
  Options freeze() => RealmObjectBase.freezeObject<Options>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'numberOfSections': numberOfSections.toEJson(),
      'skillWeight': skillWeight.toEJson(),
      'genderWeight': genderWeight.toEJson(),
      'waitedWeight': waitedWeight.toEJson(),
      'playedWeight': playedWeight.toEJson(),
      'playedWithWeight': playedWithWeight.toEJson(),
    };
  }

  static EJsonValue _toEJson(Options value) => value.toEJson();
  static Options _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'numberOfSections': EJsonValue numberOfSections,
        'skillWeight': EJsonValue skillWeight,
        'genderWeight': EJsonValue genderWeight,
        'waitedWeight': EJsonValue waitedWeight,
        'playedWeight': EJsonValue playedWeight,
        'playedWithWeight': EJsonValue playedWithWeight,
      } =>
        Options(
          fromEJson(id),
          fromEJson(numberOfSections),
          fromEJson(skillWeight),
          fromEJson(genderWeight),
          fromEJson(waitedWeight),
          fromEJson(playedWeight),
          fromEJson(playedWithWeight),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Options._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Options, 'Options', [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('numberOfSections', RealmPropertyType.int),
      SchemaProperty('skillWeight', RealmPropertyType.double),
      SchemaProperty('genderWeight', RealmPropertyType.double),
      SchemaProperty('waitedWeight', RealmPropertyType.double),
      SchemaProperty('playedWeight', RealmPropertyType.double),
      SchemaProperty('playedWithWeight', RealmPropertyType.double),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
