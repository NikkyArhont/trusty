import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserRecord extends FirestoreRecord {
  UserRecord._(DocumentReference reference, Map<String, dynamic> data)
    : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // SHA-256 of the normalized phone returned only by the public profile API.
  String? _contactPhoneHash;
  String get contactPhoneHash => _contactPhoneHash ?? '';
  bool hasContactPhoneHash() => _contactPhoneHash != null;

  // "favoriteServices" field.
  List<DocumentReference>? _favoriteServices;
  List<DocumentReference> get favoriteServices => _favoriteServices ?? const [];
  bool hasFavoriteServices() => _favoriteServices != null;

  // "bio" field.
  String? _bio;
  String get bio => _bio ?? '';
  bool hasBio() => _bio != null;

  // "mainLoc" field.
  PlaceStruct? _mainLoc;
  PlaceStruct get mainLoc => _mainLoc ?? PlaceStruct();
  bool hasMainLoc() => _mainLoc != null;

  // "masterMode" field.
  bool? _masterMode;
  bool get masterMode => _masterMode ?? false;
  bool hasMasterMode() => _masterMode != null;

  // "clientProfileCompleted" field.
  bool? _clientProfileCompleted;
  bool get clientProfileCompleted => _clientProfileCompleted ?? false;
  bool hasClientProfileCompleted() => _clientProfileCompleted != null;

  // "blockedUserIds" field.
  List<String>? _blockedUserIds;
  List<String> get blockedUserIds => _blockedUserIds ?? const [];
  bool hasBlockedUserIds() => _blockedUserIds != null;

  // "masterData" field.
  MasterDataStruct? _masterData;
  MasterDataStruct get masterData => _masterData ?? MasterDataStruct();
  bool hasMasterData() => _masterData != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _contactPhoneHash = snapshotData['contactPhoneHash'] as String?;
    _favoriteServices = getDataList(snapshotData['favoriteServices']);
    _bio = snapshotData['bio'] as String?;
    _mainLoc = snapshotData['mainLoc'] is PlaceStruct
        ? snapshotData['mainLoc']
        : PlaceStruct.maybeFromMap(snapshotData['mainLoc']);
    _masterMode = snapshotData['masterMode'] as bool?;
    _clientProfileCompleted = snapshotData['clientProfileCompleted'] as bool?;
    _blockedUserIds = getDataList(snapshotData['blockedUserIds']);
    _masterData = snapshotData['masterData'] is MasterDataStruct
        ? snapshotData['masterData']
        : MasterDataStruct.maybeFromMap(snapshotData['masterData']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('user');

  static Stream<UserRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UserRecord.fromSnapshot(s));

  static Future<UserRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UserRecord.fromSnapshot(s));

  static UserRecord fromSnapshot(DocumentSnapshot snapshot) => UserRecord._(
    snapshot.reference,
    mapFromFirestore(snapshot.data() as Map<String, dynamic>),
  );

  static UserRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) => UserRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UserRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UserRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUserRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? bio,
  PlaceStruct? mainLoc,
  bool? masterMode,
  bool? clientProfileCompleted,
  List<String>? blockedUserIds,
  MasterDataStruct? masterData,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName == null
          ? null
          : normalizeUserText(displayName),
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'bio': bio == null ? null : normalizeUserText(bio),
      'mainLoc': PlaceStruct().toMap(),
      'masterMode': masterMode,
      'clientProfileCompleted': clientProfileCompleted,
      'blockedUserIds': blockedUserIds,
      'masterData': MasterDataStruct().toMap(),
    }.withoutNulls,
  );

  // Handle nested data for "mainLoc" field.
  addPlaceStructData(firestoreData, mainLoc, 'mainLoc');

  // Handle nested data for "masterData" field.
  addMasterDataStructData(firestoreData, masterData, 'masterData');

  return firestoreData;
}

class UserRecordDocumentEquality implements Equality<UserRecord> {
  const UserRecordDocumentEquality();

  @override
  bool equals(UserRecord? e1, UserRecord? e2) {
    const listEquality = ListEquality();
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.contactPhoneHash == e2?.contactPhoneHash &&
        listEquality.equals(e1?.favoriteServices, e2?.favoriteServices) &&
        e1?.bio == e2?.bio &&
        e1?.mainLoc == e2?.mainLoc &&
        e1?.masterMode == e2?.masterMode &&
        e1?.clientProfileCompleted == e2?.clientProfileCompleted &&
        listEquality.equals(e1?.blockedUserIds, e2?.blockedUserIds) &&
        e1?.masterData == e2?.masterData;
  }

  @override
  int hash(UserRecord? e) => const ListEquality().hash([
    e?.email,
    e?.displayName,
    e?.photoUrl,
    e?.uid,
    e?.createdTime,
    e?.phoneNumber,
    e?.contactPhoneHash,
    e?.favoriteServices,
    e?.bio,
    e?.mainLoc,
    e?.masterMode,
    e?.clientProfileCompleted,
    e?.blockedUserIds,
    e?.masterData,
  ]);

  @override
  bool isValidKey(Object? o) => o is UserRecord;
}
