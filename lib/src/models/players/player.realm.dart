// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Player extends _Player with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Player(
    int id,
    String name,
    String role,
    int rate,
    String gender, {
    int played = 0,
    int waited = 0,
    int lated = 0,
    Map<String, int> gamesPlayedWith = const {},
    Iterable<int> groups = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Player>({
        'played': 0,
        'waited': 0,
        'lated': 0,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'role', role);
    RealmObjectBase.set(this, 'rate', rate);
    RealmObjectBase.set(this, 'gender', gender);
    RealmObjectBase.set(this, 'played', played);
    RealmObjectBase.set(this, 'waited', waited);
    RealmObjectBase.set(this, 'lated', lated);
    RealmObjectBase.set<RealmMap<int>>(
      this,
      'gamesPlayedWith',
      RealmMap<int>(gamesPlayedWith),
    );
    RealmObjectBase.set<RealmList<int>>(this, 'groups', RealmList<int>(groups));
  }

  Player._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get role => RealmObjectBase.get<String>(this, 'role') as String;
  @override
  set role(String value) => RealmObjectBase.set(this, 'role', value);

  @override
  int get rate => RealmObjectBase.get<int>(this, 'rate') as int;
  @override
  set rate(int value) => RealmObjectBase.set(this, 'rate', value);

  @override
  String get gender => RealmObjectBase.get<String>(this, 'gender') as String;
  @override
  set gender(String value) => RealmObjectBase.set(this, 'gender', value);

  @override
  int get played => RealmObjectBase.get<int>(this, 'played') as int;
  @override
  set played(int value) => RealmObjectBase.set(this, 'played', value);

  @override
  int get waited => RealmObjectBase.get<int>(this, 'waited') as int;
  @override
  set waited(int value) => RealmObjectBase.set(this, 'waited', value);

  @override
  int get lated => RealmObjectBase.get<int>(this, 'lated') as int;
  @override
  set lated(int value) => RealmObjectBase.set(this, 'lated', value);

  @override
  RealmMap<int> get gamesPlayedWith =>
      RealmObjectBase.get<int>(this, 'gamesPlayedWith') as RealmMap<int>;
  @override
  set gamesPlayedWith(covariant RealmMap<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<int> get groups =>
      RealmObjectBase.get<int>(this, 'groups') as RealmList<int>;
  @override
  set groups(covariant RealmList<int> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Player>> get changes =>
      RealmObjectBase.getChanges<Player>(this);

  @override
  Stream<RealmObjectChanges<Player>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Player>(this, keyPaths);

  @override
  Player freeze() => RealmObjectBase.freezeObject<Player>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'role': role.toEJson(),
      'rate': rate.toEJson(),
      'gender': gender.toEJson(),
      'played': played.toEJson(),
      'waited': waited.toEJson(),
      'lated': lated.toEJson(),
      'gamesPlayedWith': gamesPlayedWith.toEJson(),
      'groups': groups.toEJson(),
    };
  }

  static EJsonValue _toEJson(Player value) => value.toEJson();
  static Player _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'role': EJsonValue role,
        'rate': EJsonValue rate,
        'gender': EJsonValue gender,
      } =>
        Player(
          fromEJson(id),
          fromEJson(name),
          fromEJson(role),
          fromEJson(rate),
          fromEJson(gender),
          played: fromEJson(ejson['played'], defaultValue: 0),
          waited: fromEJson(ejson['waited'], defaultValue: 0),
          lated: fromEJson(ejson['lated'], defaultValue: 0),
          gamesPlayedWith: fromEJson(
            ejson['gamesPlayedWith'],
            defaultValue: const {},
          ),
          groups: fromEJson(ejson['groups'], defaultValue: const []),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Player._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Player, 'Player', [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('role', RealmPropertyType.string),
      SchemaProperty('rate', RealmPropertyType.int),
      SchemaProperty('gender', RealmPropertyType.string),
      SchemaProperty('played', RealmPropertyType.int),
      SchemaProperty('waited', RealmPropertyType.int),
      SchemaProperty('lated', RealmPropertyType.int),
      SchemaProperty(
        'gamesPlayedWith',
        RealmPropertyType.int,
        collectionType: RealmCollectionType.map,
      ),
      SchemaProperty(
        'groups',
        RealmPropertyType.int,
        collectionType: RealmCollectionType.list,
      ),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
