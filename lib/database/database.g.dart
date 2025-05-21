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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vaultIdMeta = const VerificationMeta(
    'vaultId',
  );
  @override
  late final GeneratedColumn<Uint8List> vaultId = GeneratedColumn<Uint8List>(
    'vault_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ConversationType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ConversationType>($ConversationTable.$convertertype);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _membersMeta = const VerificationMeta(
    'members',
  );
  @override
  late final GeneratedColumn<Uint8List> members = GeneratedColumn<Uint8List>(
    'members',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<Uint8List> token = GeneratedColumn<Uint8List>(
    'token',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<Uint8List> key = GeneratedColumn<Uint8List>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastVersionMeta = const VerificationMeta(
    'lastVersion',
  );
  @override
  late final GeneratedColumn<BigInt> lastVersion = GeneratedColumn<BigInt>(
    'last_version',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<BigInt> updatedAt = GeneratedColumn<BigInt>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readsMeta = const VerificationMeta('reads');
  @override
  late final GeneratedColumn<Uint8List> reads = GeneratedColumn<Uint8List>(
    'reads',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vaultId,
    type,
    data,
    members,
    token,
    key,
    lastVersion,
    updatedAt,
    reads,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversation';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConversationData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vault_id')) {
      context.handle(
        _vaultIdMeta,
        vaultId.isAcceptableOrUnknown(data['vault_id']!, _vaultIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vaultIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('members')) {
      context.handle(
        _membersMeta,
        members.isAcceptableOrUnknown(data['members']!, _membersMeta),
      );
    } else if (isInserting) {
      context.missing(_membersMeta);
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('last_version')) {
      context.handle(
        _lastVersionMeta,
        lastVersion.isAcceptableOrUnknown(
          data['last_version']!,
          _lastVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastVersionMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('reads')) {
      context.handle(
        _readsMeta,
        reads.isAcceptableOrUnknown(data['reads']!, _readsMeta),
      );
    } else if (isInserting) {
      context.missing(_readsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConversationData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      vaultId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}vault_id'],
          )!,
      type: $ConversationTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      data:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}data'],
          )!,
      members:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}members'],
          )!,
      token:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}token'],
          )!,
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}key'],
          )!,
      lastVersion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bigInt,
            data['${effectivePrefix}last_version'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bigInt,
            data['${effectivePrefix}updated_at'],
          )!,
      reads:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}reads'],
          )!,
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
  final Uint8List vaultId;
  final ConversationType type;
  final Uint8List data;
  final Uint8List members;
  final Uint8List token;
  final Uint8List key;
  final BigInt lastVersion;
  final BigInt updatedAt;
  final Uint8List reads;
  const ConversationData({
    required this.id,
    required this.vaultId,
    required this.type,
    required this.data,
    required this.members,
    required this.token,
    required this.key,
    required this.lastVersion,
    required this.updatedAt,
    required this.reads,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vault_id'] = Variable<Uint8List>(vaultId);
    {
      map['type'] = Variable<int>(
        $ConversationTable.$convertertype.toSql(type),
      );
    }
    map['data'] = Variable<Uint8List>(data);
    map['members'] = Variable<Uint8List>(members);
    map['token'] = Variable<Uint8List>(token);
    map['key'] = Variable<Uint8List>(key);
    map['last_version'] = Variable<BigInt>(lastVersion);
    map['updated_at'] = Variable<BigInt>(updatedAt);
    map['reads'] = Variable<Uint8List>(reads);
    return map;
  }

  ConversationCompanion toCompanion(bool nullToAbsent) {
    return ConversationCompanion(
      id: Value(id),
      vaultId: Value(vaultId),
      type: Value(type),
      data: Value(data),
      members: Value(members),
      token: Value(token),
      key: Value(key),
      lastVersion: Value(lastVersion),
      updatedAt: Value(updatedAt),
      reads: Value(reads),
    );
  }

  factory ConversationData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationData(
      id: serializer.fromJson<String>(json['id']),
      vaultId: serializer.fromJson<Uint8List>(json['vaultId']),
      type: $ConversationTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      data: serializer.fromJson<Uint8List>(json['data']),
      members: serializer.fromJson<Uint8List>(json['members']),
      token: serializer.fromJson<Uint8List>(json['token']),
      key: serializer.fromJson<Uint8List>(json['key']),
      lastVersion: serializer.fromJson<BigInt>(json['lastVersion']),
      updatedAt: serializer.fromJson<BigInt>(json['updatedAt']),
      reads: serializer.fromJson<Uint8List>(json['reads']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vaultId': serializer.toJson<Uint8List>(vaultId),
      'type': serializer.toJson<int>(
        $ConversationTable.$convertertype.toJson(type),
      ),
      'data': serializer.toJson<Uint8List>(data),
      'members': serializer.toJson<Uint8List>(members),
      'token': serializer.toJson<Uint8List>(token),
      'key': serializer.toJson<Uint8List>(key),
      'lastVersion': serializer.toJson<BigInt>(lastVersion),
      'updatedAt': serializer.toJson<BigInt>(updatedAt),
      'reads': serializer.toJson<Uint8List>(reads),
    };
  }

  ConversationData copyWith({
    String? id,
    Uint8List? vaultId,
    ConversationType? type,
    Uint8List? data,
    Uint8List? members,
    Uint8List? token,
    Uint8List? key,
    BigInt? lastVersion,
    BigInt? updatedAt,
    Uint8List? reads,
  }) => ConversationData(
    id: id ?? this.id,
    vaultId: vaultId ?? this.vaultId,
    type: type ?? this.type,
    data: data ?? this.data,
    members: members ?? this.members,
    token: token ?? this.token,
    key: key ?? this.key,
    lastVersion: lastVersion ?? this.lastVersion,
    updatedAt: updatedAt ?? this.updatedAt,
    reads: reads ?? this.reads,
  );
  ConversationData copyWithCompanion(ConversationCompanion data) {
    return ConversationData(
      id: data.id.present ? data.id.value : this.id,
      vaultId: data.vaultId.present ? data.vaultId.value : this.vaultId,
      type: data.type.present ? data.type.value : this.type,
      data: data.data.present ? data.data.value : this.data,
      members: data.members.present ? data.members.value : this.members,
      token: data.token.present ? data.token.value : this.token,
      key: data.key.present ? data.key.value : this.key,
      lastVersion:
          data.lastVersion.present ? data.lastVersion.value : this.lastVersion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      reads: data.reads.present ? data.reads.value : this.reads,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationData(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('type: $type, ')
          ..write('data: $data, ')
          ..write('members: $members, ')
          ..write('token: $token, ')
          ..write('key: $key, ')
          ..write('lastVersion: $lastVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('reads: $reads')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    $driftBlobEquality.hash(vaultId),
    type,
    $driftBlobEquality.hash(data),
    $driftBlobEquality.hash(members),
    $driftBlobEquality.hash(token),
    $driftBlobEquality.hash(key),
    lastVersion,
    updatedAt,
    $driftBlobEquality.hash(reads),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationData &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.vaultId, this.vaultId) &&
          other.type == this.type &&
          $driftBlobEquality.equals(other.data, this.data) &&
          $driftBlobEquality.equals(other.members, this.members) &&
          $driftBlobEquality.equals(other.token, this.token) &&
          $driftBlobEquality.equals(other.key, this.key) &&
          other.lastVersion == this.lastVersion &&
          other.updatedAt == this.updatedAt &&
          $driftBlobEquality.equals(other.reads, this.reads));
}

class ConversationCompanion extends UpdateCompanion<ConversationData> {
  final Value<String> id;
  final Value<Uint8List> vaultId;
  final Value<ConversationType> type;
  final Value<Uint8List> data;
  final Value<Uint8List> members;
  final Value<Uint8List> token;
  final Value<Uint8List> key;
  final Value<BigInt> lastVersion;
  final Value<BigInt> updatedAt;
  final Value<Uint8List> reads;
  final Value<int> rowid;
  const ConversationCompanion({
    this.id = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.type = const Value.absent(),
    this.data = const Value.absent(),
    this.members = const Value.absent(),
    this.token = const Value.absent(),
    this.key = const Value.absent(),
    this.lastVersion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.reads = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationCompanion.insert({
    required String id,
    required Uint8List vaultId,
    required ConversationType type,
    required Uint8List data,
    required Uint8List members,
    required Uint8List token,
    required Uint8List key,
    required BigInt lastVersion,
    required BigInt updatedAt,
    required Uint8List reads,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vaultId = Value(vaultId),
       type = Value(type),
       data = Value(data),
       members = Value(members),
       token = Value(token),
       key = Value(key),
       lastVersion = Value(lastVersion),
       updatedAt = Value(updatedAt),
       reads = Value(reads);
  static Insertable<ConversationData> custom({
    Expression<String>? id,
    Expression<Uint8List>? vaultId,
    Expression<int>? type,
    Expression<Uint8List>? data,
    Expression<Uint8List>? members,
    Expression<Uint8List>? token,
    Expression<Uint8List>? key,
    Expression<BigInt>? lastVersion,
    Expression<BigInt>? updatedAt,
    Expression<Uint8List>? reads,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vaultId != null) 'vault_id': vaultId,
      if (type != null) 'type': type,
      if (data != null) 'data': data,
      if (members != null) 'members': members,
      if (token != null) 'token': token,
      if (key != null) 'key': key,
      if (lastVersion != null) 'last_version': lastVersion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (reads != null) 'reads': reads,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationCompanion copyWith({
    Value<String>? id,
    Value<Uint8List>? vaultId,
    Value<ConversationType>? type,
    Value<Uint8List>? data,
    Value<Uint8List>? members,
    Value<Uint8List>? token,
    Value<Uint8List>? key,
    Value<BigInt>? lastVersion,
    Value<BigInt>? updatedAt,
    Value<Uint8List>? reads,
    Value<int>? rowid,
  }) {
    return ConversationCompanion(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      type: type ?? this.type,
      data: data ?? this.data,
      members: members ?? this.members,
      token: token ?? this.token,
      key: key ?? this.key,
      lastVersion: lastVersion ?? this.lastVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      reads: reads ?? this.reads,
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
      map['vault_id'] = Variable<Uint8List>(vaultId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $ConversationTable.$convertertype.toSql(type.value),
      );
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
    }
    if (members.present) {
      map['members'] = Variable<Uint8List>(members.value);
    }
    if (token.present) {
      map['token'] = Variable<Uint8List>(token.value);
    }
    if (key.present) {
      map['key'] = Variable<Uint8List>(key.value);
    }
    if (lastVersion.present) {
      map['last_version'] = Variable<BigInt>(lastVersion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<BigInt>(updatedAt.value);
    }
    if (reads.present) {
      map['reads'] = Variable<Uint8List>(reads.value);
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
          ..write('members: $members, ')
          ..write('token: $token, ')
          ..write('key: $key, ')
          ..write('lastVersion: $lastVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('reads: $reads, ')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<Uint8List> content = GeneratedColumn<Uint8List>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderTokenMeta = const VerificationMeta(
    'senderToken',
  );
  @override
  late final GeneratedColumn<String> senderToken = GeneratedColumn<String>(
    'sender_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderAddressMeta = const VerificationMeta(
    'senderAddress',
  );
  @override
  late final GeneratedColumn<Uint8List> senderAddress =
      GeneratedColumn<Uint8List>(
        'sender_address',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<BigInt> createdAt = GeneratedColumn<BigInt>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationMeta = const VerificationMeta(
    'conversation',
  );
  @override
  late final GeneratedColumn<String> conversation = GeneratedColumn<String>(
    'conversation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editedMeta = const VerificationMeta('edited');
  @override
  late final GeneratedColumn<bool> edited = GeneratedColumn<bool>(
    'edited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("edited" IN (0, 1))',
    ),
  );
  static const VerificationMeta _verifiedMeta = const VerificationMeta(
    'verified',
  );
  @override
  late final GeneratedColumn<bool> verified = GeneratedColumn<bool>(
    'verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("verified" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    content,
    senderToken,
    senderAddress,
    createdAt,
    conversation,
    edited,
    verified,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('sender_token')) {
      context.handle(
        _senderTokenMeta,
        senderToken.isAcceptableOrUnknown(
          data['sender_token']!,
          _senderTokenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_senderTokenMeta);
    }
    if (data.containsKey('sender_address')) {
      context.handle(
        _senderAddressMeta,
        senderAddress.isAcceptableOrUnknown(
          data['sender_address']!,
          _senderAddressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_senderAddressMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('conversation')) {
      context.handle(
        _conversationMeta,
        conversation.isAcceptableOrUnknown(
          data['conversation']!,
          _conversationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationMeta);
    }
    if (data.containsKey('edited')) {
      context.handle(
        _editedMeta,
        edited.isAcceptableOrUnknown(data['edited']!, _editedMeta),
      );
    } else if (isInserting) {
      context.missing(_editedMeta);
    }
    if (data.containsKey('verified')) {
      context.handle(
        _verifiedMeta,
        verified.isAcceptableOrUnknown(data['verified']!, _verifiedMeta),
      );
    } else if (isInserting) {
      context.missing(_verifiedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      content:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}content'],
          )!,
      senderToken:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sender_token'],
          )!,
      senderAddress:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}sender_address'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bigInt,
            data['${effectivePrefix}created_at'],
          )!,
      conversation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}conversation'],
          )!,
      edited:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}edited'],
          )!,
      verified:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}verified'],
          )!,
    );
  }

  @override
  $MessageTable createAlias(String alias) {
    return $MessageTable(attachedDatabase, alias);
  }
}

class MessageData extends DataClass implements Insertable<MessageData> {
  final String id;
  final Uint8List content;
  final String senderToken;
  final Uint8List senderAddress;
  final BigInt createdAt;
  final String conversation;
  final bool edited;
  final bool verified;
  const MessageData({
    required this.id,
    required this.content,
    required this.senderToken,
    required this.senderAddress,
    required this.createdAt,
    required this.conversation,
    required this.edited,
    required this.verified,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content'] = Variable<Uint8List>(content);
    map['sender_token'] = Variable<String>(senderToken);
    map['sender_address'] = Variable<Uint8List>(senderAddress);
    map['created_at'] = Variable<BigInt>(createdAt);
    map['conversation'] = Variable<String>(conversation);
    map['edited'] = Variable<bool>(edited);
    map['verified'] = Variable<bool>(verified);
    return map;
  }

  MessageCompanion toCompanion(bool nullToAbsent) {
    return MessageCompanion(
      id: Value(id),
      content: Value(content),
      senderToken: Value(senderToken),
      senderAddress: Value(senderAddress),
      createdAt: Value(createdAt),
      conversation: Value(conversation),
      edited: Value(edited),
      verified: Value(verified),
    );
  }

  factory MessageData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageData(
      id: serializer.fromJson<String>(json['id']),
      content: serializer.fromJson<Uint8List>(json['content']),
      senderToken: serializer.fromJson<String>(json['senderToken']),
      senderAddress: serializer.fromJson<Uint8List>(json['senderAddress']),
      createdAt: serializer.fromJson<BigInt>(json['createdAt']),
      conversation: serializer.fromJson<String>(json['conversation']),
      edited: serializer.fromJson<bool>(json['edited']),
      verified: serializer.fromJson<bool>(json['verified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'content': serializer.toJson<Uint8List>(content),
      'senderToken': serializer.toJson<String>(senderToken),
      'senderAddress': serializer.toJson<Uint8List>(senderAddress),
      'createdAt': serializer.toJson<BigInt>(createdAt),
      'conversation': serializer.toJson<String>(conversation),
      'edited': serializer.toJson<bool>(edited),
      'verified': serializer.toJson<bool>(verified),
    };
  }

  MessageData copyWith({
    String? id,
    Uint8List? content,
    String? senderToken,
    Uint8List? senderAddress,
    BigInt? createdAt,
    String? conversation,
    bool? edited,
    bool? verified,
  }) => MessageData(
    id: id ?? this.id,
    content: content ?? this.content,
    senderToken: senderToken ?? this.senderToken,
    senderAddress: senderAddress ?? this.senderAddress,
    createdAt: createdAt ?? this.createdAt,
    conversation: conversation ?? this.conversation,
    edited: edited ?? this.edited,
    verified: verified ?? this.verified,
  );
  MessageData copyWithCompanion(MessageCompanion data) {
    return MessageData(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      senderToken:
          data.senderToken.present ? data.senderToken.value : this.senderToken,
      senderAddress:
          data.senderAddress.present
              ? data.senderAddress.value
              : this.senderAddress,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      conversation:
          data.conversation.present
              ? data.conversation.value
              : this.conversation,
      edited: data.edited.present ? data.edited.value : this.edited,
      verified: data.verified.present ? data.verified.value : this.verified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageData(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('senderToken: $senderToken, ')
          ..write('senderAddress: $senderAddress, ')
          ..write('createdAt: $createdAt, ')
          ..write('conversation: $conversation, ')
          ..write('edited: $edited, ')
          ..write('verified: $verified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    $driftBlobEquality.hash(content),
    senderToken,
    $driftBlobEquality.hash(senderAddress),
    createdAt,
    conversation,
    edited,
    verified,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageData &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.content, this.content) &&
          other.senderToken == this.senderToken &&
          $driftBlobEquality.equals(other.senderAddress, this.senderAddress) &&
          other.createdAt == this.createdAt &&
          other.conversation == this.conversation &&
          other.edited == this.edited &&
          other.verified == this.verified);
}

class MessageCompanion extends UpdateCompanion<MessageData> {
  final Value<String> id;
  final Value<Uint8List> content;
  final Value<String> senderToken;
  final Value<Uint8List> senderAddress;
  final Value<BigInt> createdAt;
  final Value<String> conversation;
  final Value<bool> edited;
  final Value<bool> verified;
  final Value<int> rowid;
  const MessageCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.senderToken = const Value.absent(),
    this.senderAddress = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.conversation = const Value.absent(),
    this.edited = const Value.absent(),
    this.verified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessageCompanion.insert({
    required String id,
    required Uint8List content,
    required String senderToken,
    required Uint8List senderAddress,
    required BigInt createdAt,
    required String conversation,
    required bool edited,
    required bool verified,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       content = Value(content),
       senderToken = Value(senderToken),
       senderAddress = Value(senderAddress),
       createdAt = Value(createdAt),
       conversation = Value(conversation),
       edited = Value(edited),
       verified = Value(verified);
  static Insertable<MessageData> custom({
    Expression<String>? id,
    Expression<Uint8List>? content,
    Expression<String>? senderToken,
    Expression<Uint8List>? senderAddress,
    Expression<BigInt>? createdAt,
    Expression<String>? conversation,
    Expression<bool>? edited,
    Expression<bool>? verified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (senderToken != null) 'sender_token': senderToken,
      if (senderAddress != null) 'sender_address': senderAddress,
      if (createdAt != null) 'created_at': createdAt,
      if (conversation != null) 'conversation': conversation,
      if (edited != null) 'edited': edited,
      if (verified != null) 'verified': verified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessageCompanion copyWith({
    Value<String>? id,
    Value<Uint8List>? content,
    Value<String>? senderToken,
    Value<Uint8List>? senderAddress,
    Value<BigInt>? createdAt,
    Value<String>? conversation,
    Value<bool>? edited,
    Value<bool>? verified,
    Value<int>? rowid,
  }) {
    return MessageCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      senderToken: senderToken ?? this.senderToken,
      senderAddress: senderAddress ?? this.senderAddress,
      createdAt: createdAt ?? this.createdAt,
      conversation: conversation ?? this.conversation,
      edited: edited ?? this.edited,
      verified: verified ?? this.verified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<Uint8List>(content.value);
    }
    if (senderToken.present) {
      map['sender_token'] = Variable<String>(senderToken.value);
    }
    if (senderAddress.present) {
      map['sender_address'] = Variable<Uint8List>(senderAddress.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<BigInt>(createdAt.value);
    }
    if (conversation.present) {
      map['conversation'] = Variable<String>(conversation.value);
    }
    if (edited.present) {
      map['edited'] = Variable<bool>(edited.value);
    }
    if (verified.present) {
      map['verified'] = Variable<bool>(verified.value);
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
          ..write('content: $content, ')
          ..write('senderToken: $senderToken, ')
          ..write('senderAddress: $senderAddress, ')
          ..write('createdAt: $createdAt, ')
          ..write('conversation: $conversation, ')
          ..write('edited: $edited, ')
          ..write('verified: $verified, ')
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
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<Uint8List> value = GeneratedColumn<Uint8List>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
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
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}key'],
          )!,
      value:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}value'],
          )!,
    );
  }

  @override
  $SettingTable createAlias(String alias) {
    return $SettingTable(attachedDatabase, alias);
  }
}

class SettingData extends DataClass implements Insertable<SettingData> {
  final String key;
  final Uint8List value;
  const SettingData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<Uint8List>(value);
    return map;
  }

  SettingCompanion toCompanion(bool nullToAbsent) {
    return SettingCompanion(key: Value(key), value: Value(value));
  }

  factory SettingData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<Uint8List>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<Uint8List>(value),
    };
  }

  SettingData copyWith({String? key, Uint8List? value}) =>
      SettingData(key: key ?? this.key, value: value ?? this.value);
  SettingData copyWithCompanion(SettingCompanion data) {
    return SettingData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, $driftBlobEquality.hash(value));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingData &&
          other.key == this.key &&
          $driftBlobEquality.equals(other.value, this.value));
}

class SettingCompanion extends UpdateCompanion<SettingData> {
  final Value<String> key;
  final Value<Uint8List> value;
  final Value<int> rowid;
  const SettingCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingCompanion.insert({
    required String key,
    required Uint8List value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingData> custom({
    Expression<String>? key,
    Expression<Uint8List>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingCompanion copyWith({
    Value<String>? key,
    Value<Uint8List>? value,
    Value<int>? rowid,
  }) {
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
      map['value'] = Variable<Uint8List>(value.value);
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<Uint8List> name = GeneratedColumn<Uint8List>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<Uint8List> displayName =
      GeneratedColumn<Uint8List>(
        'display_name',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _vaultIdMeta = const VerificationMeta(
    'vaultId',
  );
  @override
  late final GeneratedColumn<Uint8List> vaultId = GeneratedColumn<Uint8List>(
    'vault_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keysMeta = const VerificationMeta('keys');
  @override
  late final GeneratedColumn<Uint8List> keys = GeneratedColumn<Uint8List>(
    'keys',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<BigInt> updatedAt = GeneratedColumn<BigInt>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    displayName,
    vaultId,
    keys,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'friend';
  @override
  VerificationContext validateIntegrity(
    Insertable<FriendData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('vault_id')) {
      context.handle(
        _vaultIdMeta,
        vaultId.isAcceptableOrUnknown(data['vault_id']!, _vaultIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vaultIdMeta);
    }
    if (data.containsKey('keys')) {
      context.handle(
        _keysMeta,
        keys.isAcceptableOrUnknown(data['keys']!, _keysMeta),
      );
    } else if (isInserting) {
      context.missing(_keysMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
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
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}name'],
          )!,
      displayName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}display_name'],
          )!,
      vaultId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}vault_id'],
          )!,
      keys:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}keys'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bigInt,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $FriendTable createAlias(String alias) {
    return $FriendTable(attachedDatabase, alias);
  }
}

class FriendData extends DataClass implements Insertable<FriendData> {
  final String id;
  final Uint8List name;
  final Uint8List displayName;
  final Uint8List vaultId;
  final Uint8List keys;
  final BigInt updatedAt;
  const FriendData({
    required this.id,
    required this.name,
    required this.displayName,
    required this.vaultId,
    required this.keys,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<Uint8List>(name);
    map['display_name'] = Variable<Uint8List>(displayName);
    map['vault_id'] = Variable<Uint8List>(vaultId);
    map['keys'] = Variable<Uint8List>(keys);
    map['updated_at'] = Variable<BigInt>(updatedAt);
    return map;
  }

  FriendCompanion toCompanion(bool nullToAbsent) {
    return FriendCompanion(
      id: Value(id),
      name: Value(name),
      displayName: Value(displayName),
      vaultId: Value(vaultId),
      keys: Value(keys),
      updatedAt: Value(updatedAt),
    );
  }

  factory FriendData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FriendData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<Uint8List>(json['name']),
      displayName: serializer.fromJson<Uint8List>(json['displayName']),
      vaultId: serializer.fromJson<Uint8List>(json['vaultId']),
      keys: serializer.fromJson<Uint8List>(json['keys']),
      updatedAt: serializer.fromJson<BigInt>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<Uint8List>(name),
      'displayName': serializer.toJson<Uint8List>(displayName),
      'vaultId': serializer.toJson<Uint8List>(vaultId),
      'keys': serializer.toJson<Uint8List>(keys),
      'updatedAt': serializer.toJson<BigInt>(updatedAt),
    };
  }

  FriendData copyWith({
    String? id,
    Uint8List? name,
    Uint8List? displayName,
    Uint8List? vaultId,
    Uint8List? keys,
    BigInt? updatedAt,
  }) => FriendData(
    id: id ?? this.id,
    name: name ?? this.name,
    displayName: displayName ?? this.displayName,
    vaultId: vaultId ?? this.vaultId,
    keys: keys ?? this.keys,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FriendData copyWithCompanion(FriendCompanion data) {
    return FriendData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      vaultId: data.vaultId.present ? data.vaultId.value : this.vaultId,
      keys: data.keys.present ? data.keys.value : this.keys,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FriendData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName, ')
          ..write('vaultId: $vaultId, ')
          ..write('keys: $keys, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    $driftBlobEquality.hash(name),
    $driftBlobEquality.hash(displayName),
    $driftBlobEquality.hash(vaultId),
    $driftBlobEquality.hash(keys),
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FriendData &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.name, this.name) &&
          $driftBlobEquality.equals(other.displayName, this.displayName) &&
          $driftBlobEquality.equals(other.vaultId, this.vaultId) &&
          $driftBlobEquality.equals(other.keys, this.keys) &&
          other.updatedAt == this.updatedAt);
}

class FriendCompanion extends UpdateCompanion<FriendData> {
  final Value<String> id;
  final Value<Uint8List> name;
  final Value<Uint8List> displayName;
  final Value<Uint8List> vaultId;
  final Value<Uint8List> keys;
  final Value<BigInt> updatedAt;
  final Value<int> rowid;
  const FriendCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.displayName = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.keys = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FriendCompanion.insert({
    required String id,
    required Uint8List name,
    required Uint8List displayName,
    required Uint8List vaultId,
    required Uint8List keys,
    required BigInt updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       displayName = Value(displayName),
       vaultId = Value(vaultId),
       keys = Value(keys),
       updatedAt = Value(updatedAt);
  static Insertable<FriendData> custom({
    Expression<String>? id,
    Expression<Uint8List>? name,
    Expression<Uint8List>? displayName,
    Expression<Uint8List>? vaultId,
    Expression<Uint8List>? keys,
    Expression<BigInt>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (displayName != null) 'display_name': displayName,
      if (vaultId != null) 'vault_id': vaultId,
      if (keys != null) 'keys': keys,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FriendCompanion copyWith({
    Value<String>? id,
    Value<Uint8List>? name,
    Value<Uint8List>? displayName,
    Value<Uint8List>? vaultId,
    Value<Uint8List>? keys,
    Value<BigInt>? updatedAt,
    Value<int>? rowid,
  }) {
    return FriendCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
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
      map['name'] = Variable<Uint8List>(name.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<Uint8List>(displayName.value);
    }
    if (vaultId.present) {
      map['vault_id'] = Variable<Uint8List>(vaultId.value);
    }
    if (keys.present) {
      map['keys'] = Variable<Uint8List>(keys.value);
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
          ..write('displayName: $displayName, ')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<Uint8List> name = GeneratedColumn<Uint8List>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<Uint8List> displayName =
      GeneratedColumn<Uint8List>(
        'display_name',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _selfMeta = const VerificationMeta('self');
  @override
  late final GeneratedColumn<bool> self = GeneratedColumn<bool>(
    'self',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("self" IN (0, 1))',
    ),
  );
  static const VerificationMeta _vaultIdMeta = const VerificationMeta(
    'vaultId',
  );
  @override
  late final GeneratedColumn<Uint8List> vaultId = GeneratedColumn<Uint8List>(
    'vault_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keysMeta = const VerificationMeta('keys');
  @override
  late final GeneratedColumn<Uint8List> keys = GeneratedColumn<Uint8List>(
    'keys',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<BigInt> updatedAt = GeneratedColumn<BigInt>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    displayName,
    self,
    vaultId,
    keys,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'request';
  @override
  VerificationContext validateIntegrity(
    Insertable<RequestData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('self')) {
      context.handle(
        _selfMeta,
        self.isAcceptableOrUnknown(data['self']!, _selfMeta),
      );
    } else if (isInserting) {
      context.missing(_selfMeta);
    }
    if (data.containsKey('vault_id')) {
      context.handle(
        _vaultIdMeta,
        vaultId.isAcceptableOrUnknown(data['vault_id']!, _vaultIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vaultIdMeta);
    }
    if (data.containsKey('keys')) {
      context.handle(
        _keysMeta,
        keys.isAcceptableOrUnknown(data['keys']!, _keysMeta),
      );
    } else if (isInserting) {
      context.missing(_keysMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
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
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}name'],
          )!,
      displayName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}display_name'],
          )!,
      self:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}self'],
          )!,
      vaultId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}vault_id'],
          )!,
      keys:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}keys'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bigInt,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $RequestTable createAlias(String alias) {
    return $RequestTable(attachedDatabase, alias);
  }
}

class RequestData extends DataClass implements Insertable<RequestData> {
  final String id;
  final Uint8List name;
  final Uint8List displayName;
  final bool self;
  final Uint8List vaultId;
  final Uint8List keys;
  final BigInt updatedAt;
  const RequestData({
    required this.id,
    required this.name,
    required this.displayName,
    required this.self,
    required this.vaultId,
    required this.keys,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<Uint8List>(name);
    map['display_name'] = Variable<Uint8List>(displayName);
    map['self'] = Variable<bool>(self);
    map['vault_id'] = Variable<Uint8List>(vaultId);
    map['keys'] = Variable<Uint8List>(keys);
    map['updated_at'] = Variable<BigInt>(updatedAt);
    return map;
  }

  RequestCompanion toCompanion(bool nullToAbsent) {
    return RequestCompanion(
      id: Value(id),
      name: Value(name),
      displayName: Value(displayName),
      self: Value(self),
      vaultId: Value(vaultId),
      keys: Value(keys),
      updatedAt: Value(updatedAt),
    );
  }

  factory RequestData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RequestData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<Uint8List>(json['name']),
      displayName: serializer.fromJson<Uint8List>(json['displayName']),
      self: serializer.fromJson<bool>(json['self']),
      vaultId: serializer.fromJson<Uint8List>(json['vaultId']),
      keys: serializer.fromJson<Uint8List>(json['keys']),
      updatedAt: serializer.fromJson<BigInt>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<Uint8List>(name),
      'displayName': serializer.toJson<Uint8List>(displayName),
      'self': serializer.toJson<bool>(self),
      'vaultId': serializer.toJson<Uint8List>(vaultId),
      'keys': serializer.toJson<Uint8List>(keys),
      'updatedAt': serializer.toJson<BigInt>(updatedAt),
    };
  }

  RequestData copyWith({
    String? id,
    Uint8List? name,
    Uint8List? displayName,
    bool? self,
    Uint8List? vaultId,
    Uint8List? keys,
    BigInt? updatedAt,
  }) => RequestData(
    id: id ?? this.id,
    name: name ?? this.name,
    displayName: displayName ?? this.displayName,
    self: self ?? this.self,
    vaultId: vaultId ?? this.vaultId,
    keys: keys ?? this.keys,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RequestData copyWithCompanion(RequestCompanion data) {
    return RequestData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      self: data.self.present ? data.self.value : this.self,
      vaultId: data.vaultId.present ? data.vaultId.value : this.vaultId,
      keys: data.keys.present ? data.keys.value : this.keys,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RequestData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName, ')
          ..write('self: $self, ')
          ..write('vaultId: $vaultId, ')
          ..write('keys: $keys, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    $driftBlobEquality.hash(name),
    $driftBlobEquality.hash(displayName),
    self,
    $driftBlobEquality.hash(vaultId),
    $driftBlobEquality.hash(keys),
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RequestData &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.name, this.name) &&
          $driftBlobEquality.equals(other.displayName, this.displayName) &&
          other.self == this.self &&
          $driftBlobEquality.equals(other.vaultId, this.vaultId) &&
          $driftBlobEquality.equals(other.keys, this.keys) &&
          other.updatedAt == this.updatedAt);
}

class RequestCompanion extends UpdateCompanion<RequestData> {
  final Value<String> id;
  final Value<Uint8List> name;
  final Value<Uint8List> displayName;
  final Value<bool> self;
  final Value<Uint8List> vaultId;
  final Value<Uint8List> keys;
  final Value<BigInt> updatedAt;
  final Value<int> rowid;
  const RequestCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.displayName = const Value.absent(),
    this.self = const Value.absent(),
    this.vaultId = const Value.absent(),
    this.keys = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RequestCompanion.insert({
    required String id,
    required Uint8List name,
    required Uint8List displayName,
    required bool self,
    required Uint8List vaultId,
    required Uint8List keys,
    required BigInt updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       displayName = Value(displayName),
       self = Value(self),
       vaultId = Value(vaultId),
       keys = Value(keys),
       updatedAt = Value(updatedAt);
  static Insertable<RequestData> custom({
    Expression<String>? id,
    Expression<Uint8List>? name,
    Expression<Uint8List>? displayName,
    Expression<bool>? self,
    Expression<Uint8List>? vaultId,
    Expression<Uint8List>? keys,
    Expression<BigInt>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (displayName != null) 'display_name': displayName,
      if (self != null) 'self': self,
      if (vaultId != null) 'vault_id': vaultId,
      if (keys != null) 'keys': keys,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RequestCompanion copyWith({
    Value<String>? id,
    Value<Uint8List>? name,
    Value<Uint8List>? displayName,
    Value<bool>? self,
    Value<Uint8List>? vaultId,
    Value<Uint8List>? keys,
    Value<BigInt>? updatedAt,
    Value<int>? rowid,
  }) {
    return RequestCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      self: self ?? this.self,
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
      map['name'] = Variable<Uint8List>(name.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<Uint8List>(displayName.value);
    }
    if (self.present) {
      map['self'] = Variable<bool>(self.value);
    }
    if (vaultId.present) {
      map['vault_id'] = Variable<Uint8List>(vaultId.value);
    }
    if (keys.present) {
      map['keys'] = Variable<Uint8List>(keys.value);
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
          ..write('displayName: $displayName, ')
          ..write('self: $self, ')
          ..write('vaultId: $vaultId, ')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<Uint8List> name = GeneratedColumn<Uint8List>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<Uint8List> displayName =
      GeneratedColumn<Uint8List>(
        'display_name',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _keysMeta = const VerificationMeta('keys');
  @override
  late final GeneratedColumn<Uint8List> keys = GeneratedColumn<Uint8List>(
    'keys',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastFetchedMeta = const VerificationMeta(
    'lastFetched',
  );
  @override
  late final GeneratedColumn<DateTime> lastFetched = GeneratedColumn<DateTime>(
    'last_fetched',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: Constant(DateTime.fromMillisecondsSinceEpoch(0)),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    displayName,
    keys,
    lastFetched,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unknown_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnknownProfileData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('keys')) {
      context.handle(
        _keysMeta,
        keys.isAcceptableOrUnknown(data['keys']!, _keysMeta),
      );
    } else if (isInserting) {
      context.missing(_keysMeta);
    }
    if (data.containsKey('last_fetched')) {
      context.handle(
        _lastFetchedMeta,
        lastFetched.isAcceptableOrUnknown(
          data['last_fetched']!,
          _lastFetchedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnknownProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnknownProfileData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}name'],
          )!,
      displayName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}display_name'],
          )!,
      keys:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}keys'],
          )!,
      lastFetched:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}last_fetched'],
          )!,
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
  final Uint8List name;
  final Uint8List displayName;
  final Uint8List keys;
  final DateTime lastFetched;
  const UnknownProfileData({
    required this.id,
    required this.name,
    required this.displayName,
    required this.keys,
    required this.lastFetched,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<Uint8List>(name);
    map['display_name'] = Variable<Uint8List>(displayName);
    map['keys'] = Variable<Uint8List>(keys);
    map['last_fetched'] = Variable<DateTime>(lastFetched);
    return map;
  }

  UnknownProfileCompanion toCompanion(bool nullToAbsent) {
    return UnknownProfileCompanion(
      id: Value(id),
      name: Value(name),
      displayName: Value(displayName),
      keys: Value(keys),
      lastFetched: Value(lastFetched),
    );
  }

  factory UnknownProfileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnknownProfileData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<Uint8List>(json['name']),
      displayName: serializer.fromJson<Uint8List>(json['displayName']),
      keys: serializer.fromJson<Uint8List>(json['keys']),
      lastFetched: serializer.fromJson<DateTime>(json['lastFetched']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<Uint8List>(name),
      'displayName': serializer.toJson<Uint8List>(displayName),
      'keys': serializer.toJson<Uint8List>(keys),
      'lastFetched': serializer.toJson<DateTime>(lastFetched),
    };
  }

  UnknownProfileData copyWith({
    String? id,
    Uint8List? name,
    Uint8List? displayName,
    Uint8List? keys,
    DateTime? lastFetched,
  }) => UnknownProfileData(
    id: id ?? this.id,
    name: name ?? this.name,
    displayName: displayName ?? this.displayName,
    keys: keys ?? this.keys,
    lastFetched: lastFetched ?? this.lastFetched,
  );
  UnknownProfileData copyWithCompanion(UnknownProfileCompanion data) {
    return UnknownProfileData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      keys: data.keys.present ? data.keys.value : this.keys,
      lastFetched:
          data.lastFetched.present ? data.lastFetched.value : this.lastFetched,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnknownProfileData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName, ')
          ..write('keys: $keys, ')
          ..write('lastFetched: $lastFetched')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    $driftBlobEquality.hash(name),
    $driftBlobEquality.hash(displayName),
    $driftBlobEquality.hash(keys),
    lastFetched,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnknownProfileData &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.name, this.name) &&
          $driftBlobEquality.equals(other.displayName, this.displayName) &&
          $driftBlobEquality.equals(other.keys, this.keys) &&
          other.lastFetched == this.lastFetched);
}

class UnknownProfileCompanion extends UpdateCompanion<UnknownProfileData> {
  final Value<String> id;
  final Value<Uint8List> name;
  final Value<Uint8List> displayName;
  final Value<Uint8List> keys;
  final Value<DateTime> lastFetched;
  final Value<int> rowid;
  const UnknownProfileCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.displayName = const Value.absent(),
    this.keys = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnknownProfileCompanion.insert({
    required String id,
    required Uint8List name,
    required Uint8List displayName,
    required Uint8List keys,
    this.lastFetched = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       displayName = Value(displayName),
       keys = Value(keys);
  static Insertable<UnknownProfileData> custom({
    Expression<String>? id,
    Expression<Uint8List>? name,
    Expression<Uint8List>? displayName,
    Expression<Uint8List>? keys,
    Expression<DateTime>? lastFetched,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (displayName != null) 'display_name': displayName,
      if (keys != null) 'keys': keys,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnknownProfileCompanion copyWith({
    Value<String>? id,
    Value<Uint8List>? name,
    Value<Uint8List>? displayName,
    Value<Uint8List>? keys,
    Value<DateTime>? lastFetched,
    Value<int>? rowid,
  }) {
    return UnknownProfileCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      keys: keys ?? this.keys,
      lastFetched: lastFetched ?? this.lastFetched,
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
      map['name'] = Variable<Uint8List>(name.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<Uint8List>(displayName.value);
    }
    if (keys.present) {
      map['keys'] = Variable<Uint8List>(keys.value);
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<DateTime>(lastFetched.value);
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
          ..write('displayName: $displayName, ')
          ..write('keys: $keys, ')
          ..write('lastFetched: $lastFetched, ')
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pictureContainerMeta = const VerificationMeta(
    'pictureContainer',
  );
  @override
  late final GeneratedColumn<Uint8List> pictureContainer =
      GeneratedColumn<Uint8List>(
        'picture_container',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
    'data',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, pictureContainer, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileData> instance, {
    bool isInserting = false,
  }) {
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
          data['picture_container']!,
          _pictureContainerMeta,
        ),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      pictureContainer: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}picture_container'],
      ),
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}data'],
      ),
    );
  }

  @override
  $ProfileTable createAlias(String alias) {
    return $ProfileTable(attachedDatabase, alias);
  }
}

class ProfileData extends DataClass implements Insertable<ProfileData> {
  final String id;
  final Uint8List? pictureContainer;
  final Uint8List? data;
  const ProfileData({required this.id, this.pictureContainer, this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || pictureContainer != null) {
      map['picture_container'] = Variable<Uint8List>(pictureContainer);
    }
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<Uint8List>(data);
    }
    return map;
  }

  ProfileCompanion toCompanion(bool nullToAbsent) {
    return ProfileCompanion(
      id: Value(id),
      pictureContainer:
          pictureContainer == null && nullToAbsent
              ? const Value.absent()
              : Value(pictureContainer),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
    );
  }

  factory ProfileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileData(
      id: serializer.fromJson<String>(json['id']),
      pictureContainer: serializer.fromJson<Uint8List?>(
        json['pictureContainer'],
      ),
      data: serializer.fromJson<Uint8List?>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pictureContainer': serializer.toJson<Uint8List?>(pictureContainer),
      'data': serializer.toJson<Uint8List?>(data),
    };
  }

  ProfileData copyWith({
    String? id,
    Value<Uint8List?> pictureContainer = const Value.absent(),
    Value<Uint8List?> data = const Value.absent(),
  }) => ProfileData(
    id: id ?? this.id,
    pictureContainer:
        pictureContainer.present
            ? pictureContainer.value
            : this.pictureContainer,
    data: data.present ? data.value : this.data,
  );
  ProfileData copyWithCompanion(ProfileCompanion data) {
    return ProfileData(
      id: data.id.present ? data.id.value : this.id,
      pictureContainer:
          data.pictureContainer.present
              ? data.pictureContainer.value
              : this.pictureContainer,
      data: data.data.present ? data.data.value : this.data,
    );
  }

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
  int get hashCode => Object.hash(
    id,
    $driftBlobEquality.hash(pictureContainer),
    $driftBlobEquality.hash(data),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileData &&
          other.id == this.id &&
          $driftBlobEquality.equals(
            other.pictureContainer,
            this.pictureContainer,
          ) &&
          $driftBlobEquality.equals(other.data, this.data));
}

class ProfileCompanion extends UpdateCompanion<ProfileData> {
  final Value<String> id;
  final Value<Uint8List?> pictureContainer;
  final Value<Uint8List?> data;
  final Value<int> rowid;
  const ProfileCompanion({
    this.id = const Value.absent(),
    this.pictureContainer = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileCompanion.insert({
    required String id,
    this.pictureContainer = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<ProfileData> custom({
    Expression<String>? id,
    Expression<Uint8List>? pictureContainer,
    Expression<Uint8List>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pictureContainer != null) 'picture_container': pictureContainer,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileCompanion copyWith({
    Value<String>? id,
    Value<Uint8List?>? pictureContainer,
    Value<Uint8List?>? data,
    Value<int>? rowid,
  }) {
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
      map['picture_container'] = Variable<Uint8List>(pictureContainer.value);
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
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
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [domain];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trusted_link';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrustedLinkData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
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
      domain:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}domain'],
          )!,
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
    return TrustedLinkCompanion(domain: Value(domain));
  }

  factory TrustedLinkData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrustedLinkData(domain: serializer.fromJson<String>(json['domain']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'domain': serializer.toJson<String>(domain)};
  }

  TrustedLinkData copyWith({String? domain}) =>
      TrustedLinkData(domain: domain ?? this.domain);
  TrustedLinkData copyWithCompanion(TrustedLinkCompanion data) {
    return TrustedLinkData(
      domain: data.domain.present ? data.domain.value : this.domain,
    );
  }

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
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LibraryEntryType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<LibraryEntryType>($LibraryEntryTable.$convertertype);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<BigInt> createdAt = GeneratedColumn<BigInt>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _identifierHashMeta = const VerificationMeta(
    'identifierHash',
  );
  @override
  late final GeneratedColumn<String> identifierHash = GeneratedColumn<String>(
    'identifier_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant("to-migrate"),
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    createdAt,
    identifierHash,
    data,
    width,
    height,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_entry';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryEntryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('identifier_hash')) {
      context.handle(
        _identifierHashMeta,
        identifierHash.isAcceptableOrUnknown(
          data['identifier_hash']!,
          _identifierHashMeta,
        ),
      );
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryEntryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryEntryData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      type: $LibraryEntryTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bigInt,
            data['${effectivePrefix}created_at'],
          )!,
      identifierHash:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}identifier_hash'],
          )!,
      data:
          attachedDatabase.typeMapping.read(
            DriftSqlType.blob,
            data['${effectivePrefix}data'],
          )!,
      width:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}width'],
          )!,
      height:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}height'],
          )!,
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
  final String id;
  final LibraryEntryType type;
  final BigInt createdAt;
  final String identifierHash;
  final Uint8List data;
  final int width;
  final int height;
  const LibraryEntryData({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.identifierHash,
    required this.data,
    required this.width,
    required this.height,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['type'] = Variable<int>(
        $LibraryEntryTable.$convertertype.toSql(type),
      );
    }
    map['created_at'] = Variable<BigInt>(createdAt);
    map['identifier_hash'] = Variable<String>(identifierHash);
    map['data'] = Variable<Uint8List>(data);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    return map;
  }

  LibraryEntryCompanion toCompanion(bool nullToAbsent) {
    return LibraryEntryCompanion(
      id: Value(id),
      type: Value(type),
      createdAt: Value(createdAt),
      identifierHash: Value(identifierHash),
      data: Value(data),
      width: Value(width),
      height: Value(height),
    );
  }

  factory LibraryEntryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryEntryData(
      id: serializer.fromJson<String>(json['id']),
      type: $LibraryEntryTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      createdAt: serializer.fromJson<BigInt>(json['createdAt']),
      identifierHash: serializer.fromJson<String>(json['identifierHash']),
      data: serializer.fromJson<Uint8List>(json['data']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<int>(
        $LibraryEntryTable.$convertertype.toJson(type),
      ),
      'createdAt': serializer.toJson<BigInt>(createdAt),
      'identifierHash': serializer.toJson<String>(identifierHash),
      'data': serializer.toJson<Uint8List>(data),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
    };
  }

  LibraryEntryData copyWith({
    String? id,
    LibraryEntryType? type,
    BigInt? createdAt,
    String? identifierHash,
    Uint8List? data,
    int? width,
    int? height,
  }) => LibraryEntryData(
    id: id ?? this.id,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
    identifierHash: identifierHash ?? this.identifierHash,
    data: data ?? this.data,
    width: width ?? this.width,
    height: height ?? this.height,
  );
  LibraryEntryData copyWithCompanion(LibraryEntryCompanion data) {
    return LibraryEntryData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      identifierHash:
          data.identifierHash.present
              ? data.identifierHash.value
              : this.identifierHash,
      data: data.data.present ? data.data.value : this.data,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntryData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('identifierHash: $identifierHash, ')
          ..write('data: $data, ')
          ..write('width: $width, ')
          ..write('height: $height')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    createdAt,
    identifierHash,
    $driftBlobEquality.hash(data),
    width,
    height,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryEntryData &&
          other.id == this.id &&
          other.type == this.type &&
          other.createdAt == this.createdAt &&
          other.identifierHash == this.identifierHash &&
          $driftBlobEquality.equals(other.data, this.data) &&
          other.width == this.width &&
          other.height == this.height);
}

class LibraryEntryCompanion extends UpdateCompanion<LibraryEntryData> {
  final Value<String> id;
  final Value<LibraryEntryType> type;
  final Value<BigInt> createdAt;
  final Value<String> identifierHash;
  final Value<Uint8List> data;
  final Value<int> width;
  final Value<int> height;
  final Value<int> rowid;
  const LibraryEntryCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.identifierHash = const Value.absent(),
    this.data = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryEntryCompanion.insert({
    required String id,
    required LibraryEntryType type,
    required BigInt createdAt,
    this.identifierHash = const Value.absent(),
    required Uint8List data,
    required int width,
    required int height,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       createdAt = Value(createdAt),
       data = Value(data),
       width = Value(width),
       height = Value(height);
  static Insertable<LibraryEntryData> custom({
    Expression<String>? id,
    Expression<int>? type,
    Expression<BigInt>? createdAt,
    Expression<String>? identifierHash,
    Expression<Uint8List>? data,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
      if (identifierHash != null) 'identifier_hash': identifierHash,
      if (data != null) 'data': data,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryEntryCompanion copyWith({
    Value<String>? id,
    Value<LibraryEntryType>? type,
    Value<BigInt>? createdAt,
    Value<String>? identifierHash,
    Value<Uint8List>? data,
    Value<int>? width,
    Value<int>? height,
    Value<int>? rowid,
  }) {
    return LibraryEntryCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      identifierHash: identifierHash ?? this.identifierHash,
      data: data ?? this.data,
      width: width ?? this.width,
      height: height ?? this.height,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $LibraryEntryTable.$convertertype.toSql(type.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<BigInt>(createdAt.value);
    }
    if (identifierHash.present) {
      map['identifier_hash'] = Variable<String>(identifierHash.value);
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
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
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('identifierHash: $identifierHash, ')
          ..write('data: $data, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $ConversationTable conversation = $ConversationTable(this);
  late final $MessageTable message = $MessageTable(this);
  late final $SettingTable setting = $SettingTable(this);
  late final $FriendTable friend = $FriendTable(this);
  late final $RequestTable request = $RequestTable(this);
  late final $UnknownProfileTable unknownProfile = $UnknownProfileTable(this);
  late final $ProfileTable profile = $ProfileTable(this);
  late final $TrustedLinkTable trustedLink = $TrustedLinkTable(this);
  late final $LibraryEntryTable libraryEntry = $LibraryEntryTable(this);
  late final Index idxConversationUpdated = Index(
    'idx_conversation_updated',
    'CREATE INDEX idx_conversation_updated ON conversation (updated_at)',
  );
  late final Index idxMessageCreated = Index(
    'idx_message_created',
    'CREATE INDEX idx_message_created ON message (created_at)',
  );
  late final Index idxFriendsUpdated = Index(
    'idx_friends_updated',
    'CREATE INDEX idx_friends_updated ON friend (updated_at)',
  );
  late final Index idxRequestsUpdated = Index(
    'idx_requests_updated',
    'CREATE INDEX idx_requests_updated ON request (updated_at)',
  );
  late final Index idxUnknownProfilesLastFetched = Index(
    'idx_unknown_profiles_last_fetched',
    'CREATE INDEX idx_unknown_profiles_last_fetched ON unknown_profile (last_fetched)',
  );
  late final Index idxLibraryEntryCreated = Index(
    'idx_library_entry_created',
    'CREATE INDEX idx_library_entry_created ON library_entry (created_at)',
  );
  late final Index idxLibraryEntryIdhash = Index(
    'idx_library_entry_idhash',
    'CREATE INDEX idx_library_entry_idhash ON library_entry (identifier_hash)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    conversation,
    message,
    setting,
    friend,
    request,
    unknownProfile,
    profile,
    trustedLink,
    libraryEntry,
    idxConversationUpdated,
    idxMessageCreated,
    idxFriendsUpdated,
    idxRequestsUpdated,
    idxUnknownProfilesLastFetched,
    idxLibraryEntryCreated,
    idxLibraryEntryIdhash,
  ];
}

typedef $$ConversationTableCreateCompanionBuilder =
    ConversationCompanion Function({
      required String id,
      required Uint8List vaultId,
      required ConversationType type,
      required Uint8List data,
      required Uint8List members,
      required Uint8List token,
      required Uint8List key,
      required BigInt lastVersion,
      required BigInt updatedAt,
      required Uint8List reads,
      Value<int> rowid,
    });
typedef $$ConversationTableUpdateCompanionBuilder =
    ConversationCompanion Function({
      Value<String> id,
      Value<Uint8List> vaultId,
      Value<ConversationType> type,
      Value<Uint8List> data,
      Value<Uint8List> members,
      Value<Uint8List> token,
      Value<Uint8List> key,
      Value<BigInt> lastVersion,
      Value<BigInt> updatedAt,
      Value<Uint8List> reads,
      Value<int> rowid,
    });

class $$ConversationTableFilterComposer
    extends Composer<_$Database, $ConversationTable> {
  $$ConversationTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get vaultId => $composableBuilder(
    column: $table.vaultId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ConversationType, ConversationType, int>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<Uint8List> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get members => $composableBuilder(
    column: $table.members,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get lastVersion => $composableBuilder(
    column: $table.lastVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get reads => $composableBuilder(
    column: $table.reads,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConversationTableOrderingComposer
    extends Composer<_$Database, $ConversationTable> {
  $$ConversationTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get vaultId => $composableBuilder(
    column: $table.vaultId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get members => $composableBuilder(
    column: $table.members,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get lastVersion => $composableBuilder(
    column: $table.lastVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get reads => $composableBuilder(
    column: $table.reads,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationTableAnnotationComposer
    extends Composer<_$Database, $ConversationTable> {
  $$ConversationTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get vaultId =>
      $composableBuilder(column: $table.vaultId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ConversationType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<Uint8List> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<Uint8List> get members =>
      $composableBuilder(column: $table.members, builder: (column) => column);

  GeneratedColumn<Uint8List> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<Uint8List> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<BigInt> get lastVersion => $composableBuilder(
    column: $table.lastVersion,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<Uint8List> get reads =>
      $composableBuilder(column: $table.reads, builder: (column) => column);
}

class $$ConversationTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ConversationTable,
          ConversationData,
          $$ConversationTableFilterComposer,
          $$ConversationTableOrderingComposer,
          $$ConversationTableAnnotationComposer,
          $$ConversationTableCreateCompanionBuilder,
          $$ConversationTableUpdateCompanionBuilder,
          (
            ConversationData,
            BaseReferences<_$Database, $ConversationTable, ConversationData>,
          ),
          ConversationData,
          PrefetchHooks Function()
        > {
  $$ConversationTableTableManager(_$Database db, $ConversationTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ConversationTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ConversationTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$ConversationTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Uint8List> vaultId = const Value.absent(),
                Value<ConversationType> type = const Value.absent(),
                Value<Uint8List> data = const Value.absent(),
                Value<Uint8List> members = const Value.absent(),
                Value<Uint8List> token = const Value.absent(),
                Value<Uint8List> key = const Value.absent(),
                Value<BigInt> lastVersion = const Value.absent(),
                Value<BigInt> updatedAt = const Value.absent(),
                Value<Uint8List> reads = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationCompanion(
                id: id,
                vaultId: vaultId,
                type: type,
                data: data,
                members: members,
                token: token,
                key: key,
                lastVersion: lastVersion,
                updatedAt: updatedAt,
                reads: reads,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required Uint8List vaultId,
                required ConversationType type,
                required Uint8List data,
                required Uint8List members,
                required Uint8List token,
                required Uint8List key,
                required BigInt lastVersion,
                required BigInt updatedAt,
                required Uint8List reads,
                Value<int> rowid = const Value.absent(),
              }) => ConversationCompanion.insert(
                id: id,
                vaultId: vaultId,
                type: type,
                data: data,
                members: members,
                token: token,
                key: key,
                lastVersion: lastVersion,
                updatedAt: updatedAt,
                reads: reads,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConversationTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ConversationTable,
      ConversationData,
      $$ConversationTableFilterComposer,
      $$ConversationTableOrderingComposer,
      $$ConversationTableAnnotationComposer,
      $$ConversationTableCreateCompanionBuilder,
      $$ConversationTableUpdateCompanionBuilder,
      (
        ConversationData,
        BaseReferences<_$Database, $ConversationTable, ConversationData>,
      ),
      ConversationData,
      PrefetchHooks Function()
    >;
typedef $$MessageTableCreateCompanionBuilder =
    MessageCompanion Function({
      required String id,
      required Uint8List content,
      required String senderToken,
      required Uint8List senderAddress,
      required BigInt createdAt,
      required String conversation,
      required bool edited,
      required bool verified,
      Value<int> rowid,
    });
typedef $$MessageTableUpdateCompanionBuilder =
    MessageCompanion Function({
      Value<String> id,
      Value<Uint8List> content,
      Value<String> senderToken,
      Value<Uint8List> senderAddress,
      Value<BigInt> createdAt,
      Value<String> conversation,
      Value<bool> edited,
      Value<bool> verified,
      Value<int> rowid,
    });

class $$MessageTableFilterComposer extends Composer<_$Database, $MessageTable> {
  $$MessageTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderToken => $composableBuilder(
    column: $table.senderToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get senderAddress => $composableBuilder(
    column: $table.senderAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversation => $composableBuilder(
    column: $table.conversation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get edited => $composableBuilder(
    column: $table.edited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get verified => $composableBuilder(
    column: $table.verified,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessageTableOrderingComposer
    extends Composer<_$Database, $MessageTable> {
  $$MessageTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderToken => $composableBuilder(
    column: $table.senderToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get senderAddress => $composableBuilder(
    column: $table.senderAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversation => $composableBuilder(
    column: $table.conversation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get edited => $composableBuilder(
    column: $table.edited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get verified => $composableBuilder(
    column: $table.verified,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessageTableAnnotationComposer
    extends Composer<_$Database, $MessageTable> {
  $$MessageTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get senderToken => $composableBuilder(
    column: $table.senderToken,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get senderAddress => $composableBuilder(
    column: $table.senderAddress,
    builder: (column) => column,
  );

  GeneratedColumn<BigInt> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get conversation => $composableBuilder(
    column: $table.conversation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get edited =>
      $composableBuilder(column: $table.edited, builder: (column) => column);

  GeneratedColumn<bool> get verified =>
      $composableBuilder(column: $table.verified, builder: (column) => column);
}

class $$MessageTableTableManager
    extends
        RootTableManager<
          _$Database,
          $MessageTable,
          MessageData,
          $$MessageTableFilterComposer,
          $$MessageTableOrderingComposer,
          $$MessageTableAnnotationComposer,
          $$MessageTableCreateCompanionBuilder,
          $$MessageTableUpdateCompanionBuilder,
          (MessageData, BaseReferences<_$Database, $MessageTable, MessageData>),
          MessageData,
          PrefetchHooks Function()
        > {
  $$MessageTableTableManager(_$Database db, $MessageTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MessageTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MessageTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$MessageTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Uint8List> content = const Value.absent(),
                Value<String> senderToken = const Value.absent(),
                Value<Uint8List> senderAddress = const Value.absent(),
                Value<BigInt> createdAt = const Value.absent(),
                Value<String> conversation = const Value.absent(),
                Value<bool> edited = const Value.absent(),
                Value<bool> verified = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessageCompanion(
                id: id,
                content: content,
                senderToken: senderToken,
                senderAddress: senderAddress,
                createdAt: createdAt,
                conversation: conversation,
                edited: edited,
                verified: verified,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required Uint8List content,
                required String senderToken,
                required Uint8List senderAddress,
                required BigInt createdAt,
                required String conversation,
                required bool edited,
                required bool verified,
                Value<int> rowid = const Value.absent(),
              }) => MessageCompanion.insert(
                id: id,
                content: content,
                senderToken: senderToken,
                senderAddress: senderAddress,
                createdAt: createdAt,
                conversation: conversation,
                edited: edited,
                verified: verified,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessageTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $MessageTable,
      MessageData,
      $$MessageTableFilterComposer,
      $$MessageTableOrderingComposer,
      $$MessageTableAnnotationComposer,
      $$MessageTableCreateCompanionBuilder,
      $$MessageTableUpdateCompanionBuilder,
      (MessageData, BaseReferences<_$Database, $MessageTable, MessageData>),
      MessageData,
      PrefetchHooks Function()
    >;
typedef $$SettingTableCreateCompanionBuilder =
    SettingCompanion Function({
      required String key,
      required Uint8List value,
      Value<int> rowid,
    });
typedef $$SettingTableUpdateCompanionBuilder =
    SettingCompanion Function({
      Value<String> key,
      Value<Uint8List> value,
      Value<int> rowid,
    });

class $$SettingTableFilterComposer extends Composer<_$Database, $SettingTable> {
  $$SettingTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingTableOrderingComposer
    extends Composer<_$Database, $SettingTable> {
  $$SettingTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingTableAnnotationComposer
    extends Composer<_$Database, $SettingTable> {
  $$SettingTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<Uint8List> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingTableTableManager
    extends
        RootTableManager<
          _$Database,
          $SettingTable,
          SettingData,
          $$SettingTableFilterComposer,
          $$SettingTableOrderingComposer,
          $$SettingTableAnnotationComposer,
          $$SettingTableCreateCompanionBuilder,
          $$SettingTableUpdateCompanionBuilder,
          (SettingData, BaseReferences<_$Database, $SettingTable, SettingData>),
          SettingData,
          PrefetchHooks Function()
        > {
  $$SettingTableTableManager(_$Database db, $SettingTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SettingTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SettingTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SettingTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<Uint8List> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required Uint8List value,
                Value<int> rowid = const Value.absent(),
              }) =>
                  SettingCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $SettingTable,
      SettingData,
      $$SettingTableFilterComposer,
      $$SettingTableOrderingComposer,
      $$SettingTableAnnotationComposer,
      $$SettingTableCreateCompanionBuilder,
      $$SettingTableUpdateCompanionBuilder,
      (SettingData, BaseReferences<_$Database, $SettingTable, SettingData>),
      SettingData,
      PrefetchHooks Function()
    >;
typedef $$FriendTableCreateCompanionBuilder =
    FriendCompanion Function({
      required String id,
      required Uint8List name,
      required Uint8List displayName,
      required Uint8List vaultId,
      required Uint8List keys,
      required BigInt updatedAt,
      Value<int> rowid,
    });
typedef $$FriendTableUpdateCompanionBuilder =
    FriendCompanion Function({
      Value<String> id,
      Value<Uint8List> name,
      Value<Uint8List> displayName,
      Value<Uint8List> vaultId,
      Value<Uint8List> keys,
      Value<BigInt> updatedAt,
      Value<int> rowid,
    });

class $$FriendTableFilterComposer extends Composer<_$Database, $FriendTable> {
  $$FriendTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get vaultId => $composableBuilder(
    column: $table.vaultId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get keys => $composableBuilder(
    column: $table.keys,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FriendTableOrderingComposer extends Composer<_$Database, $FriendTable> {
  $$FriendTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get vaultId => $composableBuilder(
    column: $table.vaultId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get keys => $composableBuilder(
    column: $table.keys,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FriendTableAnnotationComposer
    extends Composer<_$Database, $FriendTable> {
  $$FriendTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<Uint8List> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get vaultId =>
      $composableBuilder(column: $table.vaultId, builder: (column) => column);

  GeneratedColumn<Uint8List> get keys =>
      $composableBuilder(column: $table.keys, builder: (column) => column);

  GeneratedColumn<BigInt> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FriendTableTableManager
    extends
        RootTableManager<
          _$Database,
          $FriendTable,
          FriendData,
          $$FriendTableFilterComposer,
          $$FriendTableOrderingComposer,
          $$FriendTableAnnotationComposer,
          $$FriendTableCreateCompanionBuilder,
          $$FriendTableUpdateCompanionBuilder,
          (FriendData, BaseReferences<_$Database, $FriendTable, FriendData>),
          FriendData,
          PrefetchHooks Function()
        > {
  $$FriendTableTableManager(_$Database db, $FriendTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$FriendTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$FriendTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$FriendTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Uint8List> name = const Value.absent(),
                Value<Uint8List> displayName = const Value.absent(),
                Value<Uint8List> vaultId = const Value.absent(),
                Value<Uint8List> keys = const Value.absent(),
                Value<BigInt> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FriendCompanion(
                id: id,
                name: name,
                displayName: displayName,
                vaultId: vaultId,
                keys: keys,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required Uint8List name,
                required Uint8List displayName,
                required Uint8List vaultId,
                required Uint8List keys,
                required BigInt updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FriendCompanion.insert(
                id: id,
                name: name,
                displayName: displayName,
                vaultId: vaultId,
                keys: keys,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FriendTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $FriendTable,
      FriendData,
      $$FriendTableFilterComposer,
      $$FriendTableOrderingComposer,
      $$FriendTableAnnotationComposer,
      $$FriendTableCreateCompanionBuilder,
      $$FriendTableUpdateCompanionBuilder,
      (FriendData, BaseReferences<_$Database, $FriendTable, FriendData>),
      FriendData,
      PrefetchHooks Function()
    >;
typedef $$RequestTableCreateCompanionBuilder =
    RequestCompanion Function({
      required String id,
      required Uint8List name,
      required Uint8List displayName,
      required bool self,
      required Uint8List vaultId,
      required Uint8List keys,
      required BigInt updatedAt,
      Value<int> rowid,
    });
typedef $$RequestTableUpdateCompanionBuilder =
    RequestCompanion Function({
      Value<String> id,
      Value<Uint8List> name,
      Value<Uint8List> displayName,
      Value<bool> self,
      Value<Uint8List> vaultId,
      Value<Uint8List> keys,
      Value<BigInt> updatedAt,
      Value<int> rowid,
    });

class $$RequestTableFilterComposer extends Composer<_$Database, $RequestTable> {
  $$RequestTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get self => $composableBuilder(
    column: $table.self,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get vaultId => $composableBuilder(
    column: $table.vaultId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get keys => $composableBuilder(
    column: $table.keys,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RequestTableOrderingComposer
    extends Composer<_$Database, $RequestTable> {
  $$RequestTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get self => $composableBuilder(
    column: $table.self,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get vaultId => $composableBuilder(
    column: $table.vaultId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get keys => $composableBuilder(
    column: $table.keys,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RequestTableAnnotationComposer
    extends Composer<_$Database, $RequestTable> {
  $$RequestTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<Uint8List> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get self =>
      $composableBuilder(column: $table.self, builder: (column) => column);

  GeneratedColumn<Uint8List> get vaultId =>
      $composableBuilder(column: $table.vaultId, builder: (column) => column);

  GeneratedColumn<Uint8List> get keys =>
      $composableBuilder(column: $table.keys, builder: (column) => column);

  GeneratedColumn<BigInt> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RequestTableTableManager
    extends
        RootTableManager<
          _$Database,
          $RequestTable,
          RequestData,
          $$RequestTableFilterComposer,
          $$RequestTableOrderingComposer,
          $$RequestTableAnnotationComposer,
          $$RequestTableCreateCompanionBuilder,
          $$RequestTableUpdateCompanionBuilder,
          (RequestData, BaseReferences<_$Database, $RequestTable, RequestData>),
          RequestData,
          PrefetchHooks Function()
        > {
  $$RequestTableTableManager(_$Database db, $RequestTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RequestTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$RequestTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$RequestTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Uint8List> name = const Value.absent(),
                Value<Uint8List> displayName = const Value.absent(),
                Value<bool> self = const Value.absent(),
                Value<Uint8List> vaultId = const Value.absent(),
                Value<Uint8List> keys = const Value.absent(),
                Value<BigInt> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestCompanion(
                id: id,
                name: name,
                displayName: displayName,
                self: self,
                vaultId: vaultId,
                keys: keys,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required Uint8List name,
                required Uint8List displayName,
                required bool self,
                required Uint8List vaultId,
                required Uint8List keys,
                required BigInt updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RequestCompanion.insert(
                id: id,
                name: name,
                displayName: displayName,
                self: self,
                vaultId: vaultId,
                keys: keys,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RequestTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $RequestTable,
      RequestData,
      $$RequestTableFilterComposer,
      $$RequestTableOrderingComposer,
      $$RequestTableAnnotationComposer,
      $$RequestTableCreateCompanionBuilder,
      $$RequestTableUpdateCompanionBuilder,
      (RequestData, BaseReferences<_$Database, $RequestTable, RequestData>),
      RequestData,
      PrefetchHooks Function()
    >;
typedef $$UnknownProfileTableCreateCompanionBuilder =
    UnknownProfileCompanion Function({
      required String id,
      required Uint8List name,
      required Uint8List displayName,
      required Uint8List keys,
      Value<DateTime> lastFetched,
      Value<int> rowid,
    });
typedef $$UnknownProfileTableUpdateCompanionBuilder =
    UnknownProfileCompanion Function({
      Value<String> id,
      Value<Uint8List> name,
      Value<Uint8List> displayName,
      Value<Uint8List> keys,
      Value<DateTime> lastFetched,
      Value<int> rowid,
    });

class $$UnknownProfileTableFilterComposer
    extends Composer<_$Database, $UnknownProfileTable> {
  $$UnknownProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get keys => $composableBuilder(
    column: $table.keys,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UnknownProfileTableOrderingComposer
    extends Composer<_$Database, $UnknownProfileTable> {
  $$UnknownProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get keys => $composableBuilder(
    column: $table.keys,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnknownProfileTableAnnotationComposer
    extends Composer<_$Database, $UnknownProfileTable> {
  $$UnknownProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<Uint8List> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get keys =>
      $composableBuilder(column: $table.keys, builder: (column) => column);

  GeneratedColumn<DateTime> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );
}

class $$UnknownProfileTableTableManager
    extends
        RootTableManager<
          _$Database,
          $UnknownProfileTable,
          UnknownProfileData,
          $$UnknownProfileTableFilterComposer,
          $$UnknownProfileTableOrderingComposer,
          $$UnknownProfileTableAnnotationComposer,
          $$UnknownProfileTableCreateCompanionBuilder,
          $$UnknownProfileTableUpdateCompanionBuilder,
          (
            UnknownProfileData,
            BaseReferences<
              _$Database,
              $UnknownProfileTable,
              UnknownProfileData
            >,
          ),
          UnknownProfileData,
          PrefetchHooks Function()
        > {
  $$UnknownProfileTableTableManager(_$Database db, $UnknownProfileTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UnknownProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$UnknownProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$UnknownProfileTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Uint8List> name = const Value.absent(),
                Value<Uint8List> displayName = const Value.absent(),
                Value<Uint8List> keys = const Value.absent(),
                Value<DateTime> lastFetched = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnknownProfileCompanion(
                id: id,
                name: name,
                displayName: displayName,
                keys: keys,
                lastFetched: lastFetched,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required Uint8List name,
                required Uint8List displayName,
                required Uint8List keys,
                Value<DateTime> lastFetched = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnknownProfileCompanion.insert(
                id: id,
                name: name,
                displayName: displayName,
                keys: keys,
                lastFetched: lastFetched,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UnknownProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $UnknownProfileTable,
      UnknownProfileData,
      $$UnknownProfileTableFilterComposer,
      $$UnknownProfileTableOrderingComposer,
      $$UnknownProfileTableAnnotationComposer,
      $$UnknownProfileTableCreateCompanionBuilder,
      $$UnknownProfileTableUpdateCompanionBuilder,
      (
        UnknownProfileData,
        BaseReferences<_$Database, $UnknownProfileTable, UnknownProfileData>,
      ),
      UnknownProfileData,
      PrefetchHooks Function()
    >;
typedef $$ProfileTableCreateCompanionBuilder =
    ProfileCompanion Function({
      required String id,
      Value<Uint8List?> pictureContainer,
      Value<Uint8List?> data,
      Value<int> rowid,
    });
typedef $$ProfileTableUpdateCompanionBuilder =
    ProfileCompanion Function({
      Value<String> id,
      Value<Uint8List?> pictureContainer,
      Value<Uint8List?> data,
      Value<int> rowid,
    });

class $$ProfileTableFilterComposer extends Composer<_$Database, $ProfileTable> {
  $$ProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get pictureContainer => $composableBuilder(
    column: $table.pictureContainer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfileTableOrderingComposer
    extends Composer<_$Database, $ProfileTable> {
  $$ProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get pictureContainer => $composableBuilder(
    column: $table.pictureContainer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfileTableAnnotationComposer
    extends Composer<_$Database, $ProfileTable> {
  $$ProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get pictureContainer => $composableBuilder(
    column: $table.pictureContainer,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$ProfileTableTableManager
    extends
        RootTableManager<
          _$Database,
          $ProfileTable,
          ProfileData,
          $$ProfileTableFilterComposer,
          $$ProfileTableOrderingComposer,
          $$ProfileTableAnnotationComposer,
          $$ProfileTableCreateCompanionBuilder,
          $$ProfileTableUpdateCompanionBuilder,
          (ProfileData, BaseReferences<_$Database, $ProfileTable, ProfileData>),
          ProfileData,
          PrefetchHooks Function()
        > {
  $$ProfileTableTableManager(_$Database db, $ProfileTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Uint8List?> pictureContainer = const Value.absent(),
                Value<Uint8List?> data = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileCompanion(
                id: id,
                pictureContainer: pictureContainer,
                data: data,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<Uint8List?> pictureContainer = const Value.absent(),
                Value<Uint8List?> data = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileCompanion.insert(
                id: id,
                pictureContainer: pictureContainer,
                data: data,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $ProfileTable,
      ProfileData,
      $$ProfileTableFilterComposer,
      $$ProfileTableOrderingComposer,
      $$ProfileTableAnnotationComposer,
      $$ProfileTableCreateCompanionBuilder,
      $$ProfileTableUpdateCompanionBuilder,
      (ProfileData, BaseReferences<_$Database, $ProfileTable, ProfileData>),
      ProfileData,
      PrefetchHooks Function()
    >;
typedef $$TrustedLinkTableCreateCompanionBuilder =
    TrustedLinkCompanion Function({required String domain, Value<int> rowid});
typedef $$TrustedLinkTableUpdateCompanionBuilder =
    TrustedLinkCompanion Function({Value<String> domain, Value<int> rowid});

class $$TrustedLinkTableFilterComposer
    extends Composer<_$Database, $TrustedLinkTable> {
  $$TrustedLinkTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrustedLinkTableOrderingComposer
    extends Composer<_$Database, $TrustedLinkTable> {
  $$TrustedLinkTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrustedLinkTableAnnotationComposer
    extends Composer<_$Database, $TrustedLinkTable> {
  $$TrustedLinkTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);
}

class $$TrustedLinkTableTableManager
    extends
        RootTableManager<
          _$Database,
          $TrustedLinkTable,
          TrustedLinkData,
          $$TrustedLinkTableFilterComposer,
          $$TrustedLinkTableOrderingComposer,
          $$TrustedLinkTableAnnotationComposer,
          $$TrustedLinkTableCreateCompanionBuilder,
          $$TrustedLinkTableUpdateCompanionBuilder,
          (
            TrustedLinkData,
            BaseReferences<_$Database, $TrustedLinkTable, TrustedLinkData>,
          ),
          TrustedLinkData,
          PrefetchHooks Function()
        > {
  $$TrustedLinkTableTableManager(_$Database db, $TrustedLinkTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TrustedLinkTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TrustedLinkTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$TrustedLinkTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> domain = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrustedLinkCompanion(domain: domain, rowid: rowid),
          createCompanionCallback:
              ({
                required String domain,
                Value<int> rowid = const Value.absent(),
              }) => TrustedLinkCompanion.insert(domain: domain, rowid: rowid),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrustedLinkTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $TrustedLinkTable,
      TrustedLinkData,
      $$TrustedLinkTableFilterComposer,
      $$TrustedLinkTableOrderingComposer,
      $$TrustedLinkTableAnnotationComposer,
      $$TrustedLinkTableCreateCompanionBuilder,
      $$TrustedLinkTableUpdateCompanionBuilder,
      (
        TrustedLinkData,
        BaseReferences<_$Database, $TrustedLinkTable, TrustedLinkData>,
      ),
      TrustedLinkData,
      PrefetchHooks Function()
    >;
typedef $$LibraryEntryTableCreateCompanionBuilder =
    LibraryEntryCompanion Function({
      required String id,
      required LibraryEntryType type,
      required BigInt createdAt,
      Value<String> identifierHash,
      required Uint8List data,
      required int width,
      required int height,
      Value<int> rowid,
    });
typedef $$LibraryEntryTableUpdateCompanionBuilder =
    LibraryEntryCompanion Function({
      Value<String> id,
      Value<LibraryEntryType> type,
      Value<BigInt> createdAt,
      Value<String> identifierHash,
      Value<Uint8List> data,
      Value<int> width,
      Value<int> height,
      Value<int> rowid,
    });

class $$LibraryEntryTableFilterComposer
    extends Composer<_$Database, $LibraryEntryTable> {
  $$LibraryEntryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LibraryEntryType, LibraryEntryType, int>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<BigInt> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get identifierHash => $composableBuilder(
    column: $table.identifierHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryEntryTableOrderingComposer
    extends Composer<_$Database, $LibraryEntryTable> {
  $$LibraryEntryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identifierHash => $composableBuilder(
    column: $table.identifierHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryEntryTableAnnotationComposer
    extends Composer<_$Database, $LibraryEntryTable> {
  $$LibraryEntryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LibraryEntryType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<BigInt> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get identifierHash => $composableBuilder(
    column: $table.identifierHash,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);
}

class $$LibraryEntryTableTableManager
    extends
        RootTableManager<
          _$Database,
          $LibraryEntryTable,
          LibraryEntryData,
          $$LibraryEntryTableFilterComposer,
          $$LibraryEntryTableOrderingComposer,
          $$LibraryEntryTableAnnotationComposer,
          $$LibraryEntryTableCreateCompanionBuilder,
          $$LibraryEntryTableUpdateCompanionBuilder,
          (
            LibraryEntryData,
            BaseReferences<_$Database, $LibraryEntryTable, LibraryEntryData>,
          ),
          LibraryEntryData,
          PrefetchHooks Function()
        > {
  $$LibraryEntryTableTableManager(_$Database db, $LibraryEntryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LibraryEntryTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LibraryEntryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$LibraryEntryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<LibraryEntryType> type = const Value.absent(),
                Value<BigInt> createdAt = const Value.absent(),
                Value<String> identifierHash = const Value.absent(),
                Value<Uint8List> data = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryEntryCompanion(
                id: id,
                type: type,
                createdAt: createdAt,
                identifierHash: identifierHash,
                data: data,
                width: width,
                height: height,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required LibraryEntryType type,
                required BigInt createdAt,
                Value<String> identifierHash = const Value.absent(),
                required Uint8List data,
                required int width,
                required int height,
                Value<int> rowid = const Value.absent(),
              }) => LibraryEntryCompanion.insert(
                id: id,
                type: type,
                createdAt: createdAt,
                identifierHash: identifierHash,
                data: data,
                width: width,
                height: height,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryEntryTableProcessedTableManager =
    ProcessedTableManager<
      _$Database,
      $LibraryEntryTable,
      LibraryEntryData,
      $$LibraryEntryTableFilterComposer,
      $$LibraryEntryTableOrderingComposer,
      $$LibraryEntryTableAnnotationComposer,
      $$LibraryEntryTableCreateCompanionBuilder,
      $$LibraryEntryTableUpdateCompanionBuilder,
      (
        LibraryEntryData,
        BaseReferences<_$Database, $LibraryEntryTable, LibraryEntryData>,
      ),
      LibraryEntryData,
      PrefetchHooks Function()
    >;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$ConversationTableTableManager get conversation =>
      $$ConversationTableTableManager(_db, _db.conversation);
  $$MessageTableTableManager get message =>
      $$MessageTableTableManager(_db, _db.message);
  $$SettingTableTableManager get setting =>
      $$SettingTableTableManager(_db, _db.setting);
  $$FriendTableTableManager get friend =>
      $$FriendTableTableManager(_db, _db.friend);
  $$RequestTableTableManager get request =>
      $$RequestTableTableManager(_db, _db.request);
  $$UnknownProfileTableTableManager get unknownProfile =>
      $$UnknownProfileTableTableManager(_db, _db.unknownProfile);
  $$ProfileTableTableManager get profile =>
      $$ProfileTableTableManager(_db, _db.profile);
  $$TrustedLinkTableTableManager get trustedLink =>
      $$TrustedLinkTableTableManager(_db, _db.trustedLink);
  $$LibraryEntryTableTableManager get libraryEntry =>
      $$LibraryEntryTableTableManager(_db, _db.libraryEntry);
}
