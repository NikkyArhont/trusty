import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/auth/firebase_auth/auth_util.dart';

List<PlaceStruct>? createCityList(String? vocab) {
  if (vocab == null || vocab.trim().isEmpty) return [];

  dynamic source;
  try {
    source = jsonDecode(vocab);
  } catch (_) {
    return [];
  }

  if (source is Map<String, dynamic>) {
    if (source['data'] is List) {
      source = source['data'];
    } else if (source['cities'] is List) {
      source = source['cities'];
    } else {
      return [];
    }
  }

  if (source is! List) return [];

  String normalize(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('ё', 'е')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-zA-Zа-яА-Я0-9_]+'), '');
  }

  final List<PlaceStruct> result = [];

  for (int i = 0; i < source.length; i++) {
    final item = source[i];
    if (item is! Map) continue;

    final map = Map<String, dynamic>.from(item as Map);

    final name = (map['name'] ?? '').toString().trim();
    if (name.isEmpty) continue;

    final subject = (map['subject'] ?? '').toString().trim();
    final district = (map['district'] ?? '').toString().trim();

    Map<String, dynamic> coords = {};
    final coordsRaw = map['coords'];
    if (coordsRaw is Map) {
      coords = Map<String, dynamic>.from(coordsRaw);
    }

    final lat = double.tryParse((coords['lat'] ?? '').toString());
    final lng =
        double.tryParse((coords['lon'] ?? coords['lng'] ?? '').toString());

    if (lat == null || lng == null) continue;

    final descriptionParts = <String>[];
    if (subject.isNotEmpty) descriptionParts.add(subject);
    if (district.isNotEmpty) descriptionParts.add(district);

    final description = descriptionParts.join(', ');

    final baseId = [
      normalize(name),
      if (subject.isNotEmpty) normalize(subject),
      if (district.isNotEmpty) normalize(district),
      (i + 1).toString(),
    ].join('_');

    result.add(
      PlaceStruct(
        title: name,
        description: description,
        id: baseId,
        cityId: baseId,
        location: LatLng(lat, lng),
      ),
    );
  }

  return result;
}

List<PlaceStruct>? searchCityText(
  List<PlaceStruct>? listCity,
  String? text,
) {
  if (listCity == null || listCity.isEmpty) return [];
  if (text == null || text.trim().isEmpty) {
    return listCity.take(20).toList();
  }

  String normalize(String value) {
    return value.toLowerCase().trim().replaceAll('ё', 'е');
  }

  final query = normalize(text);

  final List<PlaceStruct> startsWithMatches = [];
  final List<PlaceStruct> containsMatches = [];

  for (final city in listCity) {
    final title = normalize(city.title);

    if (title.startsWith(query)) {
      startsWithMatches.add(city);
    } else if (title.contains(query)) {
      containsMatches.add(city);
    }
  }

  final result = <PlaceStruct>[
    ...startsWithMatches,
    ...containsMatches,
  ];

  return result.take(20).toList();
}

PlaceStruct? searchCityLocation(
  List<PlaceStruct>? listCity,
  LatLng? loc,
) {
  if (listCity == null || listCity.isEmpty || loc == null) return null;

  double toRad(double deg) => deg * math.pi / 180.0;

  double distanceInKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371.0;

    final dLat = toRad(lat2 - lat1);
    final dLng = toRad(lng2 - lng1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(toRad(lat1)) *
            math.cos(toRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  PlaceStruct? nearestCity;
  double minDistance = double.infinity;

  for (final city in listCity) {
    final cityLoc = city.location;
    if (cityLoc == null) continue;

    final dist = distanceInKm(
      loc.latitude,
      loc.longitude,
      cityLoc.latitude,
      cityLoc.longitude,
    );

    if (dist < minDistance) {
      minDistance = dist;
      nearestCity = city;
    }
  }

  return nearestCity;
}

LatLng? dobleTOloc(
  double? lat,
  double? lon,
) {
  if (lat == null || lon == null) return null;

  return LatLng(lat, lon);
}
