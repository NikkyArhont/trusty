// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PlaceStruct extends FFFirebaseStruct {
  PlaceStruct({
    String? title,
    String? description,
    String? id,
    String? cityId,
    LatLng? location,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  }) : _title = title,
       _description = description,
       _id = id,
       _cityId = cityId,
       _location = location,
       super(firestoreUtilData);

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  set description(String? val) => _description = val;

  bool hasDescription() => _description != null;

  // "id" field.
  String? _id;
  String get id => _id ?? '';
  set id(String? val) => _id = val;

  bool hasId() => _id != null;

  // "cityId" field.
  String? _cityId;
  String get cityId => _cityId ?? '';
  set cityId(String? val) => _cityId = val;

  bool hasCityId() => _cityId != null;

  // "location" field.
  LatLng? _location;
  LatLng? get location => _location;
  set location(LatLng? val) => _location = val;

  bool hasLocation() => _location != null;

  static PlaceStruct fromMap(Map<String, dynamic> data) => PlaceStruct(
    title: data['title'] as String?,
    description: data['description'] as String?,
    id: data['id'] as String?,
    cityId: data['cityId'] as String?,
    location: data['location'] as LatLng?,
  );

  static PlaceStruct? maybeFromMap(dynamic data) =>
      data is Map ? PlaceStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
    'title': _title,
    'description': _description,
    'id': _id,
    'cityId': _cityId,
    'location': _location,
  }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
    'title': serializeParam(_title, ParamType.String),
    'description': serializeParam(_description, ParamType.String),
    'id': serializeParam(_id, ParamType.String),
    'cityId': serializeParam(_cityId, ParamType.String),
    'location': serializeParam(_location, ParamType.LatLng),
  }.withoutNulls;

  static PlaceStruct fromSerializableMap(Map<String, dynamic> data) =>
      PlaceStruct(
        title: deserializeParam(data['title'], ParamType.String, false),
        description: deserializeParam(
          data['description'],
          ParamType.String,
          false,
        ),
        id: deserializeParam(data['id'], ParamType.String, false),
        cityId: deserializeParam(data['cityId'], ParamType.String, false),
        location: deserializeParam(data['location'], ParamType.LatLng, false),
      );

  @override
  String toString() => 'PlaceStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is PlaceStruct &&
        title == other.title &&
        description == other.description &&
        id == other.id &&
        cityId == other.cityId &&
        location == other.location;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([title, description, id, cityId, location]);
}

PlaceStruct createPlaceStruct({
  String? title,
  String? description,
  String? id,
  String? cityId,
  LatLng? location,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) => PlaceStruct(
  title: title == null ? null : normalizeUserText(title),
  description: description == null ? null : normalizeUserText(description),
  id: id,
  cityId: cityId,
  location: location,
  firestoreUtilData: FirestoreUtilData(
    clearUnsetFields: clearUnsetFields,
    create: create,
    delete: delete,
    fieldValues: fieldValues,
  ),
);

PlaceStruct? updatePlaceStruct(
  PlaceStruct? place, {
  bool clearUnsetFields = true,
  bool create = false,
}) => place
  ?..firestoreUtilData = FirestoreUtilData(
    clearUnsetFields: clearUnsetFields,
    create: create,
  );

void addPlaceStructData(
  Map<String, dynamic> firestoreData,
  PlaceStruct? place,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (place == null) {
    return;
  }
  if (place.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && place.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final placeData = getPlaceFirestoreData(place, forFieldValue);
  final nestedData = placeData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = place.firestoreUtilData.create || clearFields;
  firestoreData.addAll(
    mergeFields ? mergeNestedFields(nestedData) : nestedData,
  );
}

Map<String, dynamic> getPlaceFirestoreData(
  PlaceStruct? place, [
  bool forFieldValue = false,
]) {
  if (place == null) {
    return {};
  }
  final firestoreData = mapToFirestore(place.toMap());

  // Add any Firestore field values
  mapToFirestore(
    place.firestoreUtilData.fieldValues,
  ).forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getPlaceListFirestoreData(
  List<PlaceStruct>? places,
) => places?.map((e) => getPlaceFirestoreData(e, true)).toList() ?? [];
