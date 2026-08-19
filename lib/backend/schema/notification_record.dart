import 'dart:async';

import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';

class NotificationRecord extends FirestoreRecord {
  NotificationRecord._(DocumentReference reference, Map<String, dynamic> data)
    : super(reference, data) {
    _initializeFields();
  }

  DocumentReference? _user;
  DocumentReference? get user => _user;

  DocumentReference? _service;
  DocumentReference? get service => _service;

  DocumentReference? _chat;
  DocumentReference? get chat => _chat;

  DocumentReference? _record;
  DocumentReference? get record => _record;

  String? _title;
  String get title => _title ?? '';

  String? _body;
  String get body => _body ?? '';

  String? _type;
  String get type => _type ?? '';

  bool? _read;
  bool get read => _read ?? false;

  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;

  void _initializeFields() {
    _user = snapshotData['user'] as DocumentReference?;
    _service = snapshotData['service'] as DocumentReference?;
    _chat = snapshotData['chat'] as DocumentReference?;
    _record = snapshotData['record'] as DocumentReference?;
    _title = snapshotData['title'] as String?;
    _body = snapshotData['body'] as String?;
    _type = snapshotData['type'] as String?;
    _read = snapshotData['read'] as bool?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('notifications');

  static Stream<NotificationRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map(NotificationRecord.fromSnapshot);

  static Future<NotificationRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then(NotificationRecord.fromSnapshot);

  static NotificationRecord fromSnapshot(DocumentSnapshot snapshot) =>
      NotificationRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(Object other) =>
      other is NotificationRecord && reference.path == other.reference.path;
}

class NotificationRecordDocumentEquality
    implements Equality<NotificationRecord> {
  const NotificationRecordDocumentEquality();

  @override
  bool equals(NotificationRecord? e1, NotificationRecord? e2) =>
      e1?.reference.path == e2?.reference.path &&
      e1?.title == e2?.title &&
      e1?.body == e2?.body &&
      e1?.read == e2?.read &&
      e1?.createdAt == e2?.createdAt;

  @override
  int hash(NotificationRecord? e) =>
      Object.hash(e?.reference.path, e?.title, e?.body, e?.read, e?.createdAt);

  @override
  bool isValidKey(Object? o) => o is NotificationRecord;
}
