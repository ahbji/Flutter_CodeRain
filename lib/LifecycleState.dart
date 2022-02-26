import 'package:flutter/material.dart';

class LifecycleStateHandler {
  LifecycleStateHandler({
    this.onResumed,
    this.onPaused,
    this.onInactive,
    this.onDetached,
});
  final VoidCallback? onResumed;
  final VoidCallback? onPaused;
  final VoidCallback? onInactive;
  final VoidCallback? onDetached;
}

abstract class LifecycleState<W extends StatefulWidget> extends State<W> with WidgetsBindingObserver {

  LifecycleStateHandler? lifecycleStateHandler;

  void setLifecycleStateHandler() {
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    setLifecycleStateHandler();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state) {
      case AppLifecycleState.resumed:
        lifecycleStateHandler?.onResumed?.call();
        break;
      case AppLifecycleState.paused:
        lifecycleStateHandler?.onPaused?.call();
        break;
      case AppLifecycleState.inactive:
        lifecycleStateHandler?.onInactive?.call();
        break;
      case AppLifecycleState.detached:
        lifecycleStateHandler?.onDetached?.call();
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}