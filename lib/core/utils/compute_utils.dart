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

// Generic helper to offload heavy model to entity mapping to a background isolate
Future<List<T>> computeMapModels<T, M>(
  List<M> models,
  T Function(dynamic) mapper,
) {
  return compute(_mapModelsEntry, _MapModelsArgs<T, M>(models, mapper));
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

// Payload + entry for model mapping
class _MapModelsArgs<T, M> {
  final List<M> models;
  final T Function(dynamic) mapper;
  const _MapModelsArgs(this.models, this.mapper);
}

List<T> _mapModelsEntry<T, M>(_MapModelsArgs<T, M> args) {
  return args.models.map<T>((model) => args.mapper(model)).toList(growable: false);
}


