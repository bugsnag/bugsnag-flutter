import 'package:flutter/material.dart';

class BuildErrorWidget extends StatefulWidget {
  const BuildErrorWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BuildErrorWidgetState();
}

class _BuildErrorWidgetState extends State<BuildErrorWidget> {
  bool _isError = false;

  @override
  Widget build(BuildContext context) {
    if (!_isError) {
      return ElevatedButton(
        onPressed: _setErrorState,
        child: const Text('Throw Build Error'),
      );
    } else {
      throw Exception('I am a very bad widget.');
    }
  }

  void _setErrorState() {
    setState(() {
      _isError = true;
    });
  }
}
