part of model;

class Device {
  List<String>? cpuAbi;
  String? id;
  bool? jailbroken;
  String? locale;
  String? manufacturer;
  String? modelNumber;
  String? model;
  String? osName;
  String? osVersion;

  Map<String, String>? runtimeVersions;
  int? totalMemory;

  Device.fromJson(Map<String, Object?> json)
      : cpuAbi = json.safeGet('cpuAbi'),
        id = json.safeGet('id'),
        jailbroken = json.safeGet('jailbroken'),
        locale = json.safeGet('locale'),
        manufacturer = json.safeGet('manufacturer'),
        modelNumber = json.safeGet('modelNumber'),
        model = json.safeGet('model'),
        osName = json.safeGet('osName'),
        osVersion = json.safeGet('osVersion'),
        runtimeVersions = json
            .safeGet<Map>('runtimeVersions')
            ?.map((key, value) => MapEntry(key as String, value as String)),
        totalMemory = json.safeGet<num>('totalMemory')?.toInt();

  dynamic toJson() => {
        if (cpuAbi != null) 'cpuAbi': cpuAbi,
        if (id != null) 'id': id,
        if (jailbroken != null) 'jailbroken': jailbroken,
        if (locale != null) 'locale': locale,
        if (manufacturer != null) 'manufacturer': manufacturer,
        if (modelNumber != null) 'modelNumber': modelNumber,
        if (model != null) 'model': model,
        if (osName != null) 'osName': osName,
        if (osVersion != null) 'osVersion': osVersion,
        if (runtimeVersions != null) 'runtimeVersions': runtimeVersions,
        if (totalMemory != null) 'totalMemory': totalMemory,
      };
}

class DeviceWithState extends Device {
  int? freeDisk;
  int? freeMemory;
  String? orientation;
  DateTime? time;

  DeviceWithState.fromJson(Map<String, Object?> json)
      : freeDisk = json.safeGet<num>('freeDisk')?.toInt(),
        freeMemory = json.safeGet<num>('freeMemory')?.toInt(),
        orientation = json.safeGet('orientation'),
        time = json.safeGet<String>('time')?.let(DateTime.parse),
        super.fromJson(json);

  @override
  dynamic toJson() => {
        for (final entry in (super.toJson() as Map<String, dynamic>).entries)
          entry.key: entry.value,
        if (freeDisk != null) 'freeDisk': freeDisk,
        if (freeMemory != null) 'freeMemory': freeMemory,
        if (orientation != null) 'orientation': orientation,
        if (time != null) 'time': time!.toIso8601String(),
      };
}
