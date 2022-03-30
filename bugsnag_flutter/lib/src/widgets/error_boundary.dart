import 'package:bugsnag_flutter/bugsnag.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

bool _errorBoundaryEnabled = false;

void _initErrorWidget() {
  if (_errorBoundaryEnabled) {
    return;
  }

  final fallbackErrorBuilder = ErrorWidget.builder;
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return _BugsnagErrorWidget(details, fallbackErrorBuilder);
  };

  _errorBoundaryEnabled = true;
}

/// An ErrorBoundary protects it's parent Widgets from errors during [build]s
/// in a more controllable way than the standard [ErrorWidget] system.
/// Errors occurring in any widget nested within an [ErrorBoundary] will cause
/// the entire [ErrorBoundary] content to be replaced with it's fallback
/// widget, which can be customised to offer useful user functionality (such
/// as a Retry option). Errors caught by an [ErrorBoundary] are reported to
/// Bugsnag as [EnabledErrorTypes.unhandledExceptions].
///
/// The creation of the [fallback] widget happens within a stable rebuild
/// allowing more complex widgets than the standard [ErrorWidget].
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final WidgetBuilder fallback;
  final Client? _client;
  final String? errorContext;

  ErrorBoundary({
    Key? key,
    Client? client,
    this.errorContext,
    required this.child,
    required this.fallback,
  })  : _client = client,
        super(key: key) {
    _initErrorWidget();
  }

  Client get client => _client ?? bugsnag;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _isErrorState = false;

  void reportError(FlutterErrorDetails errorDetails) {
    // we schedule the actual setState between frames
    SchedulerBinding.instance?.scheduleTask(
      () {
        try {
          // FIXME: Notify this as a full FlutterErrorDetails
          widget.client.notify(
            errorDetails.exception,
            stackTrace: errorDetails.stack,
            callback: (event) {
              event.context = widget.errorContext;
              return true;
            },
          ).ignore();
        } catch (e, stack) {
          // most likely Bugsnag has not been attached / started - we need to
          // report this error *without* re-triggering the ErrorBoundary
          _handleNotifyFailure(e, stack);
        }

        setState(() => _isErrorState = true);
      },
      Priority.animation,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isErrorState) {
      return widget.child;
    } else {
      return widget.fallback(context);
    }
  }

  void _handleNotifyFailure(dynamic e, StackTrace stack) {
    // we attempt to report this using the default FlutterError mechanism
    // this bypassing a `throw` which is likely to cause an error-loop with
    // any parent ErrorBoundary widgets
    FlutterError.onError?.call(
      FlutterErrorDetails(
        exception: e,
        stack: stack,
        library: 'Bugsnag',
      ),
    );
  }
}

class _BugsnagErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;
  final ErrorWidgetBuilder fallbackErrorBuilder;

  const _BugsnagErrorWidget(this.errorDetails, this.fallbackErrorBuilder);

  @override
  Widget build(BuildContext context) {
    final boundary = context.findAncestorStateOfType<_ErrorBoundaryState>();
    if (boundary != null) {
      boundary.reportError(errorDetails);
      return const SizedBox.shrink();
    } else {
      return fallbackErrorBuilder(errorDetails);
    }
  }
}
