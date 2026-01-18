// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CompaniesTable extends Companies
    with TableInfo<$CompaniesTable, Company> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompaniesTable(this.attachedDatabase, [this._alias]);
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
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Company> instance, {
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
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  Company map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Company(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CompaniesTable createAlias(String alias) {
    return $CompaniesTable(attachedDatabase, alias);
  }
}

class Company extends DataClass implements Insertable<Company> {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Company({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CompaniesCompanion toCompanion(bool nullToAbsent) {
    return CompaniesCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Company.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Company(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Company copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Company(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Company copyWithCompanion(CompaniesCompanion data) {
    return Company(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Company(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Company &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CompaniesCompanion extends UpdateCompanion<Company> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CompaniesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompaniesCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Company> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompaniesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CompaniesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompaniesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StakeholdersTable extends Stakeholders
    with TableInfo<$StakeholdersTable, Stakeholder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StakeholdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasProRataRightsMeta = const VerificationMeta(
    'hasProRataRights',
  );
  @override
  late final GeneratedColumn<bool> hasProRataRights = GeneratedColumn<bool>(
    'has_pro_rata_rights',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_pro_rata_rights" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    type,
    email,
    phone,
    company,
    hasProRataRights,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stakeholders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Stakeholder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('has_pro_rata_rights')) {
      context.handle(
        _hasProRataRightsMeta,
        hasProRataRights.isAcceptableOrUnknown(
          data['has_pro_rata_rights']!,
          _hasProRataRightsMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  Stakeholder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Stakeholder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      ),
      hasProRataRights: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_pro_rata_rights'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StakeholdersTable createAlias(String alias) {
    return $StakeholdersTable(attachedDatabase, alias);
  }
}

class Stakeholder extends DataClass implements Insertable<Stakeholder> {
  final String id;
  final String companyId;
  final String name;
  final String type;
  final String? email;
  final String? phone;
  final String? company;
  final bool hasProRataRights;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Stakeholder({
    required this.id,
    required this.companyId,
    required this.name,
    required this.type,
    this.email,
    this.phone,
    this.company,
    required this.hasProRataRights,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || company != null) {
      map['company'] = Variable<String>(company);
    }
    map['has_pro_rata_rights'] = Variable<bool>(hasProRataRights);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StakeholdersCompanion toCompanion(bool nullToAbsent) {
    return StakeholdersCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      type: Value(type),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      company: company == null && nullToAbsent
          ? const Value.absent()
          : Value(company),
      hasProRataRights: Value(hasProRataRights),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Stakeholder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Stakeholder(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      company: serializer.fromJson<String?>(json['company']),
      hasProRataRights: serializer.fromJson<bool>(json['hasProRataRights']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'company': serializer.toJson<String?>(company),
      'hasProRataRights': serializer.toJson<bool>(hasProRataRights),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Stakeholder copyWith({
    String? id,
    String? companyId,
    String? name,
    String? type,
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> company = const Value.absent(),
    bool? hasProRataRights,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Stakeholder(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    type: type ?? this.type,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    company: company.present ? company.value : this.company,
    hasProRataRights: hasProRataRights ?? this.hasProRataRights,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Stakeholder copyWithCompanion(StakeholdersCompanion data) {
    return Stakeholder(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      company: data.company.present ? data.company.value : this.company,
      hasProRataRights: data.hasProRataRights.present
          ? data.hasProRataRights.value
          : this.hasProRataRights,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Stakeholder(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('company: $company, ')
          ..write('hasProRataRights: $hasProRataRights, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    name,
    type,
    email,
    phone,
    company,
    hasProRataRights,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Stakeholder &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.type == this.type &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.company == this.company &&
          other.hasProRataRights == this.hasProRataRights &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StakeholdersCompanion extends UpdateCompanion<Stakeholder> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> company;
  final Value<bool> hasProRataRights;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StakeholdersCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.company = const Value.absent(),
    this.hasProRataRights = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StakeholdersCompanion.insert({
    required String id,
    required String companyId,
    required String name,
    required String type,
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.company = const Value.absent(),
    this.hasProRataRights = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       name = Value(name),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Stakeholder> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? company,
    Expression<bool>? hasProRataRights,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (company != null) 'company': company,
      if (hasProRataRights != null) 'has_pro_rata_rights': hasProRataRights,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StakeholdersCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String?>? company,
    Value<bool>? hasProRataRights,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return StakeholdersCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      type: type ?? this.type,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      hasProRataRights: hasProRataRights ?? this.hasProRataRights,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (hasProRataRights.present) {
      map['has_pro_rata_rights'] = Variable<bool>(hasProRataRights.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StakeholdersCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('company: $company, ')
          ..write('hasProRataRights: $hasProRataRights, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShareClassesTable extends ShareClasses
    with TableInfo<$ShareClassesTable, ShareClassesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShareClassesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _votingMultiplierMeta = const VerificationMeta(
    'votingMultiplier',
  );
  @override
  late final GeneratedColumn<double> votingMultiplier = GeneratedColumn<double>(
    'voting_multiplier',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _liquidationPreferenceMeta =
      const VerificationMeta('liquidationPreference');
  @override
  late final GeneratedColumn<double> liquidationPreference =
      GeneratedColumn<double>(
        'liquidation_preference',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1.0),
      );
  static const VerificationMeta _isParticipatingMeta = const VerificationMeta(
    'isParticipating',
  );
  @override
  late final GeneratedColumn<bool> isParticipating = GeneratedColumn<bool>(
    'is_participating',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_participating" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dividendRateMeta = const VerificationMeta(
    'dividendRate',
  );
  @override
  late final GeneratedColumn<double> dividendRate = GeneratedColumn<double>(
    'dividend_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _seniorityMeta = const VerificationMeta(
    'seniority',
  );
  @override
  late final GeneratedColumn<int> seniority = GeneratedColumn<int>(
    'seniority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _antiDilutionTypeMeta = const VerificationMeta(
    'antiDilutionType',
  );
  @override
  late final GeneratedColumn<String> antiDilutionType = GeneratedColumn<String>(
    'anti_dilution_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    type,
    votingMultiplier,
    liquidationPreference,
    isParticipating,
    dividendRate,
    seniority,
    antiDilutionType,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'share_classes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShareClassesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('voting_multiplier')) {
      context.handle(
        _votingMultiplierMeta,
        votingMultiplier.isAcceptableOrUnknown(
          data['voting_multiplier']!,
          _votingMultiplierMeta,
        ),
      );
    }
    if (data.containsKey('liquidation_preference')) {
      context.handle(
        _liquidationPreferenceMeta,
        liquidationPreference.isAcceptableOrUnknown(
          data['liquidation_preference']!,
          _liquidationPreferenceMeta,
        ),
      );
    }
    if (data.containsKey('is_participating')) {
      context.handle(
        _isParticipatingMeta,
        isParticipating.isAcceptableOrUnknown(
          data['is_participating']!,
          _isParticipatingMeta,
        ),
      );
    }
    if (data.containsKey('dividend_rate')) {
      context.handle(
        _dividendRateMeta,
        dividendRate.isAcceptableOrUnknown(
          data['dividend_rate']!,
          _dividendRateMeta,
        ),
      );
    }
    if (data.containsKey('seniority')) {
      context.handle(
        _seniorityMeta,
        seniority.isAcceptableOrUnknown(data['seniority']!, _seniorityMeta),
      );
    }
    if (data.containsKey('anti_dilution_type')) {
      context.handle(
        _antiDilutionTypeMeta,
        antiDilutionType.isAcceptableOrUnknown(
          data['anti_dilution_type']!,
          _antiDilutionTypeMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  ShareClassesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShareClassesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      votingMultiplier: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}voting_multiplier'],
      )!,
      liquidationPreference: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}liquidation_preference'],
      )!,
      isParticipating: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_participating'],
      )!,
      dividendRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dividend_rate'],
      )!,
      seniority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seniority'],
      )!,
      antiDilutionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anti_dilution_type'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ShareClassesTable createAlias(String alias) {
    return $ShareClassesTable(attachedDatabase, alias);
  }
}

class ShareClassesData extends DataClass
    implements Insertable<ShareClassesData> {
  final String id;
  final String companyId;
  final String name;
  final String type;
  final double votingMultiplier;
  final double liquidationPreference;
  final bool isParticipating;
  final double dividendRate;
  final int seniority;

  /// Anti-dilution protection type: 'none', 'fullRatchet', 'broadBasedWeightedAverage', 'narrowBasedWeightedAverage'
  final String antiDilutionType;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ShareClassesData({
    required this.id,
    required this.companyId,
    required this.name,
    required this.type,
    required this.votingMultiplier,
    required this.liquidationPreference,
    required this.isParticipating,
    required this.dividendRate,
    required this.seniority,
    required this.antiDilutionType,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['voting_multiplier'] = Variable<double>(votingMultiplier);
    map['liquidation_preference'] = Variable<double>(liquidationPreference);
    map['is_participating'] = Variable<bool>(isParticipating);
    map['dividend_rate'] = Variable<double>(dividendRate);
    map['seniority'] = Variable<int>(seniority);
    map['anti_dilution_type'] = Variable<String>(antiDilutionType);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ShareClassesCompanion toCompanion(bool nullToAbsent) {
    return ShareClassesCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      type: Value(type),
      votingMultiplier: Value(votingMultiplier),
      liquidationPreference: Value(liquidationPreference),
      isParticipating: Value(isParticipating),
      dividendRate: Value(dividendRate),
      seniority: Value(seniority),
      antiDilutionType: Value(antiDilutionType),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ShareClassesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShareClassesData(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      votingMultiplier: serializer.fromJson<double>(json['votingMultiplier']),
      liquidationPreference: serializer.fromJson<double>(
        json['liquidationPreference'],
      ),
      isParticipating: serializer.fromJson<bool>(json['isParticipating']),
      dividendRate: serializer.fromJson<double>(json['dividendRate']),
      seniority: serializer.fromJson<int>(json['seniority']),
      antiDilutionType: serializer.fromJson<String>(json['antiDilutionType']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'votingMultiplier': serializer.toJson<double>(votingMultiplier),
      'liquidationPreference': serializer.toJson<double>(liquidationPreference),
      'isParticipating': serializer.toJson<bool>(isParticipating),
      'dividendRate': serializer.toJson<double>(dividendRate),
      'seniority': serializer.toJson<int>(seniority),
      'antiDilutionType': serializer.toJson<String>(antiDilutionType),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ShareClassesData copyWith({
    String? id,
    String? companyId,
    String? name,
    String? type,
    double? votingMultiplier,
    double? liquidationPreference,
    bool? isParticipating,
    double? dividendRate,
    int? seniority,
    String? antiDilutionType,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ShareClassesData(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    type: type ?? this.type,
    votingMultiplier: votingMultiplier ?? this.votingMultiplier,
    liquidationPreference: liquidationPreference ?? this.liquidationPreference,
    isParticipating: isParticipating ?? this.isParticipating,
    dividendRate: dividendRate ?? this.dividendRate,
    seniority: seniority ?? this.seniority,
    antiDilutionType: antiDilutionType ?? this.antiDilutionType,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ShareClassesData copyWithCompanion(ShareClassesCompanion data) {
    return ShareClassesData(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      votingMultiplier: data.votingMultiplier.present
          ? data.votingMultiplier.value
          : this.votingMultiplier,
      liquidationPreference: data.liquidationPreference.present
          ? data.liquidationPreference.value
          : this.liquidationPreference,
      isParticipating: data.isParticipating.present
          ? data.isParticipating.value
          : this.isParticipating,
      dividendRate: data.dividendRate.present
          ? data.dividendRate.value
          : this.dividendRate,
      seniority: data.seniority.present ? data.seniority.value : this.seniority,
      antiDilutionType: data.antiDilutionType.present
          ? data.antiDilutionType.value
          : this.antiDilutionType,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShareClassesData(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('votingMultiplier: $votingMultiplier, ')
          ..write('liquidationPreference: $liquidationPreference, ')
          ..write('isParticipating: $isParticipating, ')
          ..write('dividendRate: $dividendRate, ')
          ..write('seniority: $seniority, ')
          ..write('antiDilutionType: $antiDilutionType, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    name,
    type,
    votingMultiplier,
    liquidationPreference,
    isParticipating,
    dividendRate,
    seniority,
    antiDilutionType,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShareClassesData &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.type == this.type &&
          other.votingMultiplier == this.votingMultiplier &&
          other.liquidationPreference == this.liquidationPreference &&
          other.isParticipating == this.isParticipating &&
          other.dividendRate == this.dividendRate &&
          other.seniority == this.seniority &&
          other.antiDilutionType == this.antiDilutionType &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ShareClassesCompanion extends UpdateCompanion<ShareClassesData> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> name;
  final Value<String> type;
  final Value<double> votingMultiplier;
  final Value<double> liquidationPreference;
  final Value<bool> isParticipating;
  final Value<double> dividendRate;
  final Value<int> seniority;
  final Value<String> antiDilutionType;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ShareClassesCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.votingMultiplier = const Value.absent(),
    this.liquidationPreference = const Value.absent(),
    this.isParticipating = const Value.absent(),
    this.dividendRate = const Value.absent(),
    this.seniority = const Value.absent(),
    this.antiDilutionType = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShareClassesCompanion.insert({
    required String id,
    required String companyId,
    required String name,
    required String type,
    this.votingMultiplier = const Value.absent(),
    this.liquidationPreference = const Value.absent(),
    this.isParticipating = const Value.absent(),
    this.dividendRate = const Value.absent(),
    this.seniority = const Value.absent(),
    this.antiDilutionType = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       name = Value(name),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ShareClassesData> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? votingMultiplier,
    Expression<double>? liquidationPreference,
    Expression<bool>? isParticipating,
    Expression<double>? dividendRate,
    Expression<int>? seniority,
    Expression<String>? antiDilutionType,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (votingMultiplier != null) 'voting_multiplier': votingMultiplier,
      if (liquidationPreference != null)
        'liquidation_preference': liquidationPreference,
      if (isParticipating != null) 'is_participating': isParticipating,
      if (dividendRate != null) 'dividend_rate': dividendRate,
      if (seniority != null) 'seniority': seniority,
      if (antiDilutionType != null) 'anti_dilution_type': antiDilutionType,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShareClassesCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? name,
    Value<String>? type,
    Value<double>? votingMultiplier,
    Value<double>? liquidationPreference,
    Value<bool>? isParticipating,
    Value<double>? dividendRate,
    Value<int>? seniority,
    Value<String>? antiDilutionType,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ShareClassesCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      type: type ?? this.type,
      votingMultiplier: votingMultiplier ?? this.votingMultiplier,
      liquidationPreference:
          liquidationPreference ?? this.liquidationPreference,
      isParticipating: isParticipating ?? this.isParticipating,
      dividendRate: dividendRate ?? this.dividendRate,
      seniority: seniority ?? this.seniority,
      antiDilutionType: antiDilutionType ?? this.antiDilutionType,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (votingMultiplier.present) {
      map['voting_multiplier'] = Variable<double>(votingMultiplier.value);
    }
    if (liquidationPreference.present) {
      map['liquidation_preference'] = Variable<double>(
        liquidationPreference.value,
      );
    }
    if (isParticipating.present) {
      map['is_participating'] = Variable<bool>(isParticipating.value);
    }
    if (dividendRate.present) {
      map['dividend_rate'] = Variable<double>(dividendRate.value);
    }
    if (seniority.present) {
      map['seniority'] = Variable<int>(seniority.value);
    }
    if (antiDilutionType.present) {
      map['anti_dilution_type'] = Variable<String>(antiDilutionType.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShareClassesCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('votingMultiplier: $votingMultiplier, ')
          ..write('liquidationPreference: $liquidationPreference, ')
          ..write('isParticipating: $isParticipating, ')
          ..write('dividendRate: $dividendRate, ')
          ..write('seniority: $seniority, ')
          ..write('antiDilutionType: $antiDilutionType, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoundsTable extends Rounds with TableInfo<$RoundsTable, Round> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoundsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preMoneyValuationMeta = const VerificationMeta(
    'preMoneyValuation',
  );
  @override
  late final GeneratedColumn<double> preMoneyValuation =
      GeneratedColumn<double>(
        'pre_money_valuation',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pricePerShareMeta = const VerificationMeta(
    'pricePerShare',
  );
  @override
  late final GeneratedColumn<double> pricePerShare = GeneratedColumn<double>(
    'price_per_share',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountRaisedMeta = const VerificationMeta(
    'amountRaised',
  );
  @override
  late final GeneratedColumn<double> amountRaised = GeneratedColumn<double>(
    'amount_raised',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _leadInvestorIdMeta = const VerificationMeta(
    'leadInvestorId',
  );
  @override
  late final GeneratedColumn<String> leadInvestorId = GeneratedColumn<String>(
    'lead_investor_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stakeholders (id)',
    ),
  );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    type,
    status,
    date,
    preMoneyValuation,
    pricePerShare,
    amountRaised,
    leadInvestorId,
    displayOrder,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rounds';
  @override
  VerificationContext validateIntegrity(
    Insertable<Round> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('pre_money_valuation')) {
      context.handle(
        _preMoneyValuationMeta,
        preMoneyValuation.isAcceptableOrUnknown(
          data['pre_money_valuation']!,
          _preMoneyValuationMeta,
        ),
      );
    }
    if (data.containsKey('price_per_share')) {
      context.handle(
        _pricePerShareMeta,
        pricePerShare.isAcceptableOrUnknown(
          data['price_per_share']!,
          _pricePerShareMeta,
        ),
      );
    }
    if (data.containsKey('amount_raised')) {
      context.handle(
        _amountRaisedMeta,
        amountRaised.isAcceptableOrUnknown(
          data['amount_raised']!,
          _amountRaisedMeta,
        ),
      );
    }
    if (data.containsKey('lead_investor_id')) {
      context.handle(
        _leadInvestorIdMeta,
        leadInvestorId.isAcceptableOrUnknown(
          data['lead_investor_id']!,
          _leadInvestorIdMeta,
        ),
      );
    }
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayOrderMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  Round map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Round(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      preMoneyValuation: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pre_money_valuation'],
      ),
      pricePerShare: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_per_share'],
      ),
      amountRaised: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_raised'],
      )!,
      leadInvestorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lead_investor_id'],
      ),
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RoundsTable createAlias(String alias) {
    return $RoundsTable(attachedDatabase, alias);
  }
}

class Round extends DataClass implements Insertable<Round> {
  final String id;
  final String companyId;
  final String name;
  final String type;
  final String status;
  final DateTime date;
  final double? preMoneyValuation;
  final double? pricePerShare;
  final double amountRaised;
  final String? leadInvestorId;
  final int displayOrder;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Round({
    required this.id,
    required this.companyId,
    required this.name,
    required this.type,
    required this.status,
    required this.date,
    this.preMoneyValuation,
    this.pricePerShare,
    required this.amountRaised,
    this.leadInvestorId,
    required this.displayOrder,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || preMoneyValuation != null) {
      map['pre_money_valuation'] = Variable<double>(preMoneyValuation);
    }
    if (!nullToAbsent || pricePerShare != null) {
      map['price_per_share'] = Variable<double>(pricePerShare);
    }
    map['amount_raised'] = Variable<double>(amountRaised);
    if (!nullToAbsent || leadInvestorId != null) {
      map['lead_investor_id'] = Variable<String>(leadInvestorId);
    }
    map['display_order'] = Variable<int>(displayOrder);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RoundsCompanion toCompanion(bool nullToAbsent) {
    return RoundsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      type: Value(type),
      status: Value(status),
      date: Value(date),
      preMoneyValuation: preMoneyValuation == null && nullToAbsent
          ? const Value.absent()
          : Value(preMoneyValuation),
      pricePerShare: pricePerShare == null && nullToAbsent
          ? const Value.absent()
          : Value(pricePerShare),
      amountRaised: Value(amountRaised),
      leadInvestorId: leadInvestorId == null && nullToAbsent
          ? const Value.absent()
          : Value(leadInvestorId),
      displayOrder: Value(displayOrder),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Round.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Round(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      date: serializer.fromJson<DateTime>(json['date']),
      preMoneyValuation: serializer.fromJson<double?>(
        json['preMoneyValuation'],
      ),
      pricePerShare: serializer.fromJson<double?>(json['pricePerShare']),
      amountRaised: serializer.fromJson<double>(json['amountRaised']),
      leadInvestorId: serializer.fromJson<String?>(json['leadInvestorId']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'date': serializer.toJson<DateTime>(date),
      'preMoneyValuation': serializer.toJson<double?>(preMoneyValuation),
      'pricePerShare': serializer.toJson<double?>(pricePerShare),
      'amountRaised': serializer.toJson<double>(amountRaised),
      'leadInvestorId': serializer.toJson<String?>(leadInvestorId),
      'displayOrder': serializer.toJson<int>(displayOrder),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Round copyWith({
    String? id,
    String? companyId,
    String? name,
    String? type,
    String? status,
    DateTime? date,
    Value<double?> preMoneyValuation = const Value.absent(),
    Value<double?> pricePerShare = const Value.absent(),
    double? amountRaised,
    Value<String?> leadInvestorId = const Value.absent(),
    int? displayOrder,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Round(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    type: type ?? this.type,
    status: status ?? this.status,
    date: date ?? this.date,
    preMoneyValuation: preMoneyValuation.present
        ? preMoneyValuation.value
        : this.preMoneyValuation,
    pricePerShare: pricePerShare.present
        ? pricePerShare.value
        : this.pricePerShare,
    amountRaised: amountRaised ?? this.amountRaised,
    leadInvestorId: leadInvestorId.present
        ? leadInvestorId.value
        : this.leadInvestorId,
    displayOrder: displayOrder ?? this.displayOrder,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Round copyWithCompanion(RoundsCompanion data) {
    return Round(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      date: data.date.present ? data.date.value : this.date,
      preMoneyValuation: data.preMoneyValuation.present
          ? data.preMoneyValuation.value
          : this.preMoneyValuation,
      pricePerShare: data.pricePerShare.present
          ? data.pricePerShare.value
          : this.pricePerShare,
      amountRaised: data.amountRaised.present
          ? data.amountRaised.value
          : this.amountRaised,
      leadInvestorId: data.leadInvestorId.present
          ? data.leadInvestorId.value
          : this.leadInvestorId,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Round(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('date: $date, ')
          ..write('preMoneyValuation: $preMoneyValuation, ')
          ..write('pricePerShare: $pricePerShare, ')
          ..write('amountRaised: $amountRaised, ')
          ..write('leadInvestorId: $leadInvestorId, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    name,
    type,
    status,
    date,
    preMoneyValuation,
    pricePerShare,
    amountRaised,
    leadInvestorId,
    displayOrder,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Round &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.type == this.type &&
          other.status == this.status &&
          other.date == this.date &&
          other.preMoneyValuation == this.preMoneyValuation &&
          other.pricePerShare == this.pricePerShare &&
          other.amountRaised == this.amountRaised &&
          other.leadInvestorId == this.leadInvestorId &&
          other.displayOrder == this.displayOrder &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RoundsCompanion extends UpdateCompanion<Round> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> name;
  final Value<String> type;
  final Value<String> status;
  final Value<DateTime> date;
  final Value<double?> preMoneyValuation;
  final Value<double?> pricePerShare;
  final Value<double> amountRaised;
  final Value<String?> leadInvestorId;
  final Value<int> displayOrder;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RoundsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.date = const Value.absent(),
    this.preMoneyValuation = const Value.absent(),
    this.pricePerShare = const Value.absent(),
    this.amountRaised = const Value.absent(),
    this.leadInvestorId = const Value.absent(),
    this.displayOrder = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoundsCompanion.insert({
    required String id,
    required String companyId,
    required String name,
    required String type,
    this.status = const Value.absent(),
    required DateTime date,
    this.preMoneyValuation = const Value.absent(),
    this.pricePerShare = const Value.absent(),
    this.amountRaised = const Value.absent(),
    this.leadInvestorId = const Value.absent(),
    required int displayOrder,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       name = Value(name),
       type = Value(type),
       date = Value(date),
       displayOrder = Value(displayOrder),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Round> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? status,
    Expression<DateTime>? date,
    Expression<double>? preMoneyValuation,
    Expression<double>? pricePerShare,
    Expression<double>? amountRaised,
    Expression<String>? leadInvestorId,
    Expression<int>? displayOrder,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (date != null) 'date': date,
      if (preMoneyValuation != null) 'pre_money_valuation': preMoneyValuation,
      if (pricePerShare != null) 'price_per_share': pricePerShare,
      if (amountRaised != null) 'amount_raised': amountRaised,
      if (leadInvestorId != null) 'lead_investor_id': leadInvestorId,
      if (displayOrder != null) 'display_order': displayOrder,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoundsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? name,
    Value<String>? type,
    Value<String>? status,
    Value<DateTime>? date,
    Value<double?>? preMoneyValuation,
    Value<double?>? pricePerShare,
    Value<double>? amountRaised,
    Value<String?>? leadInvestorId,
    Value<int>? displayOrder,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RoundsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      date: date ?? this.date,
      preMoneyValuation: preMoneyValuation ?? this.preMoneyValuation,
      pricePerShare: pricePerShare ?? this.pricePerShare,
      amountRaised: amountRaised ?? this.amountRaised,
      leadInvestorId: leadInvestorId ?? this.leadInvestorId,
      displayOrder: displayOrder ?? this.displayOrder,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (preMoneyValuation.present) {
      map['pre_money_valuation'] = Variable<double>(preMoneyValuation.value);
    }
    if (pricePerShare.present) {
      map['price_per_share'] = Variable<double>(pricePerShare.value);
    }
    if (amountRaised.present) {
      map['amount_raised'] = Variable<double>(amountRaised.value);
    }
    if (leadInvestorId.present) {
      map['lead_investor_id'] = Variable<String>(leadInvestorId.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoundsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('date: $date, ')
          ..write('preMoneyValuation: $preMoneyValuation, ')
          ..write('pricePerShare: $pricePerShare, ')
          ..write('amountRaised: $amountRaised, ')
          ..write('leadInvestorId: $leadInvestorId, ')
          ..write('displayOrder: $displayOrder, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HoldingsTable extends Holdings with TableInfo<$HoldingsTable, Holding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HoldingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _stakeholderIdMeta = const VerificationMeta(
    'stakeholderId',
  );
  @override
  late final GeneratedColumn<String> stakeholderId = GeneratedColumn<String>(
    'stakeholder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stakeholders (id)',
    ),
  );
  static const VerificationMeta _shareClassIdMeta = const VerificationMeta(
    'shareClassId',
  );
  @override
  late final GeneratedColumn<String> shareClassId = GeneratedColumn<String>(
    'share_class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES share_classes (id)',
    ),
  );
  static const VerificationMeta _shareCountMeta = const VerificationMeta(
    'shareCount',
  );
  @override
  late final GeneratedColumn<int> shareCount = GeneratedColumn<int>(
    'share_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costBasisMeta = const VerificationMeta(
    'costBasis',
  );
  @override
  late final GeneratedColumn<double> costBasis = GeneratedColumn<double>(
    'cost_basis',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acquiredDateMeta = const VerificationMeta(
    'acquiredDate',
  );
  @override
  late final GeneratedColumn<DateTime> acquiredDate = GeneratedColumn<DateTime>(
    'acquired_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vestingScheduleIdMeta = const VerificationMeta(
    'vestingScheduleId',
  );
  @override
  late final GeneratedColumn<String> vestingScheduleId =
      GeneratedColumn<String>(
        'vesting_schedule_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _vestedCountMeta = const VerificationMeta(
    'vestedCount',
  );
  @override
  late final GeneratedColumn<int> vestedCount = GeneratedColumn<int>(
    'vested_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roundIdMeta = const VerificationMeta(
    'roundId',
  );
  @override
  late final GeneratedColumn<String> roundId = GeneratedColumn<String>(
    'round_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rounds (id)',
    ),
  );
  static const VerificationMeta _sourceOptionGrantIdMeta =
      const VerificationMeta('sourceOptionGrantId');
  @override
  late final GeneratedColumn<String> sourceOptionGrantId =
      GeneratedColumn<String>(
        'source_option_grant_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sourceWarrantIdMeta = const VerificationMeta(
    'sourceWarrantId',
  );
  @override
  late final GeneratedColumn<String> sourceWarrantId = GeneratedColumn<String>(
    'source_warrant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    stakeholderId,
    shareClassId,
    shareCount,
    costBasis,
    acquiredDate,
    vestingScheduleId,
    vestedCount,
    roundId,
    sourceOptionGrantId,
    sourceWarrantId,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holdings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Holding> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('stakeholder_id')) {
      context.handle(
        _stakeholderIdMeta,
        stakeholderId.isAcceptableOrUnknown(
          data['stakeholder_id']!,
          _stakeholderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stakeholderIdMeta);
    }
    if (data.containsKey('share_class_id')) {
      context.handle(
        _shareClassIdMeta,
        shareClassId.isAcceptableOrUnknown(
          data['share_class_id']!,
          _shareClassIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shareClassIdMeta);
    }
    if (data.containsKey('share_count')) {
      context.handle(
        _shareCountMeta,
        shareCount.isAcceptableOrUnknown(data['share_count']!, _shareCountMeta),
      );
    } else if (isInserting) {
      context.missing(_shareCountMeta);
    }
    if (data.containsKey('cost_basis')) {
      context.handle(
        _costBasisMeta,
        costBasis.isAcceptableOrUnknown(data['cost_basis']!, _costBasisMeta),
      );
    } else if (isInserting) {
      context.missing(_costBasisMeta);
    }
    if (data.containsKey('acquired_date')) {
      context.handle(
        _acquiredDateMeta,
        acquiredDate.isAcceptableOrUnknown(
          data['acquired_date']!,
          _acquiredDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_acquiredDateMeta);
    }
    if (data.containsKey('vesting_schedule_id')) {
      context.handle(
        _vestingScheduleIdMeta,
        vestingScheduleId.isAcceptableOrUnknown(
          data['vesting_schedule_id']!,
          _vestingScheduleIdMeta,
        ),
      );
    }
    if (data.containsKey('vested_count')) {
      context.handle(
        _vestedCountMeta,
        vestedCount.isAcceptableOrUnknown(
          data['vested_count']!,
          _vestedCountMeta,
        ),
      );
    }
    if (data.containsKey('round_id')) {
      context.handle(
        _roundIdMeta,
        roundId.isAcceptableOrUnknown(data['round_id']!, _roundIdMeta),
      );
    }
    if (data.containsKey('source_option_grant_id')) {
      context.handle(
        _sourceOptionGrantIdMeta,
        sourceOptionGrantId.isAcceptableOrUnknown(
          data['source_option_grant_id']!,
          _sourceOptionGrantIdMeta,
        ),
      );
    }
    if (data.containsKey('source_warrant_id')) {
      context.handle(
        _sourceWarrantIdMeta,
        sourceWarrantId.isAcceptableOrUnknown(
          data['source_warrant_id']!,
          _sourceWarrantIdMeta,
        ),
      );
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
  Holding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Holding(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      stakeholderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stakeholder_id'],
      )!,
      shareClassId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}share_class_id'],
      )!,
      shareCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}share_count'],
      )!,
      costBasis: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_basis'],
      )!,
      acquiredDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acquired_date'],
      )!,
      vestingScheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vesting_schedule_id'],
      ),
      vestedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vested_count'],
      ),
      roundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}round_id'],
      ),
      sourceOptionGrantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_option_grant_id'],
      ),
      sourceWarrantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_warrant_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HoldingsTable createAlias(String alias) {
    return $HoldingsTable(attachedDatabase, alias);
  }
}

class Holding extends DataClass implements Insertable<Holding> {
  final String id;
  final String companyId;
  final String stakeholderId;
  final String shareClassId;
  final int shareCount;
  final double costBasis;
  final DateTime acquiredDate;
  final String? vestingScheduleId;
  final int? vestedCount;
  final String? roundId;

  /// Source option grant ID if this holding came from exercising options.
  final String? sourceOptionGrantId;

  /// Source warrant ID if this holding came from exercising warrants.
  final String? sourceWarrantId;
  final DateTime updatedAt;
  const Holding({
    required this.id,
    required this.companyId,
    required this.stakeholderId,
    required this.shareClassId,
    required this.shareCount,
    required this.costBasis,
    required this.acquiredDate,
    this.vestingScheduleId,
    this.vestedCount,
    this.roundId,
    this.sourceOptionGrantId,
    this.sourceWarrantId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['stakeholder_id'] = Variable<String>(stakeholderId);
    map['share_class_id'] = Variable<String>(shareClassId);
    map['share_count'] = Variable<int>(shareCount);
    map['cost_basis'] = Variable<double>(costBasis);
    map['acquired_date'] = Variable<DateTime>(acquiredDate);
    if (!nullToAbsent || vestingScheduleId != null) {
      map['vesting_schedule_id'] = Variable<String>(vestingScheduleId);
    }
    if (!nullToAbsent || vestedCount != null) {
      map['vested_count'] = Variable<int>(vestedCount);
    }
    if (!nullToAbsent || roundId != null) {
      map['round_id'] = Variable<String>(roundId);
    }
    if (!nullToAbsent || sourceOptionGrantId != null) {
      map['source_option_grant_id'] = Variable<String>(sourceOptionGrantId);
    }
    if (!nullToAbsent || sourceWarrantId != null) {
      map['source_warrant_id'] = Variable<String>(sourceWarrantId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HoldingsCompanion toCompanion(bool nullToAbsent) {
    return HoldingsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      stakeholderId: Value(stakeholderId),
      shareClassId: Value(shareClassId),
      shareCount: Value(shareCount),
      costBasis: Value(costBasis),
      acquiredDate: Value(acquiredDate),
      vestingScheduleId: vestingScheduleId == null && nullToAbsent
          ? const Value.absent()
          : Value(vestingScheduleId),
      vestedCount: vestedCount == null && nullToAbsent
          ? const Value.absent()
          : Value(vestedCount),
      roundId: roundId == null && nullToAbsent
          ? const Value.absent()
          : Value(roundId),
      sourceOptionGrantId: sourceOptionGrantId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceOptionGrantId),
      sourceWarrantId: sourceWarrantId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceWarrantId),
      updatedAt: Value(updatedAt),
    );
  }

  factory Holding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Holding(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      stakeholderId: serializer.fromJson<String>(json['stakeholderId']),
      shareClassId: serializer.fromJson<String>(json['shareClassId']),
      shareCount: serializer.fromJson<int>(json['shareCount']),
      costBasis: serializer.fromJson<double>(json['costBasis']),
      acquiredDate: serializer.fromJson<DateTime>(json['acquiredDate']),
      vestingScheduleId: serializer.fromJson<String?>(
        json['vestingScheduleId'],
      ),
      vestedCount: serializer.fromJson<int?>(json['vestedCount']),
      roundId: serializer.fromJson<String?>(json['roundId']),
      sourceOptionGrantId: serializer.fromJson<String?>(
        json['sourceOptionGrantId'],
      ),
      sourceWarrantId: serializer.fromJson<String?>(json['sourceWarrantId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'stakeholderId': serializer.toJson<String>(stakeholderId),
      'shareClassId': serializer.toJson<String>(shareClassId),
      'shareCount': serializer.toJson<int>(shareCount),
      'costBasis': serializer.toJson<double>(costBasis),
      'acquiredDate': serializer.toJson<DateTime>(acquiredDate),
      'vestingScheduleId': serializer.toJson<String?>(vestingScheduleId),
      'vestedCount': serializer.toJson<int?>(vestedCount),
      'roundId': serializer.toJson<String?>(roundId),
      'sourceOptionGrantId': serializer.toJson<String?>(sourceOptionGrantId),
      'sourceWarrantId': serializer.toJson<String?>(sourceWarrantId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Holding copyWith({
    String? id,
    String? companyId,
    String? stakeholderId,
    String? shareClassId,
    int? shareCount,
    double? costBasis,
    DateTime? acquiredDate,
    Value<String?> vestingScheduleId = const Value.absent(),
    Value<int?> vestedCount = const Value.absent(),
    Value<String?> roundId = const Value.absent(),
    Value<String?> sourceOptionGrantId = const Value.absent(),
    Value<String?> sourceWarrantId = const Value.absent(),
    DateTime? updatedAt,
  }) => Holding(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    stakeholderId: stakeholderId ?? this.stakeholderId,
    shareClassId: shareClassId ?? this.shareClassId,
    shareCount: shareCount ?? this.shareCount,
    costBasis: costBasis ?? this.costBasis,
    acquiredDate: acquiredDate ?? this.acquiredDate,
    vestingScheduleId: vestingScheduleId.present
        ? vestingScheduleId.value
        : this.vestingScheduleId,
    vestedCount: vestedCount.present ? vestedCount.value : this.vestedCount,
    roundId: roundId.present ? roundId.value : this.roundId,
    sourceOptionGrantId: sourceOptionGrantId.present
        ? sourceOptionGrantId.value
        : this.sourceOptionGrantId,
    sourceWarrantId: sourceWarrantId.present
        ? sourceWarrantId.value
        : this.sourceWarrantId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Holding copyWithCompanion(HoldingsCompanion data) {
    return Holding(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      stakeholderId: data.stakeholderId.present
          ? data.stakeholderId.value
          : this.stakeholderId,
      shareClassId: data.shareClassId.present
          ? data.shareClassId.value
          : this.shareClassId,
      shareCount: data.shareCount.present
          ? data.shareCount.value
          : this.shareCount,
      costBasis: data.costBasis.present ? data.costBasis.value : this.costBasis,
      acquiredDate: data.acquiredDate.present
          ? data.acquiredDate.value
          : this.acquiredDate,
      vestingScheduleId: data.vestingScheduleId.present
          ? data.vestingScheduleId.value
          : this.vestingScheduleId,
      vestedCount: data.vestedCount.present
          ? data.vestedCount.value
          : this.vestedCount,
      roundId: data.roundId.present ? data.roundId.value : this.roundId,
      sourceOptionGrantId: data.sourceOptionGrantId.present
          ? data.sourceOptionGrantId.value
          : this.sourceOptionGrantId,
      sourceWarrantId: data.sourceWarrantId.present
          ? data.sourceWarrantId.value
          : this.sourceWarrantId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Holding(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('stakeholderId: $stakeholderId, ')
          ..write('shareClassId: $shareClassId, ')
          ..write('shareCount: $shareCount, ')
          ..write('costBasis: $costBasis, ')
          ..write('acquiredDate: $acquiredDate, ')
          ..write('vestingScheduleId: $vestingScheduleId, ')
          ..write('vestedCount: $vestedCount, ')
          ..write('roundId: $roundId, ')
          ..write('sourceOptionGrantId: $sourceOptionGrantId, ')
          ..write('sourceWarrantId: $sourceWarrantId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    stakeholderId,
    shareClassId,
    shareCount,
    costBasis,
    acquiredDate,
    vestingScheduleId,
    vestedCount,
    roundId,
    sourceOptionGrantId,
    sourceWarrantId,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Holding &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.stakeholderId == this.stakeholderId &&
          other.shareClassId == this.shareClassId &&
          other.shareCount == this.shareCount &&
          other.costBasis == this.costBasis &&
          other.acquiredDate == this.acquiredDate &&
          other.vestingScheduleId == this.vestingScheduleId &&
          other.vestedCount == this.vestedCount &&
          other.roundId == this.roundId &&
          other.sourceOptionGrantId == this.sourceOptionGrantId &&
          other.sourceWarrantId == this.sourceWarrantId &&
          other.updatedAt == this.updatedAt);
}

class HoldingsCompanion extends UpdateCompanion<Holding> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> stakeholderId;
  final Value<String> shareClassId;
  final Value<int> shareCount;
  final Value<double> costBasis;
  final Value<DateTime> acquiredDate;
  final Value<String?> vestingScheduleId;
  final Value<int?> vestedCount;
  final Value<String?> roundId;
  final Value<String?> sourceOptionGrantId;
  final Value<String?> sourceWarrantId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const HoldingsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.stakeholderId = const Value.absent(),
    this.shareClassId = const Value.absent(),
    this.shareCount = const Value.absent(),
    this.costBasis = const Value.absent(),
    this.acquiredDate = const Value.absent(),
    this.vestingScheduleId = const Value.absent(),
    this.vestedCount = const Value.absent(),
    this.roundId = const Value.absent(),
    this.sourceOptionGrantId = const Value.absent(),
    this.sourceWarrantId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HoldingsCompanion.insert({
    required String id,
    required String companyId,
    required String stakeholderId,
    required String shareClassId,
    required int shareCount,
    required double costBasis,
    required DateTime acquiredDate,
    this.vestingScheduleId = const Value.absent(),
    this.vestedCount = const Value.absent(),
    this.roundId = const Value.absent(),
    this.sourceOptionGrantId = const Value.absent(),
    this.sourceWarrantId = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       stakeholderId = Value(stakeholderId),
       shareClassId = Value(shareClassId),
       shareCount = Value(shareCount),
       costBasis = Value(costBasis),
       acquiredDate = Value(acquiredDate),
       updatedAt = Value(updatedAt);
  static Insertable<Holding> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? stakeholderId,
    Expression<String>? shareClassId,
    Expression<int>? shareCount,
    Expression<double>? costBasis,
    Expression<DateTime>? acquiredDate,
    Expression<String>? vestingScheduleId,
    Expression<int>? vestedCount,
    Expression<String>? roundId,
    Expression<String>? sourceOptionGrantId,
    Expression<String>? sourceWarrantId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (stakeholderId != null) 'stakeholder_id': stakeholderId,
      if (shareClassId != null) 'share_class_id': shareClassId,
      if (shareCount != null) 'share_count': shareCount,
      if (costBasis != null) 'cost_basis': costBasis,
      if (acquiredDate != null) 'acquired_date': acquiredDate,
      if (vestingScheduleId != null) 'vesting_schedule_id': vestingScheduleId,
      if (vestedCount != null) 'vested_count': vestedCount,
      if (roundId != null) 'round_id': roundId,
      if (sourceOptionGrantId != null)
        'source_option_grant_id': sourceOptionGrantId,
      if (sourceWarrantId != null) 'source_warrant_id': sourceWarrantId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HoldingsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? stakeholderId,
    Value<String>? shareClassId,
    Value<int>? shareCount,
    Value<double>? costBasis,
    Value<DateTime>? acquiredDate,
    Value<String?>? vestingScheduleId,
    Value<int?>? vestedCount,
    Value<String?>? roundId,
    Value<String?>? sourceOptionGrantId,
    Value<String?>? sourceWarrantId,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return HoldingsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      stakeholderId: stakeholderId ?? this.stakeholderId,
      shareClassId: shareClassId ?? this.shareClassId,
      shareCount: shareCount ?? this.shareCount,
      costBasis: costBasis ?? this.costBasis,
      acquiredDate: acquiredDate ?? this.acquiredDate,
      vestingScheduleId: vestingScheduleId ?? this.vestingScheduleId,
      vestedCount: vestedCount ?? this.vestedCount,
      roundId: roundId ?? this.roundId,
      sourceOptionGrantId: sourceOptionGrantId ?? this.sourceOptionGrantId,
      sourceWarrantId: sourceWarrantId ?? this.sourceWarrantId,
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
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (stakeholderId.present) {
      map['stakeholder_id'] = Variable<String>(stakeholderId.value);
    }
    if (shareClassId.present) {
      map['share_class_id'] = Variable<String>(shareClassId.value);
    }
    if (shareCount.present) {
      map['share_count'] = Variable<int>(shareCount.value);
    }
    if (costBasis.present) {
      map['cost_basis'] = Variable<double>(costBasis.value);
    }
    if (acquiredDate.present) {
      map['acquired_date'] = Variable<DateTime>(acquiredDate.value);
    }
    if (vestingScheduleId.present) {
      map['vesting_schedule_id'] = Variable<String>(vestingScheduleId.value);
    }
    if (vestedCount.present) {
      map['vested_count'] = Variable<int>(vestedCount.value);
    }
    if (roundId.present) {
      map['round_id'] = Variable<String>(roundId.value);
    }
    if (sourceOptionGrantId.present) {
      map['source_option_grant_id'] = Variable<String>(
        sourceOptionGrantId.value,
      );
    }
    if (sourceWarrantId.present) {
      map['source_warrant_id'] = Variable<String>(sourceWarrantId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HoldingsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('stakeholderId: $stakeholderId, ')
          ..write('shareClassId: $shareClassId, ')
          ..write('shareCount: $shareCount, ')
          ..write('costBasis: $costBasis, ')
          ..write('acquiredDate: $acquiredDate, ')
          ..write('vestingScheduleId: $vestingScheduleId, ')
          ..write('vestedCount: $vestedCount, ')
          ..write('roundId: $roundId, ')
          ..write('sourceOptionGrantId: $sourceOptionGrantId, ')
          ..write('sourceWarrantId: $sourceWarrantId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConvertiblesTable extends Convertibles
    with TableInfo<$ConvertiblesTable, Convertible> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConvertiblesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _stakeholderIdMeta = const VerificationMeta(
    'stakeholderId',
  );
  @override
  late final GeneratedColumn<String> stakeholderId = GeneratedColumn<String>(
    'stakeholder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stakeholders (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('outstanding'),
  );
  static const VerificationMeta _principalMeta = const VerificationMeta(
    'principal',
  );
  @override
  late final GeneratedColumn<double> principal = GeneratedColumn<double>(
    'principal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valuationCapMeta = const VerificationMeta(
    'valuationCap',
  );
  @override
  late final GeneratedColumn<double> valuationCap = GeneratedColumn<double>(
    'valuation_cap',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discountPercentMeta = const VerificationMeta(
    'discountPercent',
  );
  @override
  late final GeneratedColumn<double> discountPercent = GeneratedColumn<double>(
    'discount_percent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _interestRateMeta = const VerificationMeta(
    'interestRate',
  );
  @override
  late final GeneratedColumn<double> interestRate = GeneratedColumn<double>(
    'interest_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maturityDateMeta = const VerificationMeta(
    'maturityDate',
  );
  @override
  late final GeneratedColumn<DateTime> maturityDate = GeneratedColumn<DateTime>(
    'maturity_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _issueDateMeta = const VerificationMeta(
    'issueDate',
  );
  @override
  late final GeneratedColumn<DateTime> issueDate = GeneratedColumn<DateTime>(
    'issue_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasMfnMeta = const VerificationMeta('hasMfn');
  @override
  late final GeneratedColumn<bool> hasMfn = GeneratedColumn<bool>(
    'has_mfn',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_mfn" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasProRataMeta = const VerificationMeta(
    'hasProRata',
  );
  @override
  late final GeneratedColumn<bool> hasProRata = GeneratedColumn<bool>(
    'has_pro_rata',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_pro_rata" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _roundIdMeta = const VerificationMeta(
    'roundId',
  );
  @override
  late final GeneratedColumn<String> roundId = GeneratedColumn<String>(
    'round_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rounds (id)',
    ),
  );
  static const VerificationMeta _conversionEventIdMeta = const VerificationMeta(
    'conversionEventId',
  );
  @override
  late final GeneratedColumn<String> conversionEventId =
      GeneratedColumn<String>(
        'conversion_event_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _convertedToShareClassIdMeta =
      const VerificationMeta('convertedToShareClassId');
  @override
  late final GeneratedColumn<String> convertedToShareClassId =
      GeneratedColumn<String>(
        'converted_to_share_class_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sharesReceivedMeta = const VerificationMeta(
    'sharesReceived',
  );
  @override
  late final GeneratedColumn<int> sharesReceived = GeneratedColumn<int>(
    'shares_received',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maturityBehaviorMeta = const VerificationMeta(
    'maturityBehavior',
  );
  @override
  late final GeneratedColumn<String> maturityBehavior = GeneratedColumn<String>(
    'maturity_behavior',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allowsVoluntaryConversionMeta =
      const VerificationMeta('allowsVoluntaryConversion');
  @override
  late final GeneratedColumn<bool> allowsVoluntaryConversion =
      GeneratedColumn<bool>(
        'allows_voluntary_conversion',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("allows_voluntary_conversion" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _liquidityEventBehaviorMeta =
      const VerificationMeta('liquidityEventBehavior');
  @override
  late final GeneratedColumn<String> liquidityEventBehavior =
      GeneratedColumn<String>(
        'liquidity_event_behavior',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _liquidityPayoutMultipleMeta =
      const VerificationMeta('liquidityPayoutMultiple');
  @override
  late final GeneratedColumn<double> liquidityPayoutMultiple =
      GeneratedColumn<double>(
        'liquidity_payout_multiple',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dissolutionBehaviorMeta =
      const VerificationMeta('dissolutionBehavior');
  @override
  late final GeneratedColumn<String> dissolutionBehavior =
      GeneratedColumn<String>(
        'dissolution_behavior',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _preferredShareClassIdMeta =
      const VerificationMeta('preferredShareClassId');
  @override
  late final GeneratedColumn<String> preferredShareClassId =
      GeneratedColumn<String>(
        'preferred_share_class_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _qualifiedFinancingThresholdMeta =
      const VerificationMeta('qualifiedFinancingThreshold');
  @override
  late final GeneratedColumn<double> qualifiedFinancingThreshold =
      GeneratedColumn<double>(
        'qualified_financing_threshold',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    stakeholderId,
    type,
    status,
    principal,
    valuationCap,
    discountPercent,
    interestRate,
    maturityDate,
    issueDate,
    hasMfn,
    hasProRata,
    roundId,
    conversionEventId,
    convertedToShareClassId,
    sharesReceived,
    notes,
    maturityBehavior,
    allowsVoluntaryConversion,
    liquidityEventBehavior,
    liquidityPayoutMultiple,
    dissolutionBehavior,
    preferredShareClassId,
    qualifiedFinancingThreshold,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'convertibles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Convertible> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('stakeholder_id')) {
      context.handle(
        _stakeholderIdMeta,
        stakeholderId.isAcceptableOrUnknown(
          data['stakeholder_id']!,
          _stakeholderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stakeholderIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('principal')) {
      context.handle(
        _principalMeta,
        principal.isAcceptableOrUnknown(data['principal']!, _principalMeta),
      );
    } else if (isInserting) {
      context.missing(_principalMeta);
    }
    if (data.containsKey('valuation_cap')) {
      context.handle(
        _valuationCapMeta,
        valuationCap.isAcceptableOrUnknown(
          data['valuation_cap']!,
          _valuationCapMeta,
        ),
      );
    }
    if (data.containsKey('discount_percent')) {
      context.handle(
        _discountPercentMeta,
        discountPercent.isAcceptableOrUnknown(
          data['discount_percent']!,
          _discountPercentMeta,
        ),
      );
    }
    if (data.containsKey('interest_rate')) {
      context.handle(
        _interestRateMeta,
        interestRate.isAcceptableOrUnknown(
          data['interest_rate']!,
          _interestRateMeta,
        ),
      );
    }
    if (data.containsKey('maturity_date')) {
      context.handle(
        _maturityDateMeta,
        maturityDate.isAcceptableOrUnknown(
          data['maturity_date']!,
          _maturityDateMeta,
        ),
      );
    }
    if (data.containsKey('issue_date')) {
      context.handle(
        _issueDateMeta,
        issueDate.isAcceptableOrUnknown(data['issue_date']!, _issueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_issueDateMeta);
    }
    if (data.containsKey('has_mfn')) {
      context.handle(
        _hasMfnMeta,
        hasMfn.isAcceptableOrUnknown(data['has_mfn']!, _hasMfnMeta),
      );
    }
    if (data.containsKey('has_pro_rata')) {
      context.handle(
        _hasProRataMeta,
        hasProRata.isAcceptableOrUnknown(
          data['has_pro_rata']!,
          _hasProRataMeta,
        ),
      );
    }
    if (data.containsKey('round_id')) {
      context.handle(
        _roundIdMeta,
        roundId.isAcceptableOrUnknown(data['round_id']!, _roundIdMeta),
      );
    }
    if (data.containsKey('conversion_event_id')) {
      context.handle(
        _conversionEventIdMeta,
        conversionEventId.isAcceptableOrUnknown(
          data['conversion_event_id']!,
          _conversionEventIdMeta,
        ),
      );
    }
    if (data.containsKey('converted_to_share_class_id')) {
      context.handle(
        _convertedToShareClassIdMeta,
        convertedToShareClassId.isAcceptableOrUnknown(
          data['converted_to_share_class_id']!,
          _convertedToShareClassIdMeta,
        ),
      );
    }
    if (data.containsKey('shares_received')) {
      context.handle(
        _sharesReceivedMeta,
        sharesReceived.isAcceptableOrUnknown(
          data['shares_received']!,
          _sharesReceivedMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('maturity_behavior')) {
      context.handle(
        _maturityBehaviorMeta,
        maturityBehavior.isAcceptableOrUnknown(
          data['maturity_behavior']!,
          _maturityBehaviorMeta,
        ),
      );
    }
    if (data.containsKey('allows_voluntary_conversion')) {
      context.handle(
        _allowsVoluntaryConversionMeta,
        allowsVoluntaryConversion.isAcceptableOrUnknown(
          data['allows_voluntary_conversion']!,
          _allowsVoluntaryConversionMeta,
        ),
      );
    }
    if (data.containsKey('liquidity_event_behavior')) {
      context.handle(
        _liquidityEventBehaviorMeta,
        liquidityEventBehavior.isAcceptableOrUnknown(
          data['liquidity_event_behavior']!,
          _liquidityEventBehaviorMeta,
        ),
      );
    }
    if (data.containsKey('liquidity_payout_multiple')) {
      context.handle(
        _liquidityPayoutMultipleMeta,
        liquidityPayoutMultiple.isAcceptableOrUnknown(
          data['liquidity_payout_multiple']!,
          _liquidityPayoutMultipleMeta,
        ),
      );
    }
    if (data.containsKey('dissolution_behavior')) {
      context.handle(
        _dissolutionBehaviorMeta,
        dissolutionBehavior.isAcceptableOrUnknown(
          data['dissolution_behavior']!,
          _dissolutionBehaviorMeta,
        ),
      );
    }
    if (data.containsKey('preferred_share_class_id')) {
      context.handle(
        _preferredShareClassIdMeta,
        preferredShareClassId.isAcceptableOrUnknown(
          data['preferred_share_class_id']!,
          _preferredShareClassIdMeta,
        ),
      );
    }
    if (data.containsKey('qualified_financing_threshold')) {
      context.handle(
        _qualifiedFinancingThresholdMeta,
        qualifiedFinancingThreshold.isAcceptableOrUnknown(
          data['qualified_financing_threshold']!,
          _qualifiedFinancingThresholdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  Convertible map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Convertible(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      stakeholderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stakeholder_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      principal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}principal'],
      )!,
      valuationCap: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valuation_cap'],
      ),
      discountPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_percent'],
      ),
      interestRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interest_rate'],
      ),
      maturityDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}maturity_date'],
      ),
      issueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}issue_date'],
      )!,
      hasMfn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_mfn'],
      )!,
      hasProRata: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_pro_rata'],
      )!,
      roundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}round_id'],
      ),
      conversionEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversion_event_id'],
      ),
      convertedToShareClassId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}converted_to_share_class_id'],
      ),
      sharesReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shares_received'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      maturityBehavior: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}maturity_behavior'],
      ),
      allowsVoluntaryConversion: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allows_voluntary_conversion'],
      )!,
      liquidityEventBehavior: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}liquidity_event_behavior'],
      ),
      liquidityPayoutMultiple: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}liquidity_payout_multiple'],
      ),
      dissolutionBehavior: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dissolution_behavior'],
      ),
      preferredShareClassId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_share_class_id'],
      ),
      qualifiedFinancingThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}qualified_financing_threshold'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ConvertiblesTable createAlias(String alias) {
    return $ConvertiblesTable(attachedDatabase, alias);
  }
}

class Convertible extends DataClass implements Insertable<Convertible> {
  final String id;
  final String companyId;
  final String stakeholderId;
  final String type;
  final String status;
  final double principal;
  final double? valuationCap;
  final double? discountPercent;
  final double? interestRate;
  final DateTime? maturityDate;
  final DateTime issueDate;
  final bool hasMfn;
  final bool hasProRata;
  final String? roundId;
  final String? conversionEventId;
  final String? convertedToShareClassId;
  final int? sharesReceived;
  final String? notes;

  /// What happens at maturity (for notes): convertAtCap, convertAtDiscount, repay, extend, negotiate
  final String? maturityBehavior;

  /// Whether voluntary conversion (by board/investor agreement) is allowed
  final bool allowsVoluntaryConversion;

  /// Behavior on liquidity event: convertAtCap, cashPayout, greaterOf, negotiate
  final String? liquidityEventBehavior;

  /// Cash payout multiplier for liquidity events (e.g., 1.0 = 1x principal)
  final double? liquidityPayoutMultiple;

  /// Behavior on dissolution: pariPassu, principalFirst, fullAmount, nothing
  final String? dissolutionBehavior;

  /// Preferred share class for conversion (if specified upfront)
  final String? preferredShareClassId;

  /// Qualified financing threshold amount (minimum raise to trigger auto-convert)
  final double? qualifiedFinancingThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Convertible({
    required this.id,
    required this.companyId,
    required this.stakeholderId,
    required this.type,
    required this.status,
    required this.principal,
    this.valuationCap,
    this.discountPercent,
    this.interestRate,
    this.maturityDate,
    required this.issueDate,
    required this.hasMfn,
    required this.hasProRata,
    this.roundId,
    this.conversionEventId,
    this.convertedToShareClassId,
    this.sharesReceived,
    this.notes,
    this.maturityBehavior,
    required this.allowsVoluntaryConversion,
    this.liquidityEventBehavior,
    this.liquidityPayoutMultiple,
    this.dissolutionBehavior,
    this.preferredShareClassId,
    this.qualifiedFinancingThreshold,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['stakeholder_id'] = Variable<String>(stakeholderId);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    map['principal'] = Variable<double>(principal);
    if (!nullToAbsent || valuationCap != null) {
      map['valuation_cap'] = Variable<double>(valuationCap);
    }
    if (!nullToAbsent || discountPercent != null) {
      map['discount_percent'] = Variable<double>(discountPercent);
    }
    if (!nullToAbsent || interestRate != null) {
      map['interest_rate'] = Variable<double>(interestRate);
    }
    if (!nullToAbsent || maturityDate != null) {
      map['maturity_date'] = Variable<DateTime>(maturityDate);
    }
    map['issue_date'] = Variable<DateTime>(issueDate);
    map['has_mfn'] = Variable<bool>(hasMfn);
    map['has_pro_rata'] = Variable<bool>(hasProRata);
    if (!nullToAbsent || roundId != null) {
      map['round_id'] = Variable<String>(roundId);
    }
    if (!nullToAbsent || conversionEventId != null) {
      map['conversion_event_id'] = Variable<String>(conversionEventId);
    }
    if (!nullToAbsent || convertedToShareClassId != null) {
      map['converted_to_share_class_id'] = Variable<String>(
        convertedToShareClassId,
      );
    }
    if (!nullToAbsent || sharesReceived != null) {
      map['shares_received'] = Variable<int>(sharesReceived);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || maturityBehavior != null) {
      map['maturity_behavior'] = Variable<String>(maturityBehavior);
    }
    map['allows_voluntary_conversion'] = Variable<bool>(
      allowsVoluntaryConversion,
    );
    if (!nullToAbsent || liquidityEventBehavior != null) {
      map['liquidity_event_behavior'] = Variable<String>(
        liquidityEventBehavior,
      );
    }
    if (!nullToAbsent || liquidityPayoutMultiple != null) {
      map['liquidity_payout_multiple'] = Variable<double>(
        liquidityPayoutMultiple,
      );
    }
    if (!nullToAbsent || dissolutionBehavior != null) {
      map['dissolution_behavior'] = Variable<String>(dissolutionBehavior);
    }
    if (!nullToAbsent || preferredShareClassId != null) {
      map['preferred_share_class_id'] = Variable<String>(preferredShareClassId);
    }
    if (!nullToAbsent || qualifiedFinancingThreshold != null) {
      map['qualified_financing_threshold'] = Variable<double>(
        qualifiedFinancingThreshold,
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ConvertiblesCompanion toCompanion(bool nullToAbsent) {
    return ConvertiblesCompanion(
      id: Value(id),
      companyId: Value(companyId),
      stakeholderId: Value(stakeholderId),
      type: Value(type),
      status: Value(status),
      principal: Value(principal),
      valuationCap: valuationCap == null && nullToAbsent
          ? const Value.absent()
          : Value(valuationCap),
      discountPercent: discountPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(discountPercent),
      interestRate: interestRate == null && nullToAbsent
          ? const Value.absent()
          : Value(interestRate),
      maturityDate: maturityDate == null && nullToAbsent
          ? const Value.absent()
          : Value(maturityDate),
      issueDate: Value(issueDate),
      hasMfn: Value(hasMfn),
      hasProRata: Value(hasProRata),
      roundId: roundId == null && nullToAbsent
          ? const Value.absent()
          : Value(roundId),
      conversionEventId: conversionEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(conversionEventId),
      convertedToShareClassId: convertedToShareClassId == null && nullToAbsent
          ? const Value.absent()
          : Value(convertedToShareClassId),
      sharesReceived: sharesReceived == null && nullToAbsent
          ? const Value.absent()
          : Value(sharesReceived),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      maturityBehavior: maturityBehavior == null && nullToAbsent
          ? const Value.absent()
          : Value(maturityBehavior),
      allowsVoluntaryConversion: Value(allowsVoluntaryConversion),
      liquidityEventBehavior: liquidityEventBehavior == null && nullToAbsent
          ? const Value.absent()
          : Value(liquidityEventBehavior),
      liquidityPayoutMultiple: liquidityPayoutMultiple == null && nullToAbsent
          ? const Value.absent()
          : Value(liquidityPayoutMultiple),
      dissolutionBehavior: dissolutionBehavior == null && nullToAbsent
          ? const Value.absent()
          : Value(dissolutionBehavior),
      preferredShareClassId: preferredShareClassId == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredShareClassId),
      qualifiedFinancingThreshold:
          qualifiedFinancingThreshold == null && nullToAbsent
          ? const Value.absent()
          : Value(qualifiedFinancingThreshold),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Convertible.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Convertible(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      stakeholderId: serializer.fromJson<String>(json['stakeholderId']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      principal: serializer.fromJson<double>(json['principal']),
      valuationCap: serializer.fromJson<double?>(json['valuationCap']),
      discountPercent: serializer.fromJson<double?>(json['discountPercent']),
      interestRate: serializer.fromJson<double?>(json['interestRate']),
      maturityDate: serializer.fromJson<DateTime?>(json['maturityDate']),
      issueDate: serializer.fromJson<DateTime>(json['issueDate']),
      hasMfn: serializer.fromJson<bool>(json['hasMfn']),
      hasProRata: serializer.fromJson<bool>(json['hasProRata']),
      roundId: serializer.fromJson<String?>(json['roundId']),
      conversionEventId: serializer.fromJson<String?>(
        json['conversionEventId'],
      ),
      convertedToShareClassId: serializer.fromJson<String?>(
        json['convertedToShareClassId'],
      ),
      sharesReceived: serializer.fromJson<int?>(json['sharesReceived']),
      notes: serializer.fromJson<String?>(json['notes']),
      maturityBehavior: serializer.fromJson<String?>(json['maturityBehavior']),
      allowsVoluntaryConversion: serializer.fromJson<bool>(
        json['allowsVoluntaryConversion'],
      ),
      liquidityEventBehavior: serializer.fromJson<String?>(
        json['liquidityEventBehavior'],
      ),
      liquidityPayoutMultiple: serializer.fromJson<double?>(
        json['liquidityPayoutMultiple'],
      ),
      dissolutionBehavior: serializer.fromJson<String?>(
        json['dissolutionBehavior'],
      ),
      preferredShareClassId: serializer.fromJson<String?>(
        json['preferredShareClassId'],
      ),
      qualifiedFinancingThreshold: serializer.fromJson<double?>(
        json['qualifiedFinancingThreshold'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'stakeholderId': serializer.toJson<String>(stakeholderId),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'principal': serializer.toJson<double>(principal),
      'valuationCap': serializer.toJson<double?>(valuationCap),
      'discountPercent': serializer.toJson<double?>(discountPercent),
      'interestRate': serializer.toJson<double?>(interestRate),
      'maturityDate': serializer.toJson<DateTime?>(maturityDate),
      'issueDate': serializer.toJson<DateTime>(issueDate),
      'hasMfn': serializer.toJson<bool>(hasMfn),
      'hasProRata': serializer.toJson<bool>(hasProRata),
      'roundId': serializer.toJson<String?>(roundId),
      'conversionEventId': serializer.toJson<String?>(conversionEventId),
      'convertedToShareClassId': serializer.toJson<String?>(
        convertedToShareClassId,
      ),
      'sharesReceived': serializer.toJson<int?>(sharesReceived),
      'notes': serializer.toJson<String?>(notes),
      'maturityBehavior': serializer.toJson<String?>(maturityBehavior),
      'allowsVoluntaryConversion': serializer.toJson<bool>(
        allowsVoluntaryConversion,
      ),
      'liquidityEventBehavior': serializer.toJson<String?>(
        liquidityEventBehavior,
      ),
      'liquidityPayoutMultiple': serializer.toJson<double?>(
        liquidityPayoutMultiple,
      ),
      'dissolutionBehavior': serializer.toJson<String?>(dissolutionBehavior),
      'preferredShareClassId': serializer.toJson<String?>(
        preferredShareClassId,
      ),
      'qualifiedFinancingThreshold': serializer.toJson<double?>(
        qualifiedFinancingThreshold,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Convertible copyWith({
    String? id,
    String? companyId,
    String? stakeholderId,
    String? type,
    String? status,
    double? principal,
    Value<double?> valuationCap = const Value.absent(),
    Value<double?> discountPercent = const Value.absent(),
    Value<double?> interestRate = const Value.absent(),
    Value<DateTime?> maturityDate = const Value.absent(),
    DateTime? issueDate,
    bool? hasMfn,
    bool? hasProRata,
    Value<String?> roundId = const Value.absent(),
    Value<String?> conversionEventId = const Value.absent(),
    Value<String?> convertedToShareClassId = const Value.absent(),
    Value<int?> sharesReceived = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> maturityBehavior = const Value.absent(),
    bool? allowsVoluntaryConversion,
    Value<String?> liquidityEventBehavior = const Value.absent(),
    Value<double?> liquidityPayoutMultiple = const Value.absent(),
    Value<String?> dissolutionBehavior = const Value.absent(),
    Value<String?> preferredShareClassId = const Value.absent(),
    Value<double?> qualifiedFinancingThreshold = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Convertible(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    stakeholderId: stakeholderId ?? this.stakeholderId,
    type: type ?? this.type,
    status: status ?? this.status,
    principal: principal ?? this.principal,
    valuationCap: valuationCap.present ? valuationCap.value : this.valuationCap,
    discountPercent: discountPercent.present
        ? discountPercent.value
        : this.discountPercent,
    interestRate: interestRate.present ? interestRate.value : this.interestRate,
    maturityDate: maturityDate.present ? maturityDate.value : this.maturityDate,
    issueDate: issueDate ?? this.issueDate,
    hasMfn: hasMfn ?? this.hasMfn,
    hasProRata: hasProRata ?? this.hasProRata,
    roundId: roundId.present ? roundId.value : this.roundId,
    conversionEventId: conversionEventId.present
        ? conversionEventId.value
        : this.conversionEventId,
    convertedToShareClassId: convertedToShareClassId.present
        ? convertedToShareClassId.value
        : this.convertedToShareClassId,
    sharesReceived: sharesReceived.present
        ? sharesReceived.value
        : this.sharesReceived,
    notes: notes.present ? notes.value : this.notes,
    maturityBehavior: maturityBehavior.present
        ? maturityBehavior.value
        : this.maturityBehavior,
    allowsVoluntaryConversion:
        allowsVoluntaryConversion ?? this.allowsVoluntaryConversion,
    liquidityEventBehavior: liquidityEventBehavior.present
        ? liquidityEventBehavior.value
        : this.liquidityEventBehavior,
    liquidityPayoutMultiple: liquidityPayoutMultiple.present
        ? liquidityPayoutMultiple.value
        : this.liquidityPayoutMultiple,
    dissolutionBehavior: dissolutionBehavior.present
        ? dissolutionBehavior.value
        : this.dissolutionBehavior,
    preferredShareClassId: preferredShareClassId.present
        ? preferredShareClassId.value
        : this.preferredShareClassId,
    qualifiedFinancingThreshold: qualifiedFinancingThreshold.present
        ? qualifiedFinancingThreshold.value
        : this.qualifiedFinancingThreshold,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Convertible copyWithCompanion(ConvertiblesCompanion data) {
    return Convertible(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      stakeholderId: data.stakeholderId.present
          ? data.stakeholderId.value
          : this.stakeholderId,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      principal: data.principal.present ? data.principal.value : this.principal,
      valuationCap: data.valuationCap.present
          ? data.valuationCap.value
          : this.valuationCap,
      discountPercent: data.discountPercent.present
          ? data.discountPercent.value
          : this.discountPercent,
      interestRate: data.interestRate.present
          ? data.interestRate.value
          : this.interestRate,
      maturityDate: data.maturityDate.present
          ? data.maturityDate.value
          : this.maturityDate,
      issueDate: data.issueDate.present ? data.issueDate.value : this.issueDate,
      hasMfn: data.hasMfn.present ? data.hasMfn.value : this.hasMfn,
      hasProRata: data.hasProRata.present
          ? data.hasProRata.value
          : this.hasProRata,
      roundId: data.roundId.present ? data.roundId.value : this.roundId,
      conversionEventId: data.conversionEventId.present
          ? data.conversionEventId.value
          : this.conversionEventId,
      convertedToShareClassId: data.convertedToShareClassId.present
          ? data.convertedToShareClassId.value
          : this.convertedToShareClassId,
      sharesReceived: data.sharesReceived.present
          ? data.sharesReceived.value
          : this.sharesReceived,
      notes: data.notes.present ? data.notes.value : this.notes,
      maturityBehavior: data.maturityBehavior.present
          ? data.maturityBehavior.value
          : this.maturityBehavior,
      allowsVoluntaryConversion: data.allowsVoluntaryConversion.present
          ? data.allowsVoluntaryConversion.value
          : this.allowsVoluntaryConversion,
      liquidityEventBehavior: data.liquidityEventBehavior.present
          ? data.liquidityEventBehavior.value
          : this.liquidityEventBehavior,
      liquidityPayoutMultiple: data.liquidityPayoutMultiple.present
          ? data.liquidityPayoutMultiple.value
          : this.liquidityPayoutMultiple,
      dissolutionBehavior: data.dissolutionBehavior.present
          ? data.dissolutionBehavior.value
          : this.dissolutionBehavior,
      preferredShareClassId: data.preferredShareClassId.present
          ? data.preferredShareClassId.value
          : this.preferredShareClassId,
      qualifiedFinancingThreshold: data.qualifiedFinancingThreshold.present
          ? data.qualifiedFinancingThreshold.value
          : this.qualifiedFinancingThreshold,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Convertible(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('stakeholderId: $stakeholderId, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('principal: $principal, ')
          ..write('valuationCap: $valuationCap, ')
          ..write('discountPercent: $discountPercent, ')
          ..write('interestRate: $interestRate, ')
          ..write('maturityDate: $maturityDate, ')
          ..write('issueDate: $issueDate, ')
          ..write('hasMfn: $hasMfn, ')
          ..write('hasProRata: $hasProRata, ')
          ..write('roundId: $roundId, ')
          ..write('conversionEventId: $conversionEventId, ')
          ..write('convertedToShareClassId: $convertedToShareClassId, ')
          ..write('sharesReceived: $sharesReceived, ')
          ..write('notes: $notes, ')
          ..write('maturityBehavior: $maturityBehavior, ')
          ..write('allowsVoluntaryConversion: $allowsVoluntaryConversion, ')
          ..write('liquidityEventBehavior: $liquidityEventBehavior, ')
          ..write('liquidityPayoutMultiple: $liquidityPayoutMultiple, ')
          ..write('dissolutionBehavior: $dissolutionBehavior, ')
          ..write('preferredShareClassId: $preferredShareClassId, ')
          ..write('qualifiedFinancingThreshold: $qualifiedFinancingThreshold, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    companyId,
    stakeholderId,
    type,
    status,
    principal,
    valuationCap,
    discountPercent,
    interestRate,
    maturityDate,
    issueDate,
    hasMfn,
    hasProRata,
    roundId,
    conversionEventId,
    convertedToShareClassId,
    sharesReceived,
    notes,
    maturityBehavior,
    allowsVoluntaryConversion,
    liquidityEventBehavior,
    liquidityPayoutMultiple,
    dissolutionBehavior,
    preferredShareClassId,
    qualifiedFinancingThreshold,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Convertible &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.stakeholderId == this.stakeholderId &&
          other.type == this.type &&
          other.status == this.status &&
          other.principal == this.principal &&
          other.valuationCap == this.valuationCap &&
          other.discountPercent == this.discountPercent &&
          other.interestRate == this.interestRate &&
          other.maturityDate == this.maturityDate &&
          other.issueDate == this.issueDate &&
          other.hasMfn == this.hasMfn &&
          other.hasProRata == this.hasProRata &&
          other.roundId == this.roundId &&
          other.conversionEventId == this.conversionEventId &&
          other.convertedToShareClassId == this.convertedToShareClassId &&
          other.sharesReceived == this.sharesReceived &&
          other.notes == this.notes &&
          other.maturityBehavior == this.maturityBehavior &&
          other.allowsVoluntaryConversion == this.allowsVoluntaryConversion &&
          other.liquidityEventBehavior == this.liquidityEventBehavior &&
          other.liquidityPayoutMultiple == this.liquidityPayoutMultiple &&
          other.dissolutionBehavior == this.dissolutionBehavior &&
          other.preferredShareClassId == this.preferredShareClassId &&
          other.qualifiedFinancingThreshold ==
              this.qualifiedFinancingThreshold &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ConvertiblesCompanion extends UpdateCompanion<Convertible> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> stakeholderId;
  final Value<String> type;
  final Value<String> status;
  final Value<double> principal;
  final Value<double?> valuationCap;
  final Value<double?> discountPercent;
  final Value<double?> interestRate;
  final Value<DateTime?> maturityDate;
  final Value<DateTime> issueDate;
  final Value<bool> hasMfn;
  final Value<bool> hasProRata;
  final Value<String?> roundId;
  final Value<String?> conversionEventId;
  final Value<String?> convertedToShareClassId;
  final Value<int?> sharesReceived;
  final Value<String?> notes;
  final Value<String?> maturityBehavior;
  final Value<bool> allowsVoluntaryConversion;
  final Value<String?> liquidityEventBehavior;
  final Value<double?> liquidityPayoutMultiple;
  final Value<String?> dissolutionBehavior;
  final Value<String?> preferredShareClassId;
  final Value<double?> qualifiedFinancingThreshold;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ConvertiblesCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.stakeholderId = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.principal = const Value.absent(),
    this.valuationCap = const Value.absent(),
    this.discountPercent = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.maturityDate = const Value.absent(),
    this.issueDate = const Value.absent(),
    this.hasMfn = const Value.absent(),
    this.hasProRata = const Value.absent(),
    this.roundId = const Value.absent(),
    this.conversionEventId = const Value.absent(),
    this.convertedToShareClassId = const Value.absent(),
    this.sharesReceived = const Value.absent(),
    this.notes = const Value.absent(),
    this.maturityBehavior = const Value.absent(),
    this.allowsVoluntaryConversion = const Value.absent(),
    this.liquidityEventBehavior = const Value.absent(),
    this.liquidityPayoutMultiple = const Value.absent(),
    this.dissolutionBehavior = const Value.absent(),
    this.preferredShareClassId = const Value.absent(),
    this.qualifiedFinancingThreshold = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConvertiblesCompanion.insert({
    required String id,
    required String companyId,
    required String stakeholderId,
    required String type,
    this.status = const Value.absent(),
    required double principal,
    this.valuationCap = const Value.absent(),
    this.discountPercent = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.maturityDate = const Value.absent(),
    required DateTime issueDate,
    this.hasMfn = const Value.absent(),
    this.hasProRata = const Value.absent(),
    this.roundId = const Value.absent(),
    this.conversionEventId = const Value.absent(),
    this.convertedToShareClassId = const Value.absent(),
    this.sharesReceived = const Value.absent(),
    this.notes = const Value.absent(),
    this.maturityBehavior = const Value.absent(),
    this.allowsVoluntaryConversion = const Value.absent(),
    this.liquidityEventBehavior = const Value.absent(),
    this.liquidityPayoutMultiple = const Value.absent(),
    this.dissolutionBehavior = const Value.absent(),
    this.preferredShareClassId = const Value.absent(),
    this.qualifiedFinancingThreshold = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       stakeholderId = Value(stakeholderId),
       type = Value(type),
       principal = Value(principal),
       issueDate = Value(issueDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Convertible> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? stakeholderId,
    Expression<String>? type,
    Expression<String>? status,
    Expression<double>? principal,
    Expression<double>? valuationCap,
    Expression<double>? discountPercent,
    Expression<double>? interestRate,
    Expression<DateTime>? maturityDate,
    Expression<DateTime>? issueDate,
    Expression<bool>? hasMfn,
    Expression<bool>? hasProRata,
    Expression<String>? roundId,
    Expression<String>? conversionEventId,
    Expression<String>? convertedToShareClassId,
    Expression<int>? sharesReceived,
    Expression<String>? notes,
    Expression<String>? maturityBehavior,
    Expression<bool>? allowsVoluntaryConversion,
    Expression<String>? liquidityEventBehavior,
    Expression<double>? liquidityPayoutMultiple,
    Expression<String>? dissolutionBehavior,
    Expression<String>? preferredShareClassId,
    Expression<double>? qualifiedFinancingThreshold,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (stakeholderId != null) 'stakeholder_id': stakeholderId,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (principal != null) 'principal': principal,
      if (valuationCap != null) 'valuation_cap': valuationCap,
      if (discountPercent != null) 'discount_percent': discountPercent,
      if (interestRate != null) 'interest_rate': interestRate,
      if (maturityDate != null) 'maturity_date': maturityDate,
      if (issueDate != null) 'issue_date': issueDate,
      if (hasMfn != null) 'has_mfn': hasMfn,
      if (hasProRata != null) 'has_pro_rata': hasProRata,
      if (roundId != null) 'round_id': roundId,
      if (conversionEventId != null) 'conversion_event_id': conversionEventId,
      if (convertedToShareClassId != null)
        'converted_to_share_class_id': convertedToShareClassId,
      if (sharesReceived != null) 'shares_received': sharesReceived,
      if (notes != null) 'notes': notes,
      if (maturityBehavior != null) 'maturity_behavior': maturityBehavior,
      if (allowsVoluntaryConversion != null)
        'allows_voluntary_conversion': allowsVoluntaryConversion,
      if (liquidityEventBehavior != null)
        'liquidity_event_behavior': liquidityEventBehavior,
      if (liquidityPayoutMultiple != null)
        'liquidity_payout_multiple': liquidityPayoutMultiple,
      if (dissolutionBehavior != null)
        'dissolution_behavior': dissolutionBehavior,
      if (preferredShareClassId != null)
        'preferred_share_class_id': preferredShareClassId,
      if (qualifiedFinancingThreshold != null)
        'qualified_financing_threshold': qualifiedFinancingThreshold,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConvertiblesCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? stakeholderId,
    Value<String>? type,
    Value<String>? status,
    Value<double>? principal,
    Value<double?>? valuationCap,
    Value<double?>? discountPercent,
    Value<double?>? interestRate,
    Value<DateTime?>? maturityDate,
    Value<DateTime>? issueDate,
    Value<bool>? hasMfn,
    Value<bool>? hasProRata,
    Value<String?>? roundId,
    Value<String?>? conversionEventId,
    Value<String?>? convertedToShareClassId,
    Value<int?>? sharesReceived,
    Value<String?>? notes,
    Value<String?>? maturityBehavior,
    Value<bool>? allowsVoluntaryConversion,
    Value<String?>? liquidityEventBehavior,
    Value<double?>? liquidityPayoutMultiple,
    Value<String?>? dissolutionBehavior,
    Value<String?>? preferredShareClassId,
    Value<double?>? qualifiedFinancingThreshold,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ConvertiblesCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      stakeholderId: stakeholderId ?? this.stakeholderId,
      type: type ?? this.type,
      status: status ?? this.status,
      principal: principal ?? this.principal,
      valuationCap: valuationCap ?? this.valuationCap,
      discountPercent: discountPercent ?? this.discountPercent,
      interestRate: interestRate ?? this.interestRate,
      maturityDate: maturityDate ?? this.maturityDate,
      issueDate: issueDate ?? this.issueDate,
      hasMfn: hasMfn ?? this.hasMfn,
      hasProRata: hasProRata ?? this.hasProRata,
      roundId: roundId ?? this.roundId,
      conversionEventId: conversionEventId ?? this.conversionEventId,
      convertedToShareClassId:
          convertedToShareClassId ?? this.convertedToShareClassId,
      sharesReceived: sharesReceived ?? this.sharesReceived,
      notes: notes ?? this.notes,
      maturityBehavior: maturityBehavior ?? this.maturityBehavior,
      allowsVoluntaryConversion:
          allowsVoluntaryConversion ?? this.allowsVoluntaryConversion,
      liquidityEventBehavior:
          liquidityEventBehavior ?? this.liquidityEventBehavior,
      liquidityPayoutMultiple:
          liquidityPayoutMultiple ?? this.liquidityPayoutMultiple,
      dissolutionBehavior: dissolutionBehavior ?? this.dissolutionBehavior,
      preferredShareClassId:
          preferredShareClassId ?? this.preferredShareClassId,
      qualifiedFinancingThreshold:
          qualifiedFinancingThreshold ?? this.qualifiedFinancingThreshold,
      createdAt: createdAt ?? this.createdAt,
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
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (stakeholderId.present) {
      map['stakeholder_id'] = Variable<String>(stakeholderId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (principal.present) {
      map['principal'] = Variable<double>(principal.value);
    }
    if (valuationCap.present) {
      map['valuation_cap'] = Variable<double>(valuationCap.value);
    }
    if (discountPercent.present) {
      map['discount_percent'] = Variable<double>(discountPercent.value);
    }
    if (interestRate.present) {
      map['interest_rate'] = Variable<double>(interestRate.value);
    }
    if (maturityDate.present) {
      map['maturity_date'] = Variable<DateTime>(maturityDate.value);
    }
    if (issueDate.present) {
      map['issue_date'] = Variable<DateTime>(issueDate.value);
    }
    if (hasMfn.present) {
      map['has_mfn'] = Variable<bool>(hasMfn.value);
    }
    if (hasProRata.present) {
      map['has_pro_rata'] = Variable<bool>(hasProRata.value);
    }
    if (roundId.present) {
      map['round_id'] = Variable<String>(roundId.value);
    }
    if (conversionEventId.present) {
      map['conversion_event_id'] = Variable<String>(conversionEventId.value);
    }
    if (convertedToShareClassId.present) {
      map['converted_to_share_class_id'] = Variable<String>(
        convertedToShareClassId.value,
      );
    }
    if (sharesReceived.present) {
      map['shares_received'] = Variable<int>(sharesReceived.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (maturityBehavior.present) {
      map['maturity_behavior'] = Variable<String>(maturityBehavior.value);
    }
    if (allowsVoluntaryConversion.present) {
      map['allows_voluntary_conversion'] = Variable<bool>(
        allowsVoluntaryConversion.value,
      );
    }
    if (liquidityEventBehavior.present) {
      map['liquidity_event_behavior'] = Variable<String>(
        liquidityEventBehavior.value,
      );
    }
    if (liquidityPayoutMultiple.present) {
      map['liquidity_payout_multiple'] = Variable<double>(
        liquidityPayoutMultiple.value,
      );
    }
    if (dissolutionBehavior.present) {
      map['dissolution_behavior'] = Variable<String>(dissolutionBehavior.value);
    }
    if (preferredShareClassId.present) {
      map['preferred_share_class_id'] = Variable<String>(
        preferredShareClassId.value,
      );
    }
    if (qualifiedFinancingThreshold.present) {
      map['qualified_financing_threshold'] = Variable<double>(
        qualifiedFinancingThreshold.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConvertiblesCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('stakeholderId: $stakeholderId, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('principal: $principal, ')
          ..write('valuationCap: $valuationCap, ')
          ..write('discountPercent: $discountPercent, ')
          ..write('interestRate: $interestRate, ')
          ..write('maturityDate: $maturityDate, ')
          ..write('issueDate: $issueDate, ')
          ..write('hasMfn: $hasMfn, ')
          ..write('hasProRata: $hasProRata, ')
          ..write('roundId: $roundId, ')
          ..write('conversionEventId: $conversionEventId, ')
          ..write('convertedToShareClassId: $convertedToShareClassId, ')
          ..write('sharesReceived: $sharesReceived, ')
          ..write('notes: $notes, ')
          ..write('maturityBehavior: $maturityBehavior, ')
          ..write('allowsVoluntaryConversion: $allowsVoluntaryConversion, ')
          ..write('liquidityEventBehavior: $liquidityEventBehavior, ')
          ..write('liquidityPayoutMultiple: $liquidityPayoutMultiple, ')
          ..write('dissolutionBehavior: $dissolutionBehavior, ')
          ..write('preferredShareClassId: $preferredShareClassId, ')
          ..write('qualifiedFinancingThreshold: $qualifiedFinancingThreshold, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EsopPoolsTable extends EsopPools
    with TableInfo<$EsopPoolsTable, EsopPool> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EsopPoolsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _poolSizeMeta = const VerificationMeta(
    'poolSize',
  );
  @override
  late final GeneratedColumn<int> poolSize = GeneratedColumn<int>(
    'pool_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetPercentageMeta = const VerificationMeta(
    'targetPercentage',
  );
  @override
  late final GeneratedColumn<double> targetPercentage = GeneratedColumn<double>(
    'target_percentage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _establishedDateMeta = const VerificationMeta(
    'establishedDate',
  );
  @override
  late final GeneratedColumn<DateTime> establishedDate =
      GeneratedColumn<DateTime>(
        'established_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _resolutionReferenceMeta =
      const VerificationMeta('resolutionReference');
  @override
  late final GeneratedColumn<String> resolutionReference =
      GeneratedColumn<String>(
        'resolution_reference',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _roundIdMeta = const VerificationMeta(
    'roundId',
  );
  @override
  late final GeneratedColumn<String> roundId = GeneratedColumn<String>(
    'round_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rounds (id)',
    ),
  );
  static const VerificationMeta _defaultVestingScheduleIdMeta =
      const VerificationMeta('defaultVestingScheduleId');
  @override
  late final GeneratedColumn<String> defaultVestingScheduleId =
      GeneratedColumn<String>(
        'default_vesting_schedule_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _strikePriceMethodMeta = const VerificationMeta(
    'strikePriceMethod',
  );
  @override
  late final GeneratedColumn<String> strikePriceMethod =
      GeneratedColumn<String>(
        'strike_price_method',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('fmv'),
      );
  static const VerificationMeta _defaultStrikePriceMeta =
      const VerificationMeta('defaultStrikePrice');
  @override
  late final GeneratedColumn<double> defaultStrikePrice =
      GeneratedColumn<double>(
        'default_strike_price',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _defaultExpiryYearsMeta =
      const VerificationMeta('defaultExpiryYears');
  @override
  late final GeneratedColumn<int> defaultExpiryYears = GeneratedColumn<int>(
    'default_expiry_years',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    status,
    poolSize,
    targetPercentage,
    establishedDate,
    resolutionReference,
    roundId,
    defaultVestingScheduleId,
    strikePriceMethod,
    defaultStrikePrice,
    defaultExpiryYears,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'esop_pools';
  @override
  VerificationContext validateIntegrity(
    Insertable<EsopPool> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('pool_size')) {
      context.handle(
        _poolSizeMeta,
        poolSize.isAcceptableOrUnknown(data['pool_size']!, _poolSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_poolSizeMeta);
    }
    if (data.containsKey('target_percentage')) {
      context.handle(
        _targetPercentageMeta,
        targetPercentage.isAcceptableOrUnknown(
          data['target_percentage']!,
          _targetPercentageMeta,
        ),
      );
    }
    if (data.containsKey('established_date')) {
      context.handle(
        _establishedDateMeta,
        establishedDate.isAcceptableOrUnknown(
          data['established_date']!,
          _establishedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_establishedDateMeta);
    }
    if (data.containsKey('resolution_reference')) {
      context.handle(
        _resolutionReferenceMeta,
        resolutionReference.isAcceptableOrUnknown(
          data['resolution_reference']!,
          _resolutionReferenceMeta,
        ),
      );
    }
    if (data.containsKey('round_id')) {
      context.handle(
        _roundIdMeta,
        roundId.isAcceptableOrUnknown(data['round_id']!, _roundIdMeta),
      );
    }
    if (data.containsKey('default_vesting_schedule_id')) {
      context.handle(
        _defaultVestingScheduleIdMeta,
        defaultVestingScheduleId.isAcceptableOrUnknown(
          data['default_vesting_schedule_id']!,
          _defaultVestingScheduleIdMeta,
        ),
      );
    }
    if (data.containsKey('strike_price_method')) {
      context.handle(
        _strikePriceMethodMeta,
        strikePriceMethod.isAcceptableOrUnknown(
          data['strike_price_method']!,
          _strikePriceMethodMeta,
        ),
      );
    }
    if (data.containsKey('default_strike_price')) {
      context.handle(
        _defaultStrikePriceMeta,
        defaultStrikePrice.isAcceptableOrUnknown(
          data['default_strike_price']!,
          _defaultStrikePriceMeta,
        ),
      );
    }
    if (data.containsKey('default_expiry_years')) {
      context.handle(
        _defaultExpiryYearsMeta,
        defaultExpiryYears.isAcceptableOrUnknown(
          data['default_expiry_years']!,
          _defaultExpiryYearsMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  EsopPool map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EsopPool(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      poolSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pool_size'],
      )!,
      targetPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_percentage'],
      ),
      establishedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}established_date'],
      )!,
      resolutionReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution_reference'],
      ),
      roundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}round_id'],
      ),
      defaultVestingScheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_vesting_schedule_id'],
      ),
      strikePriceMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strike_price_method'],
      )!,
      defaultStrikePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_strike_price'],
      ),
      defaultExpiryYears: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_expiry_years'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EsopPoolsTable createAlias(String alias) {
    return $EsopPoolsTable(attachedDatabase, alias);
  }
}

class EsopPool extends DataClass implements Insertable<EsopPool> {
  final String id;
  final String companyId;
  final String name;
  final String status;
  final int poolSize;
  final double? targetPercentage;
  final DateTime establishedDate;
  final String? resolutionReference;
  final String? roundId;
  final String? defaultVestingScheduleId;
  final String strikePriceMethod;
  final double? defaultStrikePrice;
  final int defaultExpiryYears;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EsopPool({
    required this.id,
    required this.companyId,
    required this.name,
    required this.status,
    required this.poolSize,
    this.targetPercentage,
    required this.establishedDate,
    this.resolutionReference,
    this.roundId,
    this.defaultVestingScheduleId,
    required this.strikePriceMethod,
    this.defaultStrikePrice,
    required this.defaultExpiryYears,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['name'] = Variable<String>(name);
    map['status'] = Variable<String>(status);
    map['pool_size'] = Variable<int>(poolSize);
    if (!nullToAbsent || targetPercentage != null) {
      map['target_percentage'] = Variable<double>(targetPercentage);
    }
    map['established_date'] = Variable<DateTime>(establishedDate);
    if (!nullToAbsent || resolutionReference != null) {
      map['resolution_reference'] = Variable<String>(resolutionReference);
    }
    if (!nullToAbsent || roundId != null) {
      map['round_id'] = Variable<String>(roundId);
    }
    if (!nullToAbsent || defaultVestingScheduleId != null) {
      map['default_vesting_schedule_id'] = Variable<String>(
        defaultVestingScheduleId,
      );
    }
    map['strike_price_method'] = Variable<String>(strikePriceMethod);
    if (!nullToAbsent || defaultStrikePrice != null) {
      map['default_strike_price'] = Variable<double>(defaultStrikePrice);
    }
    map['default_expiry_years'] = Variable<int>(defaultExpiryYears);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EsopPoolsCompanion toCompanion(bool nullToAbsent) {
    return EsopPoolsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      status: Value(status),
      poolSize: Value(poolSize),
      targetPercentage: targetPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(targetPercentage),
      establishedDate: Value(establishedDate),
      resolutionReference: resolutionReference == null && nullToAbsent
          ? const Value.absent()
          : Value(resolutionReference),
      roundId: roundId == null && nullToAbsent
          ? const Value.absent()
          : Value(roundId),
      defaultVestingScheduleId: defaultVestingScheduleId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultVestingScheduleId),
      strikePriceMethod: Value(strikePriceMethod),
      defaultStrikePrice: defaultStrikePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultStrikePrice),
      defaultExpiryYears: Value(defaultExpiryYears),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EsopPool.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EsopPool(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      status: serializer.fromJson<String>(json['status']),
      poolSize: serializer.fromJson<int>(json['poolSize']),
      targetPercentage: serializer.fromJson<double?>(json['targetPercentage']),
      establishedDate: serializer.fromJson<DateTime>(json['establishedDate']),
      resolutionReference: serializer.fromJson<String?>(
        json['resolutionReference'],
      ),
      roundId: serializer.fromJson<String?>(json['roundId']),
      defaultVestingScheduleId: serializer.fromJson<String?>(
        json['defaultVestingScheduleId'],
      ),
      strikePriceMethod: serializer.fromJson<String>(json['strikePriceMethod']),
      defaultStrikePrice: serializer.fromJson<double?>(
        json['defaultStrikePrice'],
      ),
      defaultExpiryYears: serializer.fromJson<int>(json['defaultExpiryYears']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'name': serializer.toJson<String>(name),
      'status': serializer.toJson<String>(status),
      'poolSize': serializer.toJson<int>(poolSize),
      'targetPercentage': serializer.toJson<double?>(targetPercentage),
      'establishedDate': serializer.toJson<DateTime>(establishedDate),
      'resolutionReference': serializer.toJson<String?>(resolutionReference),
      'roundId': serializer.toJson<String?>(roundId),
      'defaultVestingScheduleId': serializer.toJson<String?>(
        defaultVestingScheduleId,
      ),
      'strikePriceMethod': serializer.toJson<String>(strikePriceMethod),
      'defaultStrikePrice': serializer.toJson<double?>(defaultStrikePrice),
      'defaultExpiryYears': serializer.toJson<int>(defaultExpiryYears),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EsopPool copyWith({
    String? id,
    String? companyId,
    String? name,
    String? status,
    int? poolSize,
    Value<double?> targetPercentage = const Value.absent(),
    DateTime? establishedDate,
    Value<String?> resolutionReference = const Value.absent(),
    Value<String?> roundId = const Value.absent(),
    Value<String?> defaultVestingScheduleId = const Value.absent(),
    String? strikePriceMethod,
    Value<double?> defaultStrikePrice = const Value.absent(),
    int? defaultExpiryYears,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => EsopPool(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    status: status ?? this.status,
    poolSize: poolSize ?? this.poolSize,
    targetPercentage: targetPercentage.present
        ? targetPercentage.value
        : this.targetPercentage,
    establishedDate: establishedDate ?? this.establishedDate,
    resolutionReference: resolutionReference.present
        ? resolutionReference.value
        : this.resolutionReference,
    roundId: roundId.present ? roundId.value : this.roundId,
    defaultVestingScheduleId: defaultVestingScheduleId.present
        ? defaultVestingScheduleId.value
        : this.defaultVestingScheduleId,
    strikePriceMethod: strikePriceMethod ?? this.strikePriceMethod,
    defaultStrikePrice: defaultStrikePrice.present
        ? defaultStrikePrice.value
        : this.defaultStrikePrice,
    defaultExpiryYears: defaultExpiryYears ?? this.defaultExpiryYears,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EsopPool copyWithCompanion(EsopPoolsCompanion data) {
    return EsopPool(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      poolSize: data.poolSize.present ? data.poolSize.value : this.poolSize,
      targetPercentage: data.targetPercentage.present
          ? data.targetPercentage.value
          : this.targetPercentage,
      establishedDate: data.establishedDate.present
          ? data.establishedDate.value
          : this.establishedDate,
      resolutionReference: data.resolutionReference.present
          ? data.resolutionReference.value
          : this.resolutionReference,
      roundId: data.roundId.present ? data.roundId.value : this.roundId,
      defaultVestingScheduleId: data.defaultVestingScheduleId.present
          ? data.defaultVestingScheduleId.value
          : this.defaultVestingScheduleId,
      strikePriceMethod: data.strikePriceMethod.present
          ? data.strikePriceMethod.value
          : this.strikePriceMethod,
      defaultStrikePrice: data.defaultStrikePrice.present
          ? data.defaultStrikePrice.value
          : this.defaultStrikePrice,
      defaultExpiryYears: data.defaultExpiryYears.present
          ? data.defaultExpiryYears.value
          : this.defaultExpiryYears,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EsopPool(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('poolSize: $poolSize, ')
          ..write('targetPercentage: $targetPercentage, ')
          ..write('establishedDate: $establishedDate, ')
          ..write('resolutionReference: $resolutionReference, ')
          ..write('roundId: $roundId, ')
          ..write('defaultVestingScheduleId: $defaultVestingScheduleId, ')
          ..write('strikePriceMethod: $strikePriceMethod, ')
          ..write('defaultStrikePrice: $defaultStrikePrice, ')
          ..write('defaultExpiryYears: $defaultExpiryYears, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    name,
    status,
    poolSize,
    targetPercentage,
    establishedDate,
    resolutionReference,
    roundId,
    defaultVestingScheduleId,
    strikePriceMethod,
    defaultStrikePrice,
    defaultExpiryYears,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EsopPool &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.status == this.status &&
          other.poolSize == this.poolSize &&
          other.targetPercentage == this.targetPercentage &&
          other.establishedDate == this.establishedDate &&
          other.resolutionReference == this.resolutionReference &&
          other.roundId == this.roundId &&
          other.defaultVestingScheduleId == this.defaultVestingScheduleId &&
          other.strikePriceMethod == this.strikePriceMethod &&
          other.defaultStrikePrice == this.defaultStrikePrice &&
          other.defaultExpiryYears == this.defaultExpiryYears &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EsopPoolsCompanion extends UpdateCompanion<EsopPool> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> name;
  final Value<String> status;
  final Value<int> poolSize;
  final Value<double?> targetPercentage;
  final Value<DateTime> establishedDate;
  final Value<String?> resolutionReference;
  final Value<String?> roundId;
  final Value<String?> defaultVestingScheduleId;
  final Value<String> strikePriceMethod;
  final Value<double?> defaultStrikePrice;
  final Value<int> defaultExpiryYears;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EsopPoolsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.poolSize = const Value.absent(),
    this.targetPercentage = const Value.absent(),
    this.establishedDate = const Value.absent(),
    this.resolutionReference = const Value.absent(),
    this.roundId = const Value.absent(),
    this.defaultVestingScheduleId = const Value.absent(),
    this.strikePriceMethod = const Value.absent(),
    this.defaultStrikePrice = const Value.absent(),
    this.defaultExpiryYears = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EsopPoolsCompanion.insert({
    required String id,
    required String companyId,
    required String name,
    this.status = const Value.absent(),
    required int poolSize,
    this.targetPercentage = const Value.absent(),
    required DateTime establishedDate,
    this.resolutionReference = const Value.absent(),
    this.roundId = const Value.absent(),
    this.defaultVestingScheduleId = const Value.absent(),
    this.strikePriceMethod = const Value.absent(),
    this.defaultStrikePrice = const Value.absent(),
    this.defaultExpiryYears = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       name = Value(name),
       poolSize = Value(poolSize),
       establishedDate = Value(establishedDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<EsopPool> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? name,
    Expression<String>? status,
    Expression<int>? poolSize,
    Expression<double>? targetPercentage,
    Expression<DateTime>? establishedDate,
    Expression<String>? resolutionReference,
    Expression<String>? roundId,
    Expression<String>? defaultVestingScheduleId,
    Expression<String>? strikePriceMethod,
    Expression<double>? defaultStrikePrice,
    Expression<int>? defaultExpiryYears,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (poolSize != null) 'pool_size': poolSize,
      if (targetPercentage != null) 'target_percentage': targetPercentage,
      if (establishedDate != null) 'established_date': establishedDate,
      if (resolutionReference != null)
        'resolution_reference': resolutionReference,
      if (roundId != null) 'round_id': roundId,
      if (defaultVestingScheduleId != null)
        'default_vesting_schedule_id': defaultVestingScheduleId,
      if (strikePriceMethod != null) 'strike_price_method': strikePriceMethod,
      if (defaultStrikePrice != null)
        'default_strike_price': defaultStrikePrice,
      if (defaultExpiryYears != null)
        'default_expiry_years': defaultExpiryYears,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EsopPoolsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? name,
    Value<String>? status,
    Value<int>? poolSize,
    Value<double?>? targetPercentage,
    Value<DateTime>? establishedDate,
    Value<String?>? resolutionReference,
    Value<String?>? roundId,
    Value<String?>? defaultVestingScheduleId,
    Value<String>? strikePriceMethod,
    Value<double?>? defaultStrikePrice,
    Value<int>? defaultExpiryYears,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return EsopPoolsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      status: status ?? this.status,
      poolSize: poolSize ?? this.poolSize,
      targetPercentage: targetPercentage ?? this.targetPercentage,
      establishedDate: establishedDate ?? this.establishedDate,
      resolutionReference: resolutionReference ?? this.resolutionReference,
      roundId: roundId ?? this.roundId,
      defaultVestingScheduleId:
          defaultVestingScheduleId ?? this.defaultVestingScheduleId,
      strikePriceMethod: strikePriceMethod ?? this.strikePriceMethod,
      defaultStrikePrice: defaultStrikePrice ?? this.defaultStrikePrice,
      defaultExpiryYears: defaultExpiryYears ?? this.defaultExpiryYears,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (poolSize.present) {
      map['pool_size'] = Variable<int>(poolSize.value);
    }
    if (targetPercentage.present) {
      map['target_percentage'] = Variable<double>(targetPercentage.value);
    }
    if (establishedDate.present) {
      map['established_date'] = Variable<DateTime>(establishedDate.value);
    }
    if (resolutionReference.present) {
      map['resolution_reference'] = Variable<String>(resolutionReference.value);
    }
    if (roundId.present) {
      map['round_id'] = Variable<String>(roundId.value);
    }
    if (defaultVestingScheduleId.present) {
      map['default_vesting_schedule_id'] = Variable<String>(
        defaultVestingScheduleId.value,
      );
    }
    if (strikePriceMethod.present) {
      map['strike_price_method'] = Variable<String>(strikePriceMethod.value);
    }
    if (defaultStrikePrice.present) {
      map['default_strike_price'] = Variable<double>(defaultStrikePrice.value);
    }
    if (defaultExpiryYears.present) {
      map['default_expiry_years'] = Variable<int>(defaultExpiryYears.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EsopPoolsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('poolSize: $poolSize, ')
          ..write('targetPercentage: $targetPercentage, ')
          ..write('establishedDate: $establishedDate, ')
          ..write('resolutionReference: $resolutionReference, ')
          ..write('roundId: $roundId, ')
          ..write('defaultVestingScheduleId: $defaultVestingScheduleId, ')
          ..write('strikePriceMethod: $strikePriceMethod, ')
          ..write('defaultStrikePrice: $defaultStrikePrice, ')
          ..write('defaultExpiryYears: $defaultExpiryYears, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OptionGrantsTable extends OptionGrants
    with TableInfo<$OptionGrantsTable, OptionGrant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OptionGrantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _stakeholderIdMeta = const VerificationMeta(
    'stakeholderId',
  );
  @override
  late final GeneratedColumn<String> stakeholderId = GeneratedColumn<String>(
    'stakeholder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stakeholders (id)',
    ),
  );
  static const VerificationMeta _shareClassIdMeta = const VerificationMeta(
    'shareClassId',
  );
  @override
  late final GeneratedColumn<String> shareClassId = GeneratedColumn<String>(
    'share_class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES share_classes (id)',
    ),
  );
  static const VerificationMeta _esopPoolIdMeta = const VerificationMeta(
    'esopPoolId',
  );
  @override
  late final GeneratedColumn<String> esopPoolId = GeneratedColumn<String>(
    'esop_pool_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strikePriceMeta = const VerificationMeta(
    'strikePrice',
  );
  @override
  late final GeneratedColumn<double> strikePrice = GeneratedColumn<double>(
    'strike_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grantDateMeta = const VerificationMeta(
    'grantDate',
  );
  @override
  late final GeneratedColumn<DateTime> grantDate = GeneratedColumn<DateTime>(
    'grant_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exercisedCountMeta = const VerificationMeta(
    'exercisedCount',
  );
  @override
  late final GeneratedColumn<int> exercisedCount = GeneratedColumn<int>(
    'exercised_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cancelledCountMeta = const VerificationMeta(
    'cancelledCount',
  );
  @override
  late final GeneratedColumn<int> cancelledCount = GeneratedColumn<int>(
    'cancelled_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vestingScheduleIdMeta = const VerificationMeta(
    'vestingScheduleId',
  );
  @override
  late final GeneratedColumn<String> vestingScheduleId =
      GeneratedColumn<String>(
        'vesting_schedule_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _roundIdMeta = const VerificationMeta(
    'roundId',
  );
  @override
  late final GeneratedColumn<String> roundId = GeneratedColumn<String>(
    'round_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rounds (id)',
    ),
  );
  static const VerificationMeta _allowsEarlyExerciseMeta =
      const VerificationMeta('allowsEarlyExercise');
  @override
  late final GeneratedColumn<bool> allowsEarlyExercise = GeneratedColumn<bool>(
    'allows_early_exercise',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allows_early_exercise" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    stakeholderId,
    shareClassId,
    esopPoolId,
    status,
    quantity,
    strikePrice,
    grantDate,
    expiryDate,
    exercisedCount,
    cancelledCount,
    vestingScheduleId,
    roundId,
    allowsEarlyExercise,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'option_grants';
  @override
  VerificationContext validateIntegrity(
    Insertable<OptionGrant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('stakeholder_id')) {
      context.handle(
        _stakeholderIdMeta,
        stakeholderId.isAcceptableOrUnknown(
          data['stakeholder_id']!,
          _stakeholderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stakeholderIdMeta);
    }
    if (data.containsKey('share_class_id')) {
      context.handle(
        _shareClassIdMeta,
        shareClassId.isAcceptableOrUnknown(
          data['share_class_id']!,
          _shareClassIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shareClassIdMeta);
    }
    if (data.containsKey('esop_pool_id')) {
      context.handle(
        _esopPoolIdMeta,
        esopPoolId.isAcceptableOrUnknown(
          data['esop_pool_id']!,
          _esopPoolIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('strike_price')) {
      context.handle(
        _strikePriceMeta,
        strikePrice.isAcceptableOrUnknown(
          data['strike_price']!,
          _strikePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_strikePriceMeta);
    }
    if (data.containsKey('grant_date')) {
      context.handle(
        _grantDateMeta,
        grantDate.isAcceptableOrUnknown(data['grant_date']!, _grantDateMeta),
      );
    } else if (isInserting) {
      context.missing(_grantDateMeta);
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_expiryDateMeta);
    }
    if (data.containsKey('exercised_count')) {
      context.handle(
        _exercisedCountMeta,
        exercisedCount.isAcceptableOrUnknown(
          data['exercised_count']!,
          _exercisedCountMeta,
        ),
      );
    }
    if (data.containsKey('cancelled_count')) {
      context.handle(
        _cancelledCountMeta,
        cancelledCount.isAcceptableOrUnknown(
          data['cancelled_count']!,
          _cancelledCountMeta,
        ),
      );
    }
    if (data.containsKey('vesting_schedule_id')) {
      context.handle(
        _vestingScheduleIdMeta,
        vestingScheduleId.isAcceptableOrUnknown(
          data['vesting_schedule_id']!,
          _vestingScheduleIdMeta,
        ),
      );
    }
    if (data.containsKey('round_id')) {
      context.handle(
        _roundIdMeta,
        roundId.isAcceptableOrUnknown(data['round_id']!, _roundIdMeta),
      );
    }
    if (data.containsKey('allows_early_exercise')) {
      context.handle(
        _allowsEarlyExerciseMeta,
        allowsEarlyExercise.isAcceptableOrUnknown(
          data['allows_early_exercise']!,
          _allowsEarlyExerciseMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  OptionGrant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OptionGrant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      stakeholderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stakeholder_id'],
      )!,
      shareClassId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}share_class_id'],
      )!,
      esopPoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}esop_pool_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      strikePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}strike_price'],
      )!,
      grantDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}grant_date'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      )!,
      exercisedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercised_count'],
      )!,
      cancelledCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cancelled_count'],
      )!,
      vestingScheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vesting_schedule_id'],
      ),
      roundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}round_id'],
      ),
      allowsEarlyExercise: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allows_early_exercise'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OptionGrantsTable createAlias(String alias) {
    return $OptionGrantsTable(attachedDatabase, alias);
  }
}

class OptionGrant extends DataClass implements Insertable<OptionGrant> {
  final String id;
  final String companyId;
  final String stakeholderId;
  final String shareClassId;
  final String? esopPoolId;
  final String status;
  final int quantity;
  final double strikePrice;
  final DateTime grantDate;
  final DateTime expiryDate;
  final int exercisedCount;
  final int cancelledCount;
  final String? vestingScheduleId;
  final String? roundId;
  final bool allowsEarlyExercise;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const OptionGrant({
    required this.id,
    required this.companyId,
    required this.stakeholderId,
    required this.shareClassId,
    this.esopPoolId,
    required this.status,
    required this.quantity,
    required this.strikePrice,
    required this.grantDate,
    required this.expiryDate,
    required this.exercisedCount,
    required this.cancelledCount,
    this.vestingScheduleId,
    this.roundId,
    required this.allowsEarlyExercise,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['stakeholder_id'] = Variable<String>(stakeholderId);
    map['share_class_id'] = Variable<String>(shareClassId);
    if (!nullToAbsent || esopPoolId != null) {
      map['esop_pool_id'] = Variable<String>(esopPoolId);
    }
    map['status'] = Variable<String>(status);
    map['quantity'] = Variable<int>(quantity);
    map['strike_price'] = Variable<double>(strikePrice);
    map['grant_date'] = Variable<DateTime>(grantDate);
    map['expiry_date'] = Variable<DateTime>(expiryDate);
    map['exercised_count'] = Variable<int>(exercisedCount);
    map['cancelled_count'] = Variable<int>(cancelledCount);
    if (!nullToAbsent || vestingScheduleId != null) {
      map['vesting_schedule_id'] = Variable<String>(vestingScheduleId);
    }
    if (!nullToAbsent || roundId != null) {
      map['round_id'] = Variable<String>(roundId);
    }
    map['allows_early_exercise'] = Variable<bool>(allowsEarlyExercise);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OptionGrantsCompanion toCompanion(bool nullToAbsent) {
    return OptionGrantsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      stakeholderId: Value(stakeholderId),
      shareClassId: Value(shareClassId),
      esopPoolId: esopPoolId == null && nullToAbsent
          ? const Value.absent()
          : Value(esopPoolId),
      status: Value(status),
      quantity: Value(quantity),
      strikePrice: Value(strikePrice),
      grantDate: Value(grantDate),
      expiryDate: Value(expiryDate),
      exercisedCount: Value(exercisedCount),
      cancelledCount: Value(cancelledCount),
      vestingScheduleId: vestingScheduleId == null && nullToAbsent
          ? const Value.absent()
          : Value(vestingScheduleId),
      roundId: roundId == null && nullToAbsent
          ? const Value.absent()
          : Value(roundId),
      allowsEarlyExercise: Value(allowsEarlyExercise),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory OptionGrant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OptionGrant(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      stakeholderId: serializer.fromJson<String>(json['stakeholderId']),
      shareClassId: serializer.fromJson<String>(json['shareClassId']),
      esopPoolId: serializer.fromJson<String?>(json['esopPoolId']),
      status: serializer.fromJson<String>(json['status']),
      quantity: serializer.fromJson<int>(json['quantity']),
      strikePrice: serializer.fromJson<double>(json['strikePrice']),
      grantDate: serializer.fromJson<DateTime>(json['grantDate']),
      expiryDate: serializer.fromJson<DateTime>(json['expiryDate']),
      exercisedCount: serializer.fromJson<int>(json['exercisedCount']),
      cancelledCount: serializer.fromJson<int>(json['cancelledCount']),
      vestingScheduleId: serializer.fromJson<String?>(
        json['vestingScheduleId'],
      ),
      roundId: serializer.fromJson<String?>(json['roundId']),
      allowsEarlyExercise: serializer.fromJson<bool>(
        json['allowsEarlyExercise'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'stakeholderId': serializer.toJson<String>(stakeholderId),
      'shareClassId': serializer.toJson<String>(shareClassId),
      'esopPoolId': serializer.toJson<String?>(esopPoolId),
      'status': serializer.toJson<String>(status),
      'quantity': serializer.toJson<int>(quantity),
      'strikePrice': serializer.toJson<double>(strikePrice),
      'grantDate': serializer.toJson<DateTime>(grantDate),
      'expiryDate': serializer.toJson<DateTime>(expiryDate),
      'exercisedCount': serializer.toJson<int>(exercisedCount),
      'cancelledCount': serializer.toJson<int>(cancelledCount),
      'vestingScheduleId': serializer.toJson<String?>(vestingScheduleId),
      'roundId': serializer.toJson<String?>(roundId),
      'allowsEarlyExercise': serializer.toJson<bool>(allowsEarlyExercise),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OptionGrant copyWith({
    String? id,
    String? companyId,
    String? stakeholderId,
    String? shareClassId,
    Value<String?> esopPoolId = const Value.absent(),
    String? status,
    int? quantity,
    double? strikePrice,
    DateTime? grantDate,
    DateTime? expiryDate,
    int? exercisedCount,
    int? cancelledCount,
    Value<String?> vestingScheduleId = const Value.absent(),
    Value<String?> roundId = const Value.absent(),
    bool? allowsEarlyExercise,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => OptionGrant(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    stakeholderId: stakeholderId ?? this.stakeholderId,
    shareClassId: shareClassId ?? this.shareClassId,
    esopPoolId: esopPoolId.present ? esopPoolId.value : this.esopPoolId,
    status: status ?? this.status,
    quantity: quantity ?? this.quantity,
    strikePrice: strikePrice ?? this.strikePrice,
    grantDate: grantDate ?? this.grantDate,
    expiryDate: expiryDate ?? this.expiryDate,
    exercisedCount: exercisedCount ?? this.exercisedCount,
    cancelledCount: cancelledCount ?? this.cancelledCount,
    vestingScheduleId: vestingScheduleId.present
        ? vestingScheduleId.value
        : this.vestingScheduleId,
    roundId: roundId.present ? roundId.value : this.roundId,
    allowsEarlyExercise: allowsEarlyExercise ?? this.allowsEarlyExercise,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OptionGrant copyWithCompanion(OptionGrantsCompanion data) {
    return OptionGrant(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      stakeholderId: data.stakeholderId.present
          ? data.stakeholderId.value
          : this.stakeholderId,
      shareClassId: data.shareClassId.present
          ? data.shareClassId.value
          : this.shareClassId,
      esopPoolId: data.esopPoolId.present
          ? data.esopPoolId.value
          : this.esopPoolId,
      status: data.status.present ? data.status.value : this.status,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      strikePrice: data.strikePrice.present
          ? data.strikePrice.value
          : this.strikePrice,
      grantDate: data.grantDate.present ? data.grantDate.value : this.grantDate,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      exercisedCount: data.exercisedCount.present
          ? data.exercisedCount.value
          : this.exercisedCount,
      cancelledCount: data.cancelledCount.present
          ? data.cancelledCount.value
          : this.cancelledCount,
      vestingScheduleId: data.vestingScheduleId.present
          ? data.vestingScheduleId.value
          : this.vestingScheduleId,
      roundId: data.roundId.present ? data.roundId.value : this.roundId,
      allowsEarlyExercise: data.allowsEarlyExercise.present
          ? data.allowsEarlyExercise.value
          : this.allowsEarlyExercise,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OptionGrant(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('stakeholderId: $stakeholderId, ')
          ..write('shareClassId: $shareClassId, ')
          ..write('esopPoolId: $esopPoolId, ')
          ..write('status: $status, ')
          ..write('quantity: $quantity, ')
          ..write('strikePrice: $strikePrice, ')
          ..write('grantDate: $grantDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('exercisedCount: $exercisedCount, ')
          ..write('cancelledCount: $cancelledCount, ')
          ..write('vestingScheduleId: $vestingScheduleId, ')
          ..write('roundId: $roundId, ')
          ..write('allowsEarlyExercise: $allowsEarlyExercise, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    stakeholderId,
    shareClassId,
    esopPoolId,
    status,
    quantity,
    strikePrice,
    grantDate,
    expiryDate,
    exercisedCount,
    cancelledCount,
    vestingScheduleId,
    roundId,
    allowsEarlyExercise,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OptionGrant &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.stakeholderId == this.stakeholderId &&
          other.shareClassId == this.shareClassId &&
          other.esopPoolId == this.esopPoolId &&
          other.status == this.status &&
          other.quantity == this.quantity &&
          other.strikePrice == this.strikePrice &&
          other.grantDate == this.grantDate &&
          other.expiryDate == this.expiryDate &&
          other.exercisedCount == this.exercisedCount &&
          other.cancelledCount == this.cancelledCount &&
          other.vestingScheduleId == this.vestingScheduleId &&
          other.roundId == this.roundId &&
          other.allowsEarlyExercise == this.allowsEarlyExercise &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OptionGrantsCompanion extends UpdateCompanion<OptionGrant> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> stakeholderId;
  final Value<String> shareClassId;
  final Value<String?> esopPoolId;
  final Value<String> status;
  final Value<int> quantity;
  final Value<double> strikePrice;
  final Value<DateTime> grantDate;
  final Value<DateTime> expiryDate;
  final Value<int> exercisedCount;
  final Value<int> cancelledCount;
  final Value<String?> vestingScheduleId;
  final Value<String?> roundId;
  final Value<bool> allowsEarlyExercise;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const OptionGrantsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.stakeholderId = const Value.absent(),
    this.shareClassId = const Value.absent(),
    this.esopPoolId = const Value.absent(),
    this.status = const Value.absent(),
    this.quantity = const Value.absent(),
    this.strikePrice = const Value.absent(),
    this.grantDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.exercisedCount = const Value.absent(),
    this.cancelledCount = const Value.absent(),
    this.vestingScheduleId = const Value.absent(),
    this.roundId = const Value.absent(),
    this.allowsEarlyExercise = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OptionGrantsCompanion.insert({
    required String id,
    required String companyId,
    required String stakeholderId,
    required String shareClassId,
    this.esopPoolId = const Value.absent(),
    this.status = const Value.absent(),
    required int quantity,
    required double strikePrice,
    required DateTime grantDate,
    required DateTime expiryDate,
    this.exercisedCount = const Value.absent(),
    this.cancelledCount = const Value.absent(),
    this.vestingScheduleId = const Value.absent(),
    this.roundId = const Value.absent(),
    this.allowsEarlyExercise = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       stakeholderId = Value(stakeholderId),
       shareClassId = Value(shareClassId),
       quantity = Value(quantity),
       strikePrice = Value(strikePrice),
       grantDate = Value(grantDate),
       expiryDate = Value(expiryDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<OptionGrant> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? stakeholderId,
    Expression<String>? shareClassId,
    Expression<String>? esopPoolId,
    Expression<String>? status,
    Expression<int>? quantity,
    Expression<double>? strikePrice,
    Expression<DateTime>? grantDate,
    Expression<DateTime>? expiryDate,
    Expression<int>? exercisedCount,
    Expression<int>? cancelledCount,
    Expression<String>? vestingScheduleId,
    Expression<String>? roundId,
    Expression<bool>? allowsEarlyExercise,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (stakeholderId != null) 'stakeholder_id': stakeholderId,
      if (shareClassId != null) 'share_class_id': shareClassId,
      if (esopPoolId != null) 'esop_pool_id': esopPoolId,
      if (status != null) 'status': status,
      if (quantity != null) 'quantity': quantity,
      if (strikePrice != null) 'strike_price': strikePrice,
      if (grantDate != null) 'grant_date': grantDate,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (exercisedCount != null) 'exercised_count': exercisedCount,
      if (cancelledCount != null) 'cancelled_count': cancelledCount,
      if (vestingScheduleId != null) 'vesting_schedule_id': vestingScheduleId,
      if (roundId != null) 'round_id': roundId,
      if (allowsEarlyExercise != null)
        'allows_early_exercise': allowsEarlyExercise,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OptionGrantsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? stakeholderId,
    Value<String>? shareClassId,
    Value<String?>? esopPoolId,
    Value<String>? status,
    Value<int>? quantity,
    Value<double>? strikePrice,
    Value<DateTime>? grantDate,
    Value<DateTime>? expiryDate,
    Value<int>? exercisedCount,
    Value<int>? cancelledCount,
    Value<String?>? vestingScheduleId,
    Value<String?>? roundId,
    Value<bool>? allowsEarlyExercise,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return OptionGrantsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      stakeholderId: stakeholderId ?? this.stakeholderId,
      shareClassId: shareClassId ?? this.shareClassId,
      esopPoolId: esopPoolId ?? this.esopPoolId,
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      strikePrice: strikePrice ?? this.strikePrice,
      grantDate: grantDate ?? this.grantDate,
      expiryDate: expiryDate ?? this.expiryDate,
      exercisedCount: exercisedCount ?? this.exercisedCount,
      cancelledCount: cancelledCount ?? this.cancelledCount,
      vestingScheduleId: vestingScheduleId ?? this.vestingScheduleId,
      roundId: roundId ?? this.roundId,
      allowsEarlyExercise: allowsEarlyExercise ?? this.allowsEarlyExercise,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (stakeholderId.present) {
      map['stakeholder_id'] = Variable<String>(stakeholderId.value);
    }
    if (shareClassId.present) {
      map['share_class_id'] = Variable<String>(shareClassId.value);
    }
    if (esopPoolId.present) {
      map['esop_pool_id'] = Variable<String>(esopPoolId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (strikePrice.present) {
      map['strike_price'] = Variable<double>(strikePrice.value);
    }
    if (grantDate.present) {
      map['grant_date'] = Variable<DateTime>(grantDate.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (exercisedCount.present) {
      map['exercised_count'] = Variable<int>(exercisedCount.value);
    }
    if (cancelledCount.present) {
      map['cancelled_count'] = Variable<int>(cancelledCount.value);
    }
    if (vestingScheduleId.present) {
      map['vesting_schedule_id'] = Variable<String>(vestingScheduleId.value);
    }
    if (roundId.present) {
      map['round_id'] = Variable<String>(roundId.value);
    }
    if (allowsEarlyExercise.present) {
      map['allows_early_exercise'] = Variable<bool>(allowsEarlyExercise.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OptionGrantsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('stakeholderId: $stakeholderId, ')
          ..write('shareClassId: $shareClassId, ')
          ..write('esopPoolId: $esopPoolId, ')
          ..write('status: $status, ')
          ..write('quantity: $quantity, ')
          ..write('strikePrice: $strikePrice, ')
          ..write('grantDate: $grantDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('exercisedCount: $exercisedCount, ')
          ..write('cancelledCount: $cancelledCount, ')
          ..write('vestingScheduleId: $vestingScheduleId, ')
          ..write('roundId: $roundId, ')
          ..write('allowsEarlyExercise: $allowsEarlyExercise, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WarrantsTable extends Warrants with TableInfo<$WarrantsTable, Warrant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WarrantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _stakeholderIdMeta = const VerificationMeta(
    'stakeholderId',
  );
  @override
  late final GeneratedColumn<String> stakeholderId = GeneratedColumn<String>(
    'stakeholder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stakeholders (id)',
    ),
  );
  static const VerificationMeta _shareClassIdMeta = const VerificationMeta(
    'shareClassId',
  );
  @override
  late final GeneratedColumn<String> shareClassId = GeneratedColumn<String>(
    'share_class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES share_classes (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _strikePriceMeta = const VerificationMeta(
    'strikePrice',
  );
  @override
  late final GeneratedColumn<double> strikePrice = GeneratedColumn<double>(
    'strike_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issueDateMeta = const VerificationMeta(
    'issueDate',
  );
  @override
  late final GeneratedColumn<DateTime> issueDate = GeneratedColumn<DateTime>(
    'issue_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exercisedCountMeta = const VerificationMeta(
    'exercisedCount',
  );
  @override
  late final GeneratedColumn<int> exercisedCount = GeneratedColumn<int>(
    'exercised_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cancelledCountMeta = const VerificationMeta(
    'cancelledCount',
  );
  @override
  late final GeneratedColumn<int> cancelledCount = GeneratedColumn<int>(
    'cancelled_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sourceConvertibleIdMeta =
      const VerificationMeta('sourceConvertibleId');
  @override
  late final GeneratedColumn<String> sourceConvertibleId =
      GeneratedColumn<String>(
        'source_convertible_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES convertibles (id)',
        ),
      );
  static const VerificationMeta _roundIdMeta = const VerificationMeta(
    'roundId',
  );
  @override
  late final GeneratedColumn<String> roundId = GeneratedColumn<String>(
    'round_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rounds (id)',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    stakeholderId,
    shareClassId,
    status,
    quantity,
    strikePrice,
    issueDate,
    expiryDate,
    exercisedCount,
    cancelledCount,
    sourceConvertibleId,
    roundId,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'warrants';
  @override
  VerificationContext validateIntegrity(
    Insertable<Warrant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('stakeholder_id')) {
      context.handle(
        _stakeholderIdMeta,
        stakeholderId.isAcceptableOrUnknown(
          data['stakeholder_id']!,
          _stakeholderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stakeholderIdMeta);
    }
    if (data.containsKey('share_class_id')) {
      context.handle(
        _shareClassIdMeta,
        shareClassId.isAcceptableOrUnknown(
          data['share_class_id']!,
          _shareClassIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shareClassIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('strike_price')) {
      context.handle(
        _strikePriceMeta,
        strikePrice.isAcceptableOrUnknown(
          data['strike_price']!,
          _strikePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_strikePriceMeta);
    }
    if (data.containsKey('issue_date')) {
      context.handle(
        _issueDateMeta,
        issueDate.isAcceptableOrUnknown(data['issue_date']!, _issueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_issueDateMeta);
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_expiryDateMeta);
    }
    if (data.containsKey('exercised_count')) {
      context.handle(
        _exercisedCountMeta,
        exercisedCount.isAcceptableOrUnknown(
          data['exercised_count']!,
          _exercisedCountMeta,
        ),
      );
    }
    if (data.containsKey('cancelled_count')) {
      context.handle(
        _cancelledCountMeta,
        cancelledCount.isAcceptableOrUnknown(
          data['cancelled_count']!,
          _cancelledCountMeta,
        ),
      );
    }
    if (data.containsKey('source_convertible_id')) {
      context.handle(
        _sourceConvertibleIdMeta,
        sourceConvertibleId.isAcceptableOrUnknown(
          data['source_convertible_id']!,
          _sourceConvertibleIdMeta,
        ),
      );
    }
    if (data.containsKey('round_id')) {
      context.handle(
        _roundIdMeta,
        roundId.isAcceptableOrUnknown(data['round_id']!, _roundIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  Warrant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Warrant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      stakeholderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stakeholder_id'],
      )!,
      shareClassId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}share_class_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      strikePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}strike_price'],
      )!,
      issueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}issue_date'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      )!,
      exercisedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercised_count'],
      )!,
      cancelledCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cancelled_count'],
      )!,
      sourceConvertibleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_convertible_id'],
      ),
      roundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}round_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WarrantsTable createAlias(String alias) {
    return $WarrantsTable(attachedDatabase, alias);
  }
}

class Warrant extends DataClass implements Insertable<Warrant> {
  final String id;
  final String companyId;
  final String stakeholderId;
  final String shareClassId;
  final String status;
  final int quantity;
  final double strikePrice;
  final DateTime issueDate;
  final DateTime expiryDate;
  final int exercisedCount;
  final int cancelledCount;
  final String? sourceConvertibleId;
  final String? roundId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Warrant({
    required this.id,
    required this.companyId,
    required this.stakeholderId,
    required this.shareClassId,
    required this.status,
    required this.quantity,
    required this.strikePrice,
    required this.issueDate,
    required this.expiryDate,
    required this.exercisedCount,
    required this.cancelledCount,
    this.sourceConvertibleId,
    this.roundId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['stakeholder_id'] = Variable<String>(stakeholderId);
    map['share_class_id'] = Variable<String>(shareClassId);
    map['status'] = Variable<String>(status);
    map['quantity'] = Variable<int>(quantity);
    map['strike_price'] = Variable<double>(strikePrice);
    map['issue_date'] = Variable<DateTime>(issueDate);
    map['expiry_date'] = Variable<DateTime>(expiryDate);
    map['exercised_count'] = Variable<int>(exercisedCount);
    map['cancelled_count'] = Variable<int>(cancelledCount);
    if (!nullToAbsent || sourceConvertibleId != null) {
      map['source_convertible_id'] = Variable<String>(sourceConvertibleId);
    }
    if (!nullToAbsent || roundId != null) {
      map['round_id'] = Variable<String>(roundId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WarrantsCompanion toCompanion(bool nullToAbsent) {
    return WarrantsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      stakeholderId: Value(stakeholderId),
      shareClassId: Value(shareClassId),
      status: Value(status),
      quantity: Value(quantity),
      strikePrice: Value(strikePrice),
      issueDate: Value(issueDate),
      expiryDate: Value(expiryDate),
      exercisedCount: Value(exercisedCount),
      cancelledCount: Value(cancelledCount),
      sourceConvertibleId: sourceConvertibleId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceConvertibleId),
      roundId: roundId == null && nullToAbsent
          ? const Value.absent()
          : Value(roundId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Warrant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Warrant(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      stakeholderId: serializer.fromJson<String>(json['stakeholderId']),
      shareClassId: serializer.fromJson<String>(json['shareClassId']),
      status: serializer.fromJson<String>(json['status']),
      quantity: serializer.fromJson<int>(json['quantity']),
      strikePrice: serializer.fromJson<double>(json['strikePrice']),
      issueDate: serializer.fromJson<DateTime>(json['issueDate']),
      expiryDate: serializer.fromJson<DateTime>(json['expiryDate']),
      exercisedCount: serializer.fromJson<int>(json['exercisedCount']),
      cancelledCount: serializer.fromJson<int>(json['cancelledCount']),
      sourceConvertibleId: serializer.fromJson<String?>(
        json['sourceConvertibleId'],
      ),
      roundId: serializer.fromJson<String?>(json['roundId']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'stakeholderId': serializer.toJson<String>(stakeholderId),
      'shareClassId': serializer.toJson<String>(shareClassId),
      'status': serializer.toJson<String>(status),
      'quantity': serializer.toJson<int>(quantity),
      'strikePrice': serializer.toJson<double>(strikePrice),
      'issueDate': serializer.toJson<DateTime>(issueDate),
      'expiryDate': serializer.toJson<DateTime>(expiryDate),
      'exercisedCount': serializer.toJson<int>(exercisedCount),
      'cancelledCount': serializer.toJson<int>(cancelledCount),
      'sourceConvertibleId': serializer.toJson<String?>(sourceConvertibleId),
      'roundId': serializer.toJson<String?>(roundId),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Warrant copyWith({
    String? id,
    String? companyId,
    String? stakeholderId,
    String? shareClassId,
    String? status,
    int? quantity,
    double? strikePrice,
    DateTime? issueDate,
    DateTime? expiryDate,
    int? exercisedCount,
    int? cancelledCount,
    Value<String?> sourceConvertibleId = const Value.absent(),
    Value<String?> roundId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Warrant(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    stakeholderId: stakeholderId ?? this.stakeholderId,
    shareClassId: shareClassId ?? this.shareClassId,
    status: status ?? this.status,
    quantity: quantity ?? this.quantity,
    strikePrice: strikePrice ?? this.strikePrice,
    issueDate: issueDate ?? this.issueDate,
    expiryDate: expiryDate ?? this.expiryDate,
    exercisedCount: exercisedCount ?? this.exercisedCount,
    cancelledCount: cancelledCount ?? this.cancelledCount,
    sourceConvertibleId: sourceConvertibleId.present
        ? sourceConvertibleId.value
        : this.sourceConvertibleId,
    roundId: roundId.present ? roundId.value : this.roundId,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Warrant copyWithCompanion(WarrantsCompanion data) {
    return Warrant(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      stakeholderId: data.stakeholderId.present
          ? data.stakeholderId.value
          : this.stakeholderId,
      shareClassId: data.shareClassId.present
          ? data.shareClassId.value
          : this.shareClassId,
      status: data.status.present ? data.status.value : this.status,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      strikePrice: data.strikePrice.present
          ? data.strikePrice.value
          : this.strikePrice,
      issueDate: data.issueDate.present ? data.issueDate.value : this.issueDate,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      exercisedCount: data.exercisedCount.present
          ? data.exercisedCount.value
          : this.exercisedCount,
      cancelledCount: data.cancelledCount.present
          ? data.cancelledCount.value
          : this.cancelledCount,
      sourceConvertibleId: data.sourceConvertibleId.present
          ? data.sourceConvertibleId.value
          : this.sourceConvertibleId,
      roundId: data.roundId.present ? data.roundId.value : this.roundId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Warrant(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('stakeholderId: $stakeholderId, ')
          ..write('shareClassId: $shareClassId, ')
          ..write('status: $status, ')
          ..write('quantity: $quantity, ')
          ..write('strikePrice: $strikePrice, ')
          ..write('issueDate: $issueDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('exercisedCount: $exercisedCount, ')
          ..write('cancelledCount: $cancelledCount, ')
          ..write('sourceConvertibleId: $sourceConvertibleId, ')
          ..write('roundId: $roundId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    stakeholderId,
    shareClassId,
    status,
    quantity,
    strikePrice,
    issueDate,
    expiryDate,
    exercisedCount,
    cancelledCount,
    sourceConvertibleId,
    roundId,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Warrant &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.stakeholderId == this.stakeholderId &&
          other.shareClassId == this.shareClassId &&
          other.status == this.status &&
          other.quantity == this.quantity &&
          other.strikePrice == this.strikePrice &&
          other.issueDate == this.issueDate &&
          other.expiryDate == this.expiryDate &&
          other.exercisedCount == this.exercisedCount &&
          other.cancelledCount == this.cancelledCount &&
          other.sourceConvertibleId == this.sourceConvertibleId &&
          other.roundId == this.roundId &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WarrantsCompanion extends UpdateCompanion<Warrant> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> stakeholderId;
  final Value<String> shareClassId;
  final Value<String> status;
  final Value<int> quantity;
  final Value<double> strikePrice;
  final Value<DateTime> issueDate;
  final Value<DateTime> expiryDate;
  final Value<int> exercisedCount;
  final Value<int> cancelledCount;
  final Value<String?> sourceConvertibleId;
  final Value<String?> roundId;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WarrantsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.stakeholderId = const Value.absent(),
    this.shareClassId = const Value.absent(),
    this.status = const Value.absent(),
    this.quantity = const Value.absent(),
    this.strikePrice = const Value.absent(),
    this.issueDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.exercisedCount = const Value.absent(),
    this.cancelledCount = const Value.absent(),
    this.sourceConvertibleId = const Value.absent(),
    this.roundId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WarrantsCompanion.insert({
    required String id,
    required String companyId,
    required String stakeholderId,
    required String shareClassId,
    this.status = const Value.absent(),
    required int quantity,
    required double strikePrice,
    required DateTime issueDate,
    required DateTime expiryDate,
    this.exercisedCount = const Value.absent(),
    this.cancelledCount = const Value.absent(),
    this.sourceConvertibleId = const Value.absent(),
    this.roundId = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       stakeholderId = Value(stakeholderId),
       shareClassId = Value(shareClassId),
       quantity = Value(quantity),
       strikePrice = Value(strikePrice),
       issueDate = Value(issueDate),
       expiryDate = Value(expiryDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Warrant> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? stakeholderId,
    Expression<String>? shareClassId,
    Expression<String>? status,
    Expression<int>? quantity,
    Expression<double>? strikePrice,
    Expression<DateTime>? issueDate,
    Expression<DateTime>? expiryDate,
    Expression<int>? exercisedCount,
    Expression<int>? cancelledCount,
    Expression<String>? sourceConvertibleId,
    Expression<String>? roundId,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (stakeholderId != null) 'stakeholder_id': stakeholderId,
      if (shareClassId != null) 'share_class_id': shareClassId,
      if (status != null) 'status': status,
      if (quantity != null) 'quantity': quantity,
      if (strikePrice != null) 'strike_price': strikePrice,
      if (issueDate != null) 'issue_date': issueDate,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (exercisedCount != null) 'exercised_count': exercisedCount,
      if (cancelledCount != null) 'cancelled_count': cancelledCount,
      if (sourceConvertibleId != null)
        'source_convertible_id': sourceConvertibleId,
      if (roundId != null) 'round_id': roundId,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WarrantsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? stakeholderId,
    Value<String>? shareClassId,
    Value<String>? status,
    Value<int>? quantity,
    Value<double>? strikePrice,
    Value<DateTime>? issueDate,
    Value<DateTime>? expiryDate,
    Value<int>? exercisedCount,
    Value<int>? cancelledCount,
    Value<String?>? sourceConvertibleId,
    Value<String?>? roundId,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WarrantsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      stakeholderId: stakeholderId ?? this.stakeholderId,
      shareClassId: shareClassId ?? this.shareClassId,
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      strikePrice: strikePrice ?? this.strikePrice,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      exercisedCount: exercisedCount ?? this.exercisedCount,
      cancelledCount: cancelledCount ?? this.cancelledCount,
      sourceConvertibleId: sourceConvertibleId ?? this.sourceConvertibleId,
      roundId: roundId ?? this.roundId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (stakeholderId.present) {
      map['stakeholder_id'] = Variable<String>(stakeholderId.value);
    }
    if (shareClassId.present) {
      map['share_class_id'] = Variable<String>(shareClassId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (strikePrice.present) {
      map['strike_price'] = Variable<double>(strikePrice.value);
    }
    if (issueDate.present) {
      map['issue_date'] = Variable<DateTime>(issueDate.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (exercisedCount.present) {
      map['exercised_count'] = Variable<int>(exercisedCount.value);
    }
    if (cancelledCount.present) {
      map['cancelled_count'] = Variable<int>(cancelledCount.value);
    }
    if (sourceConvertibleId.present) {
      map['source_convertible_id'] = Variable<String>(
        sourceConvertibleId.value,
      );
    }
    if (roundId.present) {
      map['round_id'] = Variable<String>(roundId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WarrantsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('stakeholderId: $stakeholderId, ')
          ..write('shareClassId: $shareClassId, ')
          ..write('status: $status, ')
          ..write('quantity: $quantity, ')
          ..write('strikePrice: $strikePrice, ')
          ..write('issueDate: $issueDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('exercisedCount: $exercisedCount, ')
          ..write('cancelledCount: $cancelledCount, ')
          ..write('sourceConvertibleId: $sourceConvertibleId, ')
          ..write('roundId: $roundId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VestingSchedulesTable extends VestingSchedules
    with TableInfo<$VestingSchedulesTable, VestingSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VestingSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMonthsMeta = const VerificationMeta(
    'totalMonths',
  );
  @override
  late final GeneratedColumn<int> totalMonths = GeneratedColumn<int>(
    'total_months',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cliffMonthsMeta = const VerificationMeta(
    'cliffMonths',
  );
  @override
  late final GeneratedColumn<int> cliffMonths = GeneratedColumn<int>(
    'cliff_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _milestonesJsonMeta = const VerificationMeta(
    'milestonesJson',
  );
  @override
  late final GeneratedColumn<String> milestonesJson = GeneratedColumn<String>(
    'milestones_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalHoursMeta = const VerificationMeta(
    'totalHours',
  );
  @override
  late final GeneratedColumn<int> totalHours = GeneratedColumn<int>(
    'total_hours',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    type,
    totalMonths,
    cliffMonths,
    frequency,
    milestonesJson,
    totalHours,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vesting_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<VestingSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('total_months')) {
      context.handle(
        _totalMonthsMeta,
        totalMonths.isAcceptableOrUnknown(
          data['total_months']!,
          _totalMonthsMeta,
        ),
      );
    }
    if (data.containsKey('cliff_months')) {
      context.handle(
        _cliffMonthsMeta,
        cliffMonths.isAcceptableOrUnknown(
          data['cliff_months']!,
          _cliffMonthsMeta,
        ),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('milestones_json')) {
      context.handle(
        _milestonesJsonMeta,
        milestonesJson.isAcceptableOrUnknown(
          data['milestones_json']!,
          _milestonesJsonMeta,
        ),
      );
    }
    if (data.containsKey('total_hours')) {
      context.handle(
        _totalHoursMeta,
        totalHours.isAcceptableOrUnknown(data['total_hours']!, _totalHoursMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  VestingSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VestingSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      totalMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_months'],
      ),
      cliffMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cliff_months'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      ),
      milestonesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}milestones_json'],
      ),
      totalHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_hours'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $VestingSchedulesTable createAlias(String alias) {
    return $VestingSchedulesTable(attachedDatabase, alias);
  }
}

class VestingSchedule extends DataClass implements Insertable<VestingSchedule> {
  final String id;
  final String companyId;
  final String name;
  final String type;
  final int? totalMonths;
  final int cliffMonths;
  final String? frequency;
  final String? milestonesJson;
  final int? totalHours;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const VestingSchedule({
    required this.id,
    required this.companyId,
    required this.name,
    required this.type,
    this.totalMonths,
    required this.cliffMonths,
    this.frequency,
    this.milestonesJson,
    this.totalHours,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || totalMonths != null) {
      map['total_months'] = Variable<int>(totalMonths);
    }
    map['cliff_months'] = Variable<int>(cliffMonths);
    if (!nullToAbsent || frequency != null) {
      map['frequency'] = Variable<String>(frequency);
    }
    if (!nullToAbsent || milestonesJson != null) {
      map['milestones_json'] = Variable<String>(milestonesJson);
    }
    if (!nullToAbsent || totalHours != null) {
      map['total_hours'] = Variable<int>(totalHours);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VestingSchedulesCompanion toCompanion(bool nullToAbsent) {
    return VestingSchedulesCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      type: Value(type),
      totalMonths: totalMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(totalMonths),
      cliffMonths: Value(cliffMonths),
      frequency: frequency == null && nullToAbsent
          ? const Value.absent()
          : Value(frequency),
      milestonesJson: milestonesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(milestonesJson),
      totalHours: totalHours == null && nullToAbsent
          ? const Value.absent()
          : Value(totalHours),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VestingSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VestingSchedule(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      totalMonths: serializer.fromJson<int?>(json['totalMonths']),
      cliffMonths: serializer.fromJson<int>(json['cliffMonths']),
      frequency: serializer.fromJson<String?>(json['frequency']),
      milestonesJson: serializer.fromJson<String?>(json['milestonesJson']),
      totalHours: serializer.fromJson<int?>(json['totalHours']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'totalMonths': serializer.toJson<int?>(totalMonths),
      'cliffMonths': serializer.toJson<int>(cliffMonths),
      'frequency': serializer.toJson<String?>(frequency),
      'milestonesJson': serializer.toJson<String?>(milestonesJson),
      'totalHours': serializer.toJson<int?>(totalHours),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  VestingSchedule copyWith({
    String? id,
    String? companyId,
    String? name,
    String? type,
    Value<int?> totalMonths = const Value.absent(),
    int? cliffMonths,
    Value<String?> frequency = const Value.absent(),
    Value<String?> milestonesJson = const Value.absent(),
    Value<int?> totalHours = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => VestingSchedule(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    type: type ?? this.type,
    totalMonths: totalMonths.present ? totalMonths.value : this.totalMonths,
    cliffMonths: cliffMonths ?? this.cliffMonths,
    frequency: frequency.present ? frequency.value : this.frequency,
    milestonesJson: milestonesJson.present
        ? milestonesJson.value
        : this.milestonesJson,
    totalHours: totalHours.present ? totalHours.value : this.totalHours,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  VestingSchedule copyWithCompanion(VestingSchedulesCompanion data) {
    return VestingSchedule(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      totalMonths: data.totalMonths.present
          ? data.totalMonths.value
          : this.totalMonths,
      cliffMonths: data.cliffMonths.present
          ? data.cliffMonths.value
          : this.cliffMonths,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      milestonesJson: data.milestonesJson.present
          ? data.milestonesJson.value
          : this.milestonesJson,
      totalHours: data.totalHours.present
          ? data.totalHours.value
          : this.totalHours,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VestingSchedule(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('totalMonths: $totalMonths, ')
          ..write('cliffMonths: $cliffMonths, ')
          ..write('frequency: $frequency, ')
          ..write('milestonesJson: $milestonesJson, ')
          ..write('totalHours: $totalHours, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    name,
    type,
    totalMonths,
    cliffMonths,
    frequency,
    milestonesJson,
    totalHours,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VestingSchedule &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.type == this.type &&
          other.totalMonths == this.totalMonths &&
          other.cliffMonths == this.cliffMonths &&
          other.frequency == this.frequency &&
          other.milestonesJson == this.milestonesJson &&
          other.totalHours == this.totalHours &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VestingSchedulesCompanion extends UpdateCompanion<VestingSchedule> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> name;
  final Value<String> type;
  final Value<int?> totalMonths;
  final Value<int> cliffMonths;
  final Value<String?> frequency;
  final Value<String?> milestonesJson;
  final Value<int?> totalHours;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const VestingSchedulesCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.totalMonths = const Value.absent(),
    this.cliffMonths = const Value.absent(),
    this.frequency = const Value.absent(),
    this.milestonesJson = const Value.absent(),
    this.totalHours = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VestingSchedulesCompanion.insert({
    required String id,
    required String companyId,
    required String name,
    required String type,
    this.totalMonths = const Value.absent(),
    this.cliffMonths = const Value.absent(),
    this.frequency = const Value.absent(),
    this.milestonesJson = const Value.absent(),
    this.totalHours = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       name = Value(name),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<VestingSchedule> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? totalMonths,
    Expression<int>? cliffMonths,
    Expression<String>? frequency,
    Expression<String>? milestonesJson,
    Expression<int>? totalHours,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (totalMonths != null) 'total_months': totalMonths,
      if (cliffMonths != null) 'cliff_months': cliffMonths,
      if (frequency != null) 'frequency': frequency,
      if (milestonesJson != null) 'milestones_json': milestonesJson,
      if (totalHours != null) 'total_hours': totalHours,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VestingSchedulesCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? name,
    Value<String>? type,
    Value<int?>? totalMonths,
    Value<int>? cliffMonths,
    Value<String?>? frequency,
    Value<String?>? milestonesJson,
    Value<int?>? totalHours,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return VestingSchedulesCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      type: type ?? this.type,
      totalMonths: totalMonths ?? this.totalMonths,
      cliffMonths: cliffMonths ?? this.cliffMonths,
      frequency: frequency ?? this.frequency,
      milestonesJson: milestonesJson ?? this.milestonesJson,
      totalHours: totalHours ?? this.totalHours,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (totalMonths.present) {
      map['total_months'] = Variable<int>(totalMonths.value);
    }
    if (cliffMonths.present) {
      map['cliff_months'] = Variable<int>(cliffMonths.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (milestonesJson.present) {
      map['milestones_json'] = Variable<String>(milestonesJson.value);
    }
    if (totalHours.present) {
      map['total_hours'] = Variable<int>(totalHours.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VestingSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('totalMonths: $totalMonths, ')
          ..write('cliffMonths: $cliffMonths, ')
          ..write('frequency: $frequency, ')
          ..write('milestonesJson: $milestonesJson, ')
          ..write('totalHours: $totalHours, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ValuationsTable extends Valuations
    with TableInfo<$ValuationsTable, Valuation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ValuationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preMoneyValueMeta = const VerificationMeta(
    'preMoneyValue',
  );
  @override
  late final GeneratedColumn<double> preMoneyValue = GeneratedColumn<double>(
    'pre_money_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodParamsJsonMeta = const VerificationMeta(
    'methodParamsJson',
  );
  @override
  late final GeneratedColumn<String> methodParamsJson = GeneratedColumn<String>(
    'method_params_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    date,
    preMoneyValue,
    method,
    methodParamsJson,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'valuations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Valuation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('pre_money_value')) {
      context.handle(
        _preMoneyValueMeta,
        preMoneyValue.isAcceptableOrUnknown(
          data['pre_money_value']!,
          _preMoneyValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_preMoneyValueMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('method_params_json')) {
      context.handle(
        _methodParamsJsonMeta,
        methodParamsJson.isAcceptableOrUnknown(
          data['method_params_json']!,
          _methodParamsJsonMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Valuation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Valuation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      preMoneyValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pre_money_value'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      methodParamsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method_params_json'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ValuationsTable createAlias(String alias) {
    return $ValuationsTable(attachedDatabase, alias);
  }
}

class Valuation extends DataClass implements Insertable<Valuation> {
  final String id;
  final String companyId;
  final DateTime date;
  final double preMoneyValue;
  final String method;
  final String? methodParamsJson;
  final String? notes;
  final DateTime createdAt;
  const Valuation({
    required this.id,
    required this.companyId,
    required this.date,
    required this.preMoneyValue,
    required this.method,
    this.methodParamsJson,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['date'] = Variable<DateTime>(date);
    map['pre_money_value'] = Variable<double>(preMoneyValue);
    map['method'] = Variable<String>(method);
    if (!nullToAbsent || methodParamsJson != null) {
      map['method_params_json'] = Variable<String>(methodParamsJson);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ValuationsCompanion toCompanion(bool nullToAbsent) {
    return ValuationsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      date: Value(date),
      preMoneyValue: Value(preMoneyValue),
      method: Value(method),
      methodParamsJson: methodParamsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(methodParamsJson),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Valuation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Valuation(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      date: serializer.fromJson<DateTime>(json['date']),
      preMoneyValue: serializer.fromJson<double>(json['preMoneyValue']),
      method: serializer.fromJson<String>(json['method']),
      methodParamsJson: serializer.fromJson<String?>(json['methodParamsJson']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'date': serializer.toJson<DateTime>(date),
      'preMoneyValue': serializer.toJson<double>(preMoneyValue),
      'method': serializer.toJson<String>(method),
      'methodParamsJson': serializer.toJson<String?>(methodParamsJson),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Valuation copyWith({
    String? id,
    String? companyId,
    DateTime? date,
    double? preMoneyValue,
    String? method,
    Value<String?> methodParamsJson = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => Valuation(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    date: date ?? this.date,
    preMoneyValue: preMoneyValue ?? this.preMoneyValue,
    method: method ?? this.method,
    methodParamsJson: methodParamsJson.present
        ? methodParamsJson.value
        : this.methodParamsJson,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Valuation copyWithCompanion(ValuationsCompanion data) {
    return Valuation(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      date: data.date.present ? data.date.value : this.date,
      preMoneyValue: data.preMoneyValue.present
          ? data.preMoneyValue.value
          : this.preMoneyValue,
      method: data.method.present ? data.method.value : this.method,
      methodParamsJson: data.methodParamsJson.present
          ? data.methodParamsJson.value
          : this.methodParamsJson,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Valuation(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('date: $date, ')
          ..write('preMoneyValue: $preMoneyValue, ')
          ..write('method: $method, ')
          ..write('methodParamsJson: $methodParamsJson, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    date,
    preMoneyValue,
    method,
    methodParamsJson,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Valuation &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.date == this.date &&
          other.preMoneyValue == this.preMoneyValue &&
          other.method == this.method &&
          other.methodParamsJson == this.methodParamsJson &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class ValuationsCompanion extends UpdateCompanion<Valuation> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<DateTime> date;
  final Value<double> preMoneyValue;
  final Value<String> method;
  final Value<String?> methodParamsJson;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ValuationsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.date = const Value.absent(),
    this.preMoneyValue = const Value.absent(),
    this.method = const Value.absent(),
    this.methodParamsJson = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ValuationsCompanion.insert({
    required String id,
    required String companyId,
    required DateTime date,
    required double preMoneyValue,
    required String method,
    this.methodParamsJson = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       date = Value(date),
       preMoneyValue = Value(preMoneyValue),
       method = Value(method),
       createdAt = Value(createdAt);
  static Insertable<Valuation> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<DateTime>? date,
    Expression<double>? preMoneyValue,
    Expression<String>? method,
    Expression<String>? methodParamsJson,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (date != null) 'date': date,
      if (preMoneyValue != null) 'pre_money_value': preMoneyValue,
      if (method != null) 'method': method,
      if (methodParamsJson != null) 'method_params_json': methodParamsJson,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ValuationsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<DateTime>? date,
    Value<double>? preMoneyValue,
    Value<String>? method,
    Value<String?>? methodParamsJson,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ValuationsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      date: date ?? this.date,
      preMoneyValue: preMoneyValue ?? this.preMoneyValue,
      method: method ?? this.method,
      methodParamsJson: methodParamsJson ?? this.methodParamsJson,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (preMoneyValue.present) {
      map['pre_money_value'] = Variable<double>(preMoneyValue.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (methodParamsJson.present) {
      map['method_params_json'] = Variable<String>(methodParamsJson.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ValuationsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('date: $date, ')
          ..write('preMoneyValue: $preMoneyValue, ')
          ..write('method: $method, ')
          ..write('methodParamsJson: $methodParamsJson, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CapitalizationEventsTable extends CapitalizationEvents
    with TableInfo<$CapitalizationEventsTable, CapitalizationEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CapitalizationEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _sequenceNumberMeta = const VerificationMeta(
    'sequenceNumber',
  );
  @override
  late final GeneratedColumn<int> sequenceNumber = GeneratedColumn<int>(
    'sequence_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventDataJsonMeta = const VerificationMeta(
    'eventDataJson',
  );
  @override
  late final GeneratedColumn<String> eventDataJson = GeneratedColumn<String>(
    'event_data_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _signatureMeta = const VerificationMeta(
    'signature',
  );
  @override
  late final GeneratedColumn<String> signature = GeneratedColumn<String>(
    'signature',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    sequenceNumber,
    eventType,
    eventDataJson,
    timestamp,
    actorId,
    signature,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capitalization_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CapitalizationEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('sequence_number')) {
      context.handle(
        _sequenceNumberMeta,
        sequenceNumber.isAcceptableOrUnknown(
          data['sequence_number']!,
          _sequenceNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sequenceNumberMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('event_data_json')) {
      context.handle(
        _eventDataJsonMeta,
        eventDataJson.isAcceptableOrUnknown(
          data['event_data_json']!,
          _eventDataJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventDataJsonMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    }
    if (data.containsKey('signature')) {
      context.handle(
        _signatureMeta,
        signature.isAcceptableOrUnknown(data['signature']!, _signatureMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CapitalizationEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CapitalizationEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      sequenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_number'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      eventDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_data_json'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      ),
      signature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signature'],
      ),
    );
  }

  @override
  $CapitalizationEventsTable createAlias(String alias) {
    return $CapitalizationEventsTable(attachedDatabase, alias);
  }
}

class CapitalizationEvent extends DataClass
    implements Insertable<CapitalizationEvent> {
  final String id;
  final String companyId;

  /// Sequence number for ordering within a company. Auto-incremented.
  final int sequenceNumber;

  /// The event type discriminator (e.g., 'stakeholderAdded', 'roundClosed')
  final String eventType;

  /// The full event data as JSON (includes all fields from the Freezed event)
  final String eventDataJson;

  /// When the event was recorded
  final DateTime timestamp;

  /// Who performed the action (for audit trail, nullable until auth is added)
  final String? actorId;

  /// Optional cryptographic signature for tamper-proofing
  final String? signature;
  const CapitalizationEvent({
    required this.id,
    required this.companyId,
    required this.sequenceNumber,
    required this.eventType,
    required this.eventDataJson,
    required this.timestamp,
    this.actorId,
    this.signature,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['sequence_number'] = Variable<int>(sequenceNumber);
    map['event_type'] = Variable<String>(eventType);
    map['event_data_json'] = Variable<String>(eventDataJson);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || actorId != null) {
      map['actor_id'] = Variable<String>(actorId);
    }
    if (!nullToAbsent || signature != null) {
      map['signature'] = Variable<String>(signature);
    }
    return map;
  }

  CapitalizationEventsCompanion toCompanion(bool nullToAbsent) {
    return CapitalizationEventsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      sequenceNumber: Value(sequenceNumber),
      eventType: Value(eventType),
      eventDataJson: Value(eventDataJson),
      timestamp: Value(timestamp),
      actorId: actorId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorId),
      signature: signature == null && nullToAbsent
          ? const Value.absent()
          : Value(signature),
    );
  }

  factory CapitalizationEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CapitalizationEvent(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      sequenceNumber: serializer.fromJson<int>(json['sequenceNumber']),
      eventType: serializer.fromJson<String>(json['eventType']),
      eventDataJson: serializer.fromJson<String>(json['eventDataJson']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      actorId: serializer.fromJson<String?>(json['actorId']),
      signature: serializer.fromJson<String?>(json['signature']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'sequenceNumber': serializer.toJson<int>(sequenceNumber),
      'eventType': serializer.toJson<String>(eventType),
      'eventDataJson': serializer.toJson<String>(eventDataJson),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'actorId': serializer.toJson<String?>(actorId),
      'signature': serializer.toJson<String?>(signature),
    };
  }

  CapitalizationEvent copyWith({
    String? id,
    String? companyId,
    int? sequenceNumber,
    String? eventType,
    String? eventDataJson,
    DateTime? timestamp,
    Value<String?> actorId = const Value.absent(),
    Value<String?> signature = const Value.absent(),
  }) => CapitalizationEvent(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    eventType: eventType ?? this.eventType,
    eventDataJson: eventDataJson ?? this.eventDataJson,
    timestamp: timestamp ?? this.timestamp,
    actorId: actorId.present ? actorId.value : this.actorId,
    signature: signature.present ? signature.value : this.signature,
  );
  CapitalizationEvent copyWithCompanion(CapitalizationEventsCompanion data) {
    return CapitalizationEvent(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      sequenceNumber: data.sequenceNumber.present
          ? data.sequenceNumber.value
          : this.sequenceNumber,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      eventDataJson: data.eventDataJson.present
          ? data.eventDataJson.value
          : this.eventDataJson,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      signature: data.signature.present ? data.signature.value : this.signature,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CapitalizationEvent(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('eventType: $eventType, ')
          ..write('eventDataJson: $eventDataJson, ')
          ..write('timestamp: $timestamp, ')
          ..write('actorId: $actorId, ')
          ..write('signature: $signature')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    sequenceNumber,
    eventType,
    eventDataJson,
    timestamp,
    actorId,
    signature,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CapitalizationEvent &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.sequenceNumber == this.sequenceNumber &&
          other.eventType == this.eventType &&
          other.eventDataJson == this.eventDataJson &&
          other.timestamp == this.timestamp &&
          other.actorId == this.actorId &&
          other.signature == this.signature);
}

class CapitalizationEventsCompanion
    extends UpdateCompanion<CapitalizationEvent> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<int> sequenceNumber;
  final Value<String> eventType;
  final Value<String> eventDataJson;
  final Value<DateTime> timestamp;
  final Value<String?> actorId;
  final Value<String?> signature;
  final Value<int> rowid;
  const CapitalizationEventsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.eventType = const Value.absent(),
    this.eventDataJson = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.actorId = const Value.absent(),
    this.signature = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CapitalizationEventsCompanion.insert({
    required String id,
    required String companyId,
    required int sequenceNumber,
    required String eventType,
    required String eventDataJson,
    required DateTime timestamp,
    this.actorId = const Value.absent(),
    this.signature = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       sequenceNumber = Value(sequenceNumber),
       eventType = Value(eventType),
       eventDataJson = Value(eventDataJson),
       timestamp = Value(timestamp);
  static Insertable<CapitalizationEvent> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<int>? sequenceNumber,
    Expression<String>? eventType,
    Expression<String>? eventDataJson,
    Expression<DateTime>? timestamp,
    Expression<String>? actorId,
    Expression<String>? signature,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (sequenceNumber != null) 'sequence_number': sequenceNumber,
      if (eventType != null) 'event_type': eventType,
      if (eventDataJson != null) 'event_data_json': eventDataJson,
      if (timestamp != null) 'timestamp': timestamp,
      if (actorId != null) 'actor_id': actorId,
      if (signature != null) 'signature': signature,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CapitalizationEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<int>? sequenceNumber,
    Value<String>? eventType,
    Value<String>? eventDataJson,
    Value<DateTime>? timestamp,
    Value<String?>? actorId,
    Value<String?>? signature,
    Value<int>? rowid,
  }) {
    return CapitalizationEventsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      eventType: eventType ?? this.eventType,
      eventDataJson: eventDataJson ?? this.eventDataJson,
      timestamp: timestamp ?? this.timestamp,
      actorId: actorId ?? this.actorId,
      signature: signature ?? this.signature,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (sequenceNumber.present) {
      map['sequence_number'] = Variable<int>(sequenceNumber.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (eventDataJson.present) {
      map['event_data_json'] = Variable<String>(eventDataJson.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (signature.present) {
      map['signature'] = Variable<String>(signature.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CapitalizationEventsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('eventType: $eventType, ')
          ..write('eventDataJson: $eventDataJson, ')
          ..write('timestamp: $timestamp, ')
          ..write('actorId: $actorId, ')
          ..write('signature: $signature, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedScenariosTable extends SavedScenarios
    with TableInfo<$SavedScenariosTable, SavedScenario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedScenariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parametersJsonMeta = const VerificationMeta(
    'parametersJson',
  );
  @override
  late final GeneratedColumn<String> parametersJson = GeneratedColumn<String>(
    'parameters_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    name,
    type,
    parametersJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_scenarios';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedScenario> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('parameters_json')) {
      context.handle(
        _parametersJsonMeta,
        parametersJson.isAcceptableOrUnknown(
          data['parameters_json']!,
          _parametersJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_parametersJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  SavedScenario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedScenario(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      parametersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parameters_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SavedScenariosTable createAlias(String alias) {
    return $SavedScenariosTable(attachedDatabase, alias);
  }
}

class SavedScenario extends DataClass implements Insertable<SavedScenario> {
  final String id;
  final String companyId;
  final String name;
  final String type;
  final String parametersJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SavedScenario({
    required this.id,
    required this.companyId,
    required this.name,
    required this.type,
    required this.parametersJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['parameters_json'] = Variable<String>(parametersJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SavedScenariosCompanion toCompanion(bool nullToAbsent) {
    return SavedScenariosCompanion(
      id: Value(id),
      companyId: Value(companyId),
      name: Value(name),
      type: Value(type),
      parametersJson: Value(parametersJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SavedScenario.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedScenario(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      parametersJson: serializer.fromJson<String>(json['parametersJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'parametersJson': serializer.toJson<String>(parametersJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SavedScenario copyWith({
    String? id,
    String? companyId,
    String? name,
    String? type,
    String? parametersJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SavedScenario(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    name: name ?? this.name,
    type: type ?? this.type,
    parametersJson: parametersJson ?? this.parametersJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SavedScenario copyWithCompanion(SavedScenariosCompanion data) {
    return SavedScenario(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      parametersJson: data.parametersJson.present
          ? data.parametersJson.value
          : this.parametersJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedScenario(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('parametersJson: $parametersJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    name,
    type,
    parametersJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedScenario &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.name == this.name &&
          other.type == this.type &&
          other.parametersJson == this.parametersJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SavedScenariosCompanion extends UpdateCompanion<SavedScenario> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> name;
  final Value<String> type;
  final Value<String> parametersJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SavedScenariosCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.parametersJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedScenariosCompanion.insert({
    required String id,
    required String companyId,
    required String name,
    required String type,
    required String parametersJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       name = Value(name),
       type = Value(type),
       parametersJson = Value(parametersJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SavedScenario> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? parametersJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (parametersJson != null) 'parameters_json': parametersJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedScenariosCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? name,
    Value<String>? type,
    Value<String>? parametersJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SavedScenariosCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      type: type ?? this.type,
      parametersJson: parametersJson ?? this.parametersJson,
      createdAt: createdAt ?? this.createdAt,
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
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (parametersJson.present) {
      map['parameters_json'] = Variable<String>(parametersJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedScenariosCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('parametersJson: $parametersJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransfersTable extends Transfers
    with TableInfo<$TransfersTable, Transfer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransfersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _sellerStakeholderIdMeta =
      const VerificationMeta('sellerStakeholderId');
  @override
  late final GeneratedColumn<String> sellerStakeholderId =
      GeneratedColumn<String>(
        'seller_stakeholder_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES stakeholders (id)',
        ),
      );
  static const VerificationMeta _buyerStakeholderIdMeta =
      const VerificationMeta('buyerStakeholderId');
  @override
  late final GeneratedColumn<String> buyerStakeholderId =
      GeneratedColumn<String>(
        'buyer_stakeholder_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES stakeholders (id)',
        ),
      );
  static const VerificationMeta _shareClassIdMeta = const VerificationMeta(
    'shareClassId',
  );
  @override
  late final GeneratedColumn<String> shareClassId = GeneratedColumn<String>(
    'share_class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES share_classes (id)',
    ),
  );
  static const VerificationMeta _shareCountMeta = const VerificationMeta(
    'shareCount',
  );
  @override
  late final GeneratedColumn<int> shareCount = GeneratedColumn<int>(
    'share_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerShareMeta = const VerificationMeta(
    'pricePerShare',
  );
  @override
  late final GeneratedColumn<double> pricePerShare = GeneratedColumn<double>(
    'price_per_share',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fairMarketValueMeta = const VerificationMeta(
    'fairMarketValue',
  );
  @override
  late final GeneratedColumn<double> fairMarketValue = GeneratedColumn<double>(
    'fair_market_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>(
        'transaction_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _rofrWaivedMeta = const VerificationMeta(
    'rofrWaived',
  );
  @override
  late final GeneratedColumn<bool> rofrWaived = GeneratedColumn<bool>(
    'rofr_waived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rofr_waived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceHoldingIdMeta = const VerificationMeta(
    'sourceHoldingId',
  );
  @override
  late final GeneratedColumn<String> sourceHoldingId = GeneratedColumn<String>(
    'source_holding_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES holdings (id)',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    sellerStakeholderId,
    buyerStakeholderId,
    shareClassId,
    shareCount,
    pricePerShare,
    fairMarketValue,
    transactionDate,
    type,
    status,
    rofrWaived,
    sourceHoldingId,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transfers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transfer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('seller_stakeholder_id')) {
      context.handle(
        _sellerStakeholderIdMeta,
        sellerStakeholderId.isAcceptableOrUnknown(
          data['seller_stakeholder_id']!,
          _sellerStakeholderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sellerStakeholderIdMeta);
    }
    if (data.containsKey('buyer_stakeholder_id')) {
      context.handle(
        _buyerStakeholderIdMeta,
        buyerStakeholderId.isAcceptableOrUnknown(
          data['buyer_stakeholder_id']!,
          _buyerStakeholderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_buyerStakeholderIdMeta);
    }
    if (data.containsKey('share_class_id')) {
      context.handle(
        _shareClassIdMeta,
        shareClassId.isAcceptableOrUnknown(
          data['share_class_id']!,
          _shareClassIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shareClassIdMeta);
    }
    if (data.containsKey('share_count')) {
      context.handle(
        _shareCountMeta,
        shareCount.isAcceptableOrUnknown(data['share_count']!, _shareCountMeta),
      );
    } else if (isInserting) {
      context.missing(_shareCountMeta);
    }
    if (data.containsKey('price_per_share')) {
      context.handle(
        _pricePerShareMeta,
        pricePerShare.isAcceptableOrUnknown(
          data['price_per_share']!,
          _pricePerShareMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerShareMeta);
    }
    if (data.containsKey('fair_market_value')) {
      context.handle(
        _fairMarketValueMeta,
        fairMarketValue.isAcceptableOrUnknown(
          data['fair_market_value']!,
          _fairMarketValueMeta,
        ),
      );
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('rofr_waived')) {
      context.handle(
        _rofrWaivedMeta,
        rofrWaived.isAcceptableOrUnknown(data['rofr_waived']!, _rofrWaivedMeta),
      );
    }
    if (data.containsKey('source_holding_id')) {
      context.handle(
        _sourceHoldingIdMeta,
        sourceHoldingId.isAcceptableOrUnknown(
          data['source_holding_id']!,
          _sourceHoldingIdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  Transfer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transfer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      sellerStakeholderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seller_stakeholder_id'],
      )!,
      buyerStakeholderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buyer_stakeholder_id'],
      )!,
      shareClassId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}share_class_id'],
      )!,
      shareCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}share_count'],
      )!,
      pricePerShare: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_per_share'],
      )!,
      fairMarketValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fair_market_value'],
      ),
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      rofrWaived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rofr_waived'],
      )!,
      sourceHoldingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_holding_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TransfersTable createAlias(String alias) {
    return $TransfersTable(attachedDatabase, alias);
  }
}

class Transfer extends DataClass implements Insertable<Transfer> {
  final String id;
  final String companyId;
  final String sellerStakeholderId;
  final String buyerStakeholderId;
  final String shareClassId;
  final int shareCount;
  final double pricePerShare;
  final double? fairMarketValue;
  final DateTime transactionDate;
  final String type;
  final String status;
  final bool rofrWaived;
  final String? sourceHoldingId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Transfer({
    required this.id,
    required this.companyId,
    required this.sellerStakeholderId,
    required this.buyerStakeholderId,
    required this.shareClassId,
    required this.shareCount,
    required this.pricePerShare,
    this.fairMarketValue,
    required this.transactionDate,
    required this.type,
    required this.status,
    required this.rofrWaived,
    this.sourceHoldingId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['seller_stakeholder_id'] = Variable<String>(sellerStakeholderId);
    map['buyer_stakeholder_id'] = Variable<String>(buyerStakeholderId);
    map['share_class_id'] = Variable<String>(shareClassId);
    map['share_count'] = Variable<int>(shareCount);
    map['price_per_share'] = Variable<double>(pricePerShare);
    if (!nullToAbsent || fairMarketValue != null) {
      map['fair_market_value'] = Variable<double>(fairMarketValue);
    }
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    map['rofr_waived'] = Variable<bool>(rofrWaived);
    if (!nullToAbsent || sourceHoldingId != null) {
      map['source_holding_id'] = Variable<String>(sourceHoldingId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TransfersCompanion toCompanion(bool nullToAbsent) {
    return TransfersCompanion(
      id: Value(id),
      companyId: Value(companyId),
      sellerStakeholderId: Value(sellerStakeholderId),
      buyerStakeholderId: Value(buyerStakeholderId),
      shareClassId: Value(shareClassId),
      shareCount: Value(shareCount),
      pricePerShare: Value(pricePerShare),
      fairMarketValue: fairMarketValue == null && nullToAbsent
          ? const Value.absent()
          : Value(fairMarketValue),
      transactionDate: Value(transactionDate),
      type: Value(type),
      status: Value(status),
      rofrWaived: Value(rofrWaived),
      sourceHoldingId: sourceHoldingId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceHoldingId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Transfer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transfer(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      sellerStakeholderId: serializer.fromJson<String>(
        json['sellerStakeholderId'],
      ),
      buyerStakeholderId: serializer.fromJson<String>(
        json['buyerStakeholderId'],
      ),
      shareClassId: serializer.fromJson<String>(json['shareClassId']),
      shareCount: serializer.fromJson<int>(json['shareCount']),
      pricePerShare: serializer.fromJson<double>(json['pricePerShare']),
      fairMarketValue: serializer.fromJson<double?>(json['fairMarketValue']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      rofrWaived: serializer.fromJson<bool>(json['rofrWaived']),
      sourceHoldingId: serializer.fromJson<String?>(json['sourceHoldingId']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'sellerStakeholderId': serializer.toJson<String>(sellerStakeholderId),
      'buyerStakeholderId': serializer.toJson<String>(buyerStakeholderId),
      'shareClassId': serializer.toJson<String>(shareClassId),
      'shareCount': serializer.toJson<int>(shareCount),
      'pricePerShare': serializer.toJson<double>(pricePerShare),
      'fairMarketValue': serializer.toJson<double?>(fairMarketValue),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'rofrWaived': serializer.toJson<bool>(rofrWaived),
      'sourceHoldingId': serializer.toJson<String?>(sourceHoldingId),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Transfer copyWith({
    String? id,
    String? companyId,
    String? sellerStakeholderId,
    String? buyerStakeholderId,
    String? shareClassId,
    int? shareCount,
    double? pricePerShare,
    Value<double?> fairMarketValue = const Value.absent(),
    DateTime? transactionDate,
    String? type,
    String? status,
    bool? rofrWaived,
    Value<String?> sourceHoldingId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Transfer(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    sellerStakeholderId: sellerStakeholderId ?? this.sellerStakeholderId,
    buyerStakeholderId: buyerStakeholderId ?? this.buyerStakeholderId,
    shareClassId: shareClassId ?? this.shareClassId,
    shareCount: shareCount ?? this.shareCount,
    pricePerShare: pricePerShare ?? this.pricePerShare,
    fairMarketValue: fairMarketValue.present
        ? fairMarketValue.value
        : this.fairMarketValue,
    transactionDate: transactionDate ?? this.transactionDate,
    type: type ?? this.type,
    status: status ?? this.status,
    rofrWaived: rofrWaived ?? this.rofrWaived,
    sourceHoldingId: sourceHoldingId.present
        ? sourceHoldingId.value
        : this.sourceHoldingId,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Transfer copyWithCompanion(TransfersCompanion data) {
    return Transfer(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      sellerStakeholderId: data.sellerStakeholderId.present
          ? data.sellerStakeholderId.value
          : this.sellerStakeholderId,
      buyerStakeholderId: data.buyerStakeholderId.present
          ? data.buyerStakeholderId.value
          : this.buyerStakeholderId,
      shareClassId: data.shareClassId.present
          ? data.shareClassId.value
          : this.shareClassId,
      shareCount: data.shareCount.present
          ? data.shareCount.value
          : this.shareCount,
      pricePerShare: data.pricePerShare.present
          ? data.pricePerShare.value
          : this.pricePerShare,
      fairMarketValue: data.fairMarketValue.present
          ? data.fairMarketValue.value
          : this.fairMarketValue,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      rofrWaived: data.rofrWaived.present
          ? data.rofrWaived.value
          : this.rofrWaived,
      sourceHoldingId: data.sourceHoldingId.present
          ? data.sourceHoldingId.value
          : this.sourceHoldingId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transfer(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('sellerStakeholderId: $sellerStakeholderId, ')
          ..write('buyerStakeholderId: $buyerStakeholderId, ')
          ..write('shareClassId: $shareClassId, ')
          ..write('shareCount: $shareCount, ')
          ..write('pricePerShare: $pricePerShare, ')
          ..write('fairMarketValue: $fairMarketValue, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('rofrWaived: $rofrWaived, ')
          ..write('sourceHoldingId: $sourceHoldingId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    sellerStakeholderId,
    buyerStakeholderId,
    shareClassId,
    shareCount,
    pricePerShare,
    fairMarketValue,
    transactionDate,
    type,
    status,
    rofrWaived,
    sourceHoldingId,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transfer &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.sellerStakeholderId == this.sellerStakeholderId &&
          other.buyerStakeholderId == this.buyerStakeholderId &&
          other.shareClassId == this.shareClassId &&
          other.shareCount == this.shareCount &&
          other.pricePerShare == this.pricePerShare &&
          other.fairMarketValue == this.fairMarketValue &&
          other.transactionDate == this.transactionDate &&
          other.type == this.type &&
          other.status == this.status &&
          other.rofrWaived == this.rofrWaived &&
          other.sourceHoldingId == this.sourceHoldingId &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TransfersCompanion extends UpdateCompanion<Transfer> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> sellerStakeholderId;
  final Value<String> buyerStakeholderId;
  final Value<String> shareClassId;
  final Value<int> shareCount;
  final Value<double> pricePerShare;
  final Value<double?> fairMarketValue;
  final Value<DateTime> transactionDate;
  final Value<String> type;
  final Value<String> status;
  final Value<bool> rofrWaived;
  final Value<String?> sourceHoldingId;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TransfersCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.sellerStakeholderId = const Value.absent(),
    this.buyerStakeholderId = const Value.absent(),
    this.shareClassId = const Value.absent(),
    this.shareCount = const Value.absent(),
    this.pricePerShare = const Value.absent(),
    this.fairMarketValue = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.rofrWaived = const Value.absent(),
    this.sourceHoldingId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransfersCompanion.insert({
    required String id,
    required String companyId,
    required String sellerStakeholderId,
    required String buyerStakeholderId,
    required String shareClassId,
    required int shareCount,
    required double pricePerShare,
    this.fairMarketValue = const Value.absent(),
    required DateTime transactionDate,
    required String type,
    this.status = const Value.absent(),
    this.rofrWaived = const Value.absent(),
    this.sourceHoldingId = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       sellerStakeholderId = Value(sellerStakeholderId),
       buyerStakeholderId = Value(buyerStakeholderId),
       shareClassId = Value(shareClassId),
       shareCount = Value(shareCount),
       pricePerShare = Value(pricePerShare),
       transactionDate = Value(transactionDate),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Transfer> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? sellerStakeholderId,
    Expression<String>? buyerStakeholderId,
    Expression<String>? shareClassId,
    Expression<int>? shareCount,
    Expression<double>? pricePerShare,
    Expression<double>? fairMarketValue,
    Expression<DateTime>? transactionDate,
    Expression<String>? type,
    Expression<String>? status,
    Expression<bool>? rofrWaived,
    Expression<String>? sourceHoldingId,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (sellerStakeholderId != null)
        'seller_stakeholder_id': sellerStakeholderId,
      if (buyerStakeholderId != null)
        'buyer_stakeholder_id': buyerStakeholderId,
      if (shareClassId != null) 'share_class_id': shareClassId,
      if (shareCount != null) 'share_count': shareCount,
      if (pricePerShare != null) 'price_per_share': pricePerShare,
      if (fairMarketValue != null) 'fair_market_value': fairMarketValue,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (rofrWaived != null) 'rofr_waived': rofrWaived,
      if (sourceHoldingId != null) 'source_holding_id': sourceHoldingId,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransfersCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? sellerStakeholderId,
    Value<String>? buyerStakeholderId,
    Value<String>? shareClassId,
    Value<int>? shareCount,
    Value<double>? pricePerShare,
    Value<double?>? fairMarketValue,
    Value<DateTime>? transactionDate,
    Value<String>? type,
    Value<String>? status,
    Value<bool>? rofrWaived,
    Value<String?>? sourceHoldingId,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TransfersCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      sellerStakeholderId: sellerStakeholderId ?? this.sellerStakeholderId,
      buyerStakeholderId: buyerStakeholderId ?? this.buyerStakeholderId,
      shareClassId: shareClassId ?? this.shareClassId,
      shareCount: shareCount ?? this.shareCount,
      pricePerShare: pricePerShare ?? this.pricePerShare,
      fairMarketValue: fairMarketValue ?? this.fairMarketValue,
      transactionDate: transactionDate ?? this.transactionDate,
      type: type ?? this.type,
      status: status ?? this.status,
      rofrWaived: rofrWaived ?? this.rofrWaived,
      sourceHoldingId: sourceHoldingId ?? this.sourceHoldingId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (sellerStakeholderId.present) {
      map['seller_stakeholder_id'] = Variable<String>(
        sellerStakeholderId.value,
      );
    }
    if (buyerStakeholderId.present) {
      map['buyer_stakeholder_id'] = Variable<String>(buyerStakeholderId.value);
    }
    if (shareClassId.present) {
      map['share_class_id'] = Variable<String>(shareClassId.value);
    }
    if (shareCount.present) {
      map['share_count'] = Variable<int>(shareCount.value);
    }
    if (pricePerShare.present) {
      map['price_per_share'] = Variable<double>(pricePerShare.value);
    }
    if (fairMarketValue.present) {
      map['fair_market_value'] = Variable<double>(fairMarketValue.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rofrWaived.present) {
      map['rofr_waived'] = Variable<bool>(rofrWaived.value);
    }
    if (sourceHoldingId.present) {
      map['source_holding_id'] = Variable<String>(sourceHoldingId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransfersCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('sellerStakeholderId: $sellerStakeholderId, ')
          ..write('buyerStakeholderId: $buyerStakeholderId, ')
          ..write('shareClassId: $shareClassId, ')
          ..write('shareCount: $shareCount, ')
          ..write('pricePerShare: $pricePerShare, ')
          ..write('fairMarketValue: $fairMarketValue, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('rofrWaived: $rofrWaived, ')
          ..write('sourceHoldingId: $sourceHoldingId, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MfnUpgradesTable extends MfnUpgrades
    with TableInfo<$MfnUpgradesTable, MfnUpgrade> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MfnUpgradesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _targetConvertibleIdMeta =
      const VerificationMeta('targetConvertibleId');
  @override
  late final GeneratedColumn<String> targetConvertibleId =
      GeneratedColumn<String>(
        'target_convertible_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES convertibles (id)',
        ),
      );
  static const VerificationMeta _sourceConvertibleIdMeta =
      const VerificationMeta('sourceConvertibleId');
  @override
  late final GeneratedColumn<String> sourceConvertibleId =
      GeneratedColumn<String>(
        'source_convertible_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES convertibles (id)',
        ),
      );
  static const VerificationMeta _previousDiscountPercentMeta =
      const VerificationMeta('previousDiscountPercent');
  @override
  late final GeneratedColumn<double> previousDiscountPercent =
      GeneratedColumn<double>(
        'previous_discount_percent',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _previousValuationCapMeta =
      const VerificationMeta('previousValuationCap');
  @override
  late final GeneratedColumn<double> previousValuationCap =
      GeneratedColumn<double>(
        'previous_valuation_cap',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _previousHasProRataMeta =
      const VerificationMeta('previousHasProRata');
  @override
  late final GeneratedColumn<bool> previousHasProRata = GeneratedColumn<bool>(
    'previous_has_pro_rata',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("previous_has_pro_rata" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _newDiscountPercentMeta =
      const VerificationMeta('newDiscountPercent');
  @override
  late final GeneratedColumn<double> newDiscountPercent =
      GeneratedColumn<double>(
        'new_discount_percent',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _newValuationCapMeta = const VerificationMeta(
    'newValuationCap',
  );
  @override
  late final GeneratedColumn<double> newValuationCap = GeneratedColumn<double>(
    'new_valuation_cap',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newHasProRataMeta = const VerificationMeta(
    'newHasProRata',
  );
  @override
  late final GeneratedColumn<bool> newHasProRata = GeneratedColumn<bool>(
    'new_has_pro_rata',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("new_has_pro_rata" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _upgradeDateMeta = const VerificationMeta(
    'upgradeDate',
  );
  @override
  late final GeneratedColumn<DateTime> upgradeDate = GeneratedColumn<DateTime>(
    'upgrade_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    targetConvertibleId,
    sourceConvertibleId,
    previousDiscountPercent,
    previousValuationCap,
    previousHasProRata,
    newDiscountPercent,
    newValuationCap,
    newHasProRata,
    upgradeDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mfn_upgrades';
  @override
  VerificationContext validateIntegrity(
    Insertable<MfnUpgrade> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('target_convertible_id')) {
      context.handle(
        _targetConvertibleIdMeta,
        targetConvertibleId.isAcceptableOrUnknown(
          data['target_convertible_id']!,
          _targetConvertibleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetConvertibleIdMeta);
    }
    if (data.containsKey('source_convertible_id')) {
      context.handle(
        _sourceConvertibleIdMeta,
        sourceConvertibleId.isAcceptableOrUnknown(
          data['source_convertible_id']!,
          _sourceConvertibleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceConvertibleIdMeta);
    }
    if (data.containsKey('previous_discount_percent')) {
      context.handle(
        _previousDiscountPercentMeta,
        previousDiscountPercent.isAcceptableOrUnknown(
          data['previous_discount_percent']!,
          _previousDiscountPercentMeta,
        ),
      );
    }
    if (data.containsKey('previous_valuation_cap')) {
      context.handle(
        _previousValuationCapMeta,
        previousValuationCap.isAcceptableOrUnknown(
          data['previous_valuation_cap']!,
          _previousValuationCapMeta,
        ),
      );
    }
    if (data.containsKey('previous_has_pro_rata')) {
      context.handle(
        _previousHasProRataMeta,
        previousHasProRata.isAcceptableOrUnknown(
          data['previous_has_pro_rata']!,
          _previousHasProRataMeta,
        ),
      );
    }
    if (data.containsKey('new_discount_percent')) {
      context.handle(
        _newDiscountPercentMeta,
        newDiscountPercent.isAcceptableOrUnknown(
          data['new_discount_percent']!,
          _newDiscountPercentMeta,
        ),
      );
    }
    if (data.containsKey('new_valuation_cap')) {
      context.handle(
        _newValuationCapMeta,
        newValuationCap.isAcceptableOrUnknown(
          data['new_valuation_cap']!,
          _newValuationCapMeta,
        ),
      );
    }
    if (data.containsKey('new_has_pro_rata')) {
      context.handle(
        _newHasProRataMeta,
        newHasProRata.isAcceptableOrUnknown(
          data['new_has_pro_rata']!,
          _newHasProRataMeta,
        ),
      );
    }
    if (data.containsKey('upgrade_date')) {
      context.handle(
        _upgradeDateMeta,
        upgradeDate.isAcceptableOrUnknown(
          data['upgrade_date']!,
          _upgradeDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_upgradeDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MfnUpgrade map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MfnUpgrade(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      targetConvertibleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_convertible_id'],
      )!,
      sourceConvertibleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_convertible_id'],
      )!,
      previousDiscountPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}previous_discount_percent'],
      ),
      previousValuationCap: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}previous_valuation_cap'],
      ),
      previousHasProRata: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}previous_has_pro_rata'],
      )!,
      newDiscountPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}new_discount_percent'],
      ),
      newValuationCap: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}new_valuation_cap'],
      ),
      newHasProRata: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}new_has_pro_rata'],
      )!,
      upgradeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}upgrade_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MfnUpgradesTable createAlias(String alias) {
    return $MfnUpgradesTable(attachedDatabase, alias);
  }
}

class MfnUpgrade extends DataClass implements Insertable<MfnUpgrade> {
  final String id;
  final String companyId;

  /// The convertible that was upgraded (has MFN clause)
  final String targetConvertibleId;

  /// The convertible that triggered the upgrade (has better terms)
  final String sourceConvertibleId;

  /// Terms BEFORE upgrade
  final double? previousDiscountPercent;
  final double? previousValuationCap;
  final bool previousHasProRata;

  /// Terms AFTER upgrade
  final double? newDiscountPercent;
  final double? newValuationCap;
  final bool newHasProRata;
  final DateTime upgradeDate;
  final DateTime createdAt;
  const MfnUpgrade({
    required this.id,
    required this.companyId,
    required this.targetConvertibleId,
    required this.sourceConvertibleId,
    this.previousDiscountPercent,
    this.previousValuationCap,
    required this.previousHasProRata,
    this.newDiscountPercent,
    this.newValuationCap,
    required this.newHasProRata,
    required this.upgradeDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['target_convertible_id'] = Variable<String>(targetConvertibleId);
    map['source_convertible_id'] = Variable<String>(sourceConvertibleId);
    if (!nullToAbsent || previousDiscountPercent != null) {
      map['previous_discount_percent'] = Variable<double>(
        previousDiscountPercent,
      );
    }
    if (!nullToAbsent || previousValuationCap != null) {
      map['previous_valuation_cap'] = Variable<double>(previousValuationCap);
    }
    map['previous_has_pro_rata'] = Variable<bool>(previousHasProRata);
    if (!nullToAbsent || newDiscountPercent != null) {
      map['new_discount_percent'] = Variable<double>(newDiscountPercent);
    }
    if (!nullToAbsent || newValuationCap != null) {
      map['new_valuation_cap'] = Variable<double>(newValuationCap);
    }
    map['new_has_pro_rata'] = Variable<bool>(newHasProRata);
    map['upgrade_date'] = Variable<DateTime>(upgradeDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MfnUpgradesCompanion toCompanion(bool nullToAbsent) {
    return MfnUpgradesCompanion(
      id: Value(id),
      companyId: Value(companyId),
      targetConvertibleId: Value(targetConvertibleId),
      sourceConvertibleId: Value(sourceConvertibleId),
      previousDiscountPercent: previousDiscountPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(previousDiscountPercent),
      previousValuationCap: previousValuationCap == null && nullToAbsent
          ? const Value.absent()
          : Value(previousValuationCap),
      previousHasProRata: Value(previousHasProRata),
      newDiscountPercent: newDiscountPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(newDiscountPercent),
      newValuationCap: newValuationCap == null && nullToAbsent
          ? const Value.absent()
          : Value(newValuationCap),
      newHasProRata: Value(newHasProRata),
      upgradeDate: Value(upgradeDate),
      createdAt: Value(createdAt),
    );
  }

  factory MfnUpgrade.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MfnUpgrade(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      targetConvertibleId: serializer.fromJson<String>(
        json['targetConvertibleId'],
      ),
      sourceConvertibleId: serializer.fromJson<String>(
        json['sourceConvertibleId'],
      ),
      previousDiscountPercent: serializer.fromJson<double?>(
        json['previousDiscountPercent'],
      ),
      previousValuationCap: serializer.fromJson<double?>(
        json['previousValuationCap'],
      ),
      previousHasProRata: serializer.fromJson<bool>(json['previousHasProRata']),
      newDiscountPercent: serializer.fromJson<double?>(
        json['newDiscountPercent'],
      ),
      newValuationCap: serializer.fromJson<double?>(json['newValuationCap']),
      newHasProRata: serializer.fromJson<bool>(json['newHasProRata']),
      upgradeDate: serializer.fromJson<DateTime>(json['upgradeDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'targetConvertibleId': serializer.toJson<String>(targetConvertibleId),
      'sourceConvertibleId': serializer.toJson<String>(sourceConvertibleId),
      'previousDiscountPercent': serializer.toJson<double?>(
        previousDiscountPercent,
      ),
      'previousValuationCap': serializer.toJson<double?>(previousValuationCap),
      'previousHasProRata': serializer.toJson<bool>(previousHasProRata),
      'newDiscountPercent': serializer.toJson<double?>(newDiscountPercent),
      'newValuationCap': serializer.toJson<double?>(newValuationCap),
      'newHasProRata': serializer.toJson<bool>(newHasProRata),
      'upgradeDate': serializer.toJson<DateTime>(upgradeDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MfnUpgrade copyWith({
    String? id,
    String? companyId,
    String? targetConvertibleId,
    String? sourceConvertibleId,
    Value<double?> previousDiscountPercent = const Value.absent(),
    Value<double?> previousValuationCap = const Value.absent(),
    bool? previousHasProRata,
    Value<double?> newDiscountPercent = const Value.absent(),
    Value<double?> newValuationCap = const Value.absent(),
    bool? newHasProRata,
    DateTime? upgradeDate,
    DateTime? createdAt,
  }) => MfnUpgrade(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    targetConvertibleId: targetConvertibleId ?? this.targetConvertibleId,
    sourceConvertibleId: sourceConvertibleId ?? this.sourceConvertibleId,
    previousDiscountPercent: previousDiscountPercent.present
        ? previousDiscountPercent.value
        : this.previousDiscountPercent,
    previousValuationCap: previousValuationCap.present
        ? previousValuationCap.value
        : this.previousValuationCap,
    previousHasProRata: previousHasProRata ?? this.previousHasProRata,
    newDiscountPercent: newDiscountPercent.present
        ? newDiscountPercent.value
        : this.newDiscountPercent,
    newValuationCap: newValuationCap.present
        ? newValuationCap.value
        : this.newValuationCap,
    newHasProRata: newHasProRata ?? this.newHasProRata,
    upgradeDate: upgradeDate ?? this.upgradeDate,
    createdAt: createdAt ?? this.createdAt,
  );
  MfnUpgrade copyWithCompanion(MfnUpgradesCompanion data) {
    return MfnUpgrade(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      targetConvertibleId: data.targetConvertibleId.present
          ? data.targetConvertibleId.value
          : this.targetConvertibleId,
      sourceConvertibleId: data.sourceConvertibleId.present
          ? data.sourceConvertibleId.value
          : this.sourceConvertibleId,
      previousDiscountPercent: data.previousDiscountPercent.present
          ? data.previousDiscountPercent.value
          : this.previousDiscountPercent,
      previousValuationCap: data.previousValuationCap.present
          ? data.previousValuationCap.value
          : this.previousValuationCap,
      previousHasProRata: data.previousHasProRata.present
          ? data.previousHasProRata.value
          : this.previousHasProRata,
      newDiscountPercent: data.newDiscountPercent.present
          ? data.newDiscountPercent.value
          : this.newDiscountPercent,
      newValuationCap: data.newValuationCap.present
          ? data.newValuationCap.value
          : this.newValuationCap,
      newHasProRata: data.newHasProRata.present
          ? data.newHasProRata.value
          : this.newHasProRata,
      upgradeDate: data.upgradeDate.present
          ? data.upgradeDate.value
          : this.upgradeDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MfnUpgrade(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('targetConvertibleId: $targetConvertibleId, ')
          ..write('sourceConvertibleId: $sourceConvertibleId, ')
          ..write('previousDiscountPercent: $previousDiscountPercent, ')
          ..write('previousValuationCap: $previousValuationCap, ')
          ..write('previousHasProRata: $previousHasProRata, ')
          ..write('newDiscountPercent: $newDiscountPercent, ')
          ..write('newValuationCap: $newValuationCap, ')
          ..write('newHasProRata: $newHasProRata, ')
          ..write('upgradeDate: $upgradeDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    targetConvertibleId,
    sourceConvertibleId,
    previousDiscountPercent,
    previousValuationCap,
    previousHasProRata,
    newDiscountPercent,
    newValuationCap,
    newHasProRata,
    upgradeDate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MfnUpgrade &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.targetConvertibleId == this.targetConvertibleId &&
          other.sourceConvertibleId == this.sourceConvertibleId &&
          other.previousDiscountPercent == this.previousDiscountPercent &&
          other.previousValuationCap == this.previousValuationCap &&
          other.previousHasProRata == this.previousHasProRata &&
          other.newDiscountPercent == this.newDiscountPercent &&
          other.newValuationCap == this.newValuationCap &&
          other.newHasProRata == this.newHasProRata &&
          other.upgradeDate == this.upgradeDate &&
          other.createdAt == this.createdAt);
}

class MfnUpgradesCompanion extends UpdateCompanion<MfnUpgrade> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> targetConvertibleId;
  final Value<String> sourceConvertibleId;
  final Value<double?> previousDiscountPercent;
  final Value<double?> previousValuationCap;
  final Value<bool> previousHasProRata;
  final Value<double?> newDiscountPercent;
  final Value<double?> newValuationCap;
  final Value<bool> newHasProRata;
  final Value<DateTime> upgradeDate;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MfnUpgradesCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.targetConvertibleId = const Value.absent(),
    this.sourceConvertibleId = const Value.absent(),
    this.previousDiscountPercent = const Value.absent(),
    this.previousValuationCap = const Value.absent(),
    this.previousHasProRata = const Value.absent(),
    this.newDiscountPercent = const Value.absent(),
    this.newValuationCap = const Value.absent(),
    this.newHasProRata = const Value.absent(),
    this.upgradeDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MfnUpgradesCompanion.insert({
    required String id,
    required String companyId,
    required String targetConvertibleId,
    required String sourceConvertibleId,
    this.previousDiscountPercent = const Value.absent(),
    this.previousValuationCap = const Value.absent(),
    this.previousHasProRata = const Value.absent(),
    this.newDiscountPercent = const Value.absent(),
    this.newValuationCap = const Value.absent(),
    this.newHasProRata = const Value.absent(),
    required DateTime upgradeDate,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       targetConvertibleId = Value(targetConvertibleId),
       sourceConvertibleId = Value(sourceConvertibleId),
       upgradeDate = Value(upgradeDate),
       createdAt = Value(createdAt);
  static Insertable<MfnUpgrade> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? targetConvertibleId,
    Expression<String>? sourceConvertibleId,
    Expression<double>? previousDiscountPercent,
    Expression<double>? previousValuationCap,
    Expression<bool>? previousHasProRata,
    Expression<double>? newDiscountPercent,
    Expression<double>? newValuationCap,
    Expression<bool>? newHasProRata,
    Expression<DateTime>? upgradeDate,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (targetConvertibleId != null)
        'target_convertible_id': targetConvertibleId,
      if (sourceConvertibleId != null)
        'source_convertible_id': sourceConvertibleId,
      if (previousDiscountPercent != null)
        'previous_discount_percent': previousDiscountPercent,
      if (previousValuationCap != null)
        'previous_valuation_cap': previousValuationCap,
      if (previousHasProRata != null)
        'previous_has_pro_rata': previousHasProRata,
      if (newDiscountPercent != null)
        'new_discount_percent': newDiscountPercent,
      if (newValuationCap != null) 'new_valuation_cap': newValuationCap,
      if (newHasProRata != null) 'new_has_pro_rata': newHasProRata,
      if (upgradeDate != null) 'upgrade_date': upgradeDate,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MfnUpgradesCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? targetConvertibleId,
    Value<String>? sourceConvertibleId,
    Value<double?>? previousDiscountPercent,
    Value<double?>? previousValuationCap,
    Value<bool>? previousHasProRata,
    Value<double?>? newDiscountPercent,
    Value<double?>? newValuationCap,
    Value<bool>? newHasProRata,
    Value<DateTime>? upgradeDate,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MfnUpgradesCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      targetConvertibleId: targetConvertibleId ?? this.targetConvertibleId,
      sourceConvertibleId: sourceConvertibleId ?? this.sourceConvertibleId,
      previousDiscountPercent:
          previousDiscountPercent ?? this.previousDiscountPercent,
      previousValuationCap: previousValuationCap ?? this.previousValuationCap,
      previousHasProRata: previousHasProRata ?? this.previousHasProRata,
      newDiscountPercent: newDiscountPercent ?? this.newDiscountPercent,
      newValuationCap: newValuationCap ?? this.newValuationCap,
      newHasProRata: newHasProRata ?? this.newHasProRata,
      upgradeDate: upgradeDate ?? this.upgradeDate,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (targetConvertibleId.present) {
      map['target_convertible_id'] = Variable<String>(
        targetConvertibleId.value,
      );
    }
    if (sourceConvertibleId.present) {
      map['source_convertible_id'] = Variable<String>(
        sourceConvertibleId.value,
      );
    }
    if (previousDiscountPercent.present) {
      map['previous_discount_percent'] = Variable<double>(
        previousDiscountPercent.value,
      );
    }
    if (previousValuationCap.present) {
      map['previous_valuation_cap'] = Variable<double>(
        previousValuationCap.value,
      );
    }
    if (previousHasProRata.present) {
      map['previous_has_pro_rata'] = Variable<bool>(previousHasProRata.value);
    }
    if (newDiscountPercent.present) {
      map['new_discount_percent'] = Variable<double>(newDiscountPercent.value);
    }
    if (newValuationCap.present) {
      map['new_valuation_cap'] = Variable<double>(newValuationCap.value);
    }
    if (newHasProRata.present) {
      map['new_has_pro_rata'] = Variable<bool>(newHasProRata.value);
    }
    if (upgradeDate.present) {
      map['upgrade_date'] = Variable<DateTime>(upgradeDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MfnUpgradesCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('targetConvertibleId: $targetConvertibleId, ')
          ..write('sourceConvertibleId: $sourceConvertibleId, ')
          ..write('previousDiscountPercent: $previousDiscountPercent, ')
          ..write('previousValuationCap: $previousValuationCap, ')
          ..write('previousHasProRata: $previousHasProRata, ')
          ..write('newDiscountPercent: $newDiscountPercent, ')
          ..write('newValuationCap: $newValuationCap, ')
          ..write('newHasProRata: $newHasProRata, ')
          ..write('upgradeDate: $upgradeDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EsopPoolExpansionsTable extends EsopPoolExpansions
    with TableInfo<$EsopPoolExpansionsTable, EsopPoolExpansion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EsopPoolExpansionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _poolIdMeta = const VerificationMeta('poolId');
  @override
  late final GeneratedColumn<String> poolId = GeneratedColumn<String>(
    'pool_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES esop_pools (id)',
    ),
  );
  static const VerificationMeta _previousSizeMeta = const VerificationMeta(
    'previousSize',
  );
  @override
  late final GeneratedColumn<int> previousSize = GeneratedColumn<int>(
    'previous_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newSizeMeta = const VerificationMeta(
    'newSize',
  );
  @override
  late final GeneratedColumn<int> newSize = GeneratedColumn<int>(
    'new_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sharesAddedMeta = const VerificationMeta(
    'sharesAdded',
  );
  @override
  late final GeneratedColumn<int> sharesAdded = GeneratedColumn<int>(
    'shares_added',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolutionReferenceMeta =
      const VerificationMeta('resolutionReference');
  @override
  late final GeneratedColumn<String> resolutionReference =
      GeneratedColumn<String>(
        'resolution_reference',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _expansionDateMeta = const VerificationMeta(
    'expansionDate',
  );
  @override
  late final GeneratedColumn<DateTime> expansionDate =
      GeneratedColumn<DateTime>(
        'expansion_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    poolId,
    previousSize,
    newSize,
    sharesAdded,
    reason,
    resolutionReference,
    expansionDate,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'esop_pool_expansions';
  @override
  VerificationContext validateIntegrity(
    Insertable<EsopPoolExpansion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('pool_id')) {
      context.handle(
        _poolIdMeta,
        poolId.isAcceptableOrUnknown(data['pool_id']!, _poolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_poolIdMeta);
    }
    if (data.containsKey('previous_size')) {
      context.handle(
        _previousSizeMeta,
        previousSize.isAcceptableOrUnknown(
          data['previous_size']!,
          _previousSizeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousSizeMeta);
    }
    if (data.containsKey('new_size')) {
      context.handle(
        _newSizeMeta,
        newSize.isAcceptableOrUnknown(data['new_size']!, _newSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_newSizeMeta);
    }
    if (data.containsKey('shares_added')) {
      context.handle(
        _sharesAddedMeta,
        sharesAdded.isAcceptableOrUnknown(
          data['shares_added']!,
          _sharesAddedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sharesAddedMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('resolution_reference')) {
      context.handle(
        _resolutionReferenceMeta,
        resolutionReference.isAcceptableOrUnknown(
          data['resolution_reference']!,
          _resolutionReferenceMeta,
        ),
      );
    }
    if (data.containsKey('expansion_date')) {
      context.handle(
        _expansionDateMeta,
        expansionDate.isAcceptableOrUnknown(
          data['expansion_date']!,
          _expansionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expansionDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EsopPoolExpansion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EsopPoolExpansion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      poolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pool_id'],
      )!,
      previousSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}previous_size'],
      )!,
      newSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_size'],
      )!,
      sharesAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shares_added'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      resolutionReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution_reference'],
      ),
      expansionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expansion_date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EsopPoolExpansionsTable createAlias(String alias) {
    return $EsopPoolExpansionsTable(attachedDatabase, alias);
  }
}

class EsopPoolExpansion extends DataClass
    implements Insertable<EsopPoolExpansion> {
  final String id;
  final String companyId;

  /// The pool that was expanded
  final String poolId;

  /// Pool size BEFORE expansion
  final int previousSize;

  /// Pool size AFTER expansion
  final int newSize;

  /// The shares added in this expansion
  final int sharesAdded;

  /// Reason for expansion: 'target_percentage', 'manual', 'round_requirement'
  final String reason;

  /// Board resolution reference if applicable
  final String? resolutionReference;

  /// Date the expansion was recorded
  final DateTime expansionDate;

  /// Notes about the expansion
  final String? notes;
  final DateTime createdAt;
  const EsopPoolExpansion({
    required this.id,
    required this.companyId,
    required this.poolId,
    required this.previousSize,
    required this.newSize,
    required this.sharesAdded,
    required this.reason,
    this.resolutionReference,
    required this.expansionDate,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['pool_id'] = Variable<String>(poolId);
    map['previous_size'] = Variable<int>(previousSize);
    map['new_size'] = Variable<int>(newSize);
    map['shares_added'] = Variable<int>(sharesAdded);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || resolutionReference != null) {
      map['resolution_reference'] = Variable<String>(resolutionReference);
    }
    map['expansion_date'] = Variable<DateTime>(expansionDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EsopPoolExpansionsCompanion toCompanion(bool nullToAbsent) {
    return EsopPoolExpansionsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      poolId: Value(poolId),
      previousSize: Value(previousSize),
      newSize: Value(newSize),
      sharesAdded: Value(sharesAdded),
      reason: Value(reason),
      resolutionReference: resolutionReference == null && nullToAbsent
          ? const Value.absent()
          : Value(resolutionReference),
      expansionDate: Value(expansionDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory EsopPoolExpansion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EsopPoolExpansion(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      poolId: serializer.fromJson<String>(json['poolId']),
      previousSize: serializer.fromJson<int>(json['previousSize']),
      newSize: serializer.fromJson<int>(json['newSize']),
      sharesAdded: serializer.fromJson<int>(json['sharesAdded']),
      reason: serializer.fromJson<String>(json['reason']),
      resolutionReference: serializer.fromJson<String?>(
        json['resolutionReference'],
      ),
      expansionDate: serializer.fromJson<DateTime>(json['expansionDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'poolId': serializer.toJson<String>(poolId),
      'previousSize': serializer.toJson<int>(previousSize),
      'newSize': serializer.toJson<int>(newSize),
      'sharesAdded': serializer.toJson<int>(sharesAdded),
      'reason': serializer.toJson<String>(reason),
      'resolutionReference': serializer.toJson<String?>(resolutionReference),
      'expansionDate': serializer.toJson<DateTime>(expansionDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EsopPoolExpansion copyWith({
    String? id,
    String? companyId,
    String? poolId,
    int? previousSize,
    int? newSize,
    int? sharesAdded,
    String? reason,
    Value<String?> resolutionReference = const Value.absent(),
    DateTime? expansionDate,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => EsopPoolExpansion(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    poolId: poolId ?? this.poolId,
    previousSize: previousSize ?? this.previousSize,
    newSize: newSize ?? this.newSize,
    sharesAdded: sharesAdded ?? this.sharesAdded,
    reason: reason ?? this.reason,
    resolutionReference: resolutionReference.present
        ? resolutionReference.value
        : this.resolutionReference,
    expansionDate: expansionDate ?? this.expansionDate,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  EsopPoolExpansion copyWithCompanion(EsopPoolExpansionsCompanion data) {
    return EsopPoolExpansion(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      poolId: data.poolId.present ? data.poolId.value : this.poolId,
      previousSize: data.previousSize.present
          ? data.previousSize.value
          : this.previousSize,
      newSize: data.newSize.present ? data.newSize.value : this.newSize,
      sharesAdded: data.sharesAdded.present
          ? data.sharesAdded.value
          : this.sharesAdded,
      reason: data.reason.present ? data.reason.value : this.reason,
      resolutionReference: data.resolutionReference.present
          ? data.resolutionReference.value
          : this.resolutionReference,
      expansionDate: data.expansionDate.present
          ? data.expansionDate.value
          : this.expansionDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EsopPoolExpansion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('poolId: $poolId, ')
          ..write('previousSize: $previousSize, ')
          ..write('newSize: $newSize, ')
          ..write('sharesAdded: $sharesAdded, ')
          ..write('reason: $reason, ')
          ..write('resolutionReference: $resolutionReference, ')
          ..write('expansionDate: $expansionDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    poolId,
    previousSize,
    newSize,
    sharesAdded,
    reason,
    resolutionReference,
    expansionDate,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EsopPoolExpansion &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.poolId == this.poolId &&
          other.previousSize == this.previousSize &&
          other.newSize == this.newSize &&
          other.sharesAdded == this.sharesAdded &&
          other.reason == this.reason &&
          other.resolutionReference == this.resolutionReference &&
          other.expansionDate == this.expansionDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class EsopPoolExpansionsCompanion extends UpdateCompanion<EsopPoolExpansion> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> poolId;
  final Value<int> previousSize;
  final Value<int> newSize;
  final Value<int> sharesAdded;
  final Value<String> reason;
  final Value<String?> resolutionReference;
  final Value<DateTime> expansionDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const EsopPoolExpansionsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.poolId = const Value.absent(),
    this.previousSize = const Value.absent(),
    this.newSize = const Value.absent(),
    this.sharesAdded = const Value.absent(),
    this.reason = const Value.absent(),
    this.resolutionReference = const Value.absent(),
    this.expansionDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EsopPoolExpansionsCompanion.insert({
    required String id,
    required String companyId,
    required String poolId,
    required int previousSize,
    required int newSize,
    required int sharesAdded,
    required String reason,
    this.resolutionReference = const Value.absent(),
    required DateTime expansionDate,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       poolId = Value(poolId),
       previousSize = Value(previousSize),
       newSize = Value(newSize),
       sharesAdded = Value(sharesAdded),
       reason = Value(reason),
       expansionDate = Value(expansionDate),
       createdAt = Value(createdAt);
  static Insertable<EsopPoolExpansion> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? poolId,
    Expression<int>? previousSize,
    Expression<int>? newSize,
    Expression<int>? sharesAdded,
    Expression<String>? reason,
    Expression<String>? resolutionReference,
    Expression<DateTime>? expansionDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (poolId != null) 'pool_id': poolId,
      if (previousSize != null) 'previous_size': previousSize,
      if (newSize != null) 'new_size': newSize,
      if (sharesAdded != null) 'shares_added': sharesAdded,
      if (reason != null) 'reason': reason,
      if (resolutionReference != null)
        'resolution_reference': resolutionReference,
      if (expansionDate != null) 'expansion_date': expansionDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EsopPoolExpansionsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? poolId,
    Value<int>? previousSize,
    Value<int>? newSize,
    Value<int>? sharesAdded,
    Value<String>? reason,
    Value<String?>? resolutionReference,
    Value<DateTime>? expansionDate,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return EsopPoolExpansionsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      poolId: poolId ?? this.poolId,
      previousSize: previousSize ?? this.previousSize,
      newSize: newSize ?? this.newSize,
      sharesAdded: sharesAdded ?? this.sharesAdded,
      reason: reason ?? this.reason,
      resolutionReference: resolutionReference ?? this.resolutionReference,
      expansionDate: expansionDate ?? this.expansionDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (poolId.present) {
      map['pool_id'] = Variable<String>(poolId.value);
    }
    if (previousSize.present) {
      map['previous_size'] = Variable<int>(previousSize.value);
    }
    if (newSize.present) {
      map['new_size'] = Variable<int>(newSize.value);
    }
    if (sharesAdded.present) {
      map['shares_added'] = Variable<int>(sharesAdded.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (resolutionReference.present) {
      map['resolution_reference'] = Variable<String>(resolutionReference.value);
    }
    if (expansionDate.present) {
      map['expansion_date'] = Variable<DateTime>(expansionDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EsopPoolExpansionsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('poolId: $poolId, ')
          ..write('previousSize: $previousSize, ')
          ..write('newSize: $newSize, ')
          ..write('sharesAdded: $sharesAdded, ')
          ..write('reason: $reason, ')
          ..write('resolutionReference: $resolutionReference, ')
          ..write('expansionDate: $expansionDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SnapshotsTable extends Snapshots
    with TableInfo<$SnapshotsTable, Snapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id)',
    ),
  );
  static const VerificationMeta _atSequenceNumberMeta = const VerificationMeta(
    'atSequenceNumber',
  );
  @override
  late final GeneratedColumn<int> atSequenceNumber = GeneratedColumn<int>(
    'at_sequence_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateJsonMeta = const VerificationMeta(
    'stateJson',
  );
  @override
  late final GeneratedColumn<String> stateJson = GeneratedColumn<String>(
    'state_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    atSequenceNumber,
    stateJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<Snapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('at_sequence_number')) {
      context.handle(
        _atSequenceNumberMeta,
        atSequenceNumber.isAcceptableOrUnknown(
          data['at_sequence_number']!,
          _atSequenceNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atSequenceNumberMeta);
    }
    if (data.containsKey('state_json')) {
      context.handle(
        _stateJsonMeta,
        stateJson.isAcceptableOrUnknown(data['state_json']!, _stateJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_stateJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Snapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Snapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      atSequenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at_sequence_number'],
      )!,
      stateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SnapshotsTable createAlias(String alias) {
    return $SnapshotsTable(attachedDatabase, alias);
  }
}

class Snapshot extends DataClass implements Insertable<Snapshot> {
  final String id;
  final String companyId;

  /// The sequence number at which this snapshot was taken
  final int atSequenceNumber;

  /// The full projected state as JSON
  final String stateJson;

  /// When the snapshot was created
  final DateTime createdAt;
  const Snapshot({
    required this.id,
    required this.companyId,
    required this.atSequenceNumber,
    required this.stateJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['at_sequence_number'] = Variable<int>(atSequenceNumber);
    map['state_json'] = Variable<String>(stateJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SnapshotsCompanion toCompanion(bool nullToAbsent) {
    return SnapshotsCompanion(
      id: Value(id),
      companyId: Value(companyId),
      atSequenceNumber: Value(atSequenceNumber),
      stateJson: Value(stateJson),
      createdAt: Value(createdAt),
    );
  }

  factory Snapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Snapshot(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      atSequenceNumber: serializer.fromJson<int>(json['atSequenceNumber']),
      stateJson: serializer.fromJson<String>(json['stateJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'atSequenceNumber': serializer.toJson<int>(atSequenceNumber),
      'stateJson': serializer.toJson<String>(stateJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Snapshot copyWith({
    String? id,
    String? companyId,
    int? atSequenceNumber,
    String? stateJson,
    DateTime? createdAt,
  }) => Snapshot(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    atSequenceNumber: atSequenceNumber ?? this.atSequenceNumber,
    stateJson: stateJson ?? this.stateJson,
    createdAt: createdAt ?? this.createdAt,
  );
  Snapshot copyWithCompanion(SnapshotsCompanion data) {
    return Snapshot(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      atSequenceNumber: data.atSequenceNumber.present
          ? data.atSequenceNumber.value
          : this.atSequenceNumber,
      stateJson: data.stateJson.present ? data.stateJson.value : this.stateJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Snapshot(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('atSequenceNumber: $atSequenceNumber, ')
          ..write('stateJson: $stateJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, companyId, atSequenceNumber, stateJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Snapshot &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.atSequenceNumber == this.atSequenceNumber &&
          other.stateJson == this.stateJson &&
          other.createdAt == this.createdAt);
}

class SnapshotsCompanion extends UpdateCompanion<Snapshot> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<int> atSequenceNumber;
  final Value<String> stateJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SnapshotsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.atSequenceNumber = const Value.absent(),
    this.stateJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SnapshotsCompanion.insert({
    required String id,
    required String companyId,
    required int atSequenceNumber,
    required String stateJson,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       companyId = Value(companyId),
       atSequenceNumber = Value(atSequenceNumber),
       stateJson = Value(stateJson),
       createdAt = Value(createdAt);
  static Insertable<Snapshot> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<int>? atSequenceNumber,
    Expression<String>? stateJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (atSequenceNumber != null) 'at_sequence_number': atSequenceNumber,
      if (stateJson != null) 'state_json': stateJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SnapshotsCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<int>? atSequenceNumber,
    Value<String>? stateJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SnapshotsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      atSequenceNumber: atSequenceNumber ?? this.atSequenceNumber,
      stateJson: stateJson ?? this.stateJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (atSequenceNumber.present) {
      map['at_sequence_number'] = Variable<int>(atSequenceNumber.value);
    }
    if (stateJson.present) {
      map['state_json'] = Variable<String>(stateJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('atSequenceNumber: $atSequenceNumber, ')
          ..write('stateJson: $stateJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CompaniesTable companies = $CompaniesTable(this);
  late final $StakeholdersTable stakeholders = $StakeholdersTable(this);
  late final $ShareClassesTable shareClasses = $ShareClassesTable(this);
  late final $RoundsTable rounds = $RoundsTable(this);
  late final $HoldingsTable holdings = $HoldingsTable(this);
  late final $ConvertiblesTable convertibles = $ConvertiblesTable(this);
  late final $EsopPoolsTable esopPools = $EsopPoolsTable(this);
  late final $OptionGrantsTable optionGrants = $OptionGrantsTable(this);
  late final $WarrantsTable warrants = $WarrantsTable(this);
  late final $VestingSchedulesTable vestingSchedules = $VestingSchedulesTable(
    this,
  );
  late final $ValuationsTable valuations = $ValuationsTable(this);
  late final $CapitalizationEventsTable capitalizationEvents =
      $CapitalizationEventsTable(this);
  late final $SavedScenariosTable savedScenarios = $SavedScenariosTable(this);
  late final $TransfersTable transfers = $TransfersTable(this);
  late final $MfnUpgradesTable mfnUpgrades = $MfnUpgradesTable(this);
  late final $EsopPoolExpansionsTable esopPoolExpansions =
      $EsopPoolExpansionsTable(this);
  late final $SnapshotsTable snapshots = $SnapshotsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    companies,
    stakeholders,
    shareClasses,
    rounds,
    holdings,
    convertibles,
    esopPools,
    optionGrants,
    warrants,
    vestingSchedules,
    valuations,
    capitalizationEvents,
    savedScenarios,
    transfers,
    mfnUpgrades,
    esopPoolExpansions,
    snapshots,
  ];
}

typedef $$CompaniesTableCreateCompanionBuilder =
    CompaniesCompanion Function({
      required String id,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CompaniesTableUpdateCompanionBuilder =
    CompaniesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CompaniesTableReferences
    extends BaseReferences<_$AppDatabase, $CompaniesTable, Company> {
  $$CompaniesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StakeholdersTable, List<Stakeholder>>
  _stakeholdersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stakeholders,
    aliasName: $_aliasNameGenerator(db.companies.id, db.stakeholders.companyId),
  );

  $$StakeholdersTableProcessedTableManager get stakeholdersRefs {
    final manager = $$StakeholdersTableTableManager(
      $_db,
      $_db.stakeholders,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stakeholdersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ShareClassesTable, List<ShareClassesData>>
  _shareClassesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shareClasses,
    aliasName: $_aliasNameGenerator(db.companies.id, db.shareClasses.companyId),
  );

  $$ShareClassesTableProcessedTableManager get shareClassesRefs {
    final manager = $$ShareClassesTableTableManager(
      $_db,
      $_db.shareClasses,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_shareClassesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RoundsTable, List<Round>> _roundsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.rounds,
    aliasName: $_aliasNameGenerator(db.companies.id, db.rounds.companyId),
  );

  $$RoundsTableProcessedTableManager get roundsRefs {
    final manager = $$RoundsTableTableManager(
      $_db,
      $_db.rounds,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_roundsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HoldingsTable, List<Holding>> _holdingsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.holdings,
    aliasName: $_aliasNameGenerator(db.companies.id, db.holdings.companyId),
  );

  $$HoldingsTableProcessedTableManager get holdingsRefs {
    final manager = $$HoldingsTableTableManager(
      $_db,
      $_db.holdings,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_holdingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConvertiblesTable, List<Convertible>>
  _convertiblesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.convertibles,
    aliasName: $_aliasNameGenerator(db.companies.id, db.convertibles.companyId),
  );

  $$ConvertiblesTableProcessedTableManager get convertiblesRefs {
    final manager = $$ConvertiblesTableTableManager(
      $_db,
      $_db.convertibles,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_convertiblesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EsopPoolsTable, List<EsopPool>>
  _esopPoolsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.esopPools,
    aliasName: $_aliasNameGenerator(db.companies.id, db.esopPools.companyId),
  );

  $$EsopPoolsTableProcessedTableManager get esopPoolsRefs {
    final manager = $$EsopPoolsTableTableManager(
      $_db,
      $_db.esopPools,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_esopPoolsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OptionGrantsTable, List<OptionGrant>>
  _optionGrantsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.optionGrants,
    aliasName: $_aliasNameGenerator(db.companies.id, db.optionGrants.companyId),
  );

  $$OptionGrantsTableProcessedTableManager get optionGrantsRefs {
    final manager = $$OptionGrantsTableTableManager(
      $_db,
      $_db.optionGrants,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_optionGrantsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WarrantsTable, List<Warrant>> _warrantsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.warrants,
    aliasName: $_aliasNameGenerator(db.companies.id, db.warrants.companyId),
  );

  $$WarrantsTableProcessedTableManager get warrantsRefs {
    final manager = $$WarrantsTableTableManager(
      $_db,
      $_db.warrants,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_warrantsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VestingSchedulesTable, List<VestingSchedule>>
  _vestingSchedulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.vestingSchedules,
    aliasName: $_aliasNameGenerator(
      db.companies.id,
      db.vestingSchedules.companyId,
    ),
  );

  $$VestingSchedulesTableProcessedTableManager get vestingSchedulesRefs {
    final manager = $$VestingSchedulesTableTableManager(
      $_db,
      $_db.vestingSchedules,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _vestingSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ValuationsTable, List<Valuation>>
  _valuationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.valuations,
    aliasName: $_aliasNameGenerator(db.companies.id, db.valuations.companyId),
  );

  $$ValuationsTableProcessedTableManager get valuationsRefs {
    final manager = $$ValuationsTableTableManager(
      $_db,
      $_db.valuations,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_valuationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CapitalizationEventsTable,
    List<CapitalizationEvent>
  >
  _capitalizationEventsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.capitalizationEvents,
        aliasName: $_aliasNameGenerator(
          db.companies.id,
          db.capitalizationEvents.companyId,
        ),
      );

  $$CapitalizationEventsTableProcessedTableManager
  get capitalizationEventsRefs {
    final manager = $$CapitalizationEventsTableTableManager(
      $_db,
      $_db.capitalizationEvents,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _capitalizationEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SavedScenariosTable, List<SavedScenario>>
  _savedScenariosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.savedScenarios,
    aliasName: $_aliasNameGenerator(
      db.companies.id,
      db.savedScenarios.companyId,
    ),
  );

  $$SavedScenariosTableProcessedTableManager get savedScenariosRefs {
    final manager = $$SavedScenariosTableTableManager(
      $_db,
      $_db.savedScenarios,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_savedScenariosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransfersTable, List<Transfer>>
  _transfersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transfers,
    aliasName: $_aliasNameGenerator(db.companies.id, db.transfers.companyId),
  );

  $$TransfersTableProcessedTableManager get transfersRefs {
    final manager = $$TransfersTableTableManager(
      $_db,
      $_db.transfers,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transfersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MfnUpgradesTable, List<MfnUpgrade>>
  _mfnUpgradesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mfnUpgrades,
    aliasName: $_aliasNameGenerator(db.companies.id, db.mfnUpgrades.companyId),
  );

  $$MfnUpgradesTableProcessedTableManager get mfnUpgradesRefs {
    final manager = $$MfnUpgradesTableTableManager(
      $_db,
      $_db.mfnUpgrades,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mfnUpgradesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EsopPoolExpansionsTable, List<EsopPoolExpansion>>
  _esopPoolExpansionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.esopPoolExpansions,
        aliasName: $_aliasNameGenerator(
          db.companies.id,
          db.esopPoolExpansions.companyId,
        ),
      );

  $$EsopPoolExpansionsTableProcessedTableManager get esopPoolExpansionsRefs {
    final manager = $$EsopPoolExpansionsTableTableManager(
      $_db,
      $_db.esopPoolExpansions,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _esopPoolExpansionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SnapshotsTable, List<Snapshot>>
  _snapshotsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.snapshots,
    aliasName: $_aliasNameGenerator(db.companies.id, db.snapshots.companyId),
  );

  $$SnapshotsTableProcessedTableManager get snapshotsRefs {
    final manager = $$SnapshotsTableTableManager(
      $_db,
      $_db.snapshots,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_snapshotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CompaniesTableFilterComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> stakeholdersRefs(
    Expression<bool> Function($$StakeholdersTableFilterComposer f) f,
  ) {
    final $$StakeholdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableFilterComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> shareClassesRefs(
    Expression<bool> Function($$ShareClassesTableFilterComposer f) f,
  ) {
    final $$ShareClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shareClasses,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareClassesTableFilterComposer(
            $db: $db,
            $table: $db.shareClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> roundsRefs(
    Expression<bool> Function($$RoundsTableFilterComposer f) f,
  ) {
    final $$RoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableFilterComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> holdingsRefs(
    Expression<bool> Function($$HoldingsTableFilterComposer f) f,
  ) {
    final $$HoldingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdings,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableFilterComposer(
            $db: $db,
            $table: $db.holdings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> convertiblesRefs(
    Expression<bool> Function($$ConvertiblesTableFilterComposer f) f,
  ) {
    final $$ConvertiblesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.convertibles,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConvertiblesTableFilterComposer(
            $db: $db,
            $table: $db.convertibles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> esopPoolsRefs(
    Expression<bool> Function($$EsopPoolsTableFilterComposer f) f,
  ) {
    final $$EsopPoolsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.esopPools,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EsopPoolsTableFilterComposer(
            $db: $db,
            $table: $db.esopPools,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> optionGrantsRefs(
    Expression<bool> Function($$OptionGrantsTableFilterComposer f) f,
  ) {
    final $$OptionGrantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.optionGrants,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OptionGrantsTableFilterComposer(
            $db: $db,
            $table: $db.optionGrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> warrantsRefs(
    Expression<bool> Function($$WarrantsTableFilterComposer f) f,
  ) {
    final $$WarrantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.warrants,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WarrantsTableFilterComposer(
            $db: $db,
            $table: $db.warrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vestingSchedulesRefs(
    Expression<bool> Function($$VestingSchedulesTableFilterComposer f) f,
  ) {
    final $$VestingSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vestingSchedules,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VestingSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.vestingSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> valuationsRefs(
    Expression<bool> Function($$ValuationsTableFilterComposer f) f,
  ) {
    final $$ValuationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.valuations,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ValuationsTableFilterComposer(
            $db: $db,
            $table: $db.valuations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> capitalizationEventsRefs(
    Expression<bool> Function($$CapitalizationEventsTableFilterComposer f) f,
  ) {
    final $$CapitalizationEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.capitalizationEvents,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapitalizationEventsTableFilterComposer(
            $db: $db,
            $table: $db.capitalizationEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> savedScenariosRefs(
    Expression<bool> Function($$SavedScenariosTableFilterComposer f) f,
  ) {
    final $$SavedScenariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedScenarios,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedScenariosTableFilterComposer(
            $db: $db,
            $table: $db.savedScenarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transfersRefs(
    Expression<bool> Function($$TransfersTableFilterComposer f) f,
  ) {
    final $$TransfersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transfers,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransfersTableFilterComposer(
            $db: $db,
            $table: $db.transfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mfnUpgradesRefs(
    Expression<bool> Function($$MfnUpgradesTableFilterComposer f) f,
  ) {
    final $$MfnUpgradesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mfnUpgrades,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MfnUpgradesTableFilterComposer(
            $db: $db,
            $table: $db.mfnUpgrades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> esopPoolExpansionsRefs(
    Expression<bool> Function($$EsopPoolExpansionsTableFilterComposer f) f,
  ) {
    final $$EsopPoolExpansionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.esopPoolExpansions,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EsopPoolExpansionsTableFilterComposer(
            $db: $db,
            $table: $db.esopPoolExpansions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> snapshotsRefs(
    Expression<bool> Function($$SnapshotsTableFilterComposer f) f,
  ) {
    final $$SnapshotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.snapshots,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SnapshotsTableFilterComposer(
            $db: $db,
            $table: $db.snapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompaniesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompaniesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> stakeholdersRefs<T extends Object>(
    Expression<T> Function($$StakeholdersTableAnnotationComposer a) f,
  ) {
    final $$StakeholdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableAnnotationComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> shareClassesRefs<T extends Object>(
    Expression<T> Function($$ShareClassesTableAnnotationComposer a) f,
  ) {
    final $$ShareClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shareClasses,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.shareClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> roundsRefs<T extends Object>(
    Expression<T> Function($$RoundsTableAnnotationComposer a) f,
  ) {
    final $$RoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> holdingsRefs<T extends Object>(
    Expression<T> Function($$HoldingsTableAnnotationComposer a) f,
  ) {
    final $$HoldingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdings,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableAnnotationComposer(
            $db: $db,
            $table: $db.holdings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> convertiblesRefs<T extends Object>(
    Expression<T> Function($$ConvertiblesTableAnnotationComposer a) f,
  ) {
    final $$ConvertiblesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.convertibles,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConvertiblesTableAnnotationComposer(
            $db: $db,
            $table: $db.convertibles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> esopPoolsRefs<T extends Object>(
    Expression<T> Function($$EsopPoolsTableAnnotationComposer a) f,
  ) {
    final $$EsopPoolsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.esopPools,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EsopPoolsTableAnnotationComposer(
            $db: $db,
            $table: $db.esopPools,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> optionGrantsRefs<T extends Object>(
    Expression<T> Function($$OptionGrantsTableAnnotationComposer a) f,
  ) {
    final $$OptionGrantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.optionGrants,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OptionGrantsTableAnnotationComposer(
            $db: $db,
            $table: $db.optionGrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> warrantsRefs<T extends Object>(
    Expression<T> Function($$WarrantsTableAnnotationComposer a) f,
  ) {
    final $$WarrantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.warrants,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WarrantsTableAnnotationComposer(
            $db: $db,
            $table: $db.warrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vestingSchedulesRefs<T extends Object>(
    Expression<T> Function($$VestingSchedulesTableAnnotationComposer a) f,
  ) {
    final $$VestingSchedulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vestingSchedules,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VestingSchedulesTableAnnotationComposer(
            $db: $db,
            $table: $db.vestingSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> valuationsRefs<T extends Object>(
    Expression<T> Function($$ValuationsTableAnnotationComposer a) f,
  ) {
    final $$ValuationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.valuations,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ValuationsTableAnnotationComposer(
            $db: $db,
            $table: $db.valuations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> capitalizationEventsRefs<T extends Object>(
    Expression<T> Function($$CapitalizationEventsTableAnnotationComposer a) f,
  ) {
    final $$CapitalizationEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.capitalizationEvents,
          getReferencedColumn: (t) => t.companyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CapitalizationEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.capitalizationEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> savedScenariosRefs<T extends Object>(
    Expression<T> Function($$SavedScenariosTableAnnotationComposer a) f,
  ) {
    final $$SavedScenariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedScenarios,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedScenariosTableAnnotationComposer(
            $db: $db,
            $table: $db.savedScenarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transfersRefs<T extends Object>(
    Expression<T> Function($$TransfersTableAnnotationComposer a) f,
  ) {
    final $$TransfersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transfers,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransfersTableAnnotationComposer(
            $db: $db,
            $table: $db.transfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mfnUpgradesRefs<T extends Object>(
    Expression<T> Function($$MfnUpgradesTableAnnotationComposer a) f,
  ) {
    final $$MfnUpgradesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mfnUpgrades,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MfnUpgradesTableAnnotationComposer(
            $db: $db,
            $table: $db.mfnUpgrades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> esopPoolExpansionsRefs<T extends Object>(
    Expression<T> Function($$EsopPoolExpansionsTableAnnotationComposer a) f,
  ) {
    final $$EsopPoolExpansionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.esopPoolExpansions,
          getReferencedColumn: (t) => t.companyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EsopPoolExpansionsTableAnnotationComposer(
                $db: $db,
                $table: $db.esopPoolExpansions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> snapshotsRefs<T extends Object>(
    Expression<T> Function($$SnapshotsTableAnnotationComposer a) f,
  ) {
    final $$SnapshotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.snapshots,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SnapshotsTableAnnotationComposer(
            $db: $db,
            $table: $db.snapshots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompaniesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompaniesTable,
          Company,
          $$CompaniesTableFilterComposer,
          $$CompaniesTableOrderingComposer,
          $$CompaniesTableAnnotationComposer,
          $$CompaniesTableCreateCompanionBuilder,
          $$CompaniesTableUpdateCompanionBuilder,
          (Company, $$CompaniesTableReferences),
          Company,
          PrefetchHooks Function({
            bool stakeholdersRefs,
            bool shareClassesRefs,
            bool roundsRefs,
            bool holdingsRefs,
            bool convertiblesRefs,
            bool esopPoolsRefs,
            bool optionGrantsRefs,
            bool warrantsRefs,
            bool vestingSchedulesRefs,
            bool valuationsRefs,
            bool capitalizationEventsRefs,
            bool savedScenariosRefs,
            bool transfersRefs,
            bool mfnUpgradesRefs,
            bool esopPoolExpansionsRefs,
            bool snapshotsRefs,
          })
        > {
  $$CompaniesTableTableManager(_$AppDatabase db, $CompaniesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompaniesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompaniesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompaniesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompaniesCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CompaniesCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompaniesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                stakeholdersRefs = false,
                shareClassesRefs = false,
                roundsRefs = false,
                holdingsRefs = false,
                convertiblesRefs = false,
                esopPoolsRefs = false,
                optionGrantsRefs = false,
                warrantsRefs = false,
                vestingSchedulesRefs = false,
                valuationsRefs = false,
                capitalizationEventsRefs = false,
                savedScenariosRefs = false,
                transfersRefs = false,
                mfnUpgradesRefs = false,
                esopPoolExpansionsRefs = false,
                snapshotsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stakeholdersRefs) db.stakeholders,
                    if (shareClassesRefs) db.shareClasses,
                    if (roundsRefs) db.rounds,
                    if (holdingsRefs) db.holdings,
                    if (convertiblesRefs) db.convertibles,
                    if (esopPoolsRefs) db.esopPools,
                    if (optionGrantsRefs) db.optionGrants,
                    if (warrantsRefs) db.warrants,
                    if (vestingSchedulesRefs) db.vestingSchedules,
                    if (valuationsRefs) db.valuations,
                    if (capitalizationEventsRefs) db.capitalizationEvents,
                    if (savedScenariosRefs) db.savedScenarios,
                    if (transfersRefs) db.transfers,
                    if (mfnUpgradesRefs) db.mfnUpgrades,
                    if (esopPoolExpansionsRefs) db.esopPoolExpansions,
                    if (snapshotsRefs) db.snapshots,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stakeholdersRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Stakeholder
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._stakeholdersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).stakeholdersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (shareClassesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          ShareClassesData
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._shareClassesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).shareClassesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (roundsRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Round
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._roundsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).roundsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (holdingsRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Holding
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._holdingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).holdingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (convertiblesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Convertible
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._convertiblesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).convertiblesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (esopPoolsRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          EsopPool
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._esopPoolsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).esopPoolsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (optionGrantsRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          OptionGrant
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._optionGrantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).optionGrantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (warrantsRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Warrant
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._warrantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).warrantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (vestingSchedulesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          VestingSchedule
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._vestingSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).vestingSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (valuationsRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Valuation
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._valuationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).valuationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (capitalizationEventsRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          CapitalizationEvent
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._capitalizationEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).capitalizationEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (savedScenariosRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          SavedScenario
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._savedScenariosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).savedScenariosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transfersRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Transfer
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._transfersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).transfersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mfnUpgradesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          MfnUpgrade
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._mfnUpgradesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).mfnUpgradesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (esopPoolExpansionsRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          EsopPoolExpansion
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._esopPoolExpansionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).esopPoolExpansionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (snapshotsRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Snapshot
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._snapshotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).snapshotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CompaniesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompaniesTable,
      Company,
      $$CompaniesTableFilterComposer,
      $$CompaniesTableOrderingComposer,
      $$CompaniesTableAnnotationComposer,
      $$CompaniesTableCreateCompanionBuilder,
      $$CompaniesTableUpdateCompanionBuilder,
      (Company, $$CompaniesTableReferences),
      Company,
      PrefetchHooks Function({
        bool stakeholdersRefs,
        bool shareClassesRefs,
        bool roundsRefs,
        bool holdingsRefs,
        bool convertiblesRefs,
        bool esopPoolsRefs,
        bool optionGrantsRefs,
        bool warrantsRefs,
        bool vestingSchedulesRefs,
        bool valuationsRefs,
        bool capitalizationEventsRefs,
        bool savedScenariosRefs,
        bool transfersRefs,
        bool mfnUpgradesRefs,
        bool esopPoolExpansionsRefs,
        bool snapshotsRefs,
      })
    >;
typedef $$StakeholdersTableCreateCompanionBuilder =
    StakeholdersCompanion Function({
      required String id,
      required String companyId,
      required String name,
      required String type,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> company,
      Value<bool> hasProRataRights,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$StakeholdersTableUpdateCompanionBuilder =
    StakeholdersCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> name,
      Value<String> type,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> company,
      Value<bool> hasProRataRights,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$StakeholdersTableReferences
    extends BaseReferences<_$AppDatabase, $StakeholdersTable, Stakeholder> {
  $$StakeholdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.stakeholders.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RoundsTable, List<Round>> _roundsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.rounds,
    aliasName: $_aliasNameGenerator(
      db.stakeholders.id,
      db.rounds.leadInvestorId,
    ),
  );

  $$RoundsTableProcessedTableManager get roundsRefs {
    final manager = $$RoundsTableTableManager(
      $_db,
      $_db.rounds,
    ).filter((f) => f.leadInvestorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_roundsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HoldingsTable, List<Holding>> _holdingsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.holdings,
    aliasName: $_aliasNameGenerator(
      db.stakeholders.id,
      db.holdings.stakeholderId,
    ),
  );

  $$HoldingsTableProcessedTableManager get holdingsRefs {
    final manager = $$HoldingsTableTableManager(
      $_db,
      $_db.holdings,
    ).filter((f) => f.stakeholderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_holdingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConvertiblesTable, List<Convertible>>
  _convertiblesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.convertibles,
    aliasName: $_aliasNameGenerator(
      db.stakeholders.id,
      db.convertibles.stakeholderId,
    ),
  );

  $$ConvertiblesTableProcessedTableManager get convertiblesRefs {
    final manager = $$ConvertiblesTableTableManager(
      $_db,
      $_db.convertibles,
    ).filter((f) => f.stakeholderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_convertiblesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OptionGrantsTable, List<OptionGrant>>
  _optionGrantsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.optionGrants,
    aliasName: $_aliasNameGenerator(
      db.stakeholders.id,
      db.optionGrants.stakeholderId,
    ),
  );

  $$OptionGrantsTableProcessedTableManager get optionGrantsRefs {
    final manager = $$OptionGrantsTableTableManager(
      $_db,
      $_db.optionGrants,
    ).filter((f) => f.stakeholderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_optionGrantsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WarrantsTable, List<Warrant>> _warrantsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.warrants,
    aliasName: $_aliasNameGenerator(
      db.stakeholders.id,
      db.warrants.stakeholderId,
    ),
  );

  $$WarrantsTableProcessedTableManager get warrantsRefs {
    final manager = $$WarrantsTableTableManager(
      $_db,
      $_db.warrants,
    ).filter((f) => f.stakeholderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_warrantsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransfersTable, List<Transfer>>
  _sellerTransfersTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transfers,
    aliasName: $_aliasNameGenerator(
      db.stakeholders.id,
      db.transfers.sellerStakeholderId,
    ),
  );

  $$TransfersTableProcessedTableManager get sellerTransfers {
    final manager = $$TransfersTableTableManager($_db, $_db.transfers).filter(
      (f) => f.sellerStakeholderId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_sellerTransfersTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransfersTable, List<Transfer>>
  _buyerTransfersTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transfers,
    aliasName: $_aliasNameGenerator(
      db.stakeholders.id,
      db.transfers.buyerStakeholderId,
    ),
  );

  $$TransfersTableProcessedTableManager get buyerTransfers {
    final manager = $$TransfersTableTableManager($_db, $_db.transfers).filter(
      (f) => f.buyerStakeholderId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_buyerTransfersTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StakeholdersTableFilterComposer
    extends Composer<_$AppDatabase, $StakeholdersTable> {
  $$StakeholdersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasProRataRights => $composableBuilder(
    column: $table.hasProRataRights,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> roundsRefs(
    Expression<bool> Function($$RoundsTableFilterComposer f) f,
  ) {
    final $$RoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.leadInvestorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableFilterComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> holdingsRefs(
    Expression<bool> Function($$HoldingsTableFilterComposer f) f,
  ) {
    final $$HoldingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdings,
      getReferencedColumn: (t) => t.stakeholderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableFilterComposer(
            $db: $db,
            $table: $db.holdings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> convertiblesRefs(
    Expression<bool> Function($$ConvertiblesTableFilterComposer f) f,
  ) {
    final $$ConvertiblesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.convertibles,
      getReferencedColumn: (t) => t.stakeholderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConvertiblesTableFilterComposer(
            $db: $db,
            $table: $db.convertibles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> optionGrantsRefs(
    Expression<bool> Function($$OptionGrantsTableFilterComposer f) f,
  ) {
    final $$OptionGrantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.optionGrants,
      getReferencedColumn: (t) => t.stakeholderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OptionGrantsTableFilterComposer(
            $db: $db,
            $table: $db.optionGrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> warrantsRefs(
    Expression<bool> Function($$WarrantsTableFilterComposer f) f,
  ) {
    final $$WarrantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.warrants,
      getReferencedColumn: (t) => t.stakeholderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WarrantsTableFilterComposer(
            $db: $db,
            $table: $db.warrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sellerTransfers(
    Expression<bool> Function($$TransfersTableFilterComposer f) f,
  ) {
    final $$TransfersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transfers,
      getReferencedColumn: (t) => t.sellerStakeholderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransfersTableFilterComposer(
            $db: $db,
            $table: $db.transfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> buyerTransfers(
    Expression<bool> Function($$TransfersTableFilterComposer f) f,
  ) {
    final $$TransfersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transfers,
      getReferencedColumn: (t) => t.buyerStakeholderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransfersTableFilterComposer(
            $db: $db,
            $table: $db.transfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StakeholdersTableOrderingComposer
    extends Composer<_$AppDatabase, $StakeholdersTable> {
  $$StakeholdersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasProRataRights => $composableBuilder(
    column: $table.hasProRataRights,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StakeholdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $StakeholdersTable> {
  $$StakeholdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<bool> get hasProRataRights => $composableBuilder(
    column: $table.hasProRataRights,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> roundsRefs<T extends Object>(
    Expression<T> Function($$RoundsTableAnnotationComposer a) f,
  ) {
    final $$RoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.leadInvestorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> holdingsRefs<T extends Object>(
    Expression<T> Function($$HoldingsTableAnnotationComposer a) f,
  ) {
    final $$HoldingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdings,
      getReferencedColumn: (t) => t.stakeholderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableAnnotationComposer(
            $db: $db,
            $table: $db.holdings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> convertiblesRefs<T extends Object>(
    Expression<T> Function($$ConvertiblesTableAnnotationComposer a) f,
  ) {
    final $$ConvertiblesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.convertibles,
      getReferencedColumn: (t) => t.stakeholderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConvertiblesTableAnnotationComposer(
            $db: $db,
            $table: $db.convertibles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> optionGrantsRefs<T extends Object>(
    Expression<T> Function($$OptionGrantsTableAnnotationComposer a) f,
  ) {
    final $$OptionGrantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.optionGrants,
      getReferencedColumn: (t) => t.stakeholderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OptionGrantsTableAnnotationComposer(
            $db: $db,
            $table: $db.optionGrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> warrantsRefs<T extends Object>(
    Expression<T> Function($$WarrantsTableAnnotationComposer a) f,
  ) {
    final $$WarrantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.warrants,
      getReferencedColumn: (t) => t.stakeholderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WarrantsTableAnnotationComposer(
            $db: $db,
            $table: $db.warrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sellerTransfers<T extends Object>(
    Expression<T> Function($$TransfersTableAnnotationComposer a) f,
  ) {
    final $$TransfersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transfers,
      getReferencedColumn: (t) => t.sellerStakeholderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransfersTableAnnotationComposer(
            $db: $db,
            $table: $db.transfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> buyerTransfers<T extends Object>(
    Expression<T> Function($$TransfersTableAnnotationComposer a) f,
  ) {
    final $$TransfersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transfers,
      getReferencedColumn: (t) => t.buyerStakeholderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransfersTableAnnotationComposer(
            $db: $db,
            $table: $db.transfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StakeholdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StakeholdersTable,
          Stakeholder,
          $$StakeholdersTableFilterComposer,
          $$StakeholdersTableOrderingComposer,
          $$StakeholdersTableAnnotationComposer,
          $$StakeholdersTableCreateCompanionBuilder,
          $$StakeholdersTableUpdateCompanionBuilder,
          (Stakeholder, $$StakeholdersTableReferences),
          Stakeholder,
          PrefetchHooks Function({
            bool companyId,
            bool roundsRefs,
            bool holdingsRefs,
            bool convertiblesRefs,
            bool optionGrantsRefs,
            bool warrantsRefs,
            bool sellerTransfers,
            bool buyerTransfers,
          })
        > {
  $$StakeholdersTableTableManager(_$AppDatabase db, $StakeholdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StakeholdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StakeholdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StakeholdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<bool> hasProRataRights = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StakeholdersCompanion(
                id: id,
                companyId: companyId,
                name: name,
                type: type,
                email: email,
                phone: phone,
                company: company,
                hasProRataRights: hasProRataRights,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String name,
                required String type,
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<bool> hasProRataRights = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => StakeholdersCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                type: type,
                email: email,
                phone: phone,
                company: company,
                hasProRataRights: hasProRataRights,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StakeholdersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                companyId = false,
                roundsRefs = false,
                holdingsRefs = false,
                convertiblesRefs = false,
                optionGrantsRefs = false,
                warrantsRefs = false,
                sellerTransfers = false,
                buyerTransfers = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (roundsRefs) db.rounds,
                    if (holdingsRefs) db.holdings,
                    if (convertiblesRefs) db.convertibles,
                    if (optionGrantsRefs) db.optionGrants,
                    if (warrantsRefs) db.warrants,
                    if (sellerTransfers) db.transfers,
                    if (buyerTransfers) db.transfers,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable:
                                        $$StakeholdersTableReferences
                                            ._companyIdTable(db),
                                    referencedColumn:
                                        $$StakeholdersTableReferences
                                            ._companyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (roundsRefs)
                        await $_getPrefetchedData<
                          Stakeholder,
                          $StakeholdersTable,
                          Round
                        >(
                          currentTable: table,
                          referencedTable: $$StakeholdersTableReferences
                              ._roundsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StakeholdersTableReferences(
                                db,
                                table,
                                p0,
                              ).roundsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.leadInvestorId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (holdingsRefs)
                        await $_getPrefetchedData<
                          Stakeholder,
                          $StakeholdersTable,
                          Holding
                        >(
                          currentTable: table,
                          referencedTable: $$StakeholdersTableReferences
                              ._holdingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StakeholdersTableReferences(
                                db,
                                table,
                                p0,
                              ).holdingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stakeholderId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (convertiblesRefs)
                        await $_getPrefetchedData<
                          Stakeholder,
                          $StakeholdersTable,
                          Convertible
                        >(
                          currentTable: table,
                          referencedTable: $$StakeholdersTableReferences
                              ._convertiblesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StakeholdersTableReferences(
                                db,
                                table,
                                p0,
                              ).convertiblesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stakeholderId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (optionGrantsRefs)
                        await $_getPrefetchedData<
                          Stakeholder,
                          $StakeholdersTable,
                          OptionGrant
                        >(
                          currentTable: table,
                          referencedTable: $$StakeholdersTableReferences
                              ._optionGrantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StakeholdersTableReferences(
                                db,
                                table,
                                p0,
                              ).optionGrantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stakeholderId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (warrantsRefs)
                        await $_getPrefetchedData<
                          Stakeholder,
                          $StakeholdersTable,
                          Warrant
                        >(
                          currentTable: table,
                          referencedTable: $$StakeholdersTableReferences
                              ._warrantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StakeholdersTableReferences(
                                db,
                                table,
                                p0,
                              ).warrantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.stakeholderId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sellerTransfers)
                        await $_getPrefetchedData<
                          Stakeholder,
                          $StakeholdersTable,
                          Transfer
                        >(
                          currentTable: table,
                          referencedTable: $$StakeholdersTableReferences
                              ._sellerTransfersTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StakeholdersTableReferences(
                                db,
                                table,
                                p0,
                              ).sellerTransfers,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sellerStakeholderId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (buyerTransfers)
                        await $_getPrefetchedData<
                          Stakeholder,
                          $StakeholdersTable,
                          Transfer
                        >(
                          currentTable: table,
                          referencedTable: $$StakeholdersTableReferences
                              ._buyerTransfersTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StakeholdersTableReferences(
                                db,
                                table,
                                p0,
                              ).buyerTransfers,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.buyerStakeholderId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StakeholdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StakeholdersTable,
      Stakeholder,
      $$StakeholdersTableFilterComposer,
      $$StakeholdersTableOrderingComposer,
      $$StakeholdersTableAnnotationComposer,
      $$StakeholdersTableCreateCompanionBuilder,
      $$StakeholdersTableUpdateCompanionBuilder,
      (Stakeholder, $$StakeholdersTableReferences),
      Stakeholder,
      PrefetchHooks Function({
        bool companyId,
        bool roundsRefs,
        bool holdingsRefs,
        bool convertiblesRefs,
        bool optionGrantsRefs,
        bool warrantsRefs,
        bool sellerTransfers,
        bool buyerTransfers,
      })
    >;
typedef $$ShareClassesTableCreateCompanionBuilder =
    ShareClassesCompanion Function({
      required String id,
      required String companyId,
      required String name,
      required String type,
      Value<double> votingMultiplier,
      Value<double> liquidationPreference,
      Value<bool> isParticipating,
      Value<double> dividendRate,
      Value<int> seniority,
      Value<String> antiDilutionType,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ShareClassesTableUpdateCompanionBuilder =
    ShareClassesCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> name,
      Value<String> type,
      Value<double> votingMultiplier,
      Value<double> liquidationPreference,
      Value<bool> isParticipating,
      Value<double> dividendRate,
      Value<int> seniority,
      Value<String> antiDilutionType,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ShareClassesTableReferences
    extends
        BaseReferences<_$AppDatabase, $ShareClassesTable, ShareClassesData> {
  $$ShareClassesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.shareClasses.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$HoldingsTable, List<Holding>> _holdingsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.holdings,
    aliasName: $_aliasNameGenerator(
      db.shareClasses.id,
      db.holdings.shareClassId,
    ),
  );

  $$HoldingsTableProcessedTableManager get holdingsRefs {
    final manager = $$HoldingsTableTableManager(
      $_db,
      $_db.holdings,
    ).filter((f) => f.shareClassId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_holdingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OptionGrantsTable, List<OptionGrant>>
  _optionGrantsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.optionGrants,
    aliasName: $_aliasNameGenerator(
      db.shareClasses.id,
      db.optionGrants.shareClassId,
    ),
  );

  $$OptionGrantsTableProcessedTableManager get optionGrantsRefs {
    final manager = $$OptionGrantsTableTableManager(
      $_db,
      $_db.optionGrants,
    ).filter((f) => f.shareClassId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_optionGrantsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WarrantsTable, List<Warrant>> _warrantsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.warrants,
    aliasName: $_aliasNameGenerator(
      db.shareClasses.id,
      db.warrants.shareClassId,
    ),
  );

  $$WarrantsTableProcessedTableManager get warrantsRefs {
    final manager = $$WarrantsTableTableManager(
      $_db,
      $_db.warrants,
    ).filter((f) => f.shareClassId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_warrantsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransfersTable, List<Transfer>>
  _transfersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transfers,
    aliasName: $_aliasNameGenerator(
      db.shareClasses.id,
      db.transfers.shareClassId,
    ),
  );

  $$TransfersTableProcessedTableManager get transfersRefs {
    final manager = $$TransfersTableTableManager(
      $_db,
      $_db.transfers,
    ).filter((f) => f.shareClassId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transfersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShareClassesTableFilterComposer
    extends Composer<_$AppDatabase, $ShareClassesTable> {
  $$ShareClassesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get votingMultiplier => $composableBuilder(
    column: $table.votingMultiplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get liquidationPreference => $composableBuilder(
    column: $table.liquidationPreference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isParticipating => $composableBuilder(
    column: $table.isParticipating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dividendRate => $composableBuilder(
    column: $table.dividendRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seniority => $composableBuilder(
    column: $table.seniority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get antiDilutionType => $composableBuilder(
    column: $table.antiDilutionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> holdingsRefs(
    Expression<bool> Function($$HoldingsTableFilterComposer f) f,
  ) {
    final $$HoldingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdings,
      getReferencedColumn: (t) => t.shareClassId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableFilterComposer(
            $db: $db,
            $table: $db.holdings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> optionGrantsRefs(
    Expression<bool> Function($$OptionGrantsTableFilterComposer f) f,
  ) {
    final $$OptionGrantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.optionGrants,
      getReferencedColumn: (t) => t.shareClassId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OptionGrantsTableFilterComposer(
            $db: $db,
            $table: $db.optionGrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> warrantsRefs(
    Expression<bool> Function($$WarrantsTableFilterComposer f) f,
  ) {
    final $$WarrantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.warrants,
      getReferencedColumn: (t) => t.shareClassId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WarrantsTableFilterComposer(
            $db: $db,
            $table: $db.warrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transfersRefs(
    Expression<bool> Function($$TransfersTableFilterComposer f) f,
  ) {
    final $$TransfersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transfers,
      getReferencedColumn: (t) => t.shareClassId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransfersTableFilterComposer(
            $db: $db,
            $table: $db.transfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShareClassesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShareClassesTable> {
  $$ShareClassesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get votingMultiplier => $composableBuilder(
    column: $table.votingMultiplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get liquidationPreference => $composableBuilder(
    column: $table.liquidationPreference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isParticipating => $composableBuilder(
    column: $table.isParticipating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dividendRate => $composableBuilder(
    column: $table.dividendRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seniority => $composableBuilder(
    column: $table.seniority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get antiDilutionType => $composableBuilder(
    column: $table.antiDilutionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShareClassesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShareClassesTable> {
  $$ShareClassesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get votingMultiplier => $composableBuilder(
    column: $table.votingMultiplier,
    builder: (column) => column,
  );

  GeneratedColumn<double> get liquidationPreference => $composableBuilder(
    column: $table.liquidationPreference,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isParticipating => $composableBuilder(
    column: $table.isParticipating,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dividendRate => $composableBuilder(
    column: $table.dividendRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seniority =>
      $composableBuilder(column: $table.seniority, builder: (column) => column);

  GeneratedColumn<String> get antiDilutionType => $composableBuilder(
    column: $table.antiDilutionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> holdingsRefs<T extends Object>(
    Expression<T> Function($$HoldingsTableAnnotationComposer a) f,
  ) {
    final $$HoldingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdings,
      getReferencedColumn: (t) => t.shareClassId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableAnnotationComposer(
            $db: $db,
            $table: $db.holdings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> optionGrantsRefs<T extends Object>(
    Expression<T> Function($$OptionGrantsTableAnnotationComposer a) f,
  ) {
    final $$OptionGrantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.optionGrants,
      getReferencedColumn: (t) => t.shareClassId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OptionGrantsTableAnnotationComposer(
            $db: $db,
            $table: $db.optionGrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> warrantsRefs<T extends Object>(
    Expression<T> Function($$WarrantsTableAnnotationComposer a) f,
  ) {
    final $$WarrantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.warrants,
      getReferencedColumn: (t) => t.shareClassId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WarrantsTableAnnotationComposer(
            $db: $db,
            $table: $db.warrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transfersRefs<T extends Object>(
    Expression<T> Function($$TransfersTableAnnotationComposer a) f,
  ) {
    final $$TransfersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transfers,
      getReferencedColumn: (t) => t.shareClassId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransfersTableAnnotationComposer(
            $db: $db,
            $table: $db.transfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShareClassesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShareClassesTable,
          ShareClassesData,
          $$ShareClassesTableFilterComposer,
          $$ShareClassesTableOrderingComposer,
          $$ShareClassesTableAnnotationComposer,
          $$ShareClassesTableCreateCompanionBuilder,
          $$ShareClassesTableUpdateCompanionBuilder,
          (ShareClassesData, $$ShareClassesTableReferences),
          ShareClassesData,
          PrefetchHooks Function({
            bool companyId,
            bool holdingsRefs,
            bool optionGrantsRefs,
            bool warrantsRefs,
            bool transfersRefs,
          })
        > {
  $$ShareClassesTableTableManager(_$AppDatabase db, $ShareClassesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShareClassesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShareClassesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShareClassesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> votingMultiplier = const Value.absent(),
                Value<double> liquidationPreference = const Value.absent(),
                Value<bool> isParticipating = const Value.absent(),
                Value<double> dividendRate = const Value.absent(),
                Value<int> seniority = const Value.absent(),
                Value<String> antiDilutionType = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShareClassesCompanion(
                id: id,
                companyId: companyId,
                name: name,
                type: type,
                votingMultiplier: votingMultiplier,
                liquidationPreference: liquidationPreference,
                isParticipating: isParticipating,
                dividendRate: dividendRate,
                seniority: seniority,
                antiDilutionType: antiDilutionType,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String name,
                required String type,
                Value<double> votingMultiplier = const Value.absent(),
                Value<double> liquidationPreference = const Value.absent(),
                Value<bool> isParticipating = const Value.absent(),
                Value<double> dividendRate = const Value.absent(),
                Value<int> seniority = const Value.absent(),
                Value<String> antiDilutionType = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ShareClassesCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                type: type,
                votingMultiplier: votingMultiplier,
                liquidationPreference: liquidationPreference,
                isParticipating: isParticipating,
                dividendRate: dividendRate,
                seniority: seniority,
                antiDilutionType: antiDilutionType,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ShareClassesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                companyId = false,
                holdingsRefs = false,
                optionGrantsRefs = false,
                warrantsRefs = false,
                transfersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (holdingsRefs) db.holdings,
                    if (optionGrantsRefs) db.optionGrants,
                    if (warrantsRefs) db.warrants,
                    if (transfersRefs) db.transfers,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable:
                                        $$ShareClassesTableReferences
                                            ._companyIdTable(db),
                                    referencedColumn:
                                        $$ShareClassesTableReferences
                                            ._companyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (holdingsRefs)
                        await $_getPrefetchedData<
                          ShareClassesData,
                          $ShareClassesTable,
                          Holding
                        >(
                          currentTable: table,
                          referencedTable: $$ShareClassesTableReferences
                              ._holdingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShareClassesTableReferences(
                                db,
                                table,
                                p0,
                              ).holdingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.shareClassId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (optionGrantsRefs)
                        await $_getPrefetchedData<
                          ShareClassesData,
                          $ShareClassesTable,
                          OptionGrant
                        >(
                          currentTable: table,
                          referencedTable: $$ShareClassesTableReferences
                              ._optionGrantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShareClassesTableReferences(
                                db,
                                table,
                                p0,
                              ).optionGrantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.shareClassId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (warrantsRefs)
                        await $_getPrefetchedData<
                          ShareClassesData,
                          $ShareClassesTable,
                          Warrant
                        >(
                          currentTable: table,
                          referencedTable: $$ShareClassesTableReferences
                              ._warrantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShareClassesTableReferences(
                                db,
                                table,
                                p0,
                              ).warrantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.shareClassId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transfersRefs)
                        await $_getPrefetchedData<
                          ShareClassesData,
                          $ShareClassesTable,
                          Transfer
                        >(
                          currentTable: table,
                          referencedTable: $$ShareClassesTableReferences
                              ._transfersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShareClassesTableReferences(
                                db,
                                table,
                                p0,
                              ).transfersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.shareClassId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ShareClassesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShareClassesTable,
      ShareClassesData,
      $$ShareClassesTableFilterComposer,
      $$ShareClassesTableOrderingComposer,
      $$ShareClassesTableAnnotationComposer,
      $$ShareClassesTableCreateCompanionBuilder,
      $$ShareClassesTableUpdateCompanionBuilder,
      (ShareClassesData, $$ShareClassesTableReferences),
      ShareClassesData,
      PrefetchHooks Function({
        bool companyId,
        bool holdingsRefs,
        bool optionGrantsRefs,
        bool warrantsRefs,
        bool transfersRefs,
      })
    >;
typedef $$RoundsTableCreateCompanionBuilder =
    RoundsCompanion Function({
      required String id,
      required String companyId,
      required String name,
      required String type,
      Value<String> status,
      required DateTime date,
      Value<double?> preMoneyValuation,
      Value<double?> pricePerShare,
      Value<double> amountRaised,
      Value<String?> leadInvestorId,
      required int displayOrder,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$RoundsTableUpdateCompanionBuilder =
    RoundsCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> name,
      Value<String> type,
      Value<String> status,
      Value<DateTime> date,
      Value<double?> preMoneyValuation,
      Value<double?> pricePerShare,
      Value<double> amountRaised,
      Value<String?> leadInvestorId,
      Value<int> displayOrder,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$RoundsTableReferences
    extends BaseReferences<_$AppDatabase, $RoundsTable, Round> {
  $$RoundsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) => db.companies
      .createAlias($_aliasNameGenerator(db.rounds.companyId, db.companies.id));

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StakeholdersTable _leadInvestorIdTable(_$AppDatabase db) =>
      db.stakeholders.createAlias(
        $_aliasNameGenerator(db.rounds.leadInvestorId, db.stakeholders.id),
      );

  $$StakeholdersTableProcessedTableManager? get leadInvestorId {
    final $_column = $_itemColumn<String>('lead_investor_id');
    if ($_column == null) return null;
    final manager = $$StakeholdersTableTableManager(
      $_db,
      $_db.stakeholders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_leadInvestorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$HoldingsTable, List<Holding>> _holdingsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.holdings,
    aliasName: $_aliasNameGenerator(db.rounds.id, db.holdings.roundId),
  );

  $$HoldingsTableProcessedTableManager get holdingsRefs {
    final manager = $$HoldingsTableTableManager(
      $_db,
      $_db.holdings,
    ).filter((f) => f.roundId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_holdingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConvertiblesTable, List<Convertible>>
  _convertiblesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.convertibles,
    aliasName: $_aliasNameGenerator(db.rounds.id, db.convertibles.roundId),
  );

  $$ConvertiblesTableProcessedTableManager get convertiblesRefs {
    final manager = $$ConvertiblesTableTableManager(
      $_db,
      $_db.convertibles,
    ).filter((f) => f.roundId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_convertiblesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EsopPoolsTable, List<EsopPool>>
  _esopPoolsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.esopPools,
    aliasName: $_aliasNameGenerator(db.rounds.id, db.esopPools.roundId),
  );

  $$EsopPoolsTableProcessedTableManager get esopPoolsRefs {
    final manager = $$EsopPoolsTableTableManager(
      $_db,
      $_db.esopPools,
    ).filter((f) => f.roundId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_esopPoolsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OptionGrantsTable, List<OptionGrant>>
  _optionGrantsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.optionGrants,
    aliasName: $_aliasNameGenerator(db.rounds.id, db.optionGrants.roundId),
  );

  $$OptionGrantsTableProcessedTableManager get optionGrantsRefs {
    final manager = $$OptionGrantsTableTableManager(
      $_db,
      $_db.optionGrants,
    ).filter((f) => f.roundId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_optionGrantsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WarrantsTable, List<Warrant>> _warrantsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.warrants,
    aliasName: $_aliasNameGenerator(db.rounds.id, db.warrants.roundId),
  );

  $$WarrantsTableProcessedTableManager get warrantsRefs {
    final manager = $$WarrantsTableTableManager(
      $_db,
      $_db.warrants,
    ).filter((f) => f.roundId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_warrantsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoundsTableFilterComposer
    extends Composer<_$AppDatabase, $RoundsTable> {
  $$RoundsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get preMoneyValuation => $composableBuilder(
    column: $table.preMoneyValuation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePerShare => $composableBuilder(
    column: $table.pricePerShare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountRaised => $composableBuilder(
    column: $table.amountRaised,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableFilterComposer get leadInvestorId {
    final $$StakeholdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.leadInvestorId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableFilterComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> holdingsRefs(
    Expression<bool> Function($$HoldingsTableFilterComposer f) f,
  ) {
    final $$HoldingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdings,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableFilterComposer(
            $db: $db,
            $table: $db.holdings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> convertiblesRefs(
    Expression<bool> Function($$ConvertiblesTableFilterComposer f) f,
  ) {
    final $$ConvertiblesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.convertibles,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConvertiblesTableFilterComposer(
            $db: $db,
            $table: $db.convertibles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> esopPoolsRefs(
    Expression<bool> Function($$EsopPoolsTableFilterComposer f) f,
  ) {
    final $$EsopPoolsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.esopPools,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EsopPoolsTableFilterComposer(
            $db: $db,
            $table: $db.esopPools,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> optionGrantsRefs(
    Expression<bool> Function($$OptionGrantsTableFilterComposer f) f,
  ) {
    final $$OptionGrantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.optionGrants,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OptionGrantsTableFilterComposer(
            $db: $db,
            $table: $db.optionGrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> warrantsRefs(
    Expression<bool> Function($$WarrantsTableFilterComposer f) f,
  ) {
    final $$WarrantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.warrants,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WarrantsTableFilterComposer(
            $db: $db,
            $table: $db.warrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoundsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoundsTable> {
  $$RoundsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get preMoneyValuation => $composableBuilder(
    column: $table.preMoneyValuation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePerShare => $composableBuilder(
    column: $table.pricePerShare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountRaised => $composableBuilder(
    column: $table.amountRaised,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableOrderingComposer get leadInvestorId {
    final $$StakeholdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.leadInvestorId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableOrderingComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoundsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoundsTable> {
  $$RoundsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get preMoneyValuation => $composableBuilder(
    column: $table.preMoneyValuation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pricePerShare => $composableBuilder(
    column: $table.pricePerShare,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountRaised => $composableBuilder(
    column: $table.amountRaised,
    builder: (column) => column,
  );

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableAnnotationComposer get leadInvestorId {
    final $$StakeholdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.leadInvestorId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableAnnotationComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> holdingsRefs<T extends Object>(
    Expression<T> Function($$HoldingsTableAnnotationComposer a) f,
  ) {
    final $$HoldingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.holdings,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableAnnotationComposer(
            $db: $db,
            $table: $db.holdings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> convertiblesRefs<T extends Object>(
    Expression<T> Function($$ConvertiblesTableAnnotationComposer a) f,
  ) {
    final $$ConvertiblesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.convertibles,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConvertiblesTableAnnotationComposer(
            $db: $db,
            $table: $db.convertibles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> esopPoolsRefs<T extends Object>(
    Expression<T> Function($$EsopPoolsTableAnnotationComposer a) f,
  ) {
    final $$EsopPoolsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.esopPools,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EsopPoolsTableAnnotationComposer(
            $db: $db,
            $table: $db.esopPools,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> optionGrantsRefs<T extends Object>(
    Expression<T> Function($$OptionGrantsTableAnnotationComposer a) f,
  ) {
    final $$OptionGrantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.optionGrants,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OptionGrantsTableAnnotationComposer(
            $db: $db,
            $table: $db.optionGrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> warrantsRefs<T extends Object>(
    Expression<T> Function($$WarrantsTableAnnotationComposer a) f,
  ) {
    final $$WarrantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.warrants,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WarrantsTableAnnotationComposer(
            $db: $db,
            $table: $db.warrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoundsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoundsTable,
          Round,
          $$RoundsTableFilterComposer,
          $$RoundsTableOrderingComposer,
          $$RoundsTableAnnotationComposer,
          $$RoundsTableCreateCompanionBuilder,
          $$RoundsTableUpdateCompanionBuilder,
          (Round, $$RoundsTableReferences),
          Round,
          PrefetchHooks Function({
            bool companyId,
            bool leadInvestorId,
            bool holdingsRefs,
            bool convertiblesRefs,
            bool esopPoolsRefs,
            bool optionGrantsRefs,
            bool warrantsRefs,
          })
        > {
  $$RoundsTableTableManager(_$AppDatabase db, $RoundsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoundsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoundsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoundsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double?> preMoneyValuation = const Value.absent(),
                Value<double?> pricePerShare = const Value.absent(),
                Value<double> amountRaised = const Value.absent(),
                Value<String?> leadInvestorId = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoundsCompanion(
                id: id,
                companyId: companyId,
                name: name,
                type: type,
                status: status,
                date: date,
                preMoneyValuation: preMoneyValuation,
                pricePerShare: pricePerShare,
                amountRaised: amountRaised,
                leadInvestorId: leadInvestorId,
                displayOrder: displayOrder,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String name,
                required String type,
                Value<String> status = const Value.absent(),
                required DateTime date,
                Value<double?> preMoneyValuation = const Value.absent(),
                Value<double?> pricePerShare = const Value.absent(),
                Value<double> amountRaised = const Value.absent(),
                Value<String?> leadInvestorId = const Value.absent(),
                required int displayOrder,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RoundsCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                type: type,
                status: status,
                date: date,
                preMoneyValuation: preMoneyValuation,
                pricePerShare: pricePerShare,
                amountRaised: amountRaised,
                leadInvestorId: leadInvestorId,
                displayOrder: displayOrder,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RoundsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                companyId = false,
                leadInvestorId = false,
                holdingsRefs = false,
                convertiblesRefs = false,
                esopPoolsRefs = false,
                optionGrantsRefs = false,
                warrantsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (holdingsRefs) db.holdings,
                    if (convertiblesRefs) db.convertibles,
                    if (esopPoolsRefs) db.esopPools,
                    if (optionGrantsRefs) db.optionGrants,
                    if (warrantsRefs) db.warrants,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable: $$RoundsTableReferences
                                        ._companyIdTable(db),
                                    referencedColumn: $$RoundsTableReferences
                                        ._companyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (leadInvestorId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.leadInvestorId,
                                    referencedTable: $$RoundsTableReferences
                                        ._leadInvestorIdTable(db),
                                    referencedColumn: $$RoundsTableReferences
                                        ._leadInvestorIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (holdingsRefs)
                        await $_getPrefetchedData<Round, $RoundsTable, Holding>(
                          currentTable: table,
                          referencedTable: $$RoundsTableReferences
                              ._holdingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoundsTableReferences(
                                db,
                                table,
                                p0,
                              ).holdingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.roundId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (convertiblesRefs)
                        await $_getPrefetchedData<
                          Round,
                          $RoundsTable,
                          Convertible
                        >(
                          currentTable: table,
                          referencedTable: $$RoundsTableReferences
                              ._convertiblesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoundsTableReferences(
                                db,
                                table,
                                p0,
                              ).convertiblesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.roundId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (esopPoolsRefs)
                        await $_getPrefetchedData<
                          Round,
                          $RoundsTable,
                          EsopPool
                        >(
                          currentTable: table,
                          referencedTable: $$RoundsTableReferences
                              ._esopPoolsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoundsTableReferences(
                                db,
                                table,
                                p0,
                              ).esopPoolsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.roundId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (optionGrantsRefs)
                        await $_getPrefetchedData<
                          Round,
                          $RoundsTable,
                          OptionGrant
                        >(
                          currentTable: table,
                          referencedTable: $$RoundsTableReferences
                              ._optionGrantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoundsTableReferences(
                                db,
                                table,
                                p0,
                              ).optionGrantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.roundId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (warrantsRefs)
                        await $_getPrefetchedData<Round, $RoundsTable, Warrant>(
                          currentTable: table,
                          referencedTable: $$RoundsTableReferences
                              ._warrantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoundsTableReferences(
                                db,
                                table,
                                p0,
                              ).warrantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.roundId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoundsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoundsTable,
      Round,
      $$RoundsTableFilterComposer,
      $$RoundsTableOrderingComposer,
      $$RoundsTableAnnotationComposer,
      $$RoundsTableCreateCompanionBuilder,
      $$RoundsTableUpdateCompanionBuilder,
      (Round, $$RoundsTableReferences),
      Round,
      PrefetchHooks Function({
        bool companyId,
        bool leadInvestorId,
        bool holdingsRefs,
        bool convertiblesRefs,
        bool esopPoolsRefs,
        bool optionGrantsRefs,
        bool warrantsRefs,
      })
    >;
typedef $$HoldingsTableCreateCompanionBuilder =
    HoldingsCompanion Function({
      required String id,
      required String companyId,
      required String stakeholderId,
      required String shareClassId,
      required int shareCount,
      required double costBasis,
      required DateTime acquiredDate,
      Value<String?> vestingScheduleId,
      Value<int?> vestedCount,
      Value<String?> roundId,
      Value<String?> sourceOptionGrantId,
      Value<String?> sourceWarrantId,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$HoldingsTableUpdateCompanionBuilder =
    HoldingsCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> stakeholderId,
      Value<String> shareClassId,
      Value<int> shareCount,
      Value<double> costBasis,
      Value<DateTime> acquiredDate,
      Value<String?> vestingScheduleId,
      Value<int?> vestedCount,
      Value<String?> roundId,
      Value<String?> sourceOptionGrantId,
      Value<String?> sourceWarrantId,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$HoldingsTableReferences
    extends BaseReferences<_$AppDatabase, $HoldingsTable, Holding> {
  $$HoldingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.holdings.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StakeholdersTable _stakeholderIdTable(_$AppDatabase db) =>
      db.stakeholders.createAlias(
        $_aliasNameGenerator(db.holdings.stakeholderId, db.stakeholders.id),
      );

  $$StakeholdersTableProcessedTableManager get stakeholderId {
    final $_column = $_itemColumn<String>('stakeholder_id')!;

    final manager = $$StakeholdersTableTableManager(
      $_db,
      $_db.stakeholders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stakeholderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ShareClassesTable _shareClassIdTable(_$AppDatabase db) =>
      db.shareClasses.createAlias(
        $_aliasNameGenerator(db.holdings.shareClassId, db.shareClasses.id),
      );

  $$ShareClassesTableProcessedTableManager get shareClassId {
    final $_column = $_itemColumn<String>('share_class_id')!;

    final manager = $$ShareClassesTableTableManager(
      $_db,
      $_db.shareClasses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shareClassIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RoundsTable _roundIdTable(_$AppDatabase db) => db.rounds.createAlias(
    $_aliasNameGenerator(db.holdings.roundId, db.rounds.id),
  );

  $$RoundsTableProcessedTableManager? get roundId {
    final $_column = $_itemColumn<String>('round_id');
    if ($_column == null) return null;
    final manager = $$RoundsTableTableManager(
      $_db,
      $_db.rounds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roundIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransfersTable, List<Transfer>>
  _transfersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transfers,
    aliasName: $_aliasNameGenerator(
      db.holdings.id,
      db.transfers.sourceHoldingId,
    ),
  );

  $$TransfersTableProcessedTableManager get transfersRefs {
    final manager = $$TransfersTableTableManager($_db, $_db.transfers).filter(
      (f) => f.sourceHoldingId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_transfersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HoldingsTableFilterComposer
    extends Composer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableFilterComposer({
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

  ColumnFilters<int> get shareCount => $composableBuilder(
    column: $table.shareCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costBasis => $composableBuilder(
    column: $table.costBasis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acquiredDate => $composableBuilder(
    column: $table.acquiredDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vestingScheduleId => $composableBuilder(
    column: $table.vestingScheduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vestedCount => $composableBuilder(
    column: $table.vestedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceOptionGrantId => $composableBuilder(
    column: $table.sourceOptionGrantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceWarrantId => $composableBuilder(
    column: $table.sourceWarrantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableFilterComposer get stakeholderId {
    final $$StakeholdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableFilterComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShareClassesTableFilterComposer get shareClassId {
    final $$ShareClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shareClassId,
      referencedTable: $db.shareClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareClassesTableFilterComposer(
            $db: $db,
            $table: $db.shareClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundsTableFilterComposer get roundId {
    final $$RoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableFilterComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transfersRefs(
    Expression<bool> Function($$TransfersTableFilterComposer f) f,
  ) {
    final $$TransfersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transfers,
      getReferencedColumn: (t) => t.sourceHoldingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransfersTableFilterComposer(
            $db: $db,
            $table: $db.transfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HoldingsTableOrderingComposer
    extends Composer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableOrderingComposer({
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

  ColumnOrderings<int> get shareCount => $composableBuilder(
    column: $table.shareCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costBasis => $composableBuilder(
    column: $table.costBasis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acquiredDate => $composableBuilder(
    column: $table.acquiredDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vestingScheduleId => $composableBuilder(
    column: $table.vestingScheduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vestedCount => $composableBuilder(
    column: $table.vestedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceOptionGrantId => $composableBuilder(
    column: $table.sourceOptionGrantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceWarrantId => $composableBuilder(
    column: $table.sourceWarrantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableOrderingComposer get stakeholderId {
    final $$StakeholdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableOrderingComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShareClassesTableOrderingComposer get shareClassId {
    final $$ShareClassesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shareClassId,
      referencedTable: $db.shareClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareClassesTableOrderingComposer(
            $db: $db,
            $table: $db.shareClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundsTableOrderingComposer get roundId {
    final $$RoundsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableOrderingComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HoldingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get shareCount => $composableBuilder(
    column: $table.shareCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costBasis =>
      $composableBuilder(column: $table.costBasis, builder: (column) => column);

  GeneratedColumn<DateTime> get acquiredDate => $composableBuilder(
    column: $table.acquiredDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vestingScheduleId => $composableBuilder(
    column: $table.vestingScheduleId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get vestedCount => $composableBuilder(
    column: $table.vestedCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceOptionGrantId => $composableBuilder(
    column: $table.sourceOptionGrantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceWarrantId => $composableBuilder(
    column: $table.sourceWarrantId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableAnnotationComposer get stakeholderId {
    final $$StakeholdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableAnnotationComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShareClassesTableAnnotationComposer get shareClassId {
    final $$ShareClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shareClassId,
      referencedTable: $db.shareClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.shareClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundsTableAnnotationComposer get roundId {
    final $$RoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transfersRefs<T extends Object>(
    Expression<T> Function($$TransfersTableAnnotationComposer a) f,
  ) {
    final $$TransfersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transfers,
      getReferencedColumn: (t) => t.sourceHoldingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransfersTableAnnotationComposer(
            $db: $db,
            $table: $db.transfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HoldingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HoldingsTable,
          Holding,
          $$HoldingsTableFilterComposer,
          $$HoldingsTableOrderingComposer,
          $$HoldingsTableAnnotationComposer,
          $$HoldingsTableCreateCompanionBuilder,
          $$HoldingsTableUpdateCompanionBuilder,
          (Holding, $$HoldingsTableReferences),
          Holding,
          PrefetchHooks Function({
            bool companyId,
            bool stakeholderId,
            bool shareClassId,
            bool roundId,
            bool transfersRefs,
          })
        > {
  $$HoldingsTableTableManager(_$AppDatabase db, $HoldingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HoldingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HoldingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HoldingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> stakeholderId = const Value.absent(),
                Value<String> shareClassId = const Value.absent(),
                Value<int> shareCount = const Value.absent(),
                Value<double> costBasis = const Value.absent(),
                Value<DateTime> acquiredDate = const Value.absent(),
                Value<String?> vestingScheduleId = const Value.absent(),
                Value<int?> vestedCount = const Value.absent(),
                Value<String?> roundId = const Value.absent(),
                Value<String?> sourceOptionGrantId = const Value.absent(),
                Value<String?> sourceWarrantId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HoldingsCompanion(
                id: id,
                companyId: companyId,
                stakeholderId: stakeholderId,
                shareClassId: shareClassId,
                shareCount: shareCount,
                costBasis: costBasis,
                acquiredDate: acquiredDate,
                vestingScheduleId: vestingScheduleId,
                vestedCount: vestedCount,
                roundId: roundId,
                sourceOptionGrantId: sourceOptionGrantId,
                sourceWarrantId: sourceWarrantId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String stakeholderId,
                required String shareClassId,
                required int shareCount,
                required double costBasis,
                required DateTime acquiredDate,
                Value<String?> vestingScheduleId = const Value.absent(),
                Value<int?> vestedCount = const Value.absent(),
                Value<String?> roundId = const Value.absent(),
                Value<String?> sourceOptionGrantId = const Value.absent(),
                Value<String?> sourceWarrantId = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => HoldingsCompanion.insert(
                id: id,
                companyId: companyId,
                stakeholderId: stakeholderId,
                shareClassId: shareClassId,
                shareCount: shareCount,
                costBasis: costBasis,
                acquiredDate: acquiredDate,
                vestingScheduleId: vestingScheduleId,
                vestedCount: vestedCount,
                roundId: roundId,
                sourceOptionGrantId: sourceOptionGrantId,
                sourceWarrantId: sourceWarrantId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HoldingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                companyId = false,
                stakeholderId = false,
                shareClassId = false,
                roundId = false,
                transfersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (transfersRefs) db.transfers],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable: $$HoldingsTableReferences
                                        ._companyIdTable(db),
                                    referencedColumn: $$HoldingsTableReferences
                                        ._companyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (stakeholderId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.stakeholderId,
                                    referencedTable: $$HoldingsTableReferences
                                        ._stakeholderIdTable(db),
                                    referencedColumn: $$HoldingsTableReferences
                                        ._stakeholderIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (shareClassId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shareClassId,
                                    referencedTable: $$HoldingsTableReferences
                                        ._shareClassIdTable(db),
                                    referencedColumn: $$HoldingsTableReferences
                                        ._shareClassIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (roundId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.roundId,
                                    referencedTable: $$HoldingsTableReferences
                                        ._roundIdTable(db),
                                    referencedColumn: $$HoldingsTableReferences
                                        ._roundIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transfersRefs)
                        await $_getPrefetchedData<
                          Holding,
                          $HoldingsTable,
                          Transfer
                        >(
                          currentTable: table,
                          referencedTable: $$HoldingsTableReferences
                              ._transfersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$HoldingsTableReferences(
                                db,
                                table,
                                p0,
                              ).transfersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceHoldingId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$HoldingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HoldingsTable,
      Holding,
      $$HoldingsTableFilterComposer,
      $$HoldingsTableOrderingComposer,
      $$HoldingsTableAnnotationComposer,
      $$HoldingsTableCreateCompanionBuilder,
      $$HoldingsTableUpdateCompanionBuilder,
      (Holding, $$HoldingsTableReferences),
      Holding,
      PrefetchHooks Function({
        bool companyId,
        bool stakeholderId,
        bool shareClassId,
        bool roundId,
        bool transfersRefs,
      })
    >;
typedef $$ConvertiblesTableCreateCompanionBuilder =
    ConvertiblesCompanion Function({
      required String id,
      required String companyId,
      required String stakeholderId,
      required String type,
      Value<String> status,
      required double principal,
      Value<double?> valuationCap,
      Value<double?> discountPercent,
      Value<double?> interestRate,
      Value<DateTime?> maturityDate,
      required DateTime issueDate,
      Value<bool> hasMfn,
      Value<bool> hasProRata,
      Value<String?> roundId,
      Value<String?> conversionEventId,
      Value<String?> convertedToShareClassId,
      Value<int?> sharesReceived,
      Value<String?> notes,
      Value<String?> maturityBehavior,
      Value<bool> allowsVoluntaryConversion,
      Value<String?> liquidityEventBehavior,
      Value<double?> liquidityPayoutMultiple,
      Value<String?> dissolutionBehavior,
      Value<String?> preferredShareClassId,
      Value<double?> qualifiedFinancingThreshold,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ConvertiblesTableUpdateCompanionBuilder =
    ConvertiblesCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> stakeholderId,
      Value<String> type,
      Value<String> status,
      Value<double> principal,
      Value<double?> valuationCap,
      Value<double?> discountPercent,
      Value<double?> interestRate,
      Value<DateTime?> maturityDate,
      Value<DateTime> issueDate,
      Value<bool> hasMfn,
      Value<bool> hasProRata,
      Value<String?> roundId,
      Value<String?> conversionEventId,
      Value<String?> convertedToShareClassId,
      Value<int?> sharesReceived,
      Value<String?> notes,
      Value<String?> maturityBehavior,
      Value<bool> allowsVoluntaryConversion,
      Value<String?> liquidityEventBehavior,
      Value<double?> liquidityPayoutMultiple,
      Value<String?> dissolutionBehavior,
      Value<String?> preferredShareClassId,
      Value<double?> qualifiedFinancingThreshold,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ConvertiblesTableReferences
    extends BaseReferences<_$AppDatabase, $ConvertiblesTable, Convertible> {
  $$ConvertiblesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.convertibles.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StakeholdersTable _stakeholderIdTable(_$AppDatabase db) =>
      db.stakeholders.createAlias(
        $_aliasNameGenerator(db.convertibles.stakeholderId, db.stakeholders.id),
      );

  $$StakeholdersTableProcessedTableManager get stakeholderId {
    final $_column = $_itemColumn<String>('stakeholder_id')!;

    final manager = $$StakeholdersTableTableManager(
      $_db,
      $_db.stakeholders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stakeholderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RoundsTable _roundIdTable(_$AppDatabase db) => db.rounds.createAlias(
    $_aliasNameGenerator(db.convertibles.roundId, db.rounds.id),
  );

  $$RoundsTableProcessedTableManager? get roundId {
    final $_column = $_itemColumn<String>('round_id');
    if ($_column == null) return null;
    final manager = $$RoundsTableTableManager(
      $_db,
      $_db.rounds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roundIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WarrantsTable, List<Warrant>> _warrantsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.warrants,
    aliasName: $_aliasNameGenerator(
      db.convertibles.id,
      db.warrants.sourceConvertibleId,
    ),
  );

  $$WarrantsTableProcessedTableManager get warrantsRefs {
    final manager = $$WarrantsTableTableManager($_db, $_db.warrants).filter(
      (f) => f.sourceConvertibleId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_warrantsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MfnUpgradesTable, List<MfnUpgrade>>
  _mfnTargetUpgradesTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mfnUpgrades,
    aliasName: $_aliasNameGenerator(
      db.convertibles.id,
      db.mfnUpgrades.targetConvertibleId,
    ),
  );

  $$MfnUpgradesTableProcessedTableManager get mfnTargetUpgrades {
    final manager = $$MfnUpgradesTableTableManager($_db, $_db.mfnUpgrades)
        .filter(
          (f) =>
              f.targetConvertibleId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_mfnTargetUpgradesTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MfnUpgradesTable, List<MfnUpgrade>>
  _mfnSourceUpgradesTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mfnUpgrades,
    aliasName: $_aliasNameGenerator(
      db.convertibles.id,
      db.mfnUpgrades.sourceConvertibleId,
    ),
  );

  $$MfnUpgradesTableProcessedTableManager get mfnSourceUpgrades {
    final manager = $$MfnUpgradesTableTableManager($_db, $_db.mfnUpgrades)
        .filter(
          (f) =>
              f.sourceConvertibleId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_mfnSourceUpgradesTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConvertiblesTableFilterComposer
    extends Composer<_$AppDatabase, $ConvertiblesTable> {
  $$ConvertiblesTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get principal => $composableBuilder(
    column: $table.principal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valuationCap => $composableBuilder(
    column: $table.valuationCap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountPercent => $composableBuilder(
    column: $table.discountPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasMfn => $composableBuilder(
    column: $table.hasMfn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasProRata => $composableBuilder(
    column: $table.hasProRata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversionEventId => $composableBuilder(
    column: $table.conversionEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get convertedToShareClassId => $composableBuilder(
    column: $table.convertedToShareClassId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sharesReceived => $composableBuilder(
    column: $table.sharesReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maturityBehavior => $composableBuilder(
    column: $table.maturityBehavior,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowsVoluntaryConversion => $composableBuilder(
    column: $table.allowsVoluntaryConversion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get liquidityEventBehavior => $composableBuilder(
    column: $table.liquidityEventBehavior,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get liquidityPayoutMultiple => $composableBuilder(
    column: $table.liquidityPayoutMultiple,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dissolutionBehavior => $composableBuilder(
    column: $table.dissolutionBehavior,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredShareClassId => $composableBuilder(
    column: $table.preferredShareClassId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get qualifiedFinancingThreshold => $composableBuilder(
    column: $table.qualifiedFinancingThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableFilterComposer get stakeholderId {
    final $$StakeholdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableFilterComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundsTableFilterComposer get roundId {
    final $$RoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableFilterComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> warrantsRefs(
    Expression<bool> Function($$WarrantsTableFilterComposer f) f,
  ) {
    final $$WarrantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.warrants,
      getReferencedColumn: (t) => t.sourceConvertibleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WarrantsTableFilterComposer(
            $db: $db,
            $table: $db.warrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mfnTargetUpgrades(
    Expression<bool> Function($$MfnUpgradesTableFilterComposer f) f,
  ) {
    final $$MfnUpgradesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mfnUpgrades,
      getReferencedColumn: (t) => t.targetConvertibleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MfnUpgradesTableFilterComposer(
            $db: $db,
            $table: $db.mfnUpgrades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mfnSourceUpgrades(
    Expression<bool> Function($$MfnUpgradesTableFilterComposer f) f,
  ) {
    final $$MfnUpgradesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mfnUpgrades,
      getReferencedColumn: (t) => t.sourceConvertibleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MfnUpgradesTableFilterComposer(
            $db: $db,
            $table: $db.mfnUpgrades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConvertiblesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConvertiblesTable> {
  $$ConvertiblesTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get principal => $composableBuilder(
    column: $table.principal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valuationCap => $composableBuilder(
    column: $table.valuationCap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountPercent => $composableBuilder(
    column: $table.discountPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasMfn => $composableBuilder(
    column: $table.hasMfn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasProRata => $composableBuilder(
    column: $table.hasProRata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversionEventId => $composableBuilder(
    column: $table.conversionEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get convertedToShareClassId => $composableBuilder(
    column: $table.convertedToShareClassId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sharesReceived => $composableBuilder(
    column: $table.sharesReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maturityBehavior => $composableBuilder(
    column: $table.maturityBehavior,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowsVoluntaryConversion => $composableBuilder(
    column: $table.allowsVoluntaryConversion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get liquidityEventBehavior => $composableBuilder(
    column: $table.liquidityEventBehavior,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get liquidityPayoutMultiple => $composableBuilder(
    column: $table.liquidityPayoutMultiple,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dissolutionBehavior => $composableBuilder(
    column: $table.dissolutionBehavior,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredShareClassId => $composableBuilder(
    column: $table.preferredShareClassId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get qualifiedFinancingThreshold => $composableBuilder(
    column: $table.qualifiedFinancingThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableOrderingComposer get stakeholderId {
    final $$StakeholdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableOrderingComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundsTableOrderingComposer get roundId {
    final $$RoundsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableOrderingComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConvertiblesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConvertiblesTable> {
  $$ConvertiblesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get principal =>
      $composableBuilder(column: $table.principal, builder: (column) => column);

  GeneratedColumn<double> get valuationCap => $composableBuilder(
    column: $table.valuationCap,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discountPercent => $composableBuilder(
    column: $table.discountPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get interestRate => $composableBuilder(
    column: $table.interestRate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get maturityDate => $composableBuilder(
    column: $table.maturityDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get issueDate =>
      $composableBuilder(column: $table.issueDate, builder: (column) => column);

  GeneratedColumn<bool> get hasMfn =>
      $composableBuilder(column: $table.hasMfn, builder: (column) => column);

  GeneratedColumn<bool> get hasProRata => $composableBuilder(
    column: $table.hasProRata,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conversionEventId => $composableBuilder(
    column: $table.conversionEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get convertedToShareClassId => $composableBuilder(
    column: $table.convertedToShareClassId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sharesReceived => $composableBuilder(
    column: $table.sharesReceived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get maturityBehavior => $composableBuilder(
    column: $table.maturityBehavior,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowsVoluntaryConversion => $composableBuilder(
    column: $table.allowsVoluntaryConversion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get liquidityEventBehavior => $composableBuilder(
    column: $table.liquidityEventBehavior,
    builder: (column) => column,
  );

  GeneratedColumn<double> get liquidityPayoutMultiple => $composableBuilder(
    column: $table.liquidityPayoutMultiple,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dissolutionBehavior => $composableBuilder(
    column: $table.dissolutionBehavior,
    builder: (column) => column,
  );

  GeneratedColumn<String> get preferredShareClassId => $composableBuilder(
    column: $table.preferredShareClassId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get qualifiedFinancingThreshold => $composableBuilder(
    column: $table.qualifiedFinancingThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableAnnotationComposer get stakeholderId {
    final $$StakeholdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableAnnotationComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundsTableAnnotationComposer get roundId {
    final $$RoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> warrantsRefs<T extends Object>(
    Expression<T> Function($$WarrantsTableAnnotationComposer a) f,
  ) {
    final $$WarrantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.warrants,
      getReferencedColumn: (t) => t.sourceConvertibleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WarrantsTableAnnotationComposer(
            $db: $db,
            $table: $db.warrants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mfnTargetUpgrades<T extends Object>(
    Expression<T> Function($$MfnUpgradesTableAnnotationComposer a) f,
  ) {
    final $$MfnUpgradesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mfnUpgrades,
      getReferencedColumn: (t) => t.targetConvertibleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MfnUpgradesTableAnnotationComposer(
            $db: $db,
            $table: $db.mfnUpgrades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mfnSourceUpgrades<T extends Object>(
    Expression<T> Function($$MfnUpgradesTableAnnotationComposer a) f,
  ) {
    final $$MfnUpgradesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mfnUpgrades,
      getReferencedColumn: (t) => t.sourceConvertibleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MfnUpgradesTableAnnotationComposer(
            $db: $db,
            $table: $db.mfnUpgrades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConvertiblesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConvertiblesTable,
          Convertible,
          $$ConvertiblesTableFilterComposer,
          $$ConvertiblesTableOrderingComposer,
          $$ConvertiblesTableAnnotationComposer,
          $$ConvertiblesTableCreateCompanionBuilder,
          $$ConvertiblesTableUpdateCompanionBuilder,
          (Convertible, $$ConvertiblesTableReferences),
          Convertible,
          PrefetchHooks Function({
            bool companyId,
            bool stakeholderId,
            bool roundId,
            bool warrantsRefs,
            bool mfnTargetUpgrades,
            bool mfnSourceUpgrades,
          })
        > {
  $$ConvertiblesTableTableManager(_$AppDatabase db, $ConvertiblesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConvertiblesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConvertiblesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConvertiblesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> stakeholderId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> principal = const Value.absent(),
                Value<double?> valuationCap = const Value.absent(),
                Value<double?> discountPercent = const Value.absent(),
                Value<double?> interestRate = const Value.absent(),
                Value<DateTime?> maturityDate = const Value.absent(),
                Value<DateTime> issueDate = const Value.absent(),
                Value<bool> hasMfn = const Value.absent(),
                Value<bool> hasProRata = const Value.absent(),
                Value<String?> roundId = const Value.absent(),
                Value<String?> conversionEventId = const Value.absent(),
                Value<String?> convertedToShareClassId = const Value.absent(),
                Value<int?> sharesReceived = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> maturityBehavior = const Value.absent(),
                Value<bool> allowsVoluntaryConversion = const Value.absent(),
                Value<String?> liquidityEventBehavior = const Value.absent(),
                Value<double?> liquidityPayoutMultiple = const Value.absent(),
                Value<String?> dissolutionBehavior = const Value.absent(),
                Value<String?> preferredShareClassId = const Value.absent(),
                Value<double?> qualifiedFinancingThreshold =
                    const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConvertiblesCompanion(
                id: id,
                companyId: companyId,
                stakeholderId: stakeholderId,
                type: type,
                status: status,
                principal: principal,
                valuationCap: valuationCap,
                discountPercent: discountPercent,
                interestRate: interestRate,
                maturityDate: maturityDate,
                issueDate: issueDate,
                hasMfn: hasMfn,
                hasProRata: hasProRata,
                roundId: roundId,
                conversionEventId: conversionEventId,
                convertedToShareClassId: convertedToShareClassId,
                sharesReceived: sharesReceived,
                notes: notes,
                maturityBehavior: maturityBehavior,
                allowsVoluntaryConversion: allowsVoluntaryConversion,
                liquidityEventBehavior: liquidityEventBehavior,
                liquidityPayoutMultiple: liquidityPayoutMultiple,
                dissolutionBehavior: dissolutionBehavior,
                preferredShareClassId: preferredShareClassId,
                qualifiedFinancingThreshold: qualifiedFinancingThreshold,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String stakeholderId,
                required String type,
                Value<String> status = const Value.absent(),
                required double principal,
                Value<double?> valuationCap = const Value.absent(),
                Value<double?> discountPercent = const Value.absent(),
                Value<double?> interestRate = const Value.absent(),
                Value<DateTime?> maturityDate = const Value.absent(),
                required DateTime issueDate,
                Value<bool> hasMfn = const Value.absent(),
                Value<bool> hasProRata = const Value.absent(),
                Value<String?> roundId = const Value.absent(),
                Value<String?> conversionEventId = const Value.absent(),
                Value<String?> convertedToShareClassId = const Value.absent(),
                Value<int?> sharesReceived = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> maturityBehavior = const Value.absent(),
                Value<bool> allowsVoluntaryConversion = const Value.absent(),
                Value<String?> liquidityEventBehavior = const Value.absent(),
                Value<double?> liquidityPayoutMultiple = const Value.absent(),
                Value<String?> dissolutionBehavior = const Value.absent(),
                Value<String?> preferredShareClassId = const Value.absent(),
                Value<double?> qualifiedFinancingThreshold =
                    const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ConvertiblesCompanion.insert(
                id: id,
                companyId: companyId,
                stakeholderId: stakeholderId,
                type: type,
                status: status,
                principal: principal,
                valuationCap: valuationCap,
                discountPercent: discountPercent,
                interestRate: interestRate,
                maturityDate: maturityDate,
                issueDate: issueDate,
                hasMfn: hasMfn,
                hasProRata: hasProRata,
                roundId: roundId,
                conversionEventId: conversionEventId,
                convertedToShareClassId: convertedToShareClassId,
                sharesReceived: sharesReceived,
                notes: notes,
                maturityBehavior: maturityBehavior,
                allowsVoluntaryConversion: allowsVoluntaryConversion,
                liquidityEventBehavior: liquidityEventBehavior,
                liquidityPayoutMultiple: liquidityPayoutMultiple,
                dissolutionBehavior: dissolutionBehavior,
                preferredShareClassId: preferredShareClassId,
                qualifiedFinancingThreshold: qualifiedFinancingThreshold,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConvertiblesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                companyId = false,
                stakeholderId = false,
                roundId = false,
                warrantsRefs = false,
                mfnTargetUpgrades = false,
                mfnSourceUpgrades = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (warrantsRefs) db.warrants,
                    if (mfnTargetUpgrades) db.mfnUpgrades,
                    if (mfnSourceUpgrades) db.mfnUpgrades,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable:
                                        $$ConvertiblesTableReferences
                                            ._companyIdTable(db),
                                    referencedColumn:
                                        $$ConvertiblesTableReferences
                                            ._companyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (stakeholderId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.stakeholderId,
                                    referencedTable:
                                        $$ConvertiblesTableReferences
                                            ._stakeholderIdTable(db),
                                    referencedColumn:
                                        $$ConvertiblesTableReferences
                                            ._stakeholderIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (roundId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.roundId,
                                    referencedTable:
                                        $$ConvertiblesTableReferences
                                            ._roundIdTable(db),
                                    referencedColumn:
                                        $$ConvertiblesTableReferences
                                            ._roundIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (warrantsRefs)
                        await $_getPrefetchedData<
                          Convertible,
                          $ConvertiblesTable,
                          Warrant
                        >(
                          currentTable: table,
                          referencedTable: $$ConvertiblesTableReferences
                              ._warrantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConvertiblesTableReferences(
                                db,
                                table,
                                p0,
                              ).warrantsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceConvertibleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mfnTargetUpgrades)
                        await $_getPrefetchedData<
                          Convertible,
                          $ConvertiblesTable,
                          MfnUpgrade
                        >(
                          currentTable: table,
                          referencedTable: $$ConvertiblesTableReferences
                              ._mfnTargetUpgradesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConvertiblesTableReferences(
                                db,
                                table,
                                p0,
                              ).mfnTargetUpgrades,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.targetConvertibleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mfnSourceUpgrades)
                        await $_getPrefetchedData<
                          Convertible,
                          $ConvertiblesTable,
                          MfnUpgrade
                        >(
                          currentTable: table,
                          referencedTable: $$ConvertiblesTableReferences
                              ._mfnSourceUpgradesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConvertiblesTableReferences(
                                db,
                                table,
                                p0,
                              ).mfnSourceUpgrades,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceConvertibleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ConvertiblesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConvertiblesTable,
      Convertible,
      $$ConvertiblesTableFilterComposer,
      $$ConvertiblesTableOrderingComposer,
      $$ConvertiblesTableAnnotationComposer,
      $$ConvertiblesTableCreateCompanionBuilder,
      $$ConvertiblesTableUpdateCompanionBuilder,
      (Convertible, $$ConvertiblesTableReferences),
      Convertible,
      PrefetchHooks Function({
        bool companyId,
        bool stakeholderId,
        bool roundId,
        bool warrantsRefs,
        bool mfnTargetUpgrades,
        bool mfnSourceUpgrades,
      })
    >;
typedef $$EsopPoolsTableCreateCompanionBuilder =
    EsopPoolsCompanion Function({
      required String id,
      required String companyId,
      required String name,
      Value<String> status,
      required int poolSize,
      Value<double?> targetPercentage,
      required DateTime establishedDate,
      Value<String?> resolutionReference,
      Value<String?> roundId,
      Value<String?> defaultVestingScheduleId,
      Value<String> strikePriceMethod,
      Value<double?> defaultStrikePrice,
      Value<int> defaultExpiryYears,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$EsopPoolsTableUpdateCompanionBuilder =
    EsopPoolsCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> name,
      Value<String> status,
      Value<int> poolSize,
      Value<double?> targetPercentage,
      Value<DateTime> establishedDate,
      Value<String?> resolutionReference,
      Value<String?> roundId,
      Value<String?> defaultVestingScheduleId,
      Value<String> strikePriceMethod,
      Value<double?> defaultStrikePrice,
      Value<int> defaultExpiryYears,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$EsopPoolsTableReferences
    extends BaseReferences<_$AppDatabase, $EsopPoolsTable, EsopPool> {
  $$EsopPoolsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.esopPools.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RoundsTable _roundIdTable(_$AppDatabase db) => db.rounds.createAlias(
    $_aliasNameGenerator(db.esopPools.roundId, db.rounds.id),
  );

  $$RoundsTableProcessedTableManager? get roundId {
    final $_column = $_itemColumn<String>('round_id');
    if ($_column == null) return null;
    final manager = $$RoundsTableTableManager(
      $_db,
      $_db.rounds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roundIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EsopPoolExpansionsTable, List<EsopPoolExpansion>>
  _esopPoolExpansionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.esopPoolExpansions,
        aliasName: $_aliasNameGenerator(
          db.esopPools.id,
          db.esopPoolExpansions.poolId,
        ),
      );

  $$EsopPoolExpansionsTableProcessedTableManager get esopPoolExpansionsRefs {
    final manager = $$EsopPoolExpansionsTableTableManager(
      $_db,
      $_db.esopPoolExpansions,
    ).filter((f) => f.poolId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _esopPoolExpansionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EsopPoolsTableFilterComposer
    extends Composer<_$AppDatabase, $EsopPoolsTable> {
  $$EsopPoolsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get poolSize => $composableBuilder(
    column: $table.poolSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetPercentage => $composableBuilder(
    column: $table.targetPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get establishedDate => $composableBuilder(
    column: $table.establishedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolutionReference => $composableBuilder(
    column: $table.resolutionReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultVestingScheduleId => $composableBuilder(
    column: $table.defaultVestingScheduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strikePriceMethod => $composableBuilder(
    column: $table.strikePriceMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultStrikePrice => $composableBuilder(
    column: $table.defaultStrikePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultExpiryYears => $composableBuilder(
    column: $table.defaultExpiryYears,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundsTableFilterComposer get roundId {
    final $$RoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableFilterComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> esopPoolExpansionsRefs(
    Expression<bool> Function($$EsopPoolExpansionsTableFilterComposer f) f,
  ) {
    final $$EsopPoolExpansionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.esopPoolExpansions,
      getReferencedColumn: (t) => t.poolId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EsopPoolExpansionsTableFilterComposer(
            $db: $db,
            $table: $db.esopPoolExpansions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EsopPoolsTableOrderingComposer
    extends Composer<_$AppDatabase, $EsopPoolsTable> {
  $$EsopPoolsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get poolSize => $composableBuilder(
    column: $table.poolSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetPercentage => $composableBuilder(
    column: $table.targetPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get establishedDate => $composableBuilder(
    column: $table.establishedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolutionReference => $composableBuilder(
    column: $table.resolutionReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultVestingScheduleId => $composableBuilder(
    column: $table.defaultVestingScheduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strikePriceMethod => $composableBuilder(
    column: $table.strikePriceMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultStrikePrice => $composableBuilder(
    column: $table.defaultStrikePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultExpiryYears => $composableBuilder(
    column: $table.defaultExpiryYears,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundsTableOrderingComposer get roundId {
    final $$RoundsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableOrderingComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EsopPoolsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EsopPoolsTable> {
  $$EsopPoolsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get poolSize =>
      $composableBuilder(column: $table.poolSize, builder: (column) => column);

  GeneratedColumn<double> get targetPercentage => $composableBuilder(
    column: $table.targetPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get establishedDate => $composableBuilder(
    column: $table.establishedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolutionReference => $composableBuilder(
    column: $table.resolutionReference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultVestingScheduleId => $composableBuilder(
    column: $table.defaultVestingScheduleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get strikePriceMethod => $composableBuilder(
    column: $table.strikePriceMethod,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultStrikePrice => $composableBuilder(
    column: $table.defaultStrikePrice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultExpiryYears => $composableBuilder(
    column: $table.defaultExpiryYears,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundsTableAnnotationComposer get roundId {
    final $$RoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> esopPoolExpansionsRefs<T extends Object>(
    Expression<T> Function($$EsopPoolExpansionsTableAnnotationComposer a) f,
  ) {
    final $$EsopPoolExpansionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.esopPoolExpansions,
          getReferencedColumn: (t) => t.poolId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EsopPoolExpansionsTableAnnotationComposer(
                $db: $db,
                $table: $db.esopPoolExpansions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$EsopPoolsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EsopPoolsTable,
          EsopPool,
          $$EsopPoolsTableFilterComposer,
          $$EsopPoolsTableOrderingComposer,
          $$EsopPoolsTableAnnotationComposer,
          $$EsopPoolsTableCreateCompanionBuilder,
          $$EsopPoolsTableUpdateCompanionBuilder,
          (EsopPool, $$EsopPoolsTableReferences),
          EsopPool,
          PrefetchHooks Function({
            bool companyId,
            bool roundId,
            bool esopPoolExpansionsRefs,
          })
        > {
  $$EsopPoolsTableTableManager(_$AppDatabase db, $EsopPoolsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EsopPoolsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EsopPoolsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EsopPoolsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> poolSize = const Value.absent(),
                Value<double?> targetPercentage = const Value.absent(),
                Value<DateTime> establishedDate = const Value.absent(),
                Value<String?> resolutionReference = const Value.absent(),
                Value<String?> roundId = const Value.absent(),
                Value<String?> defaultVestingScheduleId = const Value.absent(),
                Value<String> strikePriceMethod = const Value.absent(),
                Value<double?> defaultStrikePrice = const Value.absent(),
                Value<int> defaultExpiryYears = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EsopPoolsCompanion(
                id: id,
                companyId: companyId,
                name: name,
                status: status,
                poolSize: poolSize,
                targetPercentage: targetPercentage,
                establishedDate: establishedDate,
                resolutionReference: resolutionReference,
                roundId: roundId,
                defaultVestingScheduleId: defaultVestingScheduleId,
                strikePriceMethod: strikePriceMethod,
                defaultStrikePrice: defaultStrikePrice,
                defaultExpiryYears: defaultExpiryYears,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String name,
                Value<String> status = const Value.absent(),
                required int poolSize,
                Value<double?> targetPercentage = const Value.absent(),
                required DateTime establishedDate,
                Value<String?> resolutionReference = const Value.absent(),
                Value<String?> roundId = const Value.absent(),
                Value<String?> defaultVestingScheduleId = const Value.absent(),
                Value<String> strikePriceMethod = const Value.absent(),
                Value<double?> defaultStrikePrice = const Value.absent(),
                Value<int> defaultExpiryYears = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => EsopPoolsCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                status: status,
                poolSize: poolSize,
                targetPercentage: targetPercentage,
                establishedDate: establishedDate,
                resolutionReference: resolutionReference,
                roundId: roundId,
                defaultVestingScheduleId: defaultVestingScheduleId,
                strikePriceMethod: strikePriceMethod,
                defaultStrikePrice: defaultStrikePrice,
                defaultExpiryYears: defaultExpiryYears,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EsopPoolsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                companyId = false,
                roundId = false,
                esopPoolExpansionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (esopPoolExpansionsRefs) db.esopPoolExpansions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable: $$EsopPoolsTableReferences
                                        ._companyIdTable(db),
                                    referencedColumn: $$EsopPoolsTableReferences
                                        ._companyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (roundId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.roundId,
                                    referencedTable: $$EsopPoolsTableReferences
                                        ._roundIdTable(db),
                                    referencedColumn: $$EsopPoolsTableReferences
                                        ._roundIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (esopPoolExpansionsRefs)
                        await $_getPrefetchedData<
                          EsopPool,
                          $EsopPoolsTable,
                          EsopPoolExpansion
                        >(
                          currentTable: table,
                          referencedTable: $$EsopPoolsTableReferences
                              ._esopPoolExpansionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EsopPoolsTableReferences(
                                db,
                                table,
                                p0,
                              ).esopPoolExpansionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.poolId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EsopPoolsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EsopPoolsTable,
      EsopPool,
      $$EsopPoolsTableFilterComposer,
      $$EsopPoolsTableOrderingComposer,
      $$EsopPoolsTableAnnotationComposer,
      $$EsopPoolsTableCreateCompanionBuilder,
      $$EsopPoolsTableUpdateCompanionBuilder,
      (EsopPool, $$EsopPoolsTableReferences),
      EsopPool,
      PrefetchHooks Function({
        bool companyId,
        bool roundId,
        bool esopPoolExpansionsRefs,
      })
    >;
typedef $$OptionGrantsTableCreateCompanionBuilder =
    OptionGrantsCompanion Function({
      required String id,
      required String companyId,
      required String stakeholderId,
      required String shareClassId,
      Value<String?> esopPoolId,
      Value<String> status,
      required int quantity,
      required double strikePrice,
      required DateTime grantDate,
      required DateTime expiryDate,
      Value<int> exercisedCount,
      Value<int> cancelledCount,
      Value<String?> vestingScheduleId,
      Value<String?> roundId,
      Value<bool> allowsEarlyExercise,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$OptionGrantsTableUpdateCompanionBuilder =
    OptionGrantsCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> stakeholderId,
      Value<String> shareClassId,
      Value<String?> esopPoolId,
      Value<String> status,
      Value<int> quantity,
      Value<double> strikePrice,
      Value<DateTime> grantDate,
      Value<DateTime> expiryDate,
      Value<int> exercisedCount,
      Value<int> cancelledCount,
      Value<String?> vestingScheduleId,
      Value<String?> roundId,
      Value<bool> allowsEarlyExercise,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$OptionGrantsTableReferences
    extends BaseReferences<_$AppDatabase, $OptionGrantsTable, OptionGrant> {
  $$OptionGrantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.optionGrants.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StakeholdersTable _stakeholderIdTable(_$AppDatabase db) =>
      db.stakeholders.createAlias(
        $_aliasNameGenerator(db.optionGrants.stakeholderId, db.stakeholders.id),
      );

  $$StakeholdersTableProcessedTableManager get stakeholderId {
    final $_column = $_itemColumn<String>('stakeholder_id')!;

    final manager = $$StakeholdersTableTableManager(
      $_db,
      $_db.stakeholders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stakeholderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ShareClassesTable _shareClassIdTable(_$AppDatabase db) =>
      db.shareClasses.createAlias(
        $_aliasNameGenerator(db.optionGrants.shareClassId, db.shareClasses.id),
      );

  $$ShareClassesTableProcessedTableManager get shareClassId {
    final $_column = $_itemColumn<String>('share_class_id')!;

    final manager = $$ShareClassesTableTableManager(
      $_db,
      $_db.shareClasses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shareClassIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RoundsTable _roundIdTable(_$AppDatabase db) => db.rounds.createAlias(
    $_aliasNameGenerator(db.optionGrants.roundId, db.rounds.id),
  );

  $$RoundsTableProcessedTableManager? get roundId {
    final $_column = $_itemColumn<String>('round_id');
    if ($_column == null) return null;
    final manager = $$RoundsTableTableManager(
      $_db,
      $_db.rounds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roundIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OptionGrantsTableFilterComposer
    extends Composer<_$AppDatabase, $OptionGrantsTable> {
  $$OptionGrantsTableFilterComposer({
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

  ColumnFilters<String> get esopPoolId => $composableBuilder(
    column: $table.esopPoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get strikePrice => $composableBuilder(
    column: $table.strikePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get grantDate => $composableBuilder(
    column: $table.grantDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exercisedCount => $composableBuilder(
    column: $table.exercisedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cancelledCount => $composableBuilder(
    column: $table.cancelledCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vestingScheduleId => $composableBuilder(
    column: $table.vestingScheduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowsEarlyExercise => $composableBuilder(
    column: $table.allowsEarlyExercise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableFilterComposer get stakeholderId {
    final $$StakeholdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableFilterComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShareClassesTableFilterComposer get shareClassId {
    final $$ShareClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shareClassId,
      referencedTable: $db.shareClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareClassesTableFilterComposer(
            $db: $db,
            $table: $db.shareClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundsTableFilterComposer get roundId {
    final $$RoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableFilterComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OptionGrantsTableOrderingComposer
    extends Composer<_$AppDatabase, $OptionGrantsTable> {
  $$OptionGrantsTableOrderingComposer({
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

  ColumnOrderings<String> get esopPoolId => $composableBuilder(
    column: $table.esopPoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get strikePrice => $composableBuilder(
    column: $table.strikePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get grantDate => $composableBuilder(
    column: $table.grantDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exercisedCount => $composableBuilder(
    column: $table.exercisedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cancelledCount => $composableBuilder(
    column: $table.cancelledCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vestingScheduleId => $composableBuilder(
    column: $table.vestingScheduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowsEarlyExercise => $composableBuilder(
    column: $table.allowsEarlyExercise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableOrderingComposer get stakeholderId {
    final $$StakeholdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableOrderingComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShareClassesTableOrderingComposer get shareClassId {
    final $$ShareClassesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shareClassId,
      referencedTable: $db.shareClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareClassesTableOrderingComposer(
            $db: $db,
            $table: $db.shareClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundsTableOrderingComposer get roundId {
    final $$RoundsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableOrderingComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OptionGrantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OptionGrantsTable> {
  $$OptionGrantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get esopPoolId => $composableBuilder(
    column: $table.esopPoolId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get strikePrice => $composableBuilder(
    column: $table.strikePrice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get grantDate =>
      $composableBuilder(column: $table.grantDate, builder: (column) => column);

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get exercisedCount => $composableBuilder(
    column: $table.exercisedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cancelledCount => $composableBuilder(
    column: $table.cancelledCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vestingScheduleId => $composableBuilder(
    column: $table.vestingScheduleId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowsEarlyExercise => $composableBuilder(
    column: $table.allowsEarlyExercise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableAnnotationComposer get stakeholderId {
    final $$StakeholdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableAnnotationComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShareClassesTableAnnotationComposer get shareClassId {
    final $$ShareClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shareClassId,
      referencedTable: $db.shareClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.shareClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundsTableAnnotationComposer get roundId {
    final $$RoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OptionGrantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OptionGrantsTable,
          OptionGrant,
          $$OptionGrantsTableFilterComposer,
          $$OptionGrantsTableOrderingComposer,
          $$OptionGrantsTableAnnotationComposer,
          $$OptionGrantsTableCreateCompanionBuilder,
          $$OptionGrantsTableUpdateCompanionBuilder,
          (OptionGrant, $$OptionGrantsTableReferences),
          OptionGrant,
          PrefetchHooks Function({
            bool companyId,
            bool stakeholderId,
            bool shareClassId,
            bool roundId,
          })
        > {
  $$OptionGrantsTableTableManager(_$AppDatabase db, $OptionGrantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OptionGrantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OptionGrantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OptionGrantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> stakeholderId = const Value.absent(),
                Value<String> shareClassId = const Value.absent(),
                Value<String?> esopPoolId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> strikePrice = const Value.absent(),
                Value<DateTime> grantDate = const Value.absent(),
                Value<DateTime> expiryDate = const Value.absent(),
                Value<int> exercisedCount = const Value.absent(),
                Value<int> cancelledCount = const Value.absent(),
                Value<String?> vestingScheduleId = const Value.absent(),
                Value<String?> roundId = const Value.absent(),
                Value<bool> allowsEarlyExercise = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OptionGrantsCompanion(
                id: id,
                companyId: companyId,
                stakeholderId: stakeholderId,
                shareClassId: shareClassId,
                esopPoolId: esopPoolId,
                status: status,
                quantity: quantity,
                strikePrice: strikePrice,
                grantDate: grantDate,
                expiryDate: expiryDate,
                exercisedCount: exercisedCount,
                cancelledCount: cancelledCount,
                vestingScheduleId: vestingScheduleId,
                roundId: roundId,
                allowsEarlyExercise: allowsEarlyExercise,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String stakeholderId,
                required String shareClassId,
                Value<String?> esopPoolId = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int quantity,
                required double strikePrice,
                required DateTime grantDate,
                required DateTime expiryDate,
                Value<int> exercisedCount = const Value.absent(),
                Value<int> cancelledCount = const Value.absent(),
                Value<String?> vestingScheduleId = const Value.absent(),
                Value<String?> roundId = const Value.absent(),
                Value<bool> allowsEarlyExercise = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => OptionGrantsCompanion.insert(
                id: id,
                companyId: companyId,
                stakeholderId: stakeholderId,
                shareClassId: shareClassId,
                esopPoolId: esopPoolId,
                status: status,
                quantity: quantity,
                strikePrice: strikePrice,
                grantDate: grantDate,
                expiryDate: expiryDate,
                exercisedCount: exercisedCount,
                cancelledCount: cancelledCount,
                vestingScheduleId: vestingScheduleId,
                roundId: roundId,
                allowsEarlyExercise: allowsEarlyExercise,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OptionGrantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                companyId = false,
                stakeholderId = false,
                shareClassId = false,
                roundId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable:
                                        $$OptionGrantsTableReferences
                                            ._companyIdTable(db),
                                    referencedColumn:
                                        $$OptionGrantsTableReferences
                                            ._companyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (stakeholderId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.stakeholderId,
                                    referencedTable:
                                        $$OptionGrantsTableReferences
                                            ._stakeholderIdTable(db),
                                    referencedColumn:
                                        $$OptionGrantsTableReferences
                                            ._stakeholderIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (shareClassId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shareClassId,
                                    referencedTable:
                                        $$OptionGrantsTableReferences
                                            ._shareClassIdTable(db),
                                    referencedColumn:
                                        $$OptionGrantsTableReferences
                                            ._shareClassIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (roundId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.roundId,
                                    referencedTable:
                                        $$OptionGrantsTableReferences
                                            ._roundIdTable(db),
                                    referencedColumn:
                                        $$OptionGrantsTableReferences
                                            ._roundIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$OptionGrantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OptionGrantsTable,
      OptionGrant,
      $$OptionGrantsTableFilterComposer,
      $$OptionGrantsTableOrderingComposer,
      $$OptionGrantsTableAnnotationComposer,
      $$OptionGrantsTableCreateCompanionBuilder,
      $$OptionGrantsTableUpdateCompanionBuilder,
      (OptionGrant, $$OptionGrantsTableReferences),
      OptionGrant,
      PrefetchHooks Function({
        bool companyId,
        bool stakeholderId,
        bool shareClassId,
        bool roundId,
      })
    >;
typedef $$WarrantsTableCreateCompanionBuilder =
    WarrantsCompanion Function({
      required String id,
      required String companyId,
      required String stakeholderId,
      required String shareClassId,
      Value<String> status,
      required int quantity,
      required double strikePrice,
      required DateTime issueDate,
      required DateTime expiryDate,
      Value<int> exercisedCount,
      Value<int> cancelledCount,
      Value<String?> sourceConvertibleId,
      Value<String?> roundId,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$WarrantsTableUpdateCompanionBuilder =
    WarrantsCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> stakeholderId,
      Value<String> shareClassId,
      Value<String> status,
      Value<int> quantity,
      Value<double> strikePrice,
      Value<DateTime> issueDate,
      Value<DateTime> expiryDate,
      Value<int> exercisedCount,
      Value<int> cancelledCount,
      Value<String?> sourceConvertibleId,
      Value<String?> roundId,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$WarrantsTableReferences
    extends BaseReferences<_$AppDatabase, $WarrantsTable, Warrant> {
  $$WarrantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.warrants.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StakeholdersTable _stakeholderIdTable(_$AppDatabase db) =>
      db.stakeholders.createAlias(
        $_aliasNameGenerator(db.warrants.stakeholderId, db.stakeholders.id),
      );

  $$StakeholdersTableProcessedTableManager get stakeholderId {
    final $_column = $_itemColumn<String>('stakeholder_id')!;

    final manager = $$StakeholdersTableTableManager(
      $_db,
      $_db.stakeholders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stakeholderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ShareClassesTable _shareClassIdTable(_$AppDatabase db) =>
      db.shareClasses.createAlias(
        $_aliasNameGenerator(db.warrants.shareClassId, db.shareClasses.id),
      );

  $$ShareClassesTableProcessedTableManager get shareClassId {
    final $_column = $_itemColumn<String>('share_class_id')!;

    final manager = $$ShareClassesTableTableManager(
      $_db,
      $_db.shareClasses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shareClassIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ConvertiblesTable _sourceConvertibleIdTable(_$AppDatabase db) =>
      db.convertibles.createAlias(
        $_aliasNameGenerator(
          db.warrants.sourceConvertibleId,
          db.convertibles.id,
        ),
      );

  $$ConvertiblesTableProcessedTableManager? get sourceConvertibleId {
    final $_column = $_itemColumn<String>('source_convertible_id');
    if ($_column == null) return null;
    final manager = $$ConvertiblesTableTableManager(
      $_db,
      $_db.convertibles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceConvertibleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RoundsTable _roundIdTable(_$AppDatabase db) => db.rounds.createAlias(
    $_aliasNameGenerator(db.warrants.roundId, db.rounds.id),
  );

  $$RoundsTableProcessedTableManager? get roundId {
    final $_column = $_itemColumn<String>('round_id');
    if ($_column == null) return null;
    final manager = $$RoundsTableTableManager(
      $_db,
      $_db.rounds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roundIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WarrantsTableFilterComposer
    extends Composer<_$AppDatabase, $WarrantsTable> {
  $$WarrantsTableFilterComposer({
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get strikePrice => $composableBuilder(
    column: $table.strikePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exercisedCount => $composableBuilder(
    column: $table.exercisedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cancelledCount => $composableBuilder(
    column: $table.cancelledCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableFilterComposer get stakeholderId {
    final $$StakeholdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableFilterComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShareClassesTableFilterComposer get shareClassId {
    final $$ShareClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shareClassId,
      referencedTable: $db.shareClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareClassesTableFilterComposer(
            $db: $db,
            $table: $db.shareClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConvertiblesTableFilterComposer get sourceConvertibleId {
    final $$ConvertiblesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceConvertibleId,
      referencedTable: $db.convertibles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConvertiblesTableFilterComposer(
            $db: $db,
            $table: $db.convertibles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundsTableFilterComposer get roundId {
    final $$RoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableFilterComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WarrantsTableOrderingComposer
    extends Composer<_$AppDatabase, $WarrantsTable> {
  $$WarrantsTableOrderingComposer({
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get strikePrice => $composableBuilder(
    column: $table.strikePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get issueDate => $composableBuilder(
    column: $table.issueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exercisedCount => $composableBuilder(
    column: $table.exercisedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cancelledCount => $composableBuilder(
    column: $table.cancelledCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableOrderingComposer get stakeholderId {
    final $$StakeholdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableOrderingComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShareClassesTableOrderingComposer get shareClassId {
    final $$ShareClassesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shareClassId,
      referencedTable: $db.shareClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareClassesTableOrderingComposer(
            $db: $db,
            $table: $db.shareClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConvertiblesTableOrderingComposer get sourceConvertibleId {
    final $$ConvertiblesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceConvertibleId,
      referencedTable: $db.convertibles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConvertiblesTableOrderingComposer(
            $db: $db,
            $table: $db.convertibles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundsTableOrderingComposer get roundId {
    final $$RoundsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableOrderingComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WarrantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WarrantsTable> {
  $$WarrantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get strikePrice => $composableBuilder(
    column: $table.strikePrice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get issueDate =>
      $composableBuilder(column: $table.issueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get exercisedCount => $composableBuilder(
    column: $table.exercisedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cancelledCount => $composableBuilder(
    column: $table.cancelledCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableAnnotationComposer get stakeholderId {
    final $$StakeholdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableAnnotationComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShareClassesTableAnnotationComposer get shareClassId {
    final $$ShareClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shareClassId,
      referencedTable: $db.shareClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.shareClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConvertiblesTableAnnotationComposer get sourceConvertibleId {
    final $$ConvertiblesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceConvertibleId,
      referencedTable: $db.convertibles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConvertiblesTableAnnotationComposer(
            $db: $db,
            $table: $db.convertibles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoundsTableAnnotationComposer get roundId {
    final $$RoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WarrantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WarrantsTable,
          Warrant,
          $$WarrantsTableFilterComposer,
          $$WarrantsTableOrderingComposer,
          $$WarrantsTableAnnotationComposer,
          $$WarrantsTableCreateCompanionBuilder,
          $$WarrantsTableUpdateCompanionBuilder,
          (Warrant, $$WarrantsTableReferences),
          Warrant,
          PrefetchHooks Function({
            bool companyId,
            bool stakeholderId,
            bool shareClassId,
            bool sourceConvertibleId,
            bool roundId,
          })
        > {
  $$WarrantsTableTableManager(_$AppDatabase db, $WarrantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WarrantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WarrantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WarrantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> stakeholderId = const Value.absent(),
                Value<String> shareClassId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> strikePrice = const Value.absent(),
                Value<DateTime> issueDate = const Value.absent(),
                Value<DateTime> expiryDate = const Value.absent(),
                Value<int> exercisedCount = const Value.absent(),
                Value<int> cancelledCount = const Value.absent(),
                Value<String?> sourceConvertibleId = const Value.absent(),
                Value<String?> roundId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WarrantsCompanion(
                id: id,
                companyId: companyId,
                stakeholderId: stakeholderId,
                shareClassId: shareClassId,
                status: status,
                quantity: quantity,
                strikePrice: strikePrice,
                issueDate: issueDate,
                expiryDate: expiryDate,
                exercisedCount: exercisedCount,
                cancelledCount: cancelledCount,
                sourceConvertibleId: sourceConvertibleId,
                roundId: roundId,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String stakeholderId,
                required String shareClassId,
                Value<String> status = const Value.absent(),
                required int quantity,
                required double strikePrice,
                required DateTime issueDate,
                required DateTime expiryDate,
                Value<int> exercisedCount = const Value.absent(),
                Value<int> cancelledCount = const Value.absent(),
                Value<String?> sourceConvertibleId = const Value.absent(),
                Value<String?> roundId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => WarrantsCompanion.insert(
                id: id,
                companyId: companyId,
                stakeholderId: stakeholderId,
                shareClassId: shareClassId,
                status: status,
                quantity: quantity,
                strikePrice: strikePrice,
                issueDate: issueDate,
                expiryDate: expiryDate,
                exercisedCount: exercisedCount,
                cancelledCount: cancelledCount,
                sourceConvertibleId: sourceConvertibleId,
                roundId: roundId,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WarrantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                companyId = false,
                stakeholderId = false,
                shareClassId = false,
                sourceConvertibleId = false,
                roundId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable: $$WarrantsTableReferences
                                        ._companyIdTable(db),
                                    referencedColumn: $$WarrantsTableReferences
                                        ._companyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (stakeholderId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.stakeholderId,
                                    referencedTable: $$WarrantsTableReferences
                                        ._stakeholderIdTable(db),
                                    referencedColumn: $$WarrantsTableReferences
                                        ._stakeholderIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (shareClassId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shareClassId,
                                    referencedTable: $$WarrantsTableReferences
                                        ._shareClassIdTable(db),
                                    referencedColumn: $$WarrantsTableReferences
                                        ._shareClassIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (sourceConvertibleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceConvertibleId,
                                    referencedTable: $$WarrantsTableReferences
                                        ._sourceConvertibleIdTable(db),
                                    referencedColumn: $$WarrantsTableReferences
                                        ._sourceConvertibleIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (roundId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.roundId,
                                    referencedTable: $$WarrantsTableReferences
                                        ._roundIdTable(db),
                                    referencedColumn: $$WarrantsTableReferences
                                        ._roundIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$WarrantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WarrantsTable,
      Warrant,
      $$WarrantsTableFilterComposer,
      $$WarrantsTableOrderingComposer,
      $$WarrantsTableAnnotationComposer,
      $$WarrantsTableCreateCompanionBuilder,
      $$WarrantsTableUpdateCompanionBuilder,
      (Warrant, $$WarrantsTableReferences),
      Warrant,
      PrefetchHooks Function({
        bool companyId,
        bool stakeholderId,
        bool shareClassId,
        bool sourceConvertibleId,
        bool roundId,
      })
    >;
typedef $$VestingSchedulesTableCreateCompanionBuilder =
    VestingSchedulesCompanion Function({
      required String id,
      required String companyId,
      required String name,
      required String type,
      Value<int?> totalMonths,
      Value<int> cliffMonths,
      Value<String?> frequency,
      Value<String?> milestonesJson,
      Value<int?> totalHours,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$VestingSchedulesTableUpdateCompanionBuilder =
    VestingSchedulesCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> name,
      Value<String> type,
      Value<int?> totalMonths,
      Value<int> cliffMonths,
      Value<String?> frequency,
      Value<String?> milestonesJson,
      Value<int?> totalHours,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$VestingSchedulesTableReferences
    extends
        BaseReferences<_$AppDatabase, $VestingSchedulesTable, VestingSchedule> {
  $$VestingSchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.vestingSchedules.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VestingSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $VestingSchedulesTable> {
  $$VestingSchedulesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMonths => $composableBuilder(
    column: $table.totalMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cliffMonths => $composableBuilder(
    column: $table.cliffMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get milestonesJson => $composableBuilder(
    column: $table.milestonesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalHours => $composableBuilder(
    column: $table.totalHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VestingSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $VestingSchedulesTable> {
  $$VestingSchedulesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMonths => $composableBuilder(
    column: $table.totalMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cliffMonths => $composableBuilder(
    column: $table.cliffMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get milestonesJson => $composableBuilder(
    column: $table.milestonesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalHours => $composableBuilder(
    column: $table.totalHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VestingSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VestingSchedulesTable> {
  $$VestingSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get totalMonths => $composableBuilder(
    column: $table.totalMonths,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cliffMonths => $composableBuilder(
    column: $table.cliffMonths,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get milestonesJson => $composableBuilder(
    column: $table.milestonesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalHours => $composableBuilder(
    column: $table.totalHours,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VestingSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VestingSchedulesTable,
          VestingSchedule,
          $$VestingSchedulesTableFilterComposer,
          $$VestingSchedulesTableOrderingComposer,
          $$VestingSchedulesTableAnnotationComposer,
          $$VestingSchedulesTableCreateCompanionBuilder,
          $$VestingSchedulesTableUpdateCompanionBuilder,
          (VestingSchedule, $$VestingSchedulesTableReferences),
          VestingSchedule,
          PrefetchHooks Function({bool companyId})
        > {
  $$VestingSchedulesTableTableManager(
    _$AppDatabase db,
    $VestingSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VestingSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VestingSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VestingSchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> totalMonths = const Value.absent(),
                Value<int> cliffMonths = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
                Value<String?> milestonesJson = const Value.absent(),
                Value<int?> totalHours = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VestingSchedulesCompanion(
                id: id,
                companyId: companyId,
                name: name,
                type: type,
                totalMonths: totalMonths,
                cliffMonths: cliffMonths,
                frequency: frequency,
                milestonesJson: milestonesJson,
                totalHours: totalHours,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String name,
                required String type,
                Value<int?> totalMonths = const Value.absent(),
                Value<int> cliffMonths = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
                Value<String?> milestonesJson = const Value.absent(),
                Value<int?> totalHours = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => VestingSchedulesCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                type: type,
                totalMonths: totalMonths,
                cliffMonths: cliffMonths,
                frequency: frequency,
                milestonesJson: milestonesJson,
                totalHours: totalHours,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VestingSchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable:
                                    $$VestingSchedulesTableReferences
                                        ._companyIdTable(db),
                                referencedColumn:
                                    $$VestingSchedulesTableReferences
                                        ._companyIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VestingSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VestingSchedulesTable,
      VestingSchedule,
      $$VestingSchedulesTableFilterComposer,
      $$VestingSchedulesTableOrderingComposer,
      $$VestingSchedulesTableAnnotationComposer,
      $$VestingSchedulesTableCreateCompanionBuilder,
      $$VestingSchedulesTableUpdateCompanionBuilder,
      (VestingSchedule, $$VestingSchedulesTableReferences),
      VestingSchedule,
      PrefetchHooks Function({bool companyId})
    >;
typedef $$ValuationsTableCreateCompanionBuilder =
    ValuationsCompanion Function({
      required String id,
      required String companyId,
      required DateTime date,
      required double preMoneyValue,
      required String method,
      Value<String?> methodParamsJson,
      Value<String?> notes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ValuationsTableUpdateCompanionBuilder =
    ValuationsCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<DateTime> date,
      Value<double> preMoneyValue,
      Value<String> method,
      Value<String?> methodParamsJson,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ValuationsTableReferences
    extends BaseReferences<_$AppDatabase, $ValuationsTable, Valuation> {
  $$ValuationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.valuations.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ValuationsTableFilterComposer
    extends Composer<_$AppDatabase, $ValuationsTable> {
  $$ValuationsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get preMoneyValue => $composableBuilder(
    column: $table.preMoneyValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get methodParamsJson => $composableBuilder(
    column: $table.methodParamsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ValuationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ValuationsTable> {
  $$ValuationsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get preMoneyValue => $composableBuilder(
    column: $table.preMoneyValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get methodParamsJson => $composableBuilder(
    column: $table.methodParamsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ValuationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ValuationsTable> {
  $$ValuationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get preMoneyValue => $composableBuilder(
    column: $table.preMoneyValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get methodParamsJson => $composableBuilder(
    column: $table.methodParamsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ValuationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ValuationsTable,
          Valuation,
          $$ValuationsTableFilterComposer,
          $$ValuationsTableOrderingComposer,
          $$ValuationsTableAnnotationComposer,
          $$ValuationsTableCreateCompanionBuilder,
          $$ValuationsTableUpdateCompanionBuilder,
          (Valuation, $$ValuationsTableReferences),
          Valuation,
          PrefetchHooks Function({bool companyId})
        > {
  $$ValuationsTableTableManager(_$AppDatabase db, $ValuationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ValuationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ValuationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ValuationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> preMoneyValue = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<String?> methodParamsJson = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ValuationsCompanion(
                id: id,
                companyId: companyId,
                date: date,
                preMoneyValue: preMoneyValue,
                method: method,
                methodParamsJson: methodParamsJson,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required DateTime date,
                required double preMoneyValue,
                required String method,
                Value<String?> methodParamsJson = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ValuationsCompanion.insert(
                id: id,
                companyId: companyId,
                date: date,
                preMoneyValue: preMoneyValue,
                method: method,
                methodParamsJson: methodParamsJson,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ValuationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable: $$ValuationsTableReferences
                                    ._companyIdTable(db),
                                referencedColumn: $$ValuationsTableReferences
                                    ._companyIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ValuationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ValuationsTable,
      Valuation,
      $$ValuationsTableFilterComposer,
      $$ValuationsTableOrderingComposer,
      $$ValuationsTableAnnotationComposer,
      $$ValuationsTableCreateCompanionBuilder,
      $$ValuationsTableUpdateCompanionBuilder,
      (Valuation, $$ValuationsTableReferences),
      Valuation,
      PrefetchHooks Function({bool companyId})
    >;
typedef $$CapitalizationEventsTableCreateCompanionBuilder =
    CapitalizationEventsCompanion Function({
      required String id,
      required String companyId,
      required int sequenceNumber,
      required String eventType,
      required String eventDataJson,
      required DateTime timestamp,
      Value<String?> actorId,
      Value<String?> signature,
      Value<int> rowid,
    });
typedef $$CapitalizationEventsTableUpdateCompanionBuilder =
    CapitalizationEventsCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<int> sequenceNumber,
      Value<String> eventType,
      Value<String> eventDataJson,
      Value<DateTime> timestamp,
      Value<String?> actorId,
      Value<String?> signature,
      Value<int> rowid,
    });

final class $$CapitalizationEventsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CapitalizationEventsTable,
          CapitalizationEvent
        > {
  $$CapitalizationEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(
          db.capitalizationEvents.companyId,
          db.companies.id,
        ),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CapitalizationEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CapitalizationEventsTable> {
  $$CapitalizationEventsTableFilterComposer({
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

  ColumnFilters<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventDataJson => $composableBuilder(
    column: $table.eventDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CapitalizationEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CapitalizationEventsTable> {
  $$CapitalizationEventsTableOrderingComposer({
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

  ColumnOrderings<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventDataJson => $composableBuilder(
    column: $table.eventDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signature => $composableBuilder(
    column: $table.signature,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CapitalizationEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CapitalizationEventsTable> {
  $$CapitalizationEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get eventDataJson => $composableBuilder(
    column: $table.eventDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get signature =>
      $composableBuilder(column: $table.signature, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CapitalizationEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CapitalizationEventsTable,
          CapitalizationEvent,
          $$CapitalizationEventsTableFilterComposer,
          $$CapitalizationEventsTableOrderingComposer,
          $$CapitalizationEventsTableAnnotationComposer,
          $$CapitalizationEventsTableCreateCompanionBuilder,
          $$CapitalizationEventsTableUpdateCompanionBuilder,
          (CapitalizationEvent, $$CapitalizationEventsTableReferences),
          CapitalizationEvent,
          PrefetchHooks Function({bool companyId})
        > {
  $$CapitalizationEventsTableTableManager(
    _$AppDatabase db,
    $CapitalizationEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CapitalizationEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CapitalizationEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CapitalizationEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<int> sequenceNumber = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> eventDataJson = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> actorId = const Value.absent(),
                Value<String?> signature = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CapitalizationEventsCompanion(
                id: id,
                companyId: companyId,
                sequenceNumber: sequenceNumber,
                eventType: eventType,
                eventDataJson: eventDataJson,
                timestamp: timestamp,
                actorId: actorId,
                signature: signature,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required int sequenceNumber,
                required String eventType,
                required String eventDataJson,
                required DateTime timestamp,
                Value<String?> actorId = const Value.absent(),
                Value<String?> signature = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CapitalizationEventsCompanion.insert(
                id: id,
                companyId: companyId,
                sequenceNumber: sequenceNumber,
                eventType: eventType,
                eventDataJson: eventDataJson,
                timestamp: timestamp,
                actorId: actorId,
                signature: signature,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CapitalizationEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable:
                                    $$CapitalizationEventsTableReferences
                                        ._companyIdTable(db),
                                referencedColumn:
                                    $$CapitalizationEventsTableReferences
                                        ._companyIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CapitalizationEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CapitalizationEventsTable,
      CapitalizationEvent,
      $$CapitalizationEventsTableFilterComposer,
      $$CapitalizationEventsTableOrderingComposer,
      $$CapitalizationEventsTableAnnotationComposer,
      $$CapitalizationEventsTableCreateCompanionBuilder,
      $$CapitalizationEventsTableUpdateCompanionBuilder,
      (CapitalizationEvent, $$CapitalizationEventsTableReferences),
      CapitalizationEvent,
      PrefetchHooks Function({bool companyId})
    >;
typedef $$SavedScenariosTableCreateCompanionBuilder =
    SavedScenariosCompanion Function({
      required String id,
      required String companyId,
      required String name,
      required String type,
      required String parametersJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SavedScenariosTableUpdateCompanionBuilder =
    SavedScenariosCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> name,
      Value<String> type,
      Value<String> parametersJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SavedScenariosTableReferences
    extends BaseReferences<_$AppDatabase, $SavedScenariosTable, SavedScenario> {
  $$SavedScenariosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.savedScenarios.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SavedScenariosTableFilterComposer
    extends Composer<_$AppDatabase, $SavedScenariosTable> {
  $$SavedScenariosTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parametersJson => $composableBuilder(
    column: $table.parametersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedScenariosTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedScenariosTable> {
  $$SavedScenariosTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parametersJson => $composableBuilder(
    column: $table.parametersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedScenariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedScenariosTable> {
  $$SavedScenariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get parametersJson => $composableBuilder(
    column: $table.parametersJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedScenariosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedScenariosTable,
          SavedScenario,
          $$SavedScenariosTableFilterComposer,
          $$SavedScenariosTableOrderingComposer,
          $$SavedScenariosTableAnnotationComposer,
          $$SavedScenariosTableCreateCompanionBuilder,
          $$SavedScenariosTableUpdateCompanionBuilder,
          (SavedScenario, $$SavedScenariosTableReferences),
          SavedScenario,
          PrefetchHooks Function({bool companyId})
        > {
  $$SavedScenariosTableTableManager(
    _$AppDatabase db,
    $SavedScenariosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedScenariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedScenariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedScenariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> parametersJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedScenariosCompanion(
                id: id,
                companyId: companyId,
                name: name,
                type: type,
                parametersJson: parametersJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String name,
                required String type,
                required String parametersJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SavedScenariosCompanion.insert(
                id: id,
                companyId: companyId,
                name: name,
                type: type,
                parametersJson: parametersJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavedScenariosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable: $$SavedScenariosTableReferences
                                    ._companyIdTable(db),
                                referencedColumn:
                                    $$SavedScenariosTableReferences
                                        ._companyIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SavedScenariosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedScenariosTable,
      SavedScenario,
      $$SavedScenariosTableFilterComposer,
      $$SavedScenariosTableOrderingComposer,
      $$SavedScenariosTableAnnotationComposer,
      $$SavedScenariosTableCreateCompanionBuilder,
      $$SavedScenariosTableUpdateCompanionBuilder,
      (SavedScenario, $$SavedScenariosTableReferences),
      SavedScenario,
      PrefetchHooks Function({bool companyId})
    >;
typedef $$TransfersTableCreateCompanionBuilder =
    TransfersCompanion Function({
      required String id,
      required String companyId,
      required String sellerStakeholderId,
      required String buyerStakeholderId,
      required String shareClassId,
      required int shareCount,
      required double pricePerShare,
      Value<double?> fairMarketValue,
      required DateTime transactionDate,
      required String type,
      Value<String> status,
      Value<bool> rofrWaived,
      Value<String?> sourceHoldingId,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TransfersTableUpdateCompanionBuilder =
    TransfersCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> sellerStakeholderId,
      Value<String> buyerStakeholderId,
      Value<String> shareClassId,
      Value<int> shareCount,
      Value<double> pricePerShare,
      Value<double?> fairMarketValue,
      Value<DateTime> transactionDate,
      Value<String> type,
      Value<String> status,
      Value<bool> rofrWaived,
      Value<String?> sourceHoldingId,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TransfersTableReferences
    extends BaseReferences<_$AppDatabase, $TransfersTable, Transfer> {
  $$TransfersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.transfers.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StakeholdersTable _sellerStakeholderIdTable(_$AppDatabase db) =>
      db.stakeholders.createAlias(
        $_aliasNameGenerator(
          db.transfers.sellerStakeholderId,
          db.stakeholders.id,
        ),
      );

  $$StakeholdersTableProcessedTableManager get sellerStakeholderId {
    final $_column = $_itemColumn<String>('seller_stakeholder_id')!;

    final manager = $$StakeholdersTableTableManager(
      $_db,
      $_db.stakeholders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sellerStakeholderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StakeholdersTable _buyerStakeholderIdTable(_$AppDatabase db) =>
      db.stakeholders.createAlias(
        $_aliasNameGenerator(
          db.transfers.buyerStakeholderId,
          db.stakeholders.id,
        ),
      );

  $$StakeholdersTableProcessedTableManager get buyerStakeholderId {
    final $_column = $_itemColumn<String>('buyer_stakeholder_id')!;

    final manager = $$StakeholdersTableTableManager(
      $_db,
      $_db.stakeholders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_buyerStakeholderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ShareClassesTable _shareClassIdTable(_$AppDatabase db) =>
      db.shareClasses.createAlias(
        $_aliasNameGenerator(db.transfers.shareClassId, db.shareClasses.id),
      );

  $$ShareClassesTableProcessedTableManager get shareClassId {
    final $_column = $_itemColumn<String>('share_class_id')!;

    final manager = $$ShareClassesTableTableManager(
      $_db,
      $_db.shareClasses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shareClassIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $HoldingsTable _sourceHoldingIdTable(_$AppDatabase db) =>
      db.holdings.createAlias(
        $_aliasNameGenerator(db.transfers.sourceHoldingId, db.holdings.id),
      );

  $$HoldingsTableProcessedTableManager? get sourceHoldingId {
    final $_column = $_itemColumn<String>('source_holding_id');
    if ($_column == null) return null;
    final manager = $$HoldingsTableTableManager(
      $_db,
      $_db.holdings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceHoldingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransfersTableFilterComposer
    extends Composer<_$AppDatabase, $TransfersTable> {
  $$TransfersTableFilterComposer({
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

  ColumnFilters<int> get shareCount => $composableBuilder(
    column: $table.shareCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePerShare => $composableBuilder(
    column: $table.pricePerShare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fairMarketValue => $composableBuilder(
    column: $table.fairMarketValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rofrWaived => $composableBuilder(
    column: $table.rofrWaived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableFilterComposer get sellerStakeholderId {
    final $$StakeholdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sellerStakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableFilterComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableFilterComposer get buyerStakeholderId {
    final $$StakeholdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buyerStakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableFilterComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShareClassesTableFilterComposer get shareClassId {
    final $$ShareClassesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shareClassId,
      referencedTable: $db.shareClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareClassesTableFilterComposer(
            $db: $db,
            $table: $db.shareClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HoldingsTableFilterComposer get sourceHoldingId {
    final $$HoldingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceHoldingId,
      referencedTable: $db.holdings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableFilterComposer(
            $db: $db,
            $table: $db.holdings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransfersTableOrderingComposer
    extends Composer<_$AppDatabase, $TransfersTable> {
  $$TransfersTableOrderingComposer({
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

  ColumnOrderings<int> get shareCount => $composableBuilder(
    column: $table.shareCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePerShare => $composableBuilder(
    column: $table.pricePerShare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fairMarketValue => $composableBuilder(
    column: $table.fairMarketValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rofrWaived => $composableBuilder(
    column: $table.rofrWaived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableOrderingComposer get sellerStakeholderId {
    final $$StakeholdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sellerStakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableOrderingComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableOrderingComposer get buyerStakeholderId {
    final $$StakeholdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buyerStakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableOrderingComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShareClassesTableOrderingComposer get shareClassId {
    final $$ShareClassesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shareClassId,
      referencedTable: $db.shareClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareClassesTableOrderingComposer(
            $db: $db,
            $table: $db.shareClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HoldingsTableOrderingComposer get sourceHoldingId {
    final $$HoldingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceHoldingId,
      referencedTable: $db.holdings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableOrderingComposer(
            $db: $db,
            $table: $db.holdings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransfersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransfersTable> {
  $$TransfersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get shareCount => $composableBuilder(
    column: $table.shareCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pricePerShare => $composableBuilder(
    column: $table.pricePerShare,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fairMarketValue => $composableBuilder(
    column: $table.fairMarketValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get rofrWaived => $composableBuilder(
    column: $table.rofrWaived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableAnnotationComposer get sellerStakeholderId {
    final $$StakeholdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sellerStakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableAnnotationComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StakeholdersTableAnnotationComposer get buyerStakeholderId {
    final $$StakeholdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buyerStakeholderId,
      referencedTable: $db.stakeholders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StakeholdersTableAnnotationComposer(
            $db: $db,
            $table: $db.stakeholders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShareClassesTableAnnotationComposer get shareClassId {
    final $$ShareClassesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shareClassId,
      referencedTable: $db.shareClasses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShareClassesTableAnnotationComposer(
            $db: $db,
            $table: $db.shareClasses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HoldingsTableAnnotationComposer get sourceHoldingId {
    final $$HoldingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceHoldingId,
      referencedTable: $db.holdings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HoldingsTableAnnotationComposer(
            $db: $db,
            $table: $db.holdings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransfersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransfersTable,
          Transfer,
          $$TransfersTableFilterComposer,
          $$TransfersTableOrderingComposer,
          $$TransfersTableAnnotationComposer,
          $$TransfersTableCreateCompanionBuilder,
          $$TransfersTableUpdateCompanionBuilder,
          (Transfer, $$TransfersTableReferences),
          Transfer,
          PrefetchHooks Function({
            bool companyId,
            bool sellerStakeholderId,
            bool buyerStakeholderId,
            bool shareClassId,
            bool sourceHoldingId,
          })
        > {
  $$TransfersTableTableManager(_$AppDatabase db, $TransfersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransfersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> sellerStakeholderId = const Value.absent(),
                Value<String> buyerStakeholderId = const Value.absent(),
                Value<String> shareClassId = const Value.absent(),
                Value<int> shareCount = const Value.absent(),
                Value<double> pricePerShare = const Value.absent(),
                Value<double?> fairMarketValue = const Value.absent(),
                Value<DateTime> transactionDate = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> rofrWaived = const Value.absent(),
                Value<String?> sourceHoldingId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransfersCompanion(
                id: id,
                companyId: companyId,
                sellerStakeholderId: sellerStakeholderId,
                buyerStakeholderId: buyerStakeholderId,
                shareClassId: shareClassId,
                shareCount: shareCount,
                pricePerShare: pricePerShare,
                fairMarketValue: fairMarketValue,
                transactionDate: transactionDate,
                type: type,
                status: status,
                rofrWaived: rofrWaived,
                sourceHoldingId: sourceHoldingId,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String sellerStakeholderId,
                required String buyerStakeholderId,
                required String shareClassId,
                required int shareCount,
                required double pricePerShare,
                Value<double?> fairMarketValue = const Value.absent(),
                required DateTime transactionDate,
                required String type,
                Value<String> status = const Value.absent(),
                Value<bool> rofrWaived = const Value.absent(),
                Value<String?> sourceHoldingId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TransfersCompanion.insert(
                id: id,
                companyId: companyId,
                sellerStakeholderId: sellerStakeholderId,
                buyerStakeholderId: buyerStakeholderId,
                shareClassId: shareClassId,
                shareCount: shareCount,
                pricePerShare: pricePerShare,
                fairMarketValue: fairMarketValue,
                transactionDate: transactionDate,
                type: type,
                status: status,
                rofrWaived: rofrWaived,
                sourceHoldingId: sourceHoldingId,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransfersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                companyId = false,
                sellerStakeholderId = false,
                buyerStakeholderId = false,
                shareClassId = false,
                sourceHoldingId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable: $$TransfersTableReferences
                                        ._companyIdTable(db),
                                    referencedColumn: $$TransfersTableReferences
                                        ._companyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (sellerStakeholderId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sellerStakeholderId,
                                    referencedTable: $$TransfersTableReferences
                                        ._sellerStakeholderIdTable(db),
                                    referencedColumn: $$TransfersTableReferences
                                        ._sellerStakeholderIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (buyerStakeholderId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.buyerStakeholderId,
                                    referencedTable: $$TransfersTableReferences
                                        ._buyerStakeholderIdTable(db),
                                    referencedColumn: $$TransfersTableReferences
                                        ._buyerStakeholderIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (shareClassId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.shareClassId,
                                    referencedTable: $$TransfersTableReferences
                                        ._shareClassIdTable(db),
                                    referencedColumn: $$TransfersTableReferences
                                        ._shareClassIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (sourceHoldingId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceHoldingId,
                                    referencedTable: $$TransfersTableReferences
                                        ._sourceHoldingIdTable(db),
                                    referencedColumn: $$TransfersTableReferences
                                        ._sourceHoldingIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$TransfersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransfersTable,
      Transfer,
      $$TransfersTableFilterComposer,
      $$TransfersTableOrderingComposer,
      $$TransfersTableAnnotationComposer,
      $$TransfersTableCreateCompanionBuilder,
      $$TransfersTableUpdateCompanionBuilder,
      (Transfer, $$TransfersTableReferences),
      Transfer,
      PrefetchHooks Function({
        bool companyId,
        bool sellerStakeholderId,
        bool buyerStakeholderId,
        bool shareClassId,
        bool sourceHoldingId,
      })
    >;
typedef $$MfnUpgradesTableCreateCompanionBuilder =
    MfnUpgradesCompanion Function({
      required String id,
      required String companyId,
      required String targetConvertibleId,
      required String sourceConvertibleId,
      Value<double?> previousDiscountPercent,
      Value<double?> previousValuationCap,
      Value<bool> previousHasProRata,
      Value<double?> newDiscountPercent,
      Value<double?> newValuationCap,
      Value<bool> newHasProRata,
      required DateTime upgradeDate,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MfnUpgradesTableUpdateCompanionBuilder =
    MfnUpgradesCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> targetConvertibleId,
      Value<String> sourceConvertibleId,
      Value<double?> previousDiscountPercent,
      Value<double?> previousValuationCap,
      Value<bool> previousHasProRata,
      Value<double?> newDiscountPercent,
      Value<double?> newValuationCap,
      Value<bool> newHasProRata,
      Value<DateTime> upgradeDate,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MfnUpgradesTableReferences
    extends BaseReferences<_$AppDatabase, $MfnUpgradesTable, MfnUpgrade> {
  $$MfnUpgradesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.mfnUpgrades.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ConvertiblesTable _targetConvertibleIdTable(_$AppDatabase db) =>
      db.convertibles.createAlias(
        $_aliasNameGenerator(
          db.mfnUpgrades.targetConvertibleId,
          db.convertibles.id,
        ),
      );

  $$ConvertiblesTableProcessedTableManager get targetConvertibleId {
    final $_column = $_itemColumn<String>('target_convertible_id')!;

    final manager = $$ConvertiblesTableTableManager(
      $_db,
      $_db.convertibles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_targetConvertibleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ConvertiblesTable _sourceConvertibleIdTable(_$AppDatabase db) =>
      db.convertibles.createAlias(
        $_aliasNameGenerator(
          db.mfnUpgrades.sourceConvertibleId,
          db.convertibles.id,
        ),
      );

  $$ConvertiblesTableProcessedTableManager get sourceConvertibleId {
    final $_column = $_itemColumn<String>('source_convertible_id')!;

    final manager = $$ConvertiblesTableTableManager(
      $_db,
      $_db.convertibles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceConvertibleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MfnUpgradesTableFilterComposer
    extends Composer<_$AppDatabase, $MfnUpgradesTable> {
  $$MfnUpgradesTableFilterComposer({
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

  ColumnFilters<double> get previousDiscountPercent => $composableBuilder(
    column: $table.previousDiscountPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get previousValuationCap => $composableBuilder(
    column: $table.previousValuationCap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get previousHasProRata => $composableBuilder(
    column: $table.previousHasProRata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get newDiscountPercent => $composableBuilder(
    column: $table.newDiscountPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get newValuationCap => $composableBuilder(
    column: $table.newValuationCap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get newHasProRata => $composableBuilder(
    column: $table.newHasProRata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get upgradeDate => $composableBuilder(
    column: $table.upgradeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConvertiblesTableFilterComposer get targetConvertibleId {
    final $$ConvertiblesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetConvertibleId,
      referencedTable: $db.convertibles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConvertiblesTableFilterComposer(
            $db: $db,
            $table: $db.convertibles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConvertiblesTableFilterComposer get sourceConvertibleId {
    final $$ConvertiblesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceConvertibleId,
      referencedTable: $db.convertibles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConvertiblesTableFilterComposer(
            $db: $db,
            $table: $db.convertibles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MfnUpgradesTableOrderingComposer
    extends Composer<_$AppDatabase, $MfnUpgradesTable> {
  $$MfnUpgradesTableOrderingComposer({
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

  ColumnOrderings<double> get previousDiscountPercent => $composableBuilder(
    column: $table.previousDiscountPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get previousValuationCap => $composableBuilder(
    column: $table.previousValuationCap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get previousHasProRata => $composableBuilder(
    column: $table.previousHasProRata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get newDiscountPercent => $composableBuilder(
    column: $table.newDiscountPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get newValuationCap => $composableBuilder(
    column: $table.newValuationCap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get newHasProRata => $composableBuilder(
    column: $table.newHasProRata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get upgradeDate => $composableBuilder(
    column: $table.upgradeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConvertiblesTableOrderingComposer get targetConvertibleId {
    final $$ConvertiblesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetConvertibleId,
      referencedTable: $db.convertibles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConvertiblesTableOrderingComposer(
            $db: $db,
            $table: $db.convertibles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConvertiblesTableOrderingComposer get sourceConvertibleId {
    final $$ConvertiblesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceConvertibleId,
      referencedTable: $db.convertibles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConvertiblesTableOrderingComposer(
            $db: $db,
            $table: $db.convertibles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MfnUpgradesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MfnUpgradesTable> {
  $$MfnUpgradesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get previousDiscountPercent => $composableBuilder(
    column: $table.previousDiscountPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get previousValuationCap => $composableBuilder(
    column: $table.previousValuationCap,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get previousHasProRata => $composableBuilder(
    column: $table.previousHasProRata,
    builder: (column) => column,
  );

  GeneratedColumn<double> get newDiscountPercent => $composableBuilder(
    column: $table.newDiscountPercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get newValuationCap => $composableBuilder(
    column: $table.newValuationCap,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get newHasProRata => $composableBuilder(
    column: $table.newHasProRata,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get upgradeDate => $composableBuilder(
    column: $table.upgradeDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConvertiblesTableAnnotationComposer get targetConvertibleId {
    final $$ConvertiblesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetConvertibleId,
      referencedTable: $db.convertibles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConvertiblesTableAnnotationComposer(
            $db: $db,
            $table: $db.convertibles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConvertiblesTableAnnotationComposer get sourceConvertibleId {
    final $$ConvertiblesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceConvertibleId,
      referencedTable: $db.convertibles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConvertiblesTableAnnotationComposer(
            $db: $db,
            $table: $db.convertibles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MfnUpgradesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MfnUpgradesTable,
          MfnUpgrade,
          $$MfnUpgradesTableFilterComposer,
          $$MfnUpgradesTableOrderingComposer,
          $$MfnUpgradesTableAnnotationComposer,
          $$MfnUpgradesTableCreateCompanionBuilder,
          $$MfnUpgradesTableUpdateCompanionBuilder,
          (MfnUpgrade, $$MfnUpgradesTableReferences),
          MfnUpgrade,
          PrefetchHooks Function({
            bool companyId,
            bool targetConvertibleId,
            bool sourceConvertibleId,
          })
        > {
  $$MfnUpgradesTableTableManager(_$AppDatabase db, $MfnUpgradesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MfnUpgradesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MfnUpgradesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MfnUpgradesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> targetConvertibleId = const Value.absent(),
                Value<String> sourceConvertibleId = const Value.absent(),
                Value<double?> previousDiscountPercent = const Value.absent(),
                Value<double?> previousValuationCap = const Value.absent(),
                Value<bool> previousHasProRata = const Value.absent(),
                Value<double?> newDiscountPercent = const Value.absent(),
                Value<double?> newValuationCap = const Value.absent(),
                Value<bool> newHasProRata = const Value.absent(),
                Value<DateTime> upgradeDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MfnUpgradesCompanion(
                id: id,
                companyId: companyId,
                targetConvertibleId: targetConvertibleId,
                sourceConvertibleId: sourceConvertibleId,
                previousDiscountPercent: previousDiscountPercent,
                previousValuationCap: previousValuationCap,
                previousHasProRata: previousHasProRata,
                newDiscountPercent: newDiscountPercent,
                newValuationCap: newValuationCap,
                newHasProRata: newHasProRata,
                upgradeDate: upgradeDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String targetConvertibleId,
                required String sourceConvertibleId,
                Value<double?> previousDiscountPercent = const Value.absent(),
                Value<double?> previousValuationCap = const Value.absent(),
                Value<bool> previousHasProRata = const Value.absent(),
                Value<double?> newDiscountPercent = const Value.absent(),
                Value<double?> newValuationCap = const Value.absent(),
                Value<bool> newHasProRata = const Value.absent(),
                required DateTime upgradeDate,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MfnUpgradesCompanion.insert(
                id: id,
                companyId: companyId,
                targetConvertibleId: targetConvertibleId,
                sourceConvertibleId: sourceConvertibleId,
                previousDiscountPercent: previousDiscountPercent,
                previousValuationCap: previousValuationCap,
                previousHasProRata: previousHasProRata,
                newDiscountPercent: newDiscountPercent,
                newValuationCap: newValuationCap,
                newHasProRata: newHasProRata,
                upgradeDate: upgradeDate,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MfnUpgradesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                companyId = false,
                targetConvertibleId = false,
                sourceConvertibleId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable:
                                        $$MfnUpgradesTableReferences
                                            ._companyIdTable(db),
                                    referencedColumn:
                                        $$MfnUpgradesTableReferences
                                            ._companyIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (targetConvertibleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.targetConvertibleId,
                                    referencedTable:
                                        $$MfnUpgradesTableReferences
                                            ._targetConvertibleIdTable(db),
                                    referencedColumn:
                                        $$MfnUpgradesTableReferences
                                            ._targetConvertibleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceConvertibleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceConvertibleId,
                                    referencedTable:
                                        $$MfnUpgradesTableReferences
                                            ._sourceConvertibleIdTable(db),
                                    referencedColumn:
                                        $$MfnUpgradesTableReferences
                                            ._sourceConvertibleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$MfnUpgradesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MfnUpgradesTable,
      MfnUpgrade,
      $$MfnUpgradesTableFilterComposer,
      $$MfnUpgradesTableOrderingComposer,
      $$MfnUpgradesTableAnnotationComposer,
      $$MfnUpgradesTableCreateCompanionBuilder,
      $$MfnUpgradesTableUpdateCompanionBuilder,
      (MfnUpgrade, $$MfnUpgradesTableReferences),
      MfnUpgrade,
      PrefetchHooks Function({
        bool companyId,
        bool targetConvertibleId,
        bool sourceConvertibleId,
      })
    >;
typedef $$EsopPoolExpansionsTableCreateCompanionBuilder =
    EsopPoolExpansionsCompanion Function({
      required String id,
      required String companyId,
      required String poolId,
      required int previousSize,
      required int newSize,
      required int sharesAdded,
      required String reason,
      Value<String?> resolutionReference,
      required DateTime expansionDate,
      Value<String?> notes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$EsopPoolExpansionsTableUpdateCompanionBuilder =
    EsopPoolExpansionsCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> poolId,
      Value<int> previousSize,
      Value<int> newSize,
      Value<int> sharesAdded,
      Value<String> reason,
      Value<String?> resolutionReference,
      Value<DateTime> expansionDate,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$EsopPoolExpansionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EsopPoolExpansionsTable,
          EsopPoolExpansion
        > {
  $$EsopPoolExpansionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.esopPoolExpansions.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EsopPoolsTable _poolIdTable(_$AppDatabase db) =>
      db.esopPools.createAlias(
        $_aliasNameGenerator(db.esopPoolExpansions.poolId, db.esopPools.id),
      );

  $$EsopPoolsTableProcessedTableManager get poolId {
    final $_column = $_itemColumn<String>('pool_id')!;

    final manager = $$EsopPoolsTableTableManager(
      $_db,
      $_db.esopPools,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_poolIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EsopPoolExpansionsTableFilterComposer
    extends Composer<_$AppDatabase, $EsopPoolExpansionsTable> {
  $$EsopPoolExpansionsTableFilterComposer({
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

  ColumnFilters<int> get previousSize => $composableBuilder(
    column: $table.previousSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newSize => $composableBuilder(
    column: $table.newSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sharesAdded => $composableBuilder(
    column: $table.sharesAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolutionReference => $composableBuilder(
    column: $table.resolutionReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expansionDate => $composableBuilder(
    column: $table.expansionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EsopPoolsTableFilterComposer get poolId {
    final $$EsopPoolsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poolId,
      referencedTable: $db.esopPools,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EsopPoolsTableFilterComposer(
            $db: $db,
            $table: $db.esopPools,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EsopPoolExpansionsTableOrderingComposer
    extends Composer<_$AppDatabase, $EsopPoolExpansionsTable> {
  $$EsopPoolExpansionsTableOrderingComposer({
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

  ColumnOrderings<int> get previousSize => $composableBuilder(
    column: $table.previousSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newSize => $composableBuilder(
    column: $table.newSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sharesAdded => $composableBuilder(
    column: $table.sharesAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolutionReference => $composableBuilder(
    column: $table.resolutionReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expansionDate => $composableBuilder(
    column: $table.expansionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EsopPoolsTableOrderingComposer get poolId {
    final $$EsopPoolsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poolId,
      referencedTable: $db.esopPools,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EsopPoolsTableOrderingComposer(
            $db: $db,
            $table: $db.esopPools,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EsopPoolExpansionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EsopPoolExpansionsTable> {
  $$EsopPoolExpansionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get previousSize => $composableBuilder(
    column: $table.previousSize,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newSize =>
      $composableBuilder(column: $table.newSize, builder: (column) => column);

  GeneratedColumn<int> get sharesAdded => $composableBuilder(
    column: $table.sharesAdded,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get resolutionReference => $composableBuilder(
    column: $table.resolutionReference,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expansionDate => $composableBuilder(
    column: $table.expansionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EsopPoolsTableAnnotationComposer get poolId {
    final $$EsopPoolsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.poolId,
      referencedTable: $db.esopPools,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EsopPoolsTableAnnotationComposer(
            $db: $db,
            $table: $db.esopPools,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EsopPoolExpansionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EsopPoolExpansionsTable,
          EsopPoolExpansion,
          $$EsopPoolExpansionsTableFilterComposer,
          $$EsopPoolExpansionsTableOrderingComposer,
          $$EsopPoolExpansionsTableAnnotationComposer,
          $$EsopPoolExpansionsTableCreateCompanionBuilder,
          $$EsopPoolExpansionsTableUpdateCompanionBuilder,
          (EsopPoolExpansion, $$EsopPoolExpansionsTableReferences),
          EsopPoolExpansion,
          PrefetchHooks Function({bool companyId, bool poolId})
        > {
  $$EsopPoolExpansionsTableTableManager(
    _$AppDatabase db,
    $EsopPoolExpansionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EsopPoolExpansionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EsopPoolExpansionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EsopPoolExpansionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> poolId = const Value.absent(),
                Value<int> previousSize = const Value.absent(),
                Value<int> newSize = const Value.absent(),
                Value<int> sharesAdded = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> resolutionReference = const Value.absent(),
                Value<DateTime> expansionDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EsopPoolExpansionsCompanion(
                id: id,
                companyId: companyId,
                poolId: poolId,
                previousSize: previousSize,
                newSize: newSize,
                sharesAdded: sharesAdded,
                reason: reason,
                resolutionReference: resolutionReference,
                expansionDate: expansionDate,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required String poolId,
                required int previousSize,
                required int newSize,
                required int sharesAdded,
                required String reason,
                Value<String?> resolutionReference = const Value.absent(),
                required DateTime expansionDate,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => EsopPoolExpansionsCompanion.insert(
                id: id,
                companyId: companyId,
                poolId: poolId,
                previousSize: previousSize,
                newSize: newSize,
                sharesAdded: sharesAdded,
                reason: reason,
                resolutionReference: resolutionReference,
                expansionDate: expansionDate,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EsopPoolExpansionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false, poolId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable:
                                    $$EsopPoolExpansionsTableReferences
                                        ._companyIdTable(db),
                                referencedColumn:
                                    $$EsopPoolExpansionsTableReferences
                                        ._companyIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (poolId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.poolId,
                                referencedTable:
                                    $$EsopPoolExpansionsTableReferences
                                        ._poolIdTable(db),
                                referencedColumn:
                                    $$EsopPoolExpansionsTableReferences
                                        ._poolIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EsopPoolExpansionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EsopPoolExpansionsTable,
      EsopPoolExpansion,
      $$EsopPoolExpansionsTableFilterComposer,
      $$EsopPoolExpansionsTableOrderingComposer,
      $$EsopPoolExpansionsTableAnnotationComposer,
      $$EsopPoolExpansionsTableCreateCompanionBuilder,
      $$EsopPoolExpansionsTableUpdateCompanionBuilder,
      (EsopPoolExpansion, $$EsopPoolExpansionsTableReferences),
      EsopPoolExpansion,
      PrefetchHooks Function({bool companyId, bool poolId})
    >;
typedef $$SnapshotsTableCreateCompanionBuilder =
    SnapshotsCompanion Function({
      required String id,
      required String companyId,
      required int atSequenceNumber,
      required String stateJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SnapshotsTableUpdateCompanionBuilder =
    SnapshotsCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<int> atSequenceNumber,
      Value<String> stateJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SnapshotsTableReferences
    extends BaseReferences<_$AppDatabase, $SnapshotsTable, Snapshot> {
  $$SnapshotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias(
        $_aliasNameGenerator(db.snapshots.companyId, db.companies.id),
      );

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $SnapshotsTable> {
  $$SnapshotsTableFilterComposer({
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

  ColumnFilters<int> get atSequenceNumber => $composableBuilder(
    column: $table.atSequenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stateJson => $composableBuilder(
    column: $table.stateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $SnapshotsTable> {
  $$SnapshotsTableOrderingComposer({
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

  ColumnOrderings<int> get atSequenceNumber => $composableBuilder(
    column: $table.atSequenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stateJson => $composableBuilder(
    column: $table.stateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnapshotsTable> {
  $$SnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get atSequenceNumber => $composableBuilder(
    column: $table.atSequenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stateJson =>
      $composableBuilder(column: $table.stateJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SnapshotsTable,
          Snapshot,
          $$SnapshotsTableFilterComposer,
          $$SnapshotsTableOrderingComposer,
          $$SnapshotsTableAnnotationComposer,
          $$SnapshotsTableCreateCompanionBuilder,
          $$SnapshotsTableUpdateCompanionBuilder,
          (Snapshot, $$SnapshotsTableReferences),
          Snapshot,
          PrefetchHooks Function({bool companyId})
        > {
  $$SnapshotsTableTableManager(_$AppDatabase db, $SnapshotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<int> atSequenceNumber = const Value.absent(),
                Value<String> stateJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SnapshotsCompanion(
                id: id,
                companyId: companyId,
                atSequenceNumber: atSequenceNumber,
                stateJson: stateJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String companyId,
                required int atSequenceNumber,
                required String stateJson,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SnapshotsCompanion.insert(
                id: id,
                companyId: companyId,
                atSequenceNumber: atSequenceNumber,
                stateJson: stateJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SnapshotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable: $$SnapshotsTableReferences
                                    ._companyIdTable(db),
                                referencedColumn: $$SnapshotsTableReferences
                                    ._companyIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SnapshotsTable,
      Snapshot,
      $$SnapshotsTableFilterComposer,
      $$SnapshotsTableOrderingComposer,
      $$SnapshotsTableAnnotationComposer,
      $$SnapshotsTableCreateCompanionBuilder,
      $$SnapshotsTableUpdateCompanionBuilder,
      (Snapshot, $$SnapshotsTableReferences),
      Snapshot,
      PrefetchHooks Function({bool companyId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db, _db.companies);
  $$StakeholdersTableTableManager get stakeholders =>
      $$StakeholdersTableTableManager(_db, _db.stakeholders);
  $$ShareClassesTableTableManager get shareClasses =>
      $$ShareClassesTableTableManager(_db, _db.shareClasses);
  $$RoundsTableTableManager get rounds =>
      $$RoundsTableTableManager(_db, _db.rounds);
  $$HoldingsTableTableManager get holdings =>
      $$HoldingsTableTableManager(_db, _db.holdings);
  $$ConvertiblesTableTableManager get convertibles =>
      $$ConvertiblesTableTableManager(_db, _db.convertibles);
  $$EsopPoolsTableTableManager get esopPools =>
      $$EsopPoolsTableTableManager(_db, _db.esopPools);
  $$OptionGrantsTableTableManager get optionGrants =>
      $$OptionGrantsTableTableManager(_db, _db.optionGrants);
  $$WarrantsTableTableManager get warrants =>
      $$WarrantsTableTableManager(_db, _db.warrants);
  $$VestingSchedulesTableTableManager get vestingSchedules =>
      $$VestingSchedulesTableTableManager(_db, _db.vestingSchedules);
  $$ValuationsTableTableManager get valuations =>
      $$ValuationsTableTableManager(_db, _db.valuations);
  $$CapitalizationEventsTableTableManager get capitalizationEvents =>
      $$CapitalizationEventsTableTableManager(_db, _db.capitalizationEvents);
  $$SavedScenariosTableTableManager get savedScenarios =>
      $$SavedScenariosTableTableManager(_db, _db.savedScenarios);
  $$TransfersTableTableManager get transfers =>
      $$TransfersTableTableManager(_db, _db.transfers);
  $$MfnUpgradesTableTableManager get mfnUpgrades =>
      $$MfnUpgradesTableTableManager(_db, _db.mfnUpgrades);
  $$EsopPoolExpansionsTableTableManager get esopPoolExpansions =>
      $$EsopPoolExpansionsTableTableManager(_db, _db.esopPoolExpansions);
  $$SnapshotsTableTableManager get snapshots =>
      $$SnapshotsTableTableManager(_db, _db.snapshots);
}
