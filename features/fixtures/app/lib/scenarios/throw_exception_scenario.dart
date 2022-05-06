import 'scenario.dart';

class ThrowExceptionScenario extends Scenario {
  @override
  Future<void> run() /* non-async */ {
    throw Exception("Simple Runtime Exception");
  }
}
