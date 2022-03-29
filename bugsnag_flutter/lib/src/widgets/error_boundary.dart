import 'package:bugsnag_flutter/bugsnag.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../client.dart';

void initErrorWidget() {
  ErrorWidget.builder =
      (FlutterErrorDetails details) => _BugsnagErrorWidget(details);
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function() fallback;
  final Client? _client;

  const ErrorBoundary({
    required this.child,
    this.fallback = _defaultFallbackWidget,
    Client? client,
    Key? key,
  })  : _client = client,
        super(key: key);

  Client get _bugsnag => _client ?? bugsnag;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();

  static Widget _defaultFallbackWidget() {
    // TODO: An appropriate error fallback
    return const Center();
  }
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Widget? _fallbackWidget;

  void reportError(FlutterErrorDetails errorDetails) {
    SchedulerBinding.instance?.scheduleTask(
      () {
        setState(() {
          _fallbackWidget = widget.fallback();
        });
      },
      Priority.idle,
    );
  }

  @override
  Widget build(BuildContext context) {
    var fallbackWidget = _fallbackWidget;
    if (fallbackWidget == null) {
      return widget.child;
    } else {
      return fallbackWidget;
    }
  }
}

class _BugsnagErrorWidget extends LeafRenderObjectWidget {
  final FlutterErrorDetails errorDetails;

  const _BugsnagErrorWidget(this.errorDetails);

  @override
  RenderObject createRenderObject(BuildContext context) {
    context
        .findAncestorStateOfType<_ErrorBoundaryState>()
        ?.reportError(errorDetails);
    return _BugsnagErrorRenderBox();
  }
}

class _BugsnagErrorRenderBox extends RenderBox {
  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = Size.zero;
  }
}
