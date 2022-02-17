import 'package:flutter/foundation.dart';

Future<List<String>> listPackages() async {
  var packages = <String>{};
  // The license registry has a list of licenses entries (MIT, Apache...).
  // Each license entry has a list of packages which licensed under this particular license.
  // Libraries can be dual licensed.
  //
  // We don't care about those license issues, we just want each package name once.
  // Therefore we add each name to a set to make sure we only add it once.
  await LicenseRegistry.licenses.forEach(
    (entry) => packages.addAll(
      entry.packages.toList(),
    ),
  );

  return List.from(packages);
}
