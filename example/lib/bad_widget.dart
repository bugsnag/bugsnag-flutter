import 'package:flutter/material.dart';

class BadWidget extends StatefulWidget {
  const BadWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BadWidgetState();
}

class _BadWidgetState extends State<BadWidget> {
  bool _isError = false;

  @override
  Widget build(BuildContext context) {
    if (!_isError) {
      return ElevatedButton(
        onPressed: _setErrorState,
        child: const Text('Throw Error from Widget.build()'),
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
