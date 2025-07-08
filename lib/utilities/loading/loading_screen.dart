import 'package:flutter/material.dart';
import 'loading_screen_controller.dart';

class LoadingScreen {
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();
  factory LoadingScreen() => _shared;

  LoadingScreenController? controller;

  LoadingScreenController _showOverlay({required BuildContext context}) {
    final overlayState = Overlay.of(context);

    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );

    overlayState.insert(overlay);

    return LoadingScreenController(
      close: () {
        overlay.remove();
        return true;
      },
      update: (_) => true,
    );
  }

  void show({required BuildContext context}) {
    if (controller != null) return;
    controller = _showOverlay(context: context);
  }

  void hide() {
    controller?.close();
    controller = null;
  }
}
