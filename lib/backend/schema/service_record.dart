import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ServiceRecord extends FirestoreRecord {
  ServiceRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "owner" field.
  DocumentReference? _owner;
  DocumentReference? get owner => _owner;
  bool hasOwner() => _owner != null;

  // "image" field.
  List<String>? _image;
  List<String> get image => _image ?? const [];
  bool hasImage() => _image != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  bool hasDescription() => _description != null;

  // "price" field.
  int? _price;
  int get price => _price ?? 0;
  bool hasPrice() => _price != null;

  // "time" field.
  int? _time;
  int get time => _time ?? 0;
  bool hasTime() => _time != null;

  // "categoryKey" field.
  String? _categoryKey;
  String get categoryKey => _categoryKey ?? '';
  bool hasCategoryKey() => _categoryKey != null;

  // "place" field.
  PlaceStruct? _place;
  PlaceStruct get place => _place ?? PlaceStruct();
  bool hasPlace() => _place != null;

  // "status" field.
  ServiceStatus? _status;
  ServiceStatus? get status => _status;
  bool hasStatus() => _status != null;

  // "location" field.
  LatLng? _location;
  LatLng? get location => _location;
  bool hasLocation() => _location != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _owner = snapshotData['owner'] as DocumentReference?;
    _image = getDataList(snapshotData['image']);
    _description = snapshotData['description'] as String?;
    _price = castToType<int>(snapshotData['price']);
    _time = castToType<int>(snapshotData['time']);
    _categoryKey = snapshotData['categoryKey'] as String?;
    _place = snapshotData['place'] is PlaceStruct
        ? snapshotData['place']
        : PlaceStruct.maybeFromMap(snapshotData['place']);
    _status = snapshotData['status'] is ServiceStatus
        ? snapshotData['status']
        : deserializeEnum<ServiceStatus>(snapshotData['status']);
    _location = snapshotData['location'] as LatLng?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('service');

  static Stream<ServiceRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ServiceRecord.fromSnapshot(s));

  static Future<ServiceRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ServiceRecord.fromSnapshot(s));

  static ServiceRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ServiceRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ServiceRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ServiceRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ServiceRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ServiceRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createServiceRecordData({
  String? title,
  DocumentReference? owner,
  String? description,
  int? price,
  int? time,
  String? categoryKey,
  PlaceStruct? place,
  ServiceStatus? status,
  LatLng? location,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title,
      'owner': owner,
      'description': description,
      'price': price,
      'time': time,
      'categoryKey': categoryKey,
      'place': PlaceStruct().toMap(),
      'status': status,
      'location': location,
    }.withoutNulls,
  );

  // Handle nested data for "place" field.
  addPlaceStructData(firestoreData, place, 'place');

  return firestoreData;
}

class ServiceRecordDocumentEquality implements Equality<ServiceRecord> {
  const ServiceRecordDocumentEquality();

  @override
  bool equals(ServiceRecord? e1, ServiceRecord? e2) {
    const listEquality = ListEquality();
    return e1?.title == e2?.title &&
        e1?.owner == e2?.owner &&
        listEquality.equals(e1?.image, e2?.image) &&
        e1?.description == e2?.description &&
        e1?.price == e2?.price &&
        e1?.time == e2?.time &&
        e1?.categoryKey == e2?.categoryKey &&
        e1?.place == e2?.place &&
        e1?.status == e2?.status &&
        e1?.location == e2?.location;
  }

  @override
  int hash(ServiceRecord? e) => const ListEquality().hash([
        e?.title,
        e?.owner,
        e?.image,
        e?.description,
        e?.price,
        e?.time,
        e?.categoryKey,
        e?.place,
        e?.status,
        e?.location
      ]);

  @override
  bool isValidKey(Object? o) => o is ServiceRecord;
}
