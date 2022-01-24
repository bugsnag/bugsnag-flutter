abstract class Scenario {
  const Scenario(this.extraConfig);

  final String? extraConfig;

  Future<void> run();
}
