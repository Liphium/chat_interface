// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ConversationTable extends Conversation
    with TableInfo<$ConversationTable, ConversationData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<BigInt> updatedAt = GeneratedColumn<BigInt>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, data, key, updatedAt];
  @override
  String get aliasedName => _alias ?? 'conversation';
  @override
  String get actualTableName => 'conversation';
  @override
  VerificationContext validateIntegrity(Insertable<ConversationData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConversationData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ConversationTable createAlias(String alias) {
    return $ConversationTable(attachedDatabase, alias);
  }
}

class ConversationData extends DataClass
    implements Insertable<ConversationData> {
  final int id;
  final String data;
  final String key;
  final BigInt updatedAt;
  const ConversationData(
      {required this.id,
      required this.data,
      required this.key,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['data'] = Variable<String>(data);
    map['key'] = Variable<String>(key);
    map['updated_at'] = Variable<BigInt>(updatedAt);
    return map;
  }

  ConversationCompanion toCompanion(bool nullToAbsent) {
    return ConversationCompanion(
      id: Value(id),
      data: Value(data),
      key: Value(key),
      updatedAt: Value(updatedAt),
    );
  }

  factory ConversationData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationData(
      id: serializer.fromJson<int>(json['id']),
      data: serializer.fromJson<String>(json['data']),
      key: serializer.fromJson<String>(json['key']),
      updatedAt: serializer.fromJson<BigInt>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'data': serializer.toJson<String>(data),
      'key': serializer.toJson<String>(key),
      'updatedAt': serializer.toJson<BigInt>(updatedAt),
    };
  }

  ConversationData copyWith(
          {int? id, String? data, String? key, BigInt? updatedAt}) =>
      ConversationData(
        id: id ?? this.id,
        data: data ?? this.data,
        key: key ?? this.key,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  @override
  String toString() {
    return (StringBuffer('ConversationData(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('key: $key, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, data, key, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationData &&
          other.id == this.id &&
          other.data == this.data &&
          other.key == this.key &&
          other.updatedAt == this.updatedAt);
}

class ConversationCompanion extends UpdateCompanion<ConversationData> {
  final Value<int> id;
  final Value<String> data;
  final Value<String> key;
  final Value<BigInt> updatedAt;
  const ConversationCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.key = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ConversationCompanion.insert({
    this.id = const Value.absent(),
    required String data,
    required String key,
    required BigInt updatedAt,
  })  : data = Value(data),
        key = Value(key),
        updatedAt = Value(updatedAt);
  static Insertable<ConversationData> custom({
    Expression<int>? id,
    Expression<String>? data,
    Expression<String>? key,
    Expression<BigInt>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
      if (key != null) 'key': key,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ConversationCompanion copyWith(
      {Value<int>? id,
      Value<String>? data,
      Value<String>? key,
      Value<BigInt>? updatedAt}) {
    return ConversationCompanion(
      id: id ?? this.id,
      data: data ?? this.data,
      key: key ?? this.key,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<BigInt>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationCompanion(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('key: $key, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MemberTable extends Member with TableInfo<$MemberTable, MemberData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemberTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
      'conversation_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES conversations(id)');
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
      'account_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<int> roleId = GeneratedColumn<int>(
      'role_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, conversationId, accountId, roleId];
  @override
  String get aliasedName => _alias ?? 'member';
  @override
  String get actualTableName => 'member';
  @override
  VerificationContext validateIntegrity(Insertable<MemberData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('role_id')) {
      context.handle(_roleIdMeta,
          roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta));
    } else if (isInserting) {
      context.missing(_roleIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemberData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemberData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      conversationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conversation_id']),
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}account_id'])!,
      roleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}role_id'])!,
    );
  }

  @override
  $MemberTable createAlias(String alias) {
    return $MemberTable(attachedDatabase, alias);
  }
}

class MemberData extends DataClass implements Insertable<MemberData> {
  final int id;
  final String name;
  final int? conversationId;
  final int accountId;
  final int roleId;
  const MemberData(
      {required this.id,
      required this.name,
      this.conversationId,
      required this.accountId,
      required this.roleId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || conversationId != null) {
      map['conversation_id'] = Variable<int>(conversationId);
    }
    map['account_id'] = Variable<int>(accountId);
    map['role_id'] = Variable<int>(roleId);
    return map;
  }

  MemberCompanion toCompanion(bool nullToAbsent) {
    return MemberCompanion(
      id: Value(id),
      name: Value(name),
      conversationId: conversationId == null && nullToAbsent
          ? const Value.absent()
          : Value(conversationId),
      accountId: Value(accountId),
      roleId: Value(roleId),
    );
  }

  factory MemberData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemberData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      conversationId: serializer.fromJson<int?>(json['conversationId']),
      accountId: serializer.fromJson<int>(json['accountId']),
      roleId: serializer.fromJson<int>(json['roleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'conversationId': serializer.toJson<int?>(conversationId),
      'accountId': serializer.toJson<int>(accountId),
      'roleId': serializer.toJson<int>(roleId),
    };
  }

  MemberData copyWith(
          {int? id,
          String? name,
          Value<int?> conversationId = const Value.absent(),
          int? accountId,
          int? roleId}) =>
      MemberData(
        id: id ?? this.id,
        name: name ?? this.name,
        conversationId:
            conversationId.present ? conversationId.value : this.conversationId,
        accountId: accountId ?? this.accountId,
        roleId: roleId ?? this.roleId,
      );
  @override
  String toString() {
    return (StringBuffer('MemberData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('conversationId: $conversationId, ')
          ..write('accountId: $accountId, ')
          ..write('roleId: $roleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, conversationId, accountId, roleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemberData &&
          other.id == this.id &&
          other.name == this.name &&
          other.conversationId == this.conversationId &&
          other.accountId == this.accountId &&
          other.roleId == this.roleId);
}

class MemberCompanion extends UpdateCompanion<MemberData> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> conversationId;
  final Value<int> accountId;
  final Value<int> roleId;
  const MemberCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.roleId = const Value.absent(),
  });
  MemberCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.conversationId = const Value.absent(),
    required int accountId,
    required int roleId,
  })  : name = Value(name),
        accountId = Value(accountId),
        roleId = Value(roleId);
  static Insertable<MemberData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? conversationId,
    Expression<int>? accountId,
    Expression<int>? roleId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (conversationId != null) 'conversation_id': conversationId,
      if (accountId != null) 'account_id': accountId,
      if (roleId != null) 'role_id': roleId,
    });
  }

  MemberCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int?>? conversationId,
      Value<int>? accountId,
      Value<int>? roleId}) {
    return MemberCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      conversationId: conversationId ?? this.conversationId,
      accountId: accountId ?? this.accountId,
      roleId: roleId ?? this.roleId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<int>(roleId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemberCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('conversationId: $conversationId, ')
          ..write('accountId: $accountId, ')
          ..write('roleId: $roleId')
          ..write(')'))
        .toString();
  }
}

class $MessageTable extends Message with TableInfo<$MessageTable, MessageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _verifiedMeta =
      const VerificationMeta('verified');
  @override
  late final GeneratedColumn<bool> verified =
      GeneratedColumn<bool>('verified', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("verified" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _certificateMeta =
      const VerificationMeta('certificate');
  @override
  late final GeneratedColumn<String> certificate = GeneratedColumn<String>(
      'certificate', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<int> sender = GeneratedColumn<int>(
      'sender', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES friends(id)');
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
      'conversation_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES conversations(id)');
  static const VerificationMeta _editedMeta = const VerificationMeta('edited');
  @override
  late final GeneratedColumn<bool> edited =
      GeneratedColumn<bool>('edited', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: true,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("edited" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        verified,
        content,
        certificate,
        sender,
        createdAt,
        conversationId,
        edited
      ];
  @override
  String get aliasedName => _alias ?? 'message';
  @override
  String get actualTableName => 'message';
  @override
  VerificationContext validateIntegrity(Insertable<MessageData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('verified')) {
      context.handle(_verifiedMeta,
          verified.isAcceptableOrUnknown(data['verified']!, _verifiedMeta));
    } else if (isInserting) {
      context.missing(_verifiedMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('certificate')) {
      context.handle(
          _certificateMeta,
          certificate.isAcceptableOrUnknown(
              data['certificate']!, _certificateMeta));
    } else if (isInserting) {
      context.missing(_certificateMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(_senderMeta,
          sender.isAcceptableOrUnknown(data['sender']!, _senderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    }
    if (data.containsKey('edited')) {
      context.handle(_editedMeta,
          edited.isAcceptableOrUnknown(data['edited']!, _editedMeta));
    } else if (isInserting) {
      context.missing(_editedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      verified: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}verified'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      certificate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}certificate'])!,
      sender: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sender']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      conversationId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}conversation_id']),
      edited: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}edited'])!,
    );
  }

  @override
  $MessageTable createAlias(String alias) {
    return $MessageTable(attachedDatabase, alias);
  }
}

class MessageData extends DataClass implements Insertable<MessageData> {
  final String id;
  final bool verified;
  final String content;
  final String certificate;
  final int? sender;
  final DateTime createdAt;
  final int? conversationId;
  final bool edited;
  const MessageData(
      {required this.id,
      required this.verified,
      required this.content,
      required this.certificate,
      this.sender,
      required this.createdAt,
      this.conversationId,
      required this.edited});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['verified'] = Variable<bool>(verified);
    map['content'] = Variable<String>(content);
    map['certificate'] = Variable<String>(certificate);
    if (!nullToAbsent || sender != null) {
      map['sender'] = Variable<int>(sender);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || conversationId != null) {
      map['conversation_id'] = Variable<int>(conversationId);
    }
    map['edited'] = Variable<bool>(edited);
    return map;
  }

  MessageCompanion toCompanion(bool nullToAbsent) {
    return MessageCompanion(
      id: Value(id),
      verified: Value(verified),
      content: Value(content),
      certificate: Value(certificate),
      sender:
          sender == null && nullToAbsent ? const Value.absent() : Value(sender),
      createdAt: Value(createdAt),
      conversationId: conversationId == null && nullToAbsent
          ? const Value.absent()
          : Value(conversationId),
      edited: Value(edited),
    );
  }

  factory MessageData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageData(
      id: serializer.fromJson<String>(json['id']),
      verified: serializer.fromJson<bool>(json['verified']),
      content: serializer.fromJson<String>(json['content']),
      certificate: serializer.fromJson<String>(json['certificate']),
      sender: serializer.fromJson<int?>(json['sender']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      conversationId: serializer.fromJson<int?>(json['conversationId']),
      edited: serializer.fromJson<bool>(json['edited']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'verified': serializer.toJson<bool>(verified),
      'content': serializer.toJson<String>(content),
      'certificate': serializer.toJson<String>(certificate),
      'sender': serializer.toJson<int?>(sender),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'conversationId': serializer.toJson<int?>(conversationId),
      'edited': serializer.toJson<bool>(edited),
    };
  }

  MessageData copyWith(
          {String? id,
          bool? verified,
          String? content,
          String? certificate,
          Value<int?> sender = const Value.absent(),
          DateTime? createdAt,
          Value<int?> conversationId = const Value.absent(),
          bool? edited}) =>
      MessageData(
        id: id ?? this.id,
        verified: verified ?? this.verified,
        content: content ?? this.content,
        certificate: certificate ?? this.certificate,
        sender: sender.present ? sender.value : this.sender,
        createdAt: createdAt ?? this.createdAt,
        conversationId:
            conversationId.present ? conversationId.value : this.conversationId,
        edited: edited ?? this.edited,
      );
  @override
  String toString() {
    return (StringBuffer('MessageData(')
          ..write('id: $id, ')
          ..write('verified: $verified, ')
          ..write('content: $content, ')
          ..write('certificate: $certificate, ')
          ..write('sender: $sender, ')
          ..write('createdAt: $createdAt, ')
          ..write('conversationId: $conversationId, ')
          ..write('edited: $edited')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, verified, content, certificate, sender,
      createdAt, conversationId, edited);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageData &&
          other.id == this.id &&
          other.verified == this.verified &&
          other.content == this.content &&
          other.certificate == this.certificate &&
          other.sender == this.sender &&
          other.createdAt == this.createdAt &&
          other.conversationId == this.conversationId &&
          other.edited == this.edited);
}

class MessageCompanion extends UpdateCompanion<MessageData> {
  final Value<String> id;
  final Value<bool> verified;
  final Value<String> content;
  final Value<String> certificate;
  final Value<int?> sender;
  final Value<DateTime> createdAt;
  final Value<int?> conversationId;
  final Value<bool> edited;
  const MessageCompanion({
    this.id = const Value.absent(),
    this.verified = const Value.absent(),
    this.content = const Value.absent(),
    this.certificate = const Value.absent(),
    this.sender = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.edited = const Value.absent(),
  });
  MessageCompanion.insert({
    required String id,
    required bool verified,
    required String content,
    required String certificate,
    this.sender = const Value.absent(),
    required DateTime createdAt,
    this.conversationId = const Value.absent(),
    required bool edited,
  })  : id = Value(id),
        verified = Value(verified),
        content = Value(content),
        certificate = Value(certificate),
        createdAt = Value(createdAt),
        edited = Value(edited);
  static Insertable<MessageData> custom({
    Expression<String>? id,
    Expression<bool>? verified,
    Expression<String>? content,
    Expression<String>? certificate,
    Expression<int>? sender,
    Expression<DateTime>? createdAt,
    Expression<int>? conversationId,
    Expression<bool>? edited,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (verified != null) 'verified': verified,
      if (content != null) 'content': content,
      if (certificate != null) 'certificate': certificate,
      if (sender != null) 'sender': sender,
      if (createdAt != null) 'created_at': createdAt,
      if (conversationId != null) 'conversation_id': conversationId,
      if (edited != null) 'edited': edited,
    });
  }

  MessageCompanion copyWith(
      {Value<String>? id,
      Value<bool>? verified,
      Value<String>? content,
      Value<String>? certificate,
      Value<int?>? sender,
      Value<DateTime>? createdAt,
      Value<int?>? conversationId,
      Value<bool>? edited}) {
    return MessageCompanion(
      id: id ?? this.id,
      verified: verified ?? this.verified,
      content: content ?? this.content,
      certificate: certificate ?? this.certificate,
      sender: sender ?? this.sender,
      createdAt: createdAt ?? this.createdAt,
      conversationId: conversationId ?? this.conversationId,
      edited: edited ?? this.edited,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (verified.present) {
      map['verified'] = Variable<bool>(verified.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (certificate.present) {
      map['certificate'] = Variable<String>(certificate.value);
    }
    if (sender.present) {
      map['sender'] = Variable<int>(sender.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (edited.present) {
      map['edited'] = Variable<bool>(edited.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageCompanion(')
          ..write('id: $id, ')
          ..write('verified: $verified, ')
          ..write('content: $content, ')
          ..write('certificate: $certificate, ')
          ..write('sender: $sender, ')
          ..write('createdAt: $createdAt, ')
          ..write('conversationId: $conversationId, ')
          ..write('edited: $edited')
          ..write(')'))
        .toString();
  }
}

class $SettingTable extends Setting with TableInfo<$SettingTable, SettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? 'setting';
  @override
  String get actualTableName => 'setting';
  @override
  VerificationContext validateIntegrity(Insertable<SettingData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingTable createAlias(String alias) {
    return $SettingTable(attachedDatabase, alias);
  }
}

class SettingData extends DataClass implements Insertable<SettingData> {
  final String key;
  final String value;
  const SettingData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingCompanion toCompanion(bool nullToAbsent) {
    return SettingCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory SettingData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingData copyWith({String? key, String? value}) => SettingData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  @override
  String toString() {
    return (StringBuffer('SettingData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingData &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingCompanion extends UpdateCompanion<SettingData> {
  final Value<String> key;
  final Value<String> value;
  const SettingCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
  });
  SettingCompanion.insert({
    required String key,
    required String value,
  })  : key = Value(key),
        value = Value(value);
  static Insertable<SettingData> custom({
    Expression<String>? key,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
    });
  }

  SettingCompanion copyWith({Value<String>? key, Value<String>? value}) {
    return SettingCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingCompanion(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $FriendTable extends Friend with TableInfo<$FriendTable, FriendData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FriendTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
      'tag', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, key, tag];
  @override
  String get aliasedName => _alias ?? 'friend';
  @override
  String get actualTableName => 'friend';
  @override
  VerificationContext validateIntegrity(Insertable<FriendData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
          _tagMeta, tag.isAcceptableOrUnknown(data['tag']!, _tagMeta));
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FriendData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FriendData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      tag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag'])!,
    );
  }

  @override
  $FriendTable createAlias(String alias) {
    return $FriendTable(attachedDatabase, alias);
  }
}

class FriendData extends DataClass implements Insertable<FriendData> {
  final int id;
  final String name;
  final String key;
  final String tag;
  const FriendData(
      {required this.id,
      required this.name,
      required this.key,
      required this.tag});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['key'] = Variable<String>(key);
    map['tag'] = Variable<String>(tag);
    return map;
  }

  FriendCompanion toCompanion(bool nullToAbsent) {
    return FriendCompanion(
      id: Value(id),
      name: Value(name),
      key: Value(key),
      tag: Value(tag),
    );
  }

  factory FriendData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FriendData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      key: serializer.fromJson<String>(json['key']),
      tag: serializer.fromJson<String>(json['tag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'key': serializer.toJson<String>(key),
      'tag': serializer.toJson<String>(tag),
    };
  }

  FriendData copyWith({int? id, String? name, String? key, String? tag}) =>
      FriendData(
        id: id ?? this.id,
        name: name ?? this.name,
        key: key ?? this.key,
        tag: tag ?? this.tag,
      );
  @override
  String toString() {
    return (StringBuffer('FriendData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('key: $key, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, key, tag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FriendData &&
          other.id == this.id &&
          other.name == this.name &&
          other.key == this.key &&
          other.tag == this.tag);
}

class FriendCompanion extends UpdateCompanion<FriendData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> key;
  final Value<String> tag;
  const FriendCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.key = const Value.absent(),
    this.tag = const Value.absent(),
  });
  FriendCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String key,
    required String tag,
  })  : name = Value(name),
        key = Value(key),
        tag = Value(tag);
  static Insertable<FriendData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? key,
    Expression<String>? tag,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (key != null) 'key': key,
      if (tag != null) 'tag': tag,
    });
  }

  FriendCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? key,
      Value<String>? tag}) {
    return FriendCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      key: key ?? this.key,
      tag: tag ?? this.tag,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FriendCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('key: $key, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  late final $ConversationTable conversation = $ConversationTable(this);
  late final $MemberTable member = $MemberTable(this);
  late final $MessageTable message = $MessageTable(this);
  late final $SettingTable setting = $SettingTable(this);
  late final $FriendTable friend = $FriendTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [conversation, member, message, setting, friend];
}
