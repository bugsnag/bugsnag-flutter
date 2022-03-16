part of model;

class Notifier {
  String name;
  String version;
  String url;

  List<Notifier> dependencies;

  Notifier.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        version = json['version'],
        url = json['url'],
        dependencies = json
                .safeGet<List>('dependencies')
                ?.cast<Map>()
                .map((notifier) => Notifier.fromJson(notifier.cast()))
                .toList(growable: true) ??
            <Notifier>[];

  dynamic toJson() => {
        'name': name,
        'version': version,
        'url': url,
        if (dependencies.isNotEmpty) 'dependencies': dependencies,
      };
}
