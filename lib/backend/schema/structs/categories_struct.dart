// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CategoriesStruct extends FFFirebaseStruct {
  CategoriesStruct({
    String? key,
    String? titleRU,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _key = key,
        _titleRU = titleRU,
        super(firestoreUtilData);

  // "key" field.
  String? _key;
  String get key => _key ?? '';
  set key(String? val) => _key = val;

  bool hasKey() => _key != null;

  // "titleRU" field.
  String? _titleRU;
  String get titleRU => _titleRU ?? '';
  set titleRU(String? val) => _titleRU = val;

  bool hasTitleRU() => _titleRU != null;

  static CategoriesStruct fromMap(Map<String, dynamic> data) =>
      CategoriesStruct(
        key: data['key'] as String?,
        titleRU: data['titleRU'] as String?,
      );

  static CategoriesStruct? maybeFromMap(dynamic data) => data is Map
      ? CategoriesStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'key': _key,
        'titleRU': _titleRU,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'key': serializeParam(
          _key,
          ParamType.String,
        ),
        'titleRU': serializeParam(
          _titleRU,
          ParamType.String,
        ),
      }.withoutNulls;

  static CategoriesStruct fromSerializableMap(Map<String, dynamic> data) =>
      CategoriesStruct(
        key: deserializeParam(
          data['key'],
          ParamType.String,
          false,
        ),
        titleRU: deserializeParam(
          data['titleRU'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'CategoriesStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is CategoriesStruct &&
        key == other.key &&
        titleRU == other.titleRU;
  }

  @override
  int get hashCode => const ListEquality().hash([key, titleRU]);
}

CategoriesStruct createCategoriesStruct({
  String? key,
  String? titleRU,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    CategoriesStruct(
      key: key,
      titleRU: titleRU,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

CategoriesStruct? updateCategoriesStruct(
  CategoriesStruct? categories, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    categories
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addCategoriesStructData(
  Map<String, dynamic> firestoreData,
  CategoriesStruct? categories,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (categories == null) {
    return;
  }
  if (categories.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && categories.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final categoriesData = getCategoriesFirestoreData(categories, forFieldValue);
  final nestedData = categoriesData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = categories.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getCategoriesFirestoreData(
  CategoriesStruct? categories, [
  bool forFieldValue = false,
]) {
  if (categories == null) {
    return {};
  }
  final firestoreData = mapToFirestore(categories.toMap());

  // Add any Firestore field values
  mapToFirestore(categories.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getCategoriesListFirestoreData(
  List<CategoriesStruct>? categoriess,
) =>
    categoriess?.map((e) => getCategoriesFirestoreData(e, true)).toList() ?? [];
