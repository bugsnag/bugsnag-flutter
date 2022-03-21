import '_model_extensions.dart';

/// Represents a single feature-flag / experiment marker within Bugsnag.
/// Each `FeatureFlag` has a mandatory [name] and optional [variant] that can
/// be used to identify runtime experiments and groups when reporting errors.
///
/// See also:
/// - [FeatureFlags]
class FeatureFlag {
  String name;
  String? variant;

  FeatureFlag(this.name, [this.variant]);

  FeatureFlag.fromJson(Map<String, Object?> json)
      : name = json.safeGet('featureFlag'),
        variant = json.safeGet('variant');

  dynamic toJson() => {
        'featureFlag': name,
        if (variant != null) 'variant': variant,
      };
}

class FeatureFlags {
  final Map<String, String?> _content;

  FeatureFlags() : _content = {};

  FeatureFlags.fromJson(List<Map<String, Object?>> json)
      : _content = {
          for (final flagJson in json)
            flagJson['featureFlag'] as String: flagJson['variant'] as String?,
        };

  operator []=(String name, String? variant) {
    addFeatureFlag(name, variant);
  }

  void addFeatureFlag(String name, [String? variant]) {
    _content[name] = variant;
  }

  void clearFeatureFlag(String name) {
    _content.remove(name);
  }

  void clearFeatureFlags() {
    _content.clear();
  }

  dynamic toJson() => [
        for (final entry in _content.entries)
          {
            'featureFlag': entry.key,
            if (entry.value != null) 'variant': entry.value,
          }
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeatureFlags &&
          runtimeType == other.runtimeType &&
          _content.deepEquals(other._content);

  @override
  int get hashCode => _content.hashCode;
}
