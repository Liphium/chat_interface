// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class Conversation extends Table
    with TableInfo<Conversation, ConversationData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Conversation(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> vaultId = GeneratedColumn<String>(
    'vault_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
    'token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<BigInt> lastVersion = GeneratedColumn<BigInt>(
    'last_version',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<BigInt> updatedAt = GeneratedColumn<BigInt>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<BigInt> readAt = GeneratedColumn<BigInt>(
    'read_at',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vaultId,
    type,
    data,
    token,
    key,
    lastVersion,
    updatedAt,
    readAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversation';
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
            DriftSqlType.string,
            data['${effectivePrefix}vault_id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}type'],
          )!,
      data:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}data'],
          )!,
      token:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}token'],
          )!,
      key:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
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
      readAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bigInt,
            data['${effectivePrefix}read_at'],
          )!,
    );
  }

  @override
  Conversation createAlias(String alias) {
    return Conversation(attachedDatabase, alias);
  }
}

class ConversationData extends DataClass
    implements Insertable<ConversationData> {
  final String id;
  final String vaultId;
  final int type;
  final String data;
  final String token;
  final String key;
  final BigInt lastVersion;
  final BigInt updatedAt;
  final BigInt readAt;
  const ConversationData({
    required this.id,
    required this.vaultId,
    required this.type,
    required this.data,
    required this.token,
    required this.key,
    required this.lastVersion,
    required this.updatedAt,
    required this.readAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vault_id'] = Variable<String>(vaultId);
    map['type'] = Variable<int>(type);
    map['data'] = Variable<String>(data);
    map['token'] = Variable<String>(token);
    map['key'] = Variable<String>(key);
    map['last_version'] = Variable<BigInt>(lastVersion);
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
      lastVersion: Value(lastVersion),
      updatedAt: Value(updatedAt),
      readAt: Value(readAt),
    );
  }

  factory ConversationData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationData(
      id: serializer.fromJson<String>(json['id']),
      vaultId: serializer.fromJson<String>(json['vaultId']),
      type: serializer.fromJson<int>(json['type']),
      data: serializer.fromJson<String>(json['data']),
      token: serializer.fromJson<String>(json['token']),
      key: serializer.fromJson<String>(json['key']),
      lastVersion: serializer.fromJson<BigInt>(json['lastVersion']),
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
      'type': serializer.toJson<int>(type),
      'data': serializer.toJson<String>(data),
      'token': serializer.toJson<String>(token),
      'key': serializer.toJson<String>(key),
      'lastVersion': serializer.toJson<BigInt>(lastVersion),
      'updatedAt': serializer.toJson<BigInt>(updatedAt),
      'readAt': serializer.toJson<BigInt>(readAt),
    };
  }

  ConversationData copyWith({
    String? id,
    String? vaultId,
    int? type,
    String? data,
    String? token,
    String? key,
    BigInt? lastVersion,
    BigInt? updatedAt,
    BigInt? readAt,
  }) => ConversationData(
    id: id ?? this.id,
    vaultId: vaultId ?? this.vaultId,
    type: type ?? this.type,
    data: data ?? this.data,
    token: token ?? this.token,
    key: key ?? this.key,
    lastVersion: lastVersion ?? this.lastVersion,
    updatedAt: updatedAt ?? this.updatedAt,
    readAt: readAt ?? this.readAt,
  );
  ConversationData copyWithCompanion(ConversationCompanion data) {
    return ConversationData(
      id: data.id.present ? data.id.value : this.id,
      vaultId: data.vaultId.present ? data.vaultId.value : this.vaultId,
      type: data.type.present ? data.type.value : this.type,
      data: data.data.present ? data.data.value : this.data,
      token: data.token.present ? data.token.value : this.token,
      key: data.key.present ? data.key.value : this.key,
      lastVersion:
          data.lastVersion.present ? data.lastVersion.value : this.lastVersion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationData(')
          ..write('id: $id, ')
          ..write('vaultId: $vaultId, ')
          ..write('type: $type, ')
          ..write('data: $data, ')
          ..write('token: $token, ')
          ..write('key: $key, ')
          ..write('lastVersion: $lastVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vaultId,
    type,
    data,
    token,
    key,
    lastVersion,
    updatedAt,
    readAt,
  );
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
          other.lastVersion == this.lastVersion &&
          other.updatedAt == this.updatedAt &&
          other.readAt == this.readAt);
}

class ConversationCompanion extends UpdateCompanion<ConversationData> {
  final Value<String> id;
  final Value<String> vaultId;
  final Value<int> type;
  final Value<String> data;
  final Value<String> token;
  final Value<String> key;
  final Value<BigInt> lastVersion;
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
    this.lastVersion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationCompanion.insert({
    required String id,
    required String vaultId,
    required int type,
    required String data,
    required String token,
    required String key,
    required BigInt lastVersion,
    required BigInt updatedAt,
    required BigInt readAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vaultId = Value(vaultId),
       type = Value(type),
       data = Value(data),
       token = Value(token),
       key = Value(key),
       lastVersion = Value(lastVersion),
       updatedAt = Value(updatedAt),
       readAt = Value(readAt);
  static Insertable<ConversationData> custom({
    Expression<String>? id,
    Expression<String>? vaultId,
    Expression<int>? type,
    Expression<String>? data,
    Expression<String>? token,
    Expression<String>? key,
    Expression<BigInt>? lastVersion,
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
      if (lastVersion != null) 'last_version': lastVersion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationCompanion copyWith({
    Value<String>? id,
    Value<String>? vaultId,
    Value<int>? type,
    Value<String>? data,
    Value<String>? token,
    Value<String>? key,
    Value<BigInt>? lastVersion,
    Value<BigInt>? updatedAt,
    Value<BigInt>? readAt,
    Value<int>? rowid,
  }) {
    return ConversationCompanion(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      type: type ?? this.type,
      data: data ?? this.data,
      token: token ?? this.token,
      key: key ?? this.key,
      lastVersion: lastVersion ?? this.lastVersion,
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
      map['type'] = Variable<int>(type.value);
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
    if (lastVersion.present) {
      map['last_version'] = Variable<BigInt>(lastVersion.value);
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
          ..write('lastVersion: $lastVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Message extends Table with TableInfo<Message, MessageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Message(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> senderToken = GeneratedColumn<String>(
    'sender_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> senderAddress = GeneratedColumn<String>(
    'sender_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<BigInt> createdAt = GeneratedColumn<BigInt>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> conversation = GeneratedColumn<String>(
    'conversation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
            DriftSqlType.string,
            data['${effectivePrefix}content'],
          )!,
      senderToken:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}sender_token'],
          )!,
      senderAddress:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
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
  Message createAlias(String alias) {
    return Message(attachedDatabase, alias);
  }
}

class MessageData extends DataClass implements Insertable<MessageData> {
  final String id;
  final String content;
  final String senderToken;
  final String senderAddress;
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
    map['content'] = Variable<String>(content);
    map['sender_token'] = Variable<String>(senderToken);
    map['sender_address'] = Variable<String>(senderAddress);
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
      content: serializer.fromJson<String>(json['content']),
      senderToken: serializer.fromJson<String>(json['senderToken']),
      senderAddress: serializer.fromJson<String>(json['senderAddress']),
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
      'content': serializer.toJson<String>(content),
      'senderToken': serializer.toJson<String>(senderToken),
      'senderAddress': serializer.toJson<String>(senderAddress),
      'createdAt': serializer.toJson<BigInt>(createdAt),
      'conversation': serializer.toJson<String>(conversation),
      'edited': serializer.toJson<bool>(edited),
      'verified': serializer.toJson<bool>(verified),
    };
  }

  MessageData copyWith({
    String? id,
    String? content,
    String? senderToken,
    String? senderAddress,
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
    content,
    senderToken,
    senderAddress,
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
          other.content == this.content &&
          other.senderToken == this.senderToken &&
          other.senderAddress == this.senderAddress &&
          other.createdAt == this.createdAt &&
          other.conversation == this.conversation &&
          other.edited == this.edited &&
          other.verified == this.verified);
}

class MessageCompanion extends UpdateCompanion<MessageData> {
  final Value<String> id;
  final Value<String> content;
  final Value<String> senderToken;
  final Value<String> senderAddress;
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
    required String content,
    required String senderToken,
    required String senderAddress,
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
    Expression<String>? content,
    Expression<String>? senderToken,
    Expression<String>? senderAddress,
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
    Value<String>? content,
    Value<String>? senderToken,
    Value<String>? senderAddress,
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
      map['content'] = Variable<String>(content.value);
    }
    if (senderToken.present) {
      map['sender_token'] = Variable<String>(senderToken.value);
    }
    if (senderAddress.present) {
      map['sender_address'] = Variable<String>(senderAddress.value);
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

class Member extends Table with TableInfo<Member, MemberData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Member(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> roleId = GeneratedColumn<int>(
    'role_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, conversationId, accountId, roleId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'member';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemberData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemberData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      ),
      accountId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}account_id'],
          )!,
      roleId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}role_id'],
          )!,
    );
  }

  @override
  Member createAlias(String alias) {
    return Member(attachedDatabase, alias);
  }
}

class MemberData extends DataClass implements Insertable<MemberData> {
  final String id;
  final String? conversationId;
  final String accountId;
  final int roleId;
  const MemberData({
    required this.id,
    this.conversationId,
    required this.accountId,
    required this.roleId,
  });
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
      conversationId:
          conversationId == null && nullToAbsent
              ? const Value.absent()
              : Value(conversationId),
      accountId: Value(accountId),
      roleId: Value(roleId),
    );
  }

  factory MemberData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  MemberData copyWith({
    String? id,
    Value<String?> conversationId = const Value.absent(),
    String? accountId,
    int? roleId,
  }) => MemberData(
    id: id ?? this.id,
    conversationId:
        conversationId.present ? conversationId.value : this.conversationId,
    accountId: accountId ?? this.accountId,
    roleId: roleId ?? this.roleId,
  );
  MemberData copyWithCompanion(MemberCompanion data) {
    return MemberData(
      id: data.id.present ? data.id.value : this.id,
      conversationId:
          data.conversationId.present
              ? data.conversationId.value
              : this.conversationId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
    );
  }

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
  }) : id = Value(id),
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

  MemberCompanion copyWith({
    Value<String>? id,
    Value<String?>? conversationId,
    Value<String>? accountId,
    Value<int>? roleId,
    Value<int>? rowid,
  }) {
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

class Setting extends Table with TableInfo<Setting, SettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Setting(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
            DriftSqlType.string,
            data['${effectivePrefix}value'],
          )!,
    );
  }

  @override
  Setting createAlias(String alias) {
    return Setting(attachedDatabase, alias);
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
    return SettingCompanion(key: Value(key), value: Value(value));
  }

  factory SettingData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  SettingData copyWith({String? key, String? value}) =>
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
  }) : key = Value(key),
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

  SettingCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
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

class Friend extends Table with TableInfo<Friend, FriendData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Friend(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> vaultId = GeneratedColumn<String>(
    'vault_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> keys = GeneratedColumn<String>(
    'keys',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      displayName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}display_name'],
          )!,
      vaultId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vault_id'],
          )!,
      keys:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
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
  Friend createAlias(String alias) {
    return Friend(attachedDatabase, alias);
  }
}

class FriendData extends DataClass implements Insertable<FriendData> {
  final String id;
  final String name;
  final String displayName;
  final String vaultId;
  final String keys;
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
    map['name'] = Variable<String>(name);
    map['display_name'] = Variable<String>(displayName);
    map['vault_id'] = Variable<String>(vaultId);
    map['keys'] = Variable<String>(keys);
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
      name: serializer.fromJson<String>(json['name']),
      displayName: serializer.fromJson<String>(json['displayName']),
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
      'displayName': serializer.toJson<String>(displayName),
      'vaultId': serializer.toJson<String>(vaultId),
      'keys': serializer.toJson<String>(keys),
      'updatedAt': serializer.toJson<BigInt>(updatedAt),
    };
  }

  FriendData copyWith({
    String? id,
    String? name,
    String? displayName,
    String? vaultId,
    String? keys,
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
  int get hashCode =>
      Object.hash(id, name, displayName, vaultId, keys, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FriendData &&
          other.id == this.id &&
          other.name == this.name &&
          other.displayName == this.displayName &&
          other.vaultId == this.vaultId &&
          other.keys == this.keys &&
          other.updatedAt == this.updatedAt);
}

class FriendCompanion extends UpdateCompanion<FriendData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> displayName;
  final Value<String> vaultId;
  final Value<String> keys;
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
    required String name,
    required String displayName,
    required String vaultId,
    required String keys,
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
    Expression<String>? name,
    Expression<String>? displayName,
    Expression<String>? vaultId,
    Expression<String>? keys,
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
    Value<String>? name,
    Value<String>? displayName,
    Value<String>? vaultId,
    Value<String>? keys,
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
      map['name'] = Variable<String>(name.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
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
          ..write('displayName: $displayName, ')
          ..write('vaultId: $vaultId, ')
          ..write('keys: $keys, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Request extends Table with TableInfo<Request, RequestData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Request(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
  late final GeneratedColumn<String> vaultId = GeneratedColumn<String>(
    'vault_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> keys = GeneratedColumn<String>(
    'keys',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
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
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      displayName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}display_name'],
          )!,
      self:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}self'],
          )!,
      vaultId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}vault_id'],
          )!,
      keys:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
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
  Request createAlias(String alias) {
    return Request(attachedDatabase, alias);
  }
}

class RequestData extends DataClass implements Insertable<RequestData> {
  final String id;
  final String name;
  final String displayName;
  final bool self;
  final String vaultId;
  final String keys;
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
    map['name'] = Variable<String>(name);
    map['display_name'] = Variable<String>(displayName);
    map['self'] = Variable<bool>(self);
    map['vault_id'] = Variable<String>(vaultId);
    map['keys'] = Variable<String>(keys);
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
      name: serializer.fromJson<String>(json['name']),
      displayName: serializer.fromJson<String>(json['displayName']),
      self: serializer.fromJson<bool>(json['self']),
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
      'displayName': serializer.toJson<String>(displayName),
      'self': serializer.toJson<bool>(self),
      'vaultId': serializer.toJson<String>(vaultId),
      'keys': serializer.toJson<String>(keys),
      'updatedAt': serializer.toJson<BigInt>(updatedAt),
    };
  }

  RequestData copyWith({
    String? id,
    String? name,
    String? displayName,
    bool? self,
    String? vaultId,
    String? keys,
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
  int get hashCode =>
      Object.hash(id, name, displayName, self, vaultId, keys, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RequestData &&
          other.id == this.id &&
          other.name == this.name &&
          other.displayName == this.displayName &&
          other.self == this.self &&
          other.vaultId == this.vaultId &&
          other.keys == this.keys &&
          other.updatedAt == this.updatedAt);
}

class RequestCompanion extends UpdateCompanion<RequestData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> displayName;
  final Value<bool> self;
  final Value<String> vaultId;
  final Value<String> keys;
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
    required String name,
    required String displayName,
    required bool self,
    required String vaultId,
    required String keys,
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
    Expression<String>? name,
    Expression<String>? displayName,
    Expression<bool>? self,
    Expression<String>? vaultId,
    Expression<String>? keys,
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
    Value<String>? name,
    Value<String>? displayName,
    Value<bool>? self,
    Value<String>? vaultId,
    Value<String>? keys,
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
      map['name'] = Variable<String>(name.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (self.present) {
      map['self'] = Variable<bool>(self.value);
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

class UnknownProfile extends Table
    with TableInfo<UnknownProfile, UnknownProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  UnknownProfile(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> keys = GeneratedColumn<String>(
    'keys',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<DateTime> lastFetched = GeneratedColumn<DateTime>(
    'last_fetched',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('0'),
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
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      displayName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}display_name'],
          )!,
      keys:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
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
  UnknownProfile createAlias(String alias) {
    return UnknownProfile(attachedDatabase, alias);
  }
}

class UnknownProfileData extends DataClass
    implements Insertable<UnknownProfileData> {
  final String id;
  final String name;
  final String displayName;
  final String keys;
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
    map['name'] = Variable<String>(name);
    map['display_name'] = Variable<String>(displayName);
    map['keys'] = Variable<String>(keys);
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
      name: serializer.fromJson<String>(json['name']),
      displayName: serializer.fromJson<String>(json['displayName']),
      keys: serializer.fromJson<String>(json['keys']),
      lastFetched: serializer.fromJson<DateTime>(json['lastFetched']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'displayName': serializer.toJson<String>(displayName),
      'keys': serializer.toJson<String>(keys),
      'lastFetched': serializer.toJson<DateTime>(lastFetched),
    };
  }

  UnknownProfileData copyWith({
    String? id,
    String? name,
    String? displayName,
    String? keys,
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
  int get hashCode => Object.hash(id, name, displayName, keys, lastFetched);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnknownProfileData &&
          other.id == this.id &&
          other.name == this.name &&
          other.displayName == this.displayName &&
          other.keys == this.keys &&
          other.lastFetched == this.lastFetched);
}

class UnknownProfileCompanion extends UpdateCompanion<UnknownProfileData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> displayName;
  final Value<String> keys;
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
    required String name,
    required String displayName,
    required String keys,
    this.lastFetched = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       displayName = Value(displayName),
       keys = Value(keys);
  static Insertable<UnknownProfileData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? displayName,
    Expression<String>? keys,
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
    Value<String>? name,
    Value<String>? displayName,
    Value<String>? keys,
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
      map['name'] = Variable<String>(name.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (keys.present) {
      map['keys'] = Variable<String>(keys.value);
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

class Profile extends Table with TableInfo<Profile, ProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Profile(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> pictureContainer = GeneratedColumn<String>(
    'picture_container',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, pictureContainer, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile';
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
      pictureContainer:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}picture_container'],
          )!,
      data:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}data'],
          )!,
    );
  }

  @override
  Profile createAlias(String alias) {
    return Profile(attachedDatabase, alias);
  }
}

class ProfileData extends DataClass implements Insertable<ProfileData> {
  final String id;
  final String pictureContainer;
  final String data;
  const ProfileData({
    required this.id,
    required this.pictureContainer,
    required this.data,
  });
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

  factory ProfileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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
  }) : id = Value(id),
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

  ProfileCompanion copyWith({
    Value<String>? id,
    Value<String>? pictureContainer,
    Value<String>? data,
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

class TrustedLink extends Table with TableInfo<TrustedLink, TrustedLinkData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TrustedLink(this.attachedDatabase, [this._alias]);
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
  TrustedLink createAlias(String alias) {
    return TrustedLink(attachedDatabase, alias);
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

class LibraryEntry extends Table
    with TableInfo<LibraryEntry, LibraryEntryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LibraryEntry(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<BigInt> createdAt = GeneratedColumn<BigInt>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<String> identifierHash = GeneratedColumn<String>(
    'identifier_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression('\'to-migrate\''),
  );
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
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
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}type'],
          )!,
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
            DriftSqlType.string,
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
  LibraryEntry createAlias(String alias) {
    return LibraryEntry(attachedDatabase, alias);
  }
}

class LibraryEntryData extends DataClass
    implements Insertable<LibraryEntryData> {
  final String id;
  final int type;
  final BigInt createdAt;
  final String identifierHash;
  final String data;
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
    map['type'] = Variable<int>(type);
    map['created_at'] = Variable<BigInt>(createdAt);
    map['identifier_hash'] = Variable<String>(identifierHash);
    map['data'] = Variable<String>(data);
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
      type: serializer.fromJson<int>(json['type']),
      createdAt: serializer.fromJson<BigInt>(json['createdAt']),
      identifierHash: serializer.fromJson<String>(json['identifierHash']),
      data: serializer.fromJson<String>(json['data']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<int>(type),
      'createdAt': serializer.toJson<BigInt>(createdAt),
      'identifierHash': serializer.toJson<String>(identifierHash),
      'data': serializer.toJson<String>(data),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
    };
  }

  LibraryEntryData copyWith({
    String? id,
    int? type,
    BigInt? createdAt,
    String? identifierHash,
    String? data,
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
  int get hashCode =>
      Object.hash(id, type, createdAt, identifierHash, data, width, height);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryEntryData &&
          other.id == this.id &&
          other.type == this.type &&
          other.createdAt == this.createdAt &&
          other.identifierHash == this.identifierHash &&
          other.data == this.data &&
          other.width == this.width &&
          other.height == this.height);
}

class LibraryEntryCompanion extends UpdateCompanion<LibraryEntryData> {
  final Value<String> id;
  final Value<int> type;
  final Value<BigInt> createdAt;
  final Value<String> identifierHash;
  final Value<String> data;
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
    required int type,
    required BigInt createdAt,
    this.identifierHash = const Value.absent(),
    required String data,
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
    Expression<String>? data,
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
    Value<int>? type,
    Value<BigInt>? createdAt,
    Value<String>? identifierHash,
    Value<String>? data,
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
      map['type'] = Variable<int>(type.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<BigInt>(createdAt.value);
    }
    if (identifierHash.present) {
      map['identifier_hash'] = Variable<String>(identifierHash.value);
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

class DatabaseAtV4 extends GeneratedDatabase {
  DatabaseAtV4(QueryExecutor e) : super(e);
  late final Conversation conversation = Conversation(this);
  late final Message message = Message(this);
  late final Member member = Member(this);
  late final Setting setting = Setting(this);
  late final Friend friend = Friend(this);
  late final Request request = Request(this);
  late final UnknownProfile unknownProfile = UnknownProfile(this);
  late final Profile profile = Profile(this);
  late final TrustedLink trustedLink = TrustedLink(this);
  late final LibraryEntry libraryEntry = LibraryEntry(this);
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
    member,
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
  @override
  int get schemaVersion => 4;
}
