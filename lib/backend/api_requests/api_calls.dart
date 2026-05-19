import 'dart:convert';
import 'dart:typed_data';
import '../schema/structs/index.dart';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class AdresCall {
  static Future<ApiCallResponse> call({
    String? search = '',
  }) async {
    final ffApiRequestBody = '''
{
  "input": "${escapeStringForJson(search)}",
  "languageCode": "ru",
  "regionCode": "RU"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'adres',
      apiUrl: 'https://places.googleapis.com/v1/places:autocomplete',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-FieldMask':
            'suggestions.placePrediction.placeId,suggestions.placePrediction.text,suggestions.placePrediction.structuredFormat',
        'X-Goog-Api-Key': 'AIzaSyDT7xqBZZ0vakT3CGNYrQoRijsLsbW6nTU',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? placeid(dynamic response) => (getJsonField(
        response,
        r'''$.suggestions[:].placePrediction.placeId''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? title(dynamic response) => (getJsonField(
        response,
        r'''$.suggestions[:].placePrediction.text.text''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? description(dynamic response) => (getJsonField(
        response,
        r'''$.suggestions[:].placePrediction.structuredFormat.secondaryText.text''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class IdToGeoCall {
  static Future<ApiCallResponse> call({
    String? placeId = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'idToGeo',
      apiUrl: 'https://places.googleapis.com/v1/places/${placeId}',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': 'AIzaSyDT7xqBZZ0vakT3CGNYrQoRijsLsbW6nTU',
        'X-Goog-FieldMask': 'location,formattedAddress,displayName',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GeocodeCall {
  static Future<ApiCallResponse> call({
    String? adress = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'geocode',
      apiUrl: 'https://maps.googleapis.com/maps/api/geocode/json',
      callType: ApiCallType.GET,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {
        'address': adress,
        'key': "AIzaSyDT7xqBZZ0vakT3CGNYrQoRijsLsbW6nTU",
        'language': "ru",
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? adresID(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.results[:].place_id''',
      ));
  static String? adressTitle(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.results[:].formatted_address''',
      ));
  static double? lat(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.results[:].geometry.location.lat''',
      ));
  static double? lng(dynamic response) => castToType<double>(getJsonField(
        response,
        r'''$.results[:].geometry.location.lng''',
      ));
  static List<String>? shortadress(dynamic response) => (getJsonField(
        response,
        r'''$.results[:].address_components[:].short_name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
