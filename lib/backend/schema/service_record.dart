import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

List<String>? _serviceImageList(dynamic value) {
  if (value is! List) {
    return null;
  }

  final result = <String>[];

  void collect(dynamic item) {
    if (item is String && item.trim().isNotEmpty) {
      result.add(item);
    } else if (item is List) {
      for (final nestedItem in item) {
        collect(nestedItem);
      }
    }
  }

  for (final item in value) {
    collect(item);
  }

  return result;
}

class ServiceRecord extends FirestoreRecord {
  ServiceRecord._(DocumentReference reference, Map<String, dynamic> data)
    : super(reference, data) {
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

  // "timeUnit" field.
  String? _timeUnit;
  String get timeUnit => _timeUnit ?? 'min';
  bool hasTimeUnit() => _timeUnit != null;

  String get timeUnitLabel => switch (timeUnit) {
    'hour' => 'ч.',
    'day' => 'д.',
    _ => 'мин.',
  };

  String get formattedDuration => '$time $timeUnitLabel';

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

  // "masterTitle" field.
  String? _masterTitle;
  String get masterTitle => _masterTitle ?? '';
  bool hasMasterTitle() => _masterTitle != null;

  // "masterPhoto" field.
  String? _masterPhoto;
  String get masterPhoto => _masterPhoto ?? '';
  bool hasMasterPhoto() => _masterPhoto != null;

  // "recommenderPhones" field.
  List<String>? _recommenderPhones;
  List<String> get recommenderPhones => _recommenderPhones ?? const [];
  bool hasRecommenderPhones() => _recommenderPhones != null;

  // SHA-256 phone hashes used by current clients. Raw recommenderPhones are
  // read only for compatibility until the server migration is completed.
  List<String>? _recommenderPhoneHashes;
  List<String> get recommenderPhoneHashes =>
      _recommenderPhoneHashes ?? const [];
  bool hasRecommenderPhoneHashes() => _recommenderPhoneHashes != null;

  // "recommendations" field.
  List<RecommendationStruct>? _recommendations;
  List<RecommendationStruct> get recommendations =>
      _recommendations ?? const [];
  bool hasRecommendations() => _recommendations != null;

  String? _moderationReason;
  String get moderationReason => _moderationReason ?? '';
  bool hasModerationReason() => _moderationReason != null;

  void _initializeFields() {
    _title = snapshotData['title'] as String?;
    _owner = snapshotData['owner'] as DocumentReference?;
    _image = _serviceImageList(snapshotData['image']);
    _description = snapshotData['description'] as String?;
    _price = castToType<int>(snapshotData['price']);
    _time = castToType<int>(snapshotData['time']);
    _timeUnit = snapshotData['timeUnit'] as String?;
    _categoryKey = snapshotData['categoryKey'] as String?;
    _place = snapshotData['place'] is PlaceStruct
        ? snapshotData['place']
        : PlaceStruct.maybeFromMap(snapshotData['place']);
    _status = snapshotData['status'] is ServiceStatus
        ? snapshotData['status']
        : deserializeEnum<ServiceStatus>(snapshotData['status']);
    _location = snapshotData['location'] as LatLng?;
    _masterTitle = snapshotData['masterTitle'] as String?;
    _masterPhoto = snapshotData['masterPhoto'] as String?;
    _recommenderPhones = getDataList(snapshotData['recommenderPhones']);
    _recommenderPhoneHashes = getDataList(
      snapshotData['recommenderPhoneHashes'],
    );
    _recommendations = getStructList(
      snapshotData['recommendations'],
      RecommendationStruct.fromMap,
    );
    final moderation = snapshotData['moderation'];
    if (moderation is Map) {
      _moderationReason = moderation['reason'] as String?;
    }
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
  ) => ServiceRecord._(reference, mapFromFirestore(data));

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
  String? timeUnit,
  String? categoryKey,
  PlaceStruct? place,
  ServiceStatus? status,
  LatLng? location,
  String? masterTitle,
  String? masterPhoto,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'title': title == null ? null : normalizeUserText(title),
      'owner': owner,
      'description': description == null
          ? null
          : normalizeUserText(description),
      'price': price,
      'time': time,
      'timeUnit': timeUnit,
      'categoryKey': categoryKey,
      'place': PlaceStruct().toMap(),
      'status': status,
      'location': location,
      'masterTitle': masterTitle == null
          ? null
          : normalizeUserText(masterTitle),
      'masterPhoto': masterPhoto,
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
        e1?.timeUnit == e2?.timeUnit &&
        e1?.categoryKey == e2?.categoryKey &&
        e1?.place == e2?.place &&
        e1?.status == e2?.status &&
        e1?.location == e2?.location &&
        e1?.masterTitle == e2?.masterTitle &&
        e1?.masterPhoto == e2?.masterPhoto &&
        listEquality.equals(e1?.recommenderPhones, e2?.recommenderPhones) &&
        listEquality.equals(
          e1?.recommenderPhoneHashes,
          e2?.recommenderPhoneHashes,
        ) &&
        e1?.moderationReason == e2?.moderationReason;
  }

  @override
  int hash(ServiceRecord? e) => const ListEquality().hash([
    e?.title,
    e?.owner,
    e?.image,
    e?.description,
    e?.price,
    e?.time,
    e?.timeUnit,
    e?.categoryKey,
    e?.place,
    e?.status,
    e?.location,
    e?.masterTitle,
    e?.masterPhoto,
    e?.recommenderPhones,
    e?.recommenderPhoneHashes,
    e?.moderationReason,
  ]);

  @override
  bool isValidKey(Object? o) => o is ServiceRecord;
}
