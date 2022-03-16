part of model;

class Breadcrumb extends _JsonObject {
  Breadcrumb(
    String message, {
    BreadcrumbType type = BreadcrumbType.user,
    MetadataSection? metadata,
  }) : super.fromJson({
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
          'type': type.name,
          if (metadata != null) 'metaData': Metadata.sanitizedMap(metadata),
        });

  Breadcrumb.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  String get message => _json['message'] as String;

  set message(String message) => _json['message'] = message;

  DateTime get timestamp => DateTime.parse(_json['timestamp'] as String);

  BreadcrumbType get type =>
      BreadcrumbType.values.byName(_json['type'] as String);

  set type(BreadcrumbType type) => _json['type'] = type.name;

  MetadataSection? get metadata => _json['metaData'] as MetadataSection?;

  set metadata(MetadataSection? metadata) {
    if (metadata != null) {
      _json['metaData'] = Metadata.sanitizedMap(metadata);
    } else {
      _json.remove('metaData');
    }
  }
}

enum BreadcrumbType {
  navigation,
  request,
  process,
  log,
  user,
  state,
  error,
  manual,
}
