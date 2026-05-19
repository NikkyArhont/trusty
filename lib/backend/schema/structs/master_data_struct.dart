// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MasterDataStruct extends FFFirebaseStruct {
  MasterDataStruct({
    String? title,
    String? descrip,
    String? initCat,
    String? mainPhoto,
    PlaceStruct? mainAdres,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _title = title,
        _descrip = descrip,
        _initCat = initCat,
        _mainPhoto = mainPhoto,
        _mainAdres = mainAdres,
        super(firestoreUtilData);

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  // "descrip" field.
  String? _descrip;
  String get descrip => _descrip ?? '';
  set descrip(String? val) => _descrip = val;

  bool hasDescrip() => _descrip != null;

  // "initCat" field.
  String? _initCat;
  String get initCat => _initCat ?? '';
  set initCat(String? val) => _initCat = val;

  bool hasInitCat() => _initCat != null;

  // "mainPhoto" field.
  String? _mainPhoto;
  String get mainPhoto => _mainPhoto ?? '';
  set mainPhoto(String? val) => _mainPhoto = val;

  bool hasMainPhoto() => _mainPhoto != null;

  // "mainAdres" field.
  PlaceStruct? _mainAdres;
  PlaceStruct get mainAdres => _mainAdres ?? PlaceStruct();
  set mainAdres(PlaceStruct? val) => _mainAdres = val;

  void updateMainAdres(Function(PlaceStruct) updateFn) {
    updateFn(_mainAdres ??= PlaceStruct());
  }

  bool hasMainAdres() => _mainAdres != null;

  static MasterDataStruct fromMap(Map<String, dynamic> data) =>
      MasterDataStruct(
        title: data['title'] as String?,
        descrip: data['descrip'] as String?,
        initCat: data['initCat'] as String?,
        mainPhoto: data['mainPhoto'] as String?,
        mainAdres: data['mainAdres'] is PlaceStruct
            ? data['mainAdres']
            : PlaceStruct.maybeFromMap(data['mainAdres']),
      );

  static MasterDataStruct? maybeFromMap(dynamic data) => data is Map
      ? MasterDataStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'title': _title,
        'descrip': _descrip,
        'initCat': _initCat,
        'mainPhoto': _mainPhoto,
        'mainAdres': _mainAdres?.toMap(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
        'descrip': serializeParam(
          _descrip,
          ParamType.String,
        ),
        'initCat': serializeParam(
          _initCat,
          ParamType.String,
        ),
        'mainPhoto': serializeParam(
          _mainPhoto,
          ParamType.String,
        ),
        'mainAdres': serializeParam(
          _mainAdres,
          ParamType.DataStruct,
        ),
      }.withoutNulls;

  static MasterDataStruct fromSerializableMap(Map<String, dynamic> data) =>
      MasterDataStruct(
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
        descrip: deserializeParam(
          data['descrip'],
          ParamType.String,
          false,
        ),
        initCat: deserializeParam(
          data['initCat'],
          ParamType.String,
          false,
        ),
        mainPhoto: deserializeParam(
          data['mainPhoto'],
          ParamType.String,
          false,
        ),
        mainAdres: deserializeStructParam(
          data['mainAdres'],
          ParamType.DataStruct,
          false,
          structBuilder: PlaceStruct.fromSerializableMap,
        ),
      );

  @override
  String toString() => 'MasterDataStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is MasterDataStruct &&
        title == other.title &&
        descrip == other.descrip &&
        initCat == other.initCat &&
        mainPhoto == other.mainPhoto &&
        mainAdres == other.mainAdres;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([title, descrip, initCat, mainPhoto, mainAdres]);
}

MasterDataStruct createMasterDataStruct({
  String? title,
  String? descrip,
  String? initCat,
  String? mainPhoto,
  PlaceStruct? mainAdres,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    MasterDataStruct(
      title: title,
      descrip: descrip,
      initCat: initCat,
      mainPhoto: mainPhoto,
      mainAdres: mainAdres ?? (clearUnsetFields ? PlaceStruct() : null),
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

MasterDataStruct? updateMasterDataStruct(
  MasterDataStruct? masterData, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    masterData
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addMasterDataStructData(
  Map<String, dynamic> firestoreData,
  MasterDataStruct? masterData,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (masterData == null) {
    return;
  }
  if (masterData.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && masterData.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final masterDataData = getMasterDataFirestoreData(masterData, forFieldValue);
  final nestedData = masterDataData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = masterData.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getMasterDataFirestoreData(
  MasterDataStruct? masterData, [
  bool forFieldValue = false,
]) {
  if (masterData == null) {
    return {};
  }
  final firestoreData = mapToFirestore(masterData.toMap());

  // Handle nested data for "mainAdres" field.
  addPlaceStructData(
    firestoreData,
    masterData.hasMainAdres() ? masterData.mainAdres : null,
    'mainAdres',
    forFieldValue,
  );

  // Add any Firestore field values
  mapToFirestore(masterData.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getMasterDataListFirestoreData(
  List<MasterDataStruct>? masterDatas,
) =>
    masterDatas?.map((e) => getMasterDataFirestoreData(e, true)).toList() ?? [];
