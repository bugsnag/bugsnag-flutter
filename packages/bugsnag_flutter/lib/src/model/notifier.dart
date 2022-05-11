import '_model_extensions.dart';

/// Information about this library, including name and version.
class BugsnagNotifier {
  String name;
  String version;
  String url;

  List<BugsnagNotifier> dependencies;

  BugsnagNotifier.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        version = json['version'],
        url = json['url'],
        dependencies = json
                .safeGet<List>('dependencies')
                ?.cast<Map>()
                .map((notifier) => BugsnagNotifier.fromJson(notifier.cast()))
                .toList(growable: true) ??
            <BugsnagNotifier>[];

  dynamic toJson() => {
        'name': name,
        'version': version,
        'url': url,
        if (dependencies.isNotEmpty) 'dependencies': dependencies,
      };
}
