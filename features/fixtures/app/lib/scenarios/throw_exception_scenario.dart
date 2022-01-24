import 'scenario.dart';

class ThrowExceptionScenario extends Scenario {
  ThrowExceptionScenario(String? extraConfig) : super(extraConfig);

  @override
  Future<void> run() /* non-async */ {
    throw Exception("Simple Runtime Exception");
  }
}