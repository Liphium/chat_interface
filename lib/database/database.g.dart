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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
    } else if (isInserting) {
      context.missing(_idMeta);
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
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
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
  final String id;
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
    map['id'] = Variable<String>(id);
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
      id: serializer.fromJson<String>(json['id']),
      data: serializer.fromJson<String>(json['data']),
      key: serializer.fromJson<String>(json['key']),
      updatedAt: serializer.fromJson<BigInt>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'data': serializer.toJson<String>(data),
      'key': serializer.toJson<String>(key),
      'updatedAt': serializer.toJson<BigInt>(updatedAt),
    };
  }

  ConversationData copyWith(
          {String? id, String? data, String? key, BigInt? updatedAt}) =>
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
  final Value<String> id;
  final Value<String> data;
  final Value<String> key;
  final Value<BigInt> updatedAt;
  final Value<int> rowid;
  const ConversationCompanion({
    this.id = const Value.absent(),
    this.data = const Value.absent(),
    this.key = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationCompanion.insert({
    required String id,
    required String data,
    required String key,
    required BigInt updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        data = Value(data),
        key = Value(key),
        updatedAt = Value(updatedAt);
  static Insertable<ConversationData> custom({
    Expression<String>? id,
    Expression<String>? data,
    Expression<String>? key,
    Expression<BigInt>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (data != null) 'data': data,
      if (key != null) 'key': key,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationCompanion copyWith(
      {Value<String>? id,
      Value<String>? data,
      Value<String>? key,
      Value<BigInt>? updatedAt,
      Value<int>? rowid}) {
    return ConversationCompanion(
      id: id ?? this.id,
      data: data ?? this.data,
      key: key ?? this.key,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationCompanion(')
          ..write('id: $id, ')
          ..write('data: $data, ')
          ..write('key: $key, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
    } else if (isInserting) {
      context.missing(_idMeta);
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
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      conversationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}conversation_id']),
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
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
  final String id;
  final String name;
  final String? conversationId;
  final String accountId;
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
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || conversationId != null) {
      map['conversation_id'] = Variable<String>(conversationId);
    }
    map['account_id'] = Variable<String>(accountId);
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
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      conversationId: serializer.fromJson<String?>(json['conversationId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      roleId: serializer.fromJson<int>(json['roleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'conversationId': serializer.toJson<String?>(conversationId),
      'accountId': serializer.toJson<String>(accountId),
      'roleId': serializer.toJson<int>(roleId),
    };
  }

  MemberData copyWith(
          {String? id,
          String? name,
          Value<String?> conversationId = const Value.absent(),
          String? accountId,
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
  final Value<String> id;
  final Value<String> name;
  final Value<String?> conversationId;
  final Value<String> accountId;
  final Value<int> roleId;
  final Value<int> rowid;
  const MemberCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.roleId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemberCompanion.insert({
    required String id,
    required String name,
    this.conversationId = const Value.absent(),
    required String accountId,
    required int roleId,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        accountId = Value(accountId),
        roleId = Value(roleId);
  static Insertable<MemberData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? conversationId,
    Expression<String>? accountId,
    Expression<int>? roleId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (conversationId != null) 'conversation_id': conversationId,
      if (accountId != null) 'account_id': accountId,
      if (roleId != null) 'role_id': roleId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemberCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? conversationId,
      Value<String>? accountId,
      Value<int>? roleId,
      Value<int>? rowid}) {
    return MemberCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      conversationId: conversationId ?? this.conversationId,
      accountId: accountId ?? this.accountId,
      roleId: roleId ?? this.roleId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<int>(roleId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
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
          ..write('roleId: $roleId, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<bool> verified = GeneratedColumn<bool>(
      'verified', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("verified" IN (0, 1))'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _attachmentsMeta =
      const VerificationMeta('attachments');
  @override
  late final GeneratedColumn<String> attachments = GeneratedColumn<String>(
      'attachments', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _certificateMeta =
      const VerificationMeta('certificate');
  @override
  late final GeneratedColumn<String> certificate = GeneratedColumn<String>(
      'certificate', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
      'sender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editedMeta = const VerificationMeta('edited');
  @override
  late final GeneratedColumn<bool> edited = GeneratedColumn<bool>(
      'edited', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("edited" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        verified,
        type,
        content,
        attachments,
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
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('attachments')) {
      context.handle(
          _attachmentsMeta,
          attachments.isAcceptableOrUnknown(
              data['attachments']!, _attachmentsMeta));
    } else if (isInserting) {
      context.missing(_attachmentsMeta);
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
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      attachments: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attachments'])!,
      certificate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}certificate'])!,
      sender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      conversationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}conversation_id']),
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
  final String type;
  final String content;
  final String attachments;
  final String certificate;
  final String? sender;
  final DateTime createdAt;
  final String? conversationId;
  final bool edited;
  const MessageData(
      {required this.id,
      required this.verified,
      required this.type,
      required this.content,
      required this.attachments,
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
    map['type'] = Variable<String>(type);
    map['content'] = Variable<String>(content);
    map['attachments'] = Variable<String>(attachments);
    map['certificate'] = Variable<String>(certificate);
    if (!nullToAbsent || sender != null) {
      map['sender'] = Variable<String>(sender);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || conversationId != null) {
      map['conversation_id'] = Variable<String>(conversationId);
    }
    map['edited'] = Variable<bool>(edited);
    return map;
  }

  MessageCompanion toCompanion(bool nullToAbsent) {
    return MessageCompanion(
      id: Value(id),
      verified: Value(verified),
      type: Value(type),
      content: Value(content),
      attachments: Value(attachments),
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
      type: serializer.fromJson<String>(json['type']),
      content: serializer.fromJson<String>(json['content']),
      attachments: serializer.fromJson<String>(json['attachments']),
      certificate: serializer.fromJson<String>(json['certificate']),
      sender: serializer.fromJson<String?>(json['sender']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      conversationId: serializer.fromJson<String?>(json['conversationId']),
      edited: serializer.fromJson<bool>(json['edited']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'verified': serializer.toJson<bool>(verified),
      'type': serializer.toJson<String>(type),
      'content': serializer.toJson<String>(content),
      'attachments': serializer.toJson<String>(attachments),
      'certificate': serializer.toJson<String>(certificate),
      'sender': serializer.toJson<String?>(sender),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'conversationId': serializer.toJson<String?>(conversationId),
      'edited': serializer.toJson<bool>(edited),
    };
  }

  MessageData copyWith(
          {String? id,
          bool? verified,
          String? type,
          String? content,
          String? attachments,
          String? certificate,
          Value<String?> sender = const Value.absent(),
          DateTime? createdAt,
          Value<String?> conversationId = const Value.absent(),
          bool? edited}) =>
      MessageData(
        id: id ?? this.id,
        verified: verified ?? this.verified,
        type: type ?? this.type,
        content: content ?? this.content,
        attachments: attachments ?? this.attachments,
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
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('attachments: $attachments, ')
          ..write('certificate: $certificate, ')
          ..write('sender: $sender, ')
          ..write('createdAt: $createdAt, ')
          ..write('conversationId: $conversationId, ')
          ..write('edited: $edited')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, verified, type, content, attachments,
      certificate, sender, createdAt, conversationId, edited);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageData &&
          other.id == this.id &&
          other.verified == this.verified &&
          other.type == this.type &&
          other.content == this.content &&
          other.attachments == this.attachments &&
          other.certificate == this.certificate &&
          other.sender == this.sender &&
          other.createdAt == this.createdAt &&
          other.conversationId == this.conversationId &&
          other.edited == this.edited);
}

class MessageCompanion extends UpdateCompanion<MessageData> {
  final Value<String> id;
  final Value<bool> verified;
  final Value<String> type;
  final Value<String> content;
  final Value<String> attachments;
  final Value<String> certificate;
  final Value<String?> sender;
  final Value<DateTime> createdAt;
  final Value<String?> conversationId;
  final Value<bool> edited;
  final Value<int> rowid;
  const MessageCompanion({
    this.id = const Value.absent(),
    this.verified = const Value.absent(),
    this.type = const Value.absent(),
    this.content = const Value.absent(),
    this.attachments = const Value.absent(),
    this.certificate = const Value.absent(),
    this.sender = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.edited = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageCompanion.insert({
    required String id,
    required bool verified,
    required String type,
    required String content,
    required String attachments,
    required String certificate,
    this.sender = const Value.absent(),
    required DateTime createdAt,
    this.conversationId = const Value.absent(),
    required bool edited,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        verified = Value(verified),
        type = Value(type),
        content = Value(content),
        attachments = Value(attachments),
        certificate = Value(certificate),
        createdAt = Value(createdAt),
        edited = Value(edited);
  static Insertable<MessageData> custom({
    Expression<String>? id,
    Expression<bool>? verified,
    Expression<String>? type,
    Expression<String>? content,
    Expression<String>? attachments,
    Expression<String>? certificate,
    Expression<String>? sender,
    Expression<DateTime>? createdAt,
    Expression<String>? conversationId,
    Expression<bool>? edited,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (verified != null) 'verified': verified,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (attachments != null) 'attachments': attachments,
      if (certificate != null) 'certificate': certificate,
      if (sender != null) 'sender': sender,
      if (createdAt != null) 'created_at': createdAt,
      if (conversationId != null) 'conversation_id': conversationId,
      if (edited != null) 'edited': edited,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageCompanion copyWith(
      {Value<String>? id,
      Value<bool>? verified,
      Value<String>? type,
      Value<String>? content,
      Value<String>? attachments,
      Value<String>? certificate,
      Value<String?>? sender,
      Value<DateTime>? createdAt,
      Value<String?>? conversationId,
      Value<bool>? edited,
      Value<int>? rowid}) {
    return MessageCompanion(
      id: id ?? this.id,
      verified: verified ?? this.verified,
      type: type ?? this.type,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
      certificate: certificate ?? this.certificate,
      sender: sender ?? this.sender,
      createdAt: createdAt ?? this.createdAt,
      conversationId: conversationId ?? this.conversationId,
      edited: edited ?? this.edited,
      rowid: rowid ?? this.rowid,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (attachments.present) {
      map['attachments'] = Variable<String>(attachments.value);
    }
    if (certificate.present) {
      map['certificate'] = Variable<String>(certificate.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (edited.present) {
      map['edited'] = Variable<bool>(edited.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageCompanion(')
          ..write('id: $id, ')
          ..write('verified: $verified, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('attachments: $attachments, ')
          ..write('certificate: $certificate, ')
          ..write('sender: $sender, ')
          ..write('createdAt: $createdAt, ')
          ..write('conversationId: $conversationId, ')
          ..write('edited: $edited, ')
          ..write('rowid: $rowid')
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
  final Value<int> rowid;
  const SettingCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<SettingData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
      'tag', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vaultIdMeta =
      const VerificationMeta('vaultId');
  @override
  late final GeneratedColumn<String> vaultId = GeneratedColumn<String>(
      'vault_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _keysMeta = const VerificationMeta('keys');
  @override
  late final GeneratedColumn<String> keys = GeneratedColumn<String>(
      'keys', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, tag, vaultId, keys];
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
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
          _tagMeta, tag.isAcceptableOrUnknown(data['tag']!, _tagMeta));
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('vault_id')) {
      context.handle(_vaultIdMeta,
          vaultId.isAcceptableOrUnknown(data['vault_id']!, _vaultIdMeta));
    } else if (isInserting) {
      context.missing(_vaultIdMeta);
    }
    if (data.containsKey('keys')) {
      context.handle(
          _keysMeta, keys.isAcceptableOrUnknown(data['keys']!, _keysMeta));
    } else if (isInserting) {
      context.missing(_keysMeta);
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
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      tag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag'])!,
      vaultId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vault_id'])!,
      keys: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}keys'])!,
    );
  }

  @override
  $FriendTable createAlias(String alias) {
    return $FriendTable(attachedDatabase, alias);
  }
}

class FriendData extends DataClass implements Insertable<FriendData> {
  final String id;
  final String name;
  final String tag;
  final String vaultId;
  final String keys;
  const FriendData(
      {required this.id,
      required this.name,
      required this.tag,
      required this.vaultId,
      required this.keys});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['tag'] = Variable<String>(tag);
    map['vault_id'] = Variable<String>(vaultId);
    map['keys'] = Variable<String>(keys);
    return map;
  }

  FriendCompanion toCompanion(bool nullToAbsent) {
    return FriendCompanion(
      id: Value(id),
      name: Value(name),
      tag: Value(tag),
      vaultId: Value(vaultId),
      keys: Value(keys),
    );
  }

  factory FriendData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FriendData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      tag: serializer.fromJson<String>(json['tag']),
      vaultId: serializer.fromJson<String>(json['vaultId']),
      keys: serializer.fromJson<String>(json['keys']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'tag': serializer.toJson<String>(tag),
      'vaultId': serializer.toJson<String>(vaultId),
      'keys': serializer.toJson<String>(keys),
    };
  }

  FriendData copyWith(
          {String? id,
          String? name,
          String? tag,
          String? vaultId,
          String? keys}) =>
      FriendData(
        id: id ?? this.id,
        name: name ?? this.name,
        tag: tag ?? this.tag,
        vaultId: vaultId ?? this.vaultId,
        keys: keys ?? this.keys,
      );
  @override
  String toString() {
    return (StringBuffer('FriendData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tag: $tag, ')
          ..write('vaultId: $vaultId, ')
          ..write('keys: $keys')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, tag, vaultId, keys);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FriendData &&
          other.id == this.id &&
          other.name == this.name &&
          other.tag == this.tag &&
          other.vaultId == this.vaultId &&
          other.keys == this.keys);
}

class FriendCompanion extends UpdateCompanion<FriendData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> tag;
  final Value<String> vaultId;
  final Value<String> keys;
  final Value<int> rowid;
  const FriendCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.tag = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.keys = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FriendCompanion.insert({
    required String id,
    required String name,
    required String tag,
    required String vaultId,
    required String keys,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        tag = Value(tag),
        vaultId = Value(vaultId),
        keys = Value(keys);
  static Insertable<FriendData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? tag,
    Expression<String>? vaultId,
    Expression<String>? keys,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (tag != null) 'tag': tag,
      if (vaultId != null) 'vault_id': vaultId,
      if (keys != null) 'keys': keys,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FriendCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? tag,
      Value<String>? vaultId,
      Value<String>? keys,
      Value<int>? rowid}) {
    return FriendCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      vaultId: vaultId ?? this.vaultId,
      keys: keys ?? this.keys,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (vaultId.present) {
      map['vault_id'] = Variable<String>(vaultId.value);
    }
    if (keys.present) {
      map['keys'] = Variable<String>(keys.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FriendCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tag: $tag, ')
          ..write('vaultId: $vaultId, ')
          ..write('keys: $keys, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RequestTable extends Request with TableInfo<$RequestTable, RequestData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RequestTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
      'tag', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _selfMeta = const VerificationMeta('self');
  @override
  late final GeneratedColumn<bool> self = GeneratedColumn<bool>(
      'self', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("self" IN (0, 1))'));
  static const VerificationMeta _vaultIdMeta =
      const VerificationMeta('vaultId');
  @override
  late final GeneratedColumn<String> vaultId = GeneratedColumn<String>(
      'vault_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storedActionIdMeta =
      const VerificationMeta('storedActionId');
  @override
  late final GeneratedColumn<String> storedActionId = GeneratedColumn<String>(
      'stored_action_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _keysMeta = const VerificationMeta('keys');
  @override
  late final GeneratedColumn<String> keys = GeneratedColumn<String>(
      'keys', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, tag, self, vaultId, storedActionId, keys];
  @override
  String get aliasedName => _alias ?? 'request';
  @override
  String get actualTableName => 'request';
  @override
  VerificationContext validateIntegrity(Insertable<RequestData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
          _tagMeta, tag.isAcceptableOrUnknown(data['tag']!, _tagMeta));
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('self')) {
      context.handle(
          _selfMeta, self.isAcceptableOrUnknown(data['self']!, _selfMeta));
    } else if (isInserting) {
      context.missing(_selfMeta);
    }
    if (data.containsKey('vault_id')) {
      context.handle(_vaultIdMeta,
          vaultId.isAcceptableOrUnknown(data['vault_id']!, _vaultIdMeta));
    } else if (isInserting) {
      context.missing(_vaultIdMeta);
    }
    if (data.containsKey('stored_action_id')) {
      context.handle(
          _storedActionIdMeta,
          storedActionId.isAcceptableOrUnknown(
              data['stored_action_id']!, _storedActionIdMeta));
    } else if (isInserting) {
      context.missing(_storedActionIdMeta);
    }
    if (data.containsKey('keys')) {
      context.handle(
          _keysMeta, keys.isAcceptableOrUnknown(data['keys']!, _keysMeta));
    } else if (isInserting) {
      context.missing(_keysMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RequestData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RequestData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      tag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag'])!,
      self: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}self'])!,
      vaultId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vault_id'])!,
      storedActionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}stored_action_id'])!,
      keys: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}keys'])!,
    );
  }

  @override
  $RequestTable createAlias(String alias) {
    return $RequestTable(attachedDatabase, alias);
  }
}

class RequestData extends DataClass implements Insertable<RequestData> {
  final String id;
  final String name;
  final String tag;
  final bool self;
  final String vaultId;
  final String storedActionId;
  final String keys;
  const RequestData(
      {required this.id,
      required this.name,
      required this.tag,
      required this.self,
      required this.vaultId,
      required this.storedActionId,
      required this.keys});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['tag'] = Variable<String>(tag);
    map['self'] = Variable<bool>(self);
    map['vault_id'] = Variable<String>(vaultId);
    map['stored_action_id'] = Variable<String>(storedActionId);
    map['keys'] = Variable<String>(keys);
    return map;
  }

  RequestCompanion toCompanion(bool nullToAbsent) {
    return RequestCompanion(
      id: Value(id),
      name: Value(name),
      tag: Value(tag),
      self: Value(self),
      vaultId: Value(vaultId),
      storedActionId: Value(storedActionId),
      keys: Value(keys),
    );
  }

  factory RequestData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RequestData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      tag: serializer.fromJson<String>(json['tag']),
      self: serializer.fromJson<bool>(json['self']),
      vaultId: serializer.fromJson<String>(json['vaultId']),
      storedActionId: serializer.fromJson<String>(json['storedActionId']),
      keys: serializer.fromJson<String>(json['keys']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'tag': serializer.toJson<String>(tag),
      'self': serializer.toJson<bool>(self),
      'vaultId': serializer.toJson<String>(vaultId),
      'storedActionId': serializer.toJson<String>(storedActionId),
      'keys': serializer.toJson<String>(keys),
    };
  }

  RequestData copyWith(
          {String? id,
          String? name,
          String? tag,
          bool? self,
          String? vaultId,
          String? storedActionId,
          String? keys}) =>
      RequestData(
        id: id ?? this.id,
        name: name ?? this.name,
        tag: tag ?? this.tag,
        self: self ?? this.self,
        vaultId: vaultId ?? this.vaultId,
        storedActionId: storedActionId ?? this.storedActionId,
        keys: keys ?? this.keys,
      );
  @override
  String toString() {
    return (StringBuffer('RequestData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tag: $tag, ')
          ..write('self: $self, ')
          ..write('vaultId: $vaultId, ')
          ..write('storedActionId: $storedActionId, ')
          ..write('keys: $keys')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, tag, self, vaultId, storedActionId, keys);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RequestData &&
          other.id == this.id &&
          other.name == this.name &&
          other.tag == this.tag &&
          other.self == this.self &&
          other.vaultId == this.vaultId &&
          other.storedActionId == this.storedActionId &&
          other.keys == this.keys);
}

class RequestCompanion extends UpdateCompanion<RequestData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> tag;
  final Value<bool> self;
  final Value<String> vaultId;
  final Value<String> storedActionId;
  final Value<String> keys;
  final Value<int> rowid;
  const RequestCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.tag = const Value.absent(),
    this.self = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.storedActionId = const Value.absent(),
    this.keys = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RequestCompanion.insert({
    required String id,
    required String name,
    required String tag,
    required bool self,
    required String vaultId,
    required String storedActionId,
    required String keys,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        tag = Value(tag),
        self = Value(self),
        vaultId = Value(vaultId),
        storedActionId = Value(storedActionId),
        keys = Value(keys);
  static Insertable<RequestData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? tag,
    Expression<bool>? self,
    Expression<String>? vaultId,
    Expression<String>? storedActionId,
    Expression<String>? keys,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (tag != null) 'tag': tag,
      if (self != null) 'self': self,
      if (vaultId != null) 'vault_id': vaultId,
      if (storedActionId != null) 'stored_action_id': storedActionId,
      if (keys != null) 'keys': keys,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RequestCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? tag,
      Value<bool>? self,
      Value<String>? vaultId,
      Value<String>? storedActionId,
      Value<String>? keys,
      Value<int>? rowid}) {
    return RequestCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      self: self ?? this.self,
      vaultId: vaultId ?? this.vaultId,
      storedActionId: storedActionId ?? this.storedActionId,
      keys: keys ?? this.keys,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (self.present) {
      map['self'] = Variable<bool>(self.value);
    }
    if (vaultId.present) {
      map['vault_id'] = Variable<String>(vaultId.value);
    }
    if (storedActionId.present) {
      map['stored_action_id'] = Variable<String>(storedActionId.value);
    }
    if (keys.present) {
      map['keys'] = Variable<String>(keys.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RequestCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tag: $tag, ')
          ..write('self: $self, ')
          ..write('vaultId: $vaultId, ')
          ..write('storedActionId: $storedActionId, ')
          ..write('keys: $keys, ')
          ..write('rowid: $rowid')
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
  late final $RequestTable request = $RequestTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [conversation, member, message, setting, friend, request];
}
