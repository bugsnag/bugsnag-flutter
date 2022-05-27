import '_model_extensions.dart';
import 'metadata.dart';

class BugsnagBreadcrumb {
  String message;
  BugsnagBreadcrumbType type;
  MetadataSection? metadata;

  final DateTime timestamp;

  BugsnagBreadcrumb(
    this.message, {
    this.type = BugsnagBreadcrumbType.manual,
    this.metadata,
  }) : timestamp = DateTime.now().toUtc();

  BugsnagBreadcrumb.fromJson(Map<String, dynamic> json)
      : message = json.safeGet('name'),
        timestamp = DateTime.parse(json['timestamp'] as String).toUtc(),
        type = BugsnagBreadcrumbType.values.byName(json['type'] as String),
        metadata = json
            .safeGet<Map>('metaData')
            ?.let((map) => BugsnagMetadata.sanitizedMap(map.cast()));

  dynamic toJson() => {
        'name': message,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'metaData': metadata ?? {},
      };
}

enum BugsnagBreadcrumbType {
  navigation,
  request,
  process,
  log,
  user,
  state,
  error,
  manual,
}
