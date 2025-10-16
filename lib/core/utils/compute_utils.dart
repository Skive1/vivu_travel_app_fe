import 'package:flutter/foundation.dart';

// Generic helper to offload heavy JSON list mapping to a background isolate
Future<List<T>> computeMapList<T>(
  List<dynamic> source,
  T Function(Map<String, dynamic>) fromJson,
) {
  return compute(_mapListEntry, _MapListArgs<T>(source, fromJson));
}

// Generic helper to offload heavy JSON object parsing to a background isolate
Future<T> computeParseObject<T>(
  Map<String, dynamic> json,
  T Function(Map<String, dynamic>) fromJson,
) {
  return compute(_parseObjectEntry, _ParseObjectArgs<T>(json, fromJson));
}

// Payload + entry for list mapping
class _MapListArgs<T> {
  final List<dynamic> source;
  final T Function(Map<String, dynamic>) fromJson;
  const _MapListArgs(this.source, this.fromJson);
}

List<T> _mapListEntry<T>(_MapListArgs<T> args) {
  return args.source
      .cast<Map<String, dynamic>>()
      .map<T>(args.fromJson)
      .toList(growable: false);
}

// Payload + entry for single object parsing
class _ParseObjectArgs<T> {
  final Map<String, dynamic> json;
  final T Function(Map<String, dynamic>) fromJson;
  const _ParseObjectArgs(this.json, this.fromJson);
}

T _parseObjectEntry<T>(_ParseObjectArgs<T> args) {
  return args.fromJson(args.json);
}


