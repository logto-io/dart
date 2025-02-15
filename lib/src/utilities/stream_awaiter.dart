import 'dart:async';

Future<void> awaitUriLinkStream(Stream<Uri?> uriLinkStream, Future<void> Function(Uri? uri) onUri) async {
  final completer = Completer<void>();
  late StreamSubscription<Uri?> subscription;

  subscription = uriLinkStream.listen(
    (uri) async {
      try {
        await onUri(uri);
        completer.complete();
      } catch (e) {
        completer.completeError(e);
      } finally {
        await subscription.cancel(); // Ensure subscription is canceled
      }
    },
    onError: (error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    },
    onDone: () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    },
    cancelOnError: true,
  );

  return completer.future;
}