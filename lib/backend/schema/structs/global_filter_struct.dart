// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GlobalFilterStruct extends FFFirebaseStruct {
  GlobalFilterStruct({
    String? catKey,
    PlaceStruct? place,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _catKey = catKey,
        _place = place,
        super(firestoreUtilData);

  // "catKey" field.
  String? _catKey;
  String get catKey => _catKey ?? '';
  set catKey(String? val) => _catKey = val;

  bool hasCatKey() => _catKey != null;

  // "place" field.
  PlaceStruct? _place;
  PlaceStruct get place => _place ?? PlaceStruct();
  set place(PlaceStruct? val) => _place = val;

  void updatePlace(Function(PlaceStruct) updateFn) {
    updateFn(_place ??= PlaceStruct());
  }

  bool hasPlace() => _place != null;

  static GlobalFilterStruct fromMap(Map<String, dynamic> data) =>
      GlobalFilterStruct(
        catKey: data['catKey'] as String?,
        place: data['place'] is PlaceStruct
            ? data['place']
            : PlaceStruct.maybeFromMap(data['place']),
      );

  static GlobalFilterStruct? maybeFromMap(dynamic data) => data is Map
      ? GlobalFilterStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'catKey': _catKey,
        'place': _place?.toMap(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'catKey': serializeParam(
          _catKey,
          ParamType.String,
        ),
        'place': serializeParam(
          _place,
          ParamType.DataStruct,
        ),
      }.withoutNulls;

  static GlobalFilterStruct fromSerializableMap(Map<String, dynamic> data) =>
      GlobalFilterStruct(
        catKey: deserializeParam(
          data['catKey'],
          ParamType.String,
          false,
        ),
        place: deserializeStructParam(
          data['place'],
          ParamType.DataStruct,
          false,
          structBuilder: PlaceStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'GlobalFilterStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is GlobalFilterStruct &&
        catKey == other.catKey &&
        place == other.place;
  }

  @override
  int get hashCode => const ListEquality().hash([catKey, place]);
}

GlobalFilterStruct createGlobalFilterStruct({
  String? catKey,
  PlaceStruct? place,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    GlobalFilterStruct(
      catKey: catKey,
      place: place ?? (clearUnsetFields ? PlaceStruct() : null),
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

GlobalFilterStruct? updateGlobalFilterStruct(
  GlobalFilterStruct? globalFilter, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    globalFilter
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addGlobalFilterStructData(
  Map<String, dynamic> firestoreData,
  GlobalFilterStruct? globalFilter,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (globalFilter == null) {
    return;
  }
  if (globalFilter.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && globalFilter.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final globalFilterData =
      getGlobalFilterFirestoreData(globalFilter, forFieldValue);
  final nestedData =
      globalFilterData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = globalFilter.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getGlobalFilterFirestoreData(
  GlobalFilterStruct? globalFilter, [
  bool forFieldValue = false,
]) {
  if (globalFilter == null) {
    return {};
  }
  final firestoreData = mapToFirestore(globalFilter.toMap());

  // Handle nested data for "place" field.
  addPlaceStructData(
    firestoreData,
    globalFilter.hasPlace() ? globalFilter.place : null,
    'place',
    forFieldValue,
  );

  // Add any Firestore field values
  mapToFirestore(globalFilter.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getGlobalFilterListFirestoreData(
  List<GlobalFilterStruct>? globalFilters,
) =>
    globalFilters?.map((e) => getGlobalFilterFirestoreData(e, true)).toList() ??
    [];
