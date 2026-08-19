// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RecommendationStruct extends FFFirebaseStruct {
  RecommendationStruct({
    String? phone,
    String? comment,
    DateTime? date,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  }) : _phone = phone,
       _comment = comment,
       _date = date,
       super(firestoreUtilData);

  // "phone" field.
  String? _phone;
  String get phone => _phone ?? '';
  set phone(String? val) => _phone = val;

  bool hasPhone() => _phone != null;

  // "comment" field.
  String? _comment;
  String get comment => _comment ?? '';
  set comment(String? val) => _comment = val;

  bool hasComment() => _comment != null;

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  set date(DateTime? val) => _date = val;

  bool hasDate() => _date != null;

  static RecommendationStruct fromMap(Map<String, dynamic> data) =>
      RecommendationStruct(
        phone: data['phone'] as String?,
        comment: data['comment'] as String?,
        date: data['date'] as DateTime?,
      );

  static RecommendationStruct? maybeFromMap(dynamic data) => data is Map
      ? RecommendationStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() =>
      {'phone': _phone, 'comment': _comment, 'date': _date}.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
    'phone': serializeParam(_phone, ParamType.String),
    'comment': serializeParam(_comment, ParamType.String),
    'date': serializeParam(_date, ParamType.DateTime),
  }.withoutNulls;

  static RecommendationStruct fromSerializableMap(Map<String, dynamic> data) =>
      RecommendationStruct(
        phone: deserializeParam(data['phone'], ParamType.String, false),
        comment: deserializeParam(data['comment'], ParamType.String, false),
        date: deserializeParam(data['date'], ParamType.DateTime, false),
      );

  @override
  String toString() => 'RecommendationStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is RecommendationStruct &&
        phone == other.phone &&
        comment == other.comment &&
        date == other.date;
  }

  @override
  int get hashCode => const ListEquality().hash([phone, comment, date]);
}

RecommendationStruct createRecommendationStruct({
  String? phone,
  String? comment,
  DateTime? date,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) => RecommendationStruct(
  phone: phone,
  comment: comment == null ? null : normalizeUserText(comment),
  date: date,
  firestoreUtilData: FirestoreUtilData(
    clearUnsetFields: clearUnsetFields,
    create: create,
    delete: delete,
    fieldValues: fieldValues,
  ),
);

RecommendationStruct? updateRecommendationStruct(
  RecommendationStruct? recommendation, {
  bool clearUnsetFields = true,
  bool create = false,
}) => recommendation
  ?..firestoreUtilData = FirestoreUtilData(
    clearUnsetFields: clearUnsetFields,
    create: create,
  );

void addRecommendationStructData(
  Map<String, dynamic> firestoreData,
  RecommendationStruct? recommendation,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (recommendation == null) {
    return;
  }
  if (recommendation.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && recommendation.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final recommendationData = getRecommendationFirestoreData(
    recommendation,
    forFieldValue,
  );
  final nestedData = recommendationData.map(
    (k, v) => MapEntry('$fieldName.$k', v),
  );

  final mergeFields = recommendation.firestoreUtilData.create || clearFields;
  firestoreData.addAll(
    mergeFields ? mergeNestedFields(nestedData) : nestedData,
  );
}

Map<String, dynamic> getRecommendationFirestoreData(
  RecommendationStruct? recommendation, [
  bool forFieldValue = false,
]) {
  if (recommendation == null) {
    return {};
  }
  final firestoreData = mapToFirestore(recommendation.toMap());

  // Add any Firestore field values
  mapToFirestore(
    recommendation.firestoreUtilData.fieldValues,
  ).forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getRecommendationListFirestoreData(
  List<RecommendationStruct>? recommendations,
) =>
    recommendations
        ?.map((e) => getRecommendationFirestoreData(e, true))
        .toList() ??
    [];
