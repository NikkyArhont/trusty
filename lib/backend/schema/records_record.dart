import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RecordsRecord extends FirestoreRecord {
  RecordsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
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

  void _initializeFields() {
    _master = snapshotData['master'] as DocumentReference?;
    _client = snapshotData['client'] as DocumentReference?;
    _service = snapshotData['service'] as DocumentReference?;
    _date = snapshotData['date'] as DateTime?;
    _status = snapshotData['status'] is RecordStatus
        ? snapshotData['status']
        : deserializeEnum<RecordStatus>(snapshotData['status']);
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
  ) =>
      RecordsRecord._(reference, mapFromFirestore(data));

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
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'master': master,
      'client': client,
      'service': service,
      'date': date,
      'status': status,
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
        e1?.status == e2?.status;
  }

  @override
  int hash(RecordsRecord? e) => const ListEquality()
      .hash([e?.master, e?.client, e?.service, e?.date, e?.status]);

  @override
  bool isValidKey(Object? o) => o is RecordsRecord;
}
