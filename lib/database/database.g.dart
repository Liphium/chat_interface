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
  static const VerificationMeta _vaultIdMeta =
      const VerificationMeta('vaultId');
  @override
  late final GeneratedColumn<String> vaultId = GeneratedColumn<String>(
      'vault_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<ConversationType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<ConversationType>($ConversationTable.$convertertype);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
      'token', aliasedName, false,
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
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<BigInt> readAt = GeneratedColumn<BigInt>(
      'read_at', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, vaultId, type, data, token, key, updatedAt, readAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversation';
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
    if (data.containsKey('vault_id')) {
      context.handle(_vaultIdMeta,
          vaultId.isAcceptableOrUnknown(data['vault_id']!, _vaultIdMeta));
    } else if (isInserting) {
      context.missing(_vaultIdMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
          _tokenMeta, token.isAcceptableOrUnknown(data['token']!, _tokenMeta));
    } else if (isInserting) {
      context.missing(_tokenMeta);
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
    if (data.containsKey('read_at')) {
      context.handle(_readAtMeta,
          readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta));
    } else if (isInserting) {
      context.missing(_readAtMeta);
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
      vaultId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vault_id'])!,
      type: $ConversationTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      token: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}updated_at'])!,
      readAt: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}read_at'])!,
    );
  }

  @override
  $ConversationTable createAlias(String alias) {
    return $ConversationTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ConversationType, int, int> $convertertype =
      const EnumIndexConverter<ConversationType>(ConversationType.values);
}

class ConversationData extends DataClass
    implements Insertable<ConversationData> {
  final String id;
  final String vaultId;
  final ConversationType type;
  final String data;
  final String token;
  final String key;
  final BigInt updatedAt;
  final BigInt readAt;
  const ConversationData(
      {required this.id,
      required this.vaultId,
      required this.type,
      required this.data,
      required this.token,
      required this.key,
      required this.updatedAt,
      required this.readAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vault_id'] = Variable<String>(vaultId);
    {
      map['type'] =
          Variable<int>($ConversationTable.$convertertype.toSql(type));
    }
    map['data'] = Variable<String>(data);
    map['token'] = Variable<String>(token);
    map['key'] = Variable<String>(key);
    map['updated_at'] = Variable<BigInt>(updatedAt);
    map['read_at'] = Variable<BigInt>(readAt);
    return map;
  }

  ConversationCompanion toCompanion(bool nullToAbsent) {
    return ConversationCompanion(
      id: Value(id),
      vaultId: Value(vaultId),
      type: Value(type),
      data: Value(data),
      token: Value(token),
      key: Value(key),
      updatedAt: Value(updatedAt),
      readAt: Value(readAt),
    );
  }

  factory ConversationData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationData(
      id: serializer.fromJson<String>(json['id']),
      vaultId: serializer.fromJson<String>(json['vaultId']),
      type: $ConversationTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      data: serializer.fromJson<String>(json['data']),
      token: serializer.fromJson<String>(json['token']),
      key: serializer.fromJson<String>(json['key']),
      updatedAt: serializer.fromJson<BigInt>(json['updatedAt']),
      readAt: serializer.fromJson<BigInt>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vaultId': serializer.toJson<String>(vaultId),
      'type': serializer
          .toJson<int>($ConversationTable.$convertertype.toJson(type)),
      'data': serializer.toJson<String>(data),
      'token': serializer.toJson<String>(token),
      'key': serializer.toJson<String>(key),
      'updatedAt': serializer.toJson<BigInt>(updatedAt),
      'readAt': serializer.toJson<BigInt>(readAt),
    };
  }

  ConversationData copyWith(
          {String? id,
          String? vaultId,
          ConversationType? type,
          String? data,
          String? token,
          String? key,
          BigInt? updatedAt,
          BigInt? readAt}) =>
      ConversationData(
        id: id ?? this.id,
        vaultId: vaultId ?? this.vaultId,
        type: type ?? this.type,
        data: data ?? this.data,
        token: token ?? this.token,
        key: key ?? this.key,
        updatedAt: updatedAt ?? this.updatedAt,
        readAt: readAt ?? this.readAt,
      );
  @override
  String toString() {
    return (StringBuffer('ConversationData(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('type: $type, ')
          ..write('data: $data, ')
          ..write('token: $token, ')
          ..write('key: $key, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, vaultId, type, data, token, key, updatedAt, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationData &&
          other.id == this.id &&
          other.vaultId == this.vaultId &&
          other.type == this.type &&
          other.data == this.data &&
          other.token == this.token &&
          other.key == this.key &&
          other.updatedAt == this.updatedAt &&
          other.readAt == this.readAt);
}

class ConversationCompanion extends UpdateCompanion<ConversationData> {
  final Value<String> id;
  final Value<String> vaultId;
  final Value<ConversationType> type;
  final Value<String> data;
  final Value<String> token;
  final Value<String> key;
  final Value<BigInt> updatedAt;
  final Value<BigInt> readAt;
  final Value<int> rowid;
  const ConversationCompanion({
    this.id = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.type = const Value.absent(),
    this.data = const Value.absent(),
    this.token = const Value.absent(),
    this.key = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationCompanion.insert({
    required String id,
    required String vaultId,
    required ConversationType type,
    required String data,
    required String token,
    required String key,
    required BigInt updatedAt,
    required BigInt readAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        vaultId = Value(vaultId),
        type = Value(type),
        data = Value(data),
        token = Value(token),
        key = Value(key),
        updatedAt = Value(updatedAt),
        readAt = Value(readAt);
  static Insertable<ConversationData> custom({
    Expression<String>? id,
    Expression<String>? vaultId,
    Expression<int>? type,
    Expression<String>? data,
    Expression<String>? token,
    Expression<String>? key,
    Expression<BigInt>? updatedAt,
    Expression<BigInt>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vaultId != null) 'vault_id': vaultId,
      if (type != null) 'type': type,
      if (data != null) 'data': data,
      if (token != null) 'token': token,
      if (key != null) 'key': key,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationCompanion copyWith(
      {Value<String>? id,
      Value<String>? vaultId,
      Value<ConversationType>? type,
      Value<String>? data,
      Value<String>? token,
      Value<String>? key,
      Value<BigInt>? updatedAt,
      Value<BigInt>? readAt,
      Value<int>? rowid}) {
    return ConversationCompanion(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      type: type ?? this.type,
      data: data ?? this.data,
      token: token ?? this.token,
      key: key ?? this.key,
      updatedAt: updatedAt ?? this.updatedAt,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vaultId.present) {
      map['vault_id'] = Variable<String>(vaultId.value);
    }
    if (type.present) {
      map['type'] =
          Variable<int>($ConversationTable.$convertertype.toSql(type.value));
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<BigInt>(updatedAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<BigInt>(readAt.value);
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
          ..write('vaultId: $vaultId, ')
          ..write('type: $type, ')
          ..write('data: $data, ')
          ..write('token: $token, ')
          ..write('key: $key, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('readAt: $readAt, ')
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
  List<GeneratedColumn> get $columns => [id, conversationId, accountId, roleId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'member';
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
  final String? conversationId;
  final String accountId;
  final int roleId;
  const MemberData(
      {required this.id,
      this.conversationId,
      required this.accountId,
      required this.roleId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
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
      'conversationId': serializer.toJson<String?>(conversationId),
      'accountId': serializer.toJson<String>(accountId),
      'roleId': serializer.toJson<int>(roleId),
    };
  }

  MemberData copyWith(
          {String? id,
          Value<String?> conversationId = const Value.absent(),
          String? accountId,
          int? roleId}) =>
      MemberData(
        id: id ?? this.id,
        conversationId:
            conversationId.present ? conversationId.value : this.conversationId,
        accountId: accountId ?? this.accountId,
        roleId: roleId ?? this.roleId,
      );
  @override
  String toString() {
    return (StringBuffer('MemberData(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('accountId: $accountId, ')
          ..write('roleId: $roleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, conversationId, accountId, roleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemberData &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.accountId == this.accountId &&
          other.roleId == this.roleId);
}

class MemberCompanion extends UpdateCompanion<MemberData> {
  final Value<String> id;
  final Value<String?> conversationId;
  final Value<String> accountId;
  final Value<int> roleId;
  final Value<int> rowid;
  const MemberCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.roleId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemberCompanion.insert({
    required String id,
    this.conversationId = const Value.absent(),
    required String accountId,
    required int roleId,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        accountId = Value(accountId),
        roleId = Value(roleId);
  static Insertable<MemberData> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? accountId,
    Expression<int>? roleId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (accountId != null) 'account_id': accountId,
      if (roleId != null) 'role_id': roleId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemberCompanion copyWith(
      {Value<String>? id,
      Value<String?>? conversationId,
      Value<String>? accountId,
      Value<int>? roleId,
      Value<int>? rowid}) {
    return MemberCompanion(
      id: id ?? this.id,
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
  static const VerificationMeta _systemMeta = const VerificationMeta('system');
  @override
  late final GeneratedColumn<bool> system = GeneratedColumn<bool>(
      'system', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("system" IN (0, 1))'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _signatureMeta =
      const VerificationMeta('signature');
  @override
  late final GeneratedColumn<String> signature = GeneratedColumn<String>(
      'signature', aliasedName, false,
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
      'sender', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderAccountMeta =
      const VerificationMeta('senderAccount');
  @override
  late final GeneratedColumn<String> senderAccount = GeneratedColumn<String>(
      'sender_account', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _answerMeta = const VerificationMeta('answer');
  @override
  late final GeneratedColumn<String> answer = GeneratedColumn<String>(
      'answer', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<BigInt> createdAt = GeneratedColumn<BigInt>(
      'created_at', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: true);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
        system,
        type,
        content,
        signature,
        attachments,
        certificate,
        sender,
        senderAccount,
        answer,
        createdAt,
        conversationId,
        edited
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message';
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
    if (data.containsKey('system')) {
      context.handle(_systemMeta,
          system.isAcceptableOrUnknown(data['system']!, _systemMeta));
    } else if (isInserting) {
      context.missing(_systemMeta);
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
    if (data.containsKey('signature')) {
      context.handle(_signatureMeta,
          signature.isAcceptableOrUnknown(data['signature']!, _signatureMeta));
    } else if (isInserting) {
      context.missing(_signatureMeta);
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
    } else if (isInserting) {
      context.missing(_senderMeta);
    }
    if (data.containsKey('sender_account')) {
      context.handle(
          _senderAccountMeta,
          senderAccount.isAcceptableOrUnknown(
              data['sender_account']!, _senderAccountMeta));
    } else if (isInserting) {
      context.missing(_senderAccountMeta);
    }
    if (data.containsKey('answer')) {
      context.handle(_answerMeta,
          answer.isAcceptableOrUnknown(data['answer']!, _answerMeta));
    } else if (isInserting) {
      context.missing(_answerMeta);
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
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
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
      system: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}system'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      signature: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}signature'])!,
      attachments: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attachments'])!,
      certificate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}certificate'])!,
      sender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender'])!,
      senderAccount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_account'])!,
      answer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}answer'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}created_at'])!,
      conversationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conversation_id'])!,
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
  final bool system;
  final int type;
  final String content;
  final String signature;
  final String attachments;
  final String certificate;
  final String sender;
  final String senderAccount;
  final String answer;
  final BigInt createdAt;
  final String conversationId;
  final bool edited;
  const MessageData(
      {required this.id,
      required this.verified,
      required this.system,
      required this.type,
      required this.content,
      required this.signature,
      required this.attachments,
      required this.certificate,
      required this.sender,
      required this.senderAccount,
      required this.answer,
      required this.createdAt,
      required this.conversationId,
      required this.edited});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['verified'] = Variable<bool>(verified);
    map['system'] = Variable<bool>(system);
    map['type'] = Variable<int>(type);
    map['content'] = Variable<String>(content);
    map['signature'] = Variable<String>(signature);
    map['attachments'] = Variable<String>(attachments);
    map['certificate'] = Variable<String>(certificate);
    map['sender'] = Variable<String>(sender);
    map['sender_account'] = Variable<String>(senderAccount);
    map['answer'] = Variable<String>(answer);
    map['created_at'] = Variable<BigInt>(createdAt);
    map['conversation_id'] = Variable<String>(conversationId);
    map['edited'] = Variable<bool>(edited);
    return map;
  }

  MessageCompanion toCompanion(bool nullToAbsent) {
    return MessageCompanion(
      id: Value(id),
      verified: Value(verified),
      system: Value(system),
      type: Value(type),
      content: Value(content),
      signature: Value(signature),
      attachments: Value(attachments),
      certificate: Value(certificate),
      sender: Value(sender),
      senderAccount: Value(senderAccount),
      answer: Value(answer),
      createdAt: Value(createdAt),
      conversationId: Value(conversationId),
      edited: Value(edited),
    );
  }

  factory MessageData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageData(
      id: serializer.fromJson<String>(json['id']),
      verified: serializer.fromJson<bool>(json['verified']),
      system: serializer.fromJson<bool>(json['system']),
      type: serializer.fromJson<int>(json['type']),
      content: serializer.fromJson<String>(json['content']),
      signature: serializer.fromJson<String>(json['signature']),
      attachments: serializer.fromJson<String>(json['attachments']),
      certificate: serializer.fromJson<String>(json['certificate']),
      sender: serializer.fromJson<String>(json['sender']),
      senderAccount: serializer.fromJson<String>(json['senderAccount']),
      answer: serializer.fromJson<String>(json['answer']),
      createdAt: serializer.fromJson<BigInt>(json['createdAt']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      edited: serializer.fromJson<bool>(json['edited']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'verified': serializer.toJson<bool>(verified),
      'system': serializer.toJson<bool>(system),
      'type': serializer.toJson<int>(type),
      'content': serializer.toJson<String>(content),
      'signature': serializer.toJson<String>(signature),
      'attachments': serializer.toJson<String>(attachments),
      'certificate': serializer.toJson<String>(certificate),
      'sender': serializer.toJson<String>(sender),
      'senderAccount': serializer.toJson<String>(senderAccount),
      'answer': serializer.toJson<String>(answer),
      'createdAt': serializer.toJson<BigInt>(createdAt),
      'conversationId': serializer.toJson<String>(conversationId),
      'edited': serializer.toJson<bool>(edited),
    };
  }

  MessageData copyWith(
          {String? id,
          bool? verified,
          bool? system,
          int? type,
          String? content,
          String? signature,
          String? attachments,
          String? certificate,
          String? sender,
          String? senderAccount,
          String? answer,
          BigInt? createdAt,
          String? conversationId,
          bool? edited}) =>
      MessageData(
        id: id ?? this.id,
        verified: verified ?? this.verified,
        system: system ?? this.system,
        type: type ?? this.type,
        content: content ?? this.content,
        signature: signature ?? this.signature,
        attachments: attachments ?? this.attachments,
        certificate: certificate ?? this.certificate,
        sender: sender ?? this.sender,
        senderAccount: senderAccount ?? this.senderAccount,
        answer: answer ?? this.answer,
        createdAt: createdAt ?? this.createdAt,
        conversationId: conversationId ?? this.conversationId,
        edited: edited ?? this.edited,
      );
  @override
  String toString() {
    return (StringBuffer('MessageData(')
          ..write('id: $id, ')
          ..write('verified: $verified, ')
          ..write('system: $system, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('signature: $signature, ')
          ..write('attachments: $attachments, ')
          ..write('certificate: $certificate, ')
          ..write('sender: $sender, ')
          ..write('senderAccount: $senderAccount, ')
          ..write('answer: $answer, ')
          ..write('createdAt: $createdAt, ')
          ..write('conversationId: $conversationId, ')
          ..write('edited: $edited')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      verified,
      system,
      type,
      content,
      signature,
      attachments,
      certificate,
      sender,
      senderAccount,
      answer,
      createdAt,
      conversationId,
      edited);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageData &&
          other.id == this.id &&
          other.verified == this.verified &&
          other.system == this.system &&
          other.type == this.type &&
          other.content == this.content &&
          other.signature == this.signature &&
          other.attachments == this.attachments &&
          other.certificate == this.certificate &&
          other.sender == this.sender &&
          other.senderAccount == this.senderAccount &&
          other.answer == this.answer &&
          other.createdAt == this.createdAt &&
          other.conversationId == this.conversationId &&
          other.edited == this.edited);
}

class MessageCompanion extends UpdateCompanion<MessageData> {
  final Value<String> id;
  final Value<bool> verified;
  final Value<bool> system;
  final Value<int> type;
  final Value<String> content;
  final Value<String> signature;
  final Value<String> attachments;
  final Value<String> certificate;
  final Value<String> sender;
  final Value<String> senderAccount;
  final Value<String> answer;
  final Value<BigInt> createdAt;
  final Value<String> conversationId;
  final Value<bool> edited;
  final Value<int> rowid;
  const MessageCompanion({
    this.id = const Value.absent(),
    this.verified = const Value.absent(),
    this.system = const Value.absent(),
    this.type = const Value.absent(),
    this.content = const Value.absent(),
    this.signature = const Value.absent(),
    this.attachments = const Value.absent(),
    this.certificate = const Value.absent(),
    this.sender = const Value.absent(),
    this.senderAccount = const Value.absent(),
    this.answer = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.edited = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageCompanion.insert({
    required String id,
    required bool verified,
    required bool system,
    required int type,
    required String content,
    required String signature,
    required String attachments,
    required String certificate,
    required String sender,
    required String senderAccount,
    required String answer,
    required BigInt createdAt,
    required String conversationId,
    required bool edited,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        verified = Value(verified),
        system = Value(system),
        type = Value(type),
        content = Value(content),
        signature = Value(signature),
        attachments = Value(attachments),
        certificate = Value(certificate),
        sender = Value(sender),
        senderAccount = Value(senderAccount),
        answer = Value(answer),
        createdAt = Value(createdAt),
        conversationId = Value(conversationId),
        edited = Value(edited);
  static Insertable<MessageData> custom({
    Expression<String>? id,
    Expression<bool>? verified,
    Expression<bool>? system,
    Expression<int>? type,
    Expression<String>? content,
    Expression<String>? signature,
    Expression<String>? attachments,
    Expression<String>? certificate,
    Expression<String>? sender,
    Expression<String>? senderAccount,
    Expression<String>? answer,
    Expression<BigInt>? createdAt,
    Expression<String>? conversationId,
    Expression<bool>? edited,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (verified != null) 'verified': verified,
      if (system != null) 'system': system,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (signature != null) 'signature': signature,
      if (attachments != null) 'attachments': attachments,
      if (certificate != null) 'certificate': certificate,
      if (sender != null) 'sender': sender,
      if (senderAccount != null) 'sender_account': senderAccount,
      if (answer != null) 'answer': answer,
      if (createdAt != null) 'created_at': createdAt,
      if (conversationId != null) 'conversation_id': conversationId,
      if (edited != null) 'edited': edited,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageCompanion copyWith(
      {Value<String>? id,
      Value<bool>? verified,
      Value<bool>? system,
      Value<int>? type,
      Value<String>? content,
      Value<String>? signature,
      Value<String>? attachments,
      Value<String>? certificate,
      Value<String>? sender,
      Value<String>? senderAccount,
      Value<String>? answer,
      Value<BigInt>? createdAt,
      Value<String>? conversationId,
      Value<bool>? edited,
      Value<int>? rowid}) {
    return MessageCompanion(
      id: id ?? this.id,
      verified: verified ?? this.verified,
      system: system ?? this.system,
      type: type ?? this.type,
      content: content ?? this.content,
      signature: signature ?? this.signature,
      attachments: attachments ?? this.attachments,
      certificate: certificate ?? this.certificate,
      sender: sender ?? this.sender,
      senderAccount: senderAccount ?? this.senderAccount,
      answer: answer ?? this.answer,
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
    if (system.present) {
      map['system'] = Variable<bool>(system.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (signature.present) {
      map['signature'] = Variable<String>(signature.value);
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
    if (senderAccount.present) {
      map['sender_account'] = Variable<String>(senderAccount.value);
    }
    if (answer.present) {
      map['answer'] = Variable<String>(answer.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<BigInt>(createdAt.value);
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
          ..write('system: $system, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('signature: $signature, ')
          ..write('attachments: $attachments, ')
          ..write('certificate: $certificate, ')
          ..write('sender: $sender, ')
          ..write('senderAccount: $senderAccount, ')
          ..write('answer: $answer, ')
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
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting';
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
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<BigInt> updatedAt = GeneratedColumn<BigInt>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, tag, vaultId, keys, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'friend';
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
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}updated_at'])!,
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
  final BigInt updatedAt;
  const FriendData(
      {required this.id,
      required this.name,
      required this.tag,
      required this.vaultId,
      required this.keys,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['tag'] = Variable<String>(tag);
    map['vault_id'] = Variable<String>(vaultId);
    map['keys'] = Variable<String>(keys);
    map['updated_at'] = Variable<BigInt>(updatedAt);
    return map;
  }

  FriendCompanion toCompanion(bool nullToAbsent) {
    return FriendCompanion(
      id: Value(id),
      name: Value(name),
      tag: Value(tag),
      vaultId: Value(vaultId),
      keys: Value(keys),
      updatedAt: Value(updatedAt),
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
      updatedAt: serializer.fromJson<BigInt>(json['updatedAt']),
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
      'updatedAt': serializer.toJson<BigInt>(updatedAt),
    };
  }

  FriendData copyWith(
          {String? id,
          String? name,
          String? tag,
          String? vaultId,
          String? keys,
          BigInt? updatedAt}) =>
      FriendData(
        id: id ?? this.id,
        name: name ?? this.name,
        tag: tag ?? this.tag,
        vaultId: vaultId ?? this.vaultId,
        keys: keys ?? this.keys,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  @override
  String toString() {
    return (StringBuffer('FriendData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tag: $tag, ')
          ..write('vaultId: $vaultId, ')
          ..write('keys: $keys, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, tag, vaultId, keys, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FriendData &&
          other.id == this.id &&
          other.name == this.name &&
          other.tag == this.tag &&
          other.vaultId == this.vaultId &&
          other.keys == this.keys &&
          other.updatedAt == this.updatedAt);
}

class FriendCompanion extends UpdateCompanion<FriendData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> tag;
  final Value<String> vaultId;
  final Value<String> keys;
  final Value<BigInt> updatedAt;
  final Value<int> rowid;
  const FriendCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.tag = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.keys = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FriendCompanion.insert({
    required String id,
    required String name,
    required String tag,
    required String vaultId,
    required String keys,
    required BigInt updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        tag = Value(tag),
        vaultId = Value(vaultId),
        keys = Value(keys),
        updatedAt = Value(updatedAt);
  static Insertable<FriendData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? tag,
    Expression<String>? vaultId,
    Expression<String>? keys,
    Expression<BigInt>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (tag != null) 'tag': tag,
      if (vaultId != null) 'vault_id': vaultId,
      if (keys != null) 'keys': keys,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FriendCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? tag,
      Value<String>? vaultId,
      Value<String>? keys,
      Value<BigInt>? updatedAt,
      Value<int>? rowid}) {
    return FriendCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      vaultId: vaultId ?? this.vaultId,
      keys: keys ?? this.keys,
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
    return (StringBuffer('FriendCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tag: $tag, ')
          ..write('vaultId: $vaultId, ')
          ..write('keys: $keys, ')
          ..write('updatedAt: $updatedAt, ')
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
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<BigInt> updatedAt = GeneratedColumn<BigInt>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, tag, self, vaultId, storedActionId, keys, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'request';
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
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}updated_at'])!,
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
  final BigInt updatedAt;
  const RequestData(
      {required this.id,
      required this.name,
      required this.tag,
      required this.self,
      required this.vaultId,
      required this.storedActionId,
      required this.keys,
      required this.updatedAt});
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
    map['updated_at'] = Variable<BigInt>(updatedAt);
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
      updatedAt: Value(updatedAt),
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
      updatedAt: serializer.fromJson<BigInt>(json['updatedAt']),
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
      'updatedAt': serializer.toJson<BigInt>(updatedAt),
    };
  }

  RequestData copyWith(
          {String? id,
          String? name,
          String? tag,
          bool? self,
          String? vaultId,
          String? storedActionId,
          String? keys,
          BigInt? updatedAt}) =>
      RequestData(
        id: id ?? this.id,
        name: name ?? this.name,
        tag: tag ?? this.tag,
        self: self ?? this.self,
        vaultId: vaultId ?? this.vaultId,
        storedActionId: storedActionId ?? this.storedActionId,
        keys: keys ?? this.keys,
        updatedAt: updatedAt ?? this.updatedAt,
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
          ..write('keys: $keys, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, tag, self, vaultId, storedActionId, keys, updatedAt);
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
          other.keys == this.keys &&
          other.updatedAt == this.updatedAt);
}

class RequestCompanion extends UpdateCompanion<RequestData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> tag;
  final Value<bool> self;
  final Value<String> vaultId;
  final Value<String> storedActionId;
  final Value<String> keys;
  final Value<BigInt> updatedAt;
  final Value<int> rowid;
  const RequestCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.tag = const Value.absent(),
    this.self = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.storedActionId = const Value.absent(),
    this.keys = const Value.absent(),
    this.updatedAt = const Value.absent(),
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
    required BigInt updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        tag = Value(tag),
        self = Value(self),
        vaultId = Value(vaultId),
        storedActionId = Value(storedActionId),
        keys = Value(keys),
        updatedAt = Value(updatedAt);
  static Insertable<RequestData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? tag,
    Expression<bool>? self,
    Expression<String>? vaultId,
    Expression<String>? storedActionId,
    Expression<String>? keys,
    Expression<BigInt>? updatedAt,
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
      if (updatedAt != null) 'updated_at': updatedAt,
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
      Value<BigInt>? updatedAt,
      Value<int>? rowid}) {
    return RequestCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      self: self ?? this.self,
      vaultId: vaultId ?? this.vaultId,
      storedActionId: storedActionId ?? this.storedActionId,
      keys: keys ?? this.keys,
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
    return (StringBuffer('RequestCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tag: $tag, ')
          ..write('self: $self, ')
          ..write('vaultId: $vaultId, ')
          ..write('storedActionId: $storedActionId, ')
          ..write('keys: $keys, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnknownProfileTable extends UnknownProfile
    with TableInfo<$UnknownProfileTable, UnknownProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnknownProfileTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _keysMeta = const VerificationMeta('keys');
  @override
  late final GeneratedColumn<String> keys = GeneratedColumn<String>(
      'keys', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, tag, keys];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unknown_profile';
  @override
  VerificationContext validateIntegrity(Insertable<UnknownProfileData> instance,
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
  UnknownProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnknownProfileData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      tag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag'])!,
      keys: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}keys'])!,
    );
  }

  @override
  $UnknownProfileTable createAlias(String alias) {
    return $UnknownProfileTable(attachedDatabase, alias);
  }
}

class UnknownProfileData extends DataClass
    implements Insertable<UnknownProfileData> {
  final String id;
  final String name;
  final String tag;
  final String keys;
  const UnknownProfileData(
      {required this.id,
      required this.name,
      required this.tag,
      required this.keys});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['tag'] = Variable<String>(tag);
    map['keys'] = Variable<String>(keys);
    return map;
  }

  UnknownProfileCompanion toCompanion(bool nullToAbsent) {
    return UnknownProfileCompanion(
      id: Value(id),
      name: Value(name),
      tag: Value(tag),
      keys: Value(keys),
    );
  }

  factory UnknownProfileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnknownProfileData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      tag: serializer.fromJson<String>(json['tag']),
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
      'keys': serializer.toJson<String>(keys),
    };
  }

  UnknownProfileData copyWith(
          {String? id, String? name, String? tag, String? keys}) =>
      UnknownProfileData(
        id: id ?? this.id,
        name: name ?? this.name,
        tag: tag ?? this.tag,
        keys: keys ?? this.keys,
      );
  @override
  String toString() {
    return (StringBuffer('UnknownProfileData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tag: $tag, ')
          ..write('keys: $keys')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, tag, keys);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnknownProfileData &&
          other.id == this.id &&
          other.name == this.name &&
          other.tag == this.tag &&
          other.keys == this.keys);
}

class UnknownProfileCompanion extends UpdateCompanion<UnknownProfileData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> tag;
  final Value<String> keys;
  final Value<int> rowid;
  const UnknownProfileCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.tag = const Value.absent(),
    this.keys = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnknownProfileCompanion.insert({
    required String id,
    required String name,
    required String tag,
    required String keys,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        tag = Value(tag),
        keys = Value(keys);
  static Insertable<UnknownProfileData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? tag,
    Expression<String>? keys,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (tag != null) 'tag': tag,
      if (keys != null) 'keys': keys,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnknownProfileCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? tag,
      Value<String>? keys,
      Value<int>? rowid}) {
    return UnknownProfileCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
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
    return (StringBuffer('UnknownProfileCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tag: $tag, ')
          ..write('keys: $keys, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileTable extends Profile with TableInfo<$ProfileTable, ProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pictureContainerMeta =
      const VerificationMeta('pictureContainer');
  @override
  late final GeneratedColumn<String> pictureContainer = GeneratedColumn<String>(
      'picture_container', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, pictureContainer, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile';
  @override
  VerificationContext validateIntegrity(Insertable<ProfileData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('picture_container')) {
      context.handle(
          _pictureContainerMeta,
          pictureContainer.isAcceptableOrUnknown(
              data['picture_container']!, _pictureContainerMeta));
    } else if (isInserting) {
      context.missing(_pictureContainerMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      pictureContainer: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}picture_container'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
    );
  }

  @override
  $ProfileTable createAlias(String alias) {
    return $ProfileTable(attachedDatabase, alias);
  }
}

class ProfileData extends DataClass implements Insertable<ProfileData> {
  final String id;
  final String pictureContainer;
  final String data;
  const ProfileData(
      {required this.id, required this.pictureContainer, required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['picture_container'] = Variable<String>(pictureContainer);
    map['data'] = Variable<String>(data);
    return map;
  }

  ProfileCompanion toCompanion(bool nullToAbsent) {
    return ProfileCompanion(
      id: Value(id),
      pictureContainer: Value(pictureContainer),
      data: Value(data),
    );
  }

  factory ProfileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileData(
      id: serializer.fromJson<String>(json['id']),
      pictureContainer: serializer.fromJson<String>(json['pictureContainer']),
      data: serializer.fromJson<String>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pictureContainer': serializer.toJson<String>(pictureContainer),
      'data': serializer.toJson<String>(data),
    };
  }

  ProfileData copyWith({String? id, String? pictureContainer, String? data}) =>
      ProfileData(
        id: id ?? this.id,
        pictureContainer: pictureContainer ?? this.pictureContainer,
        data: data ?? this.data,
      );
  @override
  String toString() {
    return (StringBuffer('ProfileData(')
          ..write('id: $id, ')
          ..write('pictureContainer: $pictureContainer, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pictureContainer, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileData &&
          other.id == this.id &&
          other.pictureContainer == this.pictureContainer &&
          other.data == this.data);
}

class ProfileCompanion extends UpdateCompanion<ProfileData> {
  final Value<String> id;
  final Value<String> pictureContainer;
  final Value<String> data;
  final Value<int> rowid;
  const ProfileCompanion({
    this.id = const Value.absent(),
    this.pictureContainer = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileCompanion.insert({
    required String id,
    required String pictureContainer,
    required String data,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        pictureContainer = Value(pictureContainer),
        data = Value(data);
  static Insertable<ProfileData> custom({
    Expression<String>? id,
    Expression<String>? pictureContainer,
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pictureContainer != null) 'picture_container': pictureContainer,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileCompanion copyWith(
      {Value<String>? id,
      Value<String>? pictureContainer,
      Value<String>? data,
      Value<int>? rowid}) {
    return ProfileCompanion(
      id: id ?? this.id,
      pictureContainer: pictureContainer ?? this.pictureContainer,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pictureContainer.present) {
      map['picture_container'] = Variable<String>(pictureContainer.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileCompanion(')
          ..write('id: $id, ')
          ..write('pictureContainer: $pictureContainer, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrustedLinkTable extends TrustedLink
    with TableInfo<$TrustedLinkTable, TrustedLinkData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrustedLinkTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
      'domain', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [domain];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trusted_link';
  @override
  VerificationContext validateIntegrity(Insertable<TrustedLinkData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('domain')) {
      context.handle(_domainMeta,
          domain.isAcceptableOrUnknown(data['domain']!, _domainMeta));
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {domain};
  @override
  TrustedLinkData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrustedLinkData(
      domain: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}domain'])!,
    );
  }

  @override
  $TrustedLinkTable createAlias(String alias) {
    return $TrustedLinkTable(attachedDatabase, alias);
  }
}

class TrustedLinkData extends DataClass implements Insertable<TrustedLinkData> {
  final String domain;
  const TrustedLinkData({required this.domain});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['domain'] = Variable<String>(domain);
    return map;
  }

  TrustedLinkCompanion toCompanion(bool nullToAbsent) {
    return TrustedLinkCompanion(
      domain: Value(domain),
    );
  }

  factory TrustedLinkData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrustedLinkData(
      domain: serializer.fromJson<String>(json['domain']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'domain': serializer.toJson<String>(domain),
    };
  }

  TrustedLinkData copyWith({String? domain}) => TrustedLinkData(
        domain: domain ?? this.domain,
      );
  @override
  String toString() {
    return (StringBuffer('TrustedLinkData(')
          ..write('domain: $domain')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => domain.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrustedLinkData && other.domain == this.domain);
}

class TrustedLinkCompanion extends UpdateCompanion<TrustedLinkData> {
  final Value<String> domain;
  final Value<int> rowid;
  const TrustedLinkCompanion({
    this.domain = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrustedLinkCompanion.insert({
    required String domain,
    this.rowid = const Value.absent(),
  }) : domain = Value(domain);
  static Insertable<TrustedLinkData> custom({
    Expression<String>? domain,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (domain != null) 'domain': domain,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrustedLinkCompanion copyWith({Value<String>? domain, Value<int>? rowid}) {
    return TrustedLinkCompanion(
      domain: domain ?? this.domain,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrustedLinkCompanion(')
          ..write('domain: $domain, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibraryEntryTable extends LibraryEntry
    with TableInfo<$LibraryEntryTable, LibraryEntryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryEntryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<LibraryEntryType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<LibraryEntryType>($LibraryEntryTable.$convertertype);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<BigInt> createdAt = GeneratedColumn<BigInt>(
      'created_at', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
      'width', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
      'height', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [type, createdAt, data, width, height];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_entry';
  @override
  VerificationContext validateIntegrity(Insertable<LibraryEntryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
          _widthMeta, width.isAcceptableOrUnknown(data['width']!, _widthMeta));
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  LibraryEntryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryEntryData(
      type: $LibraryEntryTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}created_at'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      width: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}width'])!,
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height'])!,
    );
  }

  @override
  $LibraryEntryTable createAlias(String alias) {
    return $LibraryEntryTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LibraryEntryType, int, int> $convertertype =
      const EnumIndexConverter<LibraryEntryType>(LibraryEntryType.values);
}

class LibraryEntryData extends DataClass
    implements Insertable<LibraryEntryData> {
  final LibraryEntryType type;
  final BigInt createdAt;
  final String data;
  final int width;
  final int height;
  const LibraryEntryData(
      {required this.type,
      required this.createdAt,
      required this.data,
      required this.width,
      required this.height});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['type'] =
          Variable<int>($LibraryEntryTable.$convertertype.toSql(type));
    }
    map['created_at'] = Variable<BigInt>(createdAt);
    map['data'] = Variable<String>(data);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    return map;
  }

  LibraryEntryCompanion toCompanion(bool nullToAbsent) {
    return LibraryEntryCompanion(
      type: Value(type),
      createdAt: Value(createdAt),
      data: Value(data),
      width: Value(width),
      height: Value(height),
    );
  }

  factory LibraryEntryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryEntryData(
      type: $LibraryEntryTable.$convertertype
          .fromJson(serializer.fromJson<int>(json['type'])),
      createdAt: serializer.fromJson<BigInt>(json['createdAt']),
      data: serializer.fromJson<String>(json['data']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'type': serializer
          .toJson<int>($LibraryEntryTable.$convertertype.toJson(type)),
      'createdAt': serializer.toJson<BigInt>(createdAt),
      'data': serializer.toJson<String>(data),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
    };
  }

  LibraryEntryData copyWith(
          {LibraryEntryType? type,
          BigInt? createdAt,
          String? data,
          int? width,
          int? height}) =>
      LibraryEntryData(
        type: type ?? this.type,
        createdAt: createdAt ?? this.createdAt,
        data: data ?? this.data,
        width: width ?? this.width,
        height: height ?? this.height,
      );
  @override
  String toString() {
    return (StringBuffer('LibraryEntryData(')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('data: $data, ')
          ..write('width: $width, ')
          ..write('height: $height')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(type, createdAt, data, width, height);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryEntryData &&
          other.type == this.type &&
          other.createdAt == this.createdAt &&
          other.data == this.data &&
          other.width == this.width &&
          other.height == this.height);
}

class LibraryEntryCompanion extends UpdateCompanion<LibraryEntryData> {
  final Value<LibraryEntryType> type;
  final Value<BigInt> createdAt;
  final Value<String> data;
  final Value<int> width;
  final Value<int> height;
  final Value<int> rowid;
  const LibraryEntryCompanion({
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.data = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryEntryCompanion.insert({
    required LibraryEntryType type,
    required BigInt createdAt,
    required String data,
    required int width,
    required int height,
    this.rowid = const Value.absent(),
  })  : type = Value(type),
        createdAt = Value(createdAt),
        data = Value(data),
        width = Value(width),
        height = Value(height);
  static Insertable<LibraryEntryData> custom({
    Expression<int>? type,
    Expression<BigInt>? createdAt,
    Expression<String>? data,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
      if (data != null) 'data': data,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryEntryCompanion copyWith(
      {Value<LibraryEntryType>? type,
      Value<BigInt>? createdAt,
      Value<String>? data,
      Value<int>? width,
      Value<int>? height,
      Value<int>? rowid}) {
    return LibraryEntryCompanion(
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
      width: width ?? this.width,
      height: height ?? this.height,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (type.present) {
      map['type'] =
          Variable<int>($LibraryEntryTable.$convertertype.toSql(type.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<BigInt>(createdAt.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntryCompanion(')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('data: $data, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessageReactionTable extends MessageReaction
    with TableInfo<$MessageReactionTable, MessageReactionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageReactionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
      'message_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
      'sender', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _reactionMeta =
      const VerificationMeta('reaction');
  @override
  late final GeneratedColumn<String> reaction = GeneratedColumn<String>(
      'reaction', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<BigInt> createdAt = GeneratedColumn<BigInt>(
      'created_at', aliasedName, false,
      type: DriftSqlType.bigInt, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [messageId, sender, reaction, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_reaction';
  @override
  VerificationContext validateIntegrity(
      Insertable<MessageReactionData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('sender')) {
      context.handle(_senderMeta,
          sender.isAcceptableOrUnknown(data['sender']!, _senderMeta));
    } else if (isInserting) {
      context.missing(_senderMeta);
    }
    if (data.containsKey('reaction')) {
      context.handle(_reactionMeta,
          reaction.isAcceptableOrUnknown(data['reaction']!, _reactionMeta));
    } else if (isInserting) {
      context.missing(_reactionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  MessageReactionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageReactionData(
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_id'])!,
      sender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender'])!,
      reaction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reaction'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MessageReactionTable createAlias(String alias) {
    return $MessageReactionTable(attachedDatabase, alias);
  }
}

class MessageReactionData extends DataClass
    implements Insertable<MessageReactionData> {
  final String messageId;
  final String sender;
  final String reaction;
  final BigInt createdAt;
  const MessageReactionData(
      {required this.messageId,
      required this.sender,
      required this.reaction,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<String>(messageId);
    map['sender'] = Variable<String>(sender);
    map['reaction'] = Variable<String>(reaction);
    map['created_at'] = Variable<BigInt>(createdAt);
    return map;
  }

  MessageReactionCompanion toCompanion(bool nullToAbsent) {
    return MessageReactionCompanion(
      messageId: Value(messageId),
      sender: Value(sender),
      reaction: Value(reaction),
      createdAt: Value(createdAt),
    );
  }

  factory MessageReactionData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageReactionData(
      messageId: serializer.fromJson<String>(json['messageId']),
      sender: serializer.fromJson<String>(json['sender']),
      reaction: serializer.fromJson<String>(json['reaction']),
      createdAt: serializer.fromJson<BigInt>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<String>(messageId),
      'sender': serializer.toJson<String>(sender),
      'reaction': serializer.toJson<String>(reaction),
      'createdAt': serializer.toJson<BigInt>(createdAt),
    };
  }

  MessageReactionData copyWith(
          {String? messageId,
          String? sender,
          String? reaction,
          BigInt? createdAt}) =>
      MessageReactionData(
        messageId: messageId ?? this.messageId,
        sender: sender ?? this.sender,
        reaction: reaction ?? this.reaction,
        createdAt: createdAt ?? this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('MessageReactionData(')
          ..write('messageId: $messageId, ')
          ..write('sender: $sender, ')
          ..write('reaction: $reaction, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(messageId, sender, reaction, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageReactionData &&
          other.messageId == this.messageId &&
          other.sender == this.sender &&
          other.reaction == this.reaction &&
          other.createdAt == this.createdAt);
}

class MessageReactionCompanion extends UpdateCompanion<MessageReactionData> {
  final Value<String> messageId;
  final Value<String> sender;
  final Value<String> reaction;
  final Value<BigInt> createdAt;
  final Value<int> rowid;
  const MessageReactionCompanion({
    this.messageId = const Value.absent(),
    this.sender = const Value.absent(),
    this.reaction = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageReactionCompanion.insert({
    required String messageId,
    required String sender,
    required String reaction,
    required BigInt createdAt,
    this.rowid = const Value.absent(),
  })  : messageId = Value(messageId),
        sender = Value(sender),
        reaction = Value(reaction),
        createdAt = Value(createdAt);
  static Insertable<MessageReactionData> custom({
    Expression<String>? messageId,
    Expression<String>? sender,
    Expression<String>? reaction,
    Expression<BigInt>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (sender != null) 'sender': sender,
      if (reaction != null) 'reaction': reaction,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageReactionCompanion copyWith(
      {Value<String>? messageId,
      Value<String>? sender,
      Value<String>? reaction,
      Value<BigInt>? createdAt,
      Value<int>? rowid}) {
    return MessageReactionCompanion(
      messageId: messageId ?? this.messageId,
      sender: sender ?? this.sender,
      reaction: reaction ?? this.reaction,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (reaction.present) {
      map['reaction'] = Variable<String>(reaction.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<BigInt>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageReactionCompanion(')
          ..write('messageId: $messageId, ')
          ..write('sender: $sender, ')
          ..write('reaction: $reaction, ')
          ..write('createdAt: $createdAt, ')
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
  late final $UnknownProfileTable unknownProfile = $UnknownProfileTable(this);
  late final $ProfileTable profile = $ProfileTable(this);
  late final $TrustedLinkTable trustedLink = $TrustedLinkTable(this);
  late final $LibraryEntryTable libraryEntry = $LibraryEntryTable(this);
  late final $MessageReactionTable messageReaction =
      $MessageReactionTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        conversation,
        member,
        message,
        setting,
        friend,
        request,
        unknownProfile,
        profile,
        trustedLink,
        libraryEntry,
        messageReaction
      ];
}
