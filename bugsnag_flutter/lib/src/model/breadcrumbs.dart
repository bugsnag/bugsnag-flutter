import '_model_extensions.dart';
import 'metadata.dart';

class Breadcrumb {
  String message;
  BreadcrumbType type;
  MetadataSection? metadata;

  final DateTime timestamp;

  Breadcrumb(
    this.message, {
    this.type = BreadcrumbType.user,
    this.metadata,
  }) : timestamp = DateTime.now();

  Breadcrumb.fromJson(Map<String, dynamic> json)
      : message = json.safeGet('name'),
        timestamp = DateTime.parse(json['timestamp'] as String),
        type = BreadcrumbType.values.byName(json['type'] as String),
        metadata = json
            .safeGet<Map>('metaData')
            ?.let((map) => Metadata.sanitizedMap(map.cast()));

  dynamic toJson() => {
        'name': message,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        if (metadata != null) 'metaData': metadata,
      };
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
