import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RecordsRecord extends FirestoreRecord {
  RecordsRecord._(DocumentReference reference, Map<String, dynamic> data)
    : super(reference, data) {
    _initializeFields();
  }

  // "master" field.
  DocumentReference? _master;
  DocumentReference? get master => _master;
  bool hasMaster() => _master != null;

  // "client" field.
  DocumentReference? _client;
  DocumentReference? get client => _client;
  bool hasClient() => _client != null;

  // "service" field.
  DocumentReference? _service;
  DocumentReference? get service => _service;
  bool hasService() => _service != null;

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "status" field.
  RecordStatus? _status;
  RecordStatus? get status => _status;
  bool hasStatus() => _status != null;

  // "clientName" field.
  String? _clientName;
  String get clientName => _clientName ?? '';
  bool hasClientName() => _clientName != null;

  // "clientPhoto" field.
  String? _clientPhoto;
  String get clientPhoto => _clientPhoto ?? '';
  bool hasClientPhoto() => _clientPhoto != null;

  // "clientPhone" field.
  String? _clientPhone;
  String get clientPhone => _clientPhone ?? '';
  bool hasClientPhone() => _clientPhone != null;

  // "completed_time" field.
  DateTime? _completedTime;
  DateTime? get completedTime => _completedTime;
  bool hasCompletedTime() => _completedTime != null;

  // "completed_by" field.
  DocumentReference? _completedBy;
  DocumentReference? get completedBy => _completedBy;
  bool hasCompletedBy() => _completedBy != null;

  // "completion_method" field.
  String? _completionMethod;
  String get completionMethod => _completionMethod ?? '';
  bool hasCompletionMethod() => _completionMethod != null;

  void _initializeFields() {
    _master = snapshotData['master'] as DocumentReference?;
    _client = snapshotData['client'] as DocumentReference?;
    _service = snapshotData['service'] as DocumentReference?;
    _date = snapshotData['date'] as DateTime?;
    _status = snapshotData['status'] is RecordStatus
        ? snapshotData['status']
        : deserializeEnum<RecordStatus>(snapshotData['status']);
    _clientName = snapshotData['clientName'] as String?;
    _clientPhoto = snapshotData['clientPhoto'] as String?;
    _clientPhone = snapshotData['clientPhone'] as String?;
    _completedTime = snapshotData['completed_time'] as DateTime?;
    _completedBy = snapshotData['completed_by'] as DocumentReference?;
    _completionMethod = snapshotData['completion_method'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('records');

  static Stream<RecordsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RecordsRecord.fromSnapshot(s));

  static Future<RecordsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RecordsRecord.fromSnapshot(s));

  static RecordsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RecordsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RecordsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) => RecordsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RecordsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RecordsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRecordsRecordData({
  DocumentReference? master,
  DocumentReference? client,
  DocumentReference? service,
  DateTime? date,
  RecordStatus? status,
  String? clientName,
  String? clientPhoto,
  String? clientPhone,
  DateTime? completedTime,
  DocumentReference? completedBy,
  String? completionMethod,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'master': master,
      'client': client,
      'service': service,
      'date': date,
      'status': status,
      'clientName': clientName,
      'clientPhoto': clientPhoto,
      'clientPhone': clientPhone,
      'completed_time': completedTime,
      'completed_by': completedBy,
      'completion_method': completionMethod,
    }.withoutNulls,
  );

  return firestoreData;
}

class RecordsRecordDocumentEquality implements Equality<RecordsRecord> {
  const RecordsRecordDocumentEquality();

  @override
  bool equals(RecordsRecord? e1, RecordsRecord? e2) {
    return e1?.master == e2?.master &&
        e1?.client == e2?.client &&
        e1?.service == e2?.service &&
        e1?.date == e2?.date &&
        e1?.status == e2?.status &&
        e1?.clientName == e2?.clientName &&
        e1?.clientPhoto == e2?.clientPhoto &&
        e1?.clientPhone == e2?.clientPhone &&
        e1?.completedTime == e2?.completedTime &&
        e1?.completedBy == e2?.completedBy &&
        e1?.completionMethod == e2?.completionMethod;
  }

  @override
  int hash(RecordsRecord? e) => const ListEquality().hash([
    e?.master,
    e?.client,
    e?.service,
    e?.date,
    e?.status,
    e?.clientName,
    e?.clientPhoto,
    e?.clientPhone,
    e?.completedTime,
    e?.completedBy,
    e?.completionMethod,
  ]);

  @override
  bool isValidKey(Object? o) => o is RecordsRecord;
}
