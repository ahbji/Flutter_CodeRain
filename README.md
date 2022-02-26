# Flutter 实现《黑客帝国》代码雨

## 实现目标
- 
- 背景为黑色
- “代码雨”由随机字符组成
- "代码雨"的长度有所不同
- “代码雨”从屏幕顶部随机水平位置开始
- 每隔 300 ms 新生成一条 “代码雨”
- “代码雨”中最新的字符始终为白色，之前的字符颜色为绿色，并且使用线性渐变将最早字符淡出

## 执行

首先从 main 函数开始：
- 实现 Edge to Edge 效果
- 设置 UI 背景色为黑色

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(top: 50),
        child: VerticalTextLine(),
      ),
    );
  }
}
```

接着实现单列代码雨： 

首先使用 Column 作为容器实现一个简单的垂直布局，另外需要在初始化时设置代码雨的降落速度和最大长度。

```dart
class VerticalTextLine extends StatefulWidget {
  const VerticalTextLine({
    this.speed = 12.0,
    this.maxLength = 10,
    Key? key,
  }) : super(key: key);

  final double speed;
  final int maxLength;

  @override
  _VerticalTextLineState createState() => _VerticalTextLineState();
}

class _VerticalTextLineState extends State<VerticalTextLine> {
  List<String> _characters = ['T', 'E', 'S', 'T'];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: _getCharacters(),
    );
  }

  List<Widget> _getCharacters() {
    List<Widget> textWidgets = [];
    for (var character in _characters) {
      textWidgets.add(
        Text(
          character,
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return textWidgets;
  }
}
```

“代码雨”只有最新的字符是白色的，其余字符从绿色线性渐变到淡出。

为了将文本显示为渐变，这里使用 ShaderMask 包裹 Column：
- `shaderCallback` 参数需要一个传参矩形边框并返回 Shader 的函数，所以可利用线性渐变 LinearGradient 对象的 createShader 方法创建 Shader 对象。
- `blendMode` 参数设置为 BlendMode.srcIn 将 `shaderCallback` 参数的 Shader 对象与 Column 的背景色混合。

然后构建 LinearGradient 对象：
- 使用 List 定义颜色的渐变梯度 colors
- 定义与 colors 对应的渐变梯度的位置 stops:
  - 0 -> greenStart 之间为淡出
  - greenStart -> whiteStart 之间为绿色
  - whiteStart 为白色

最后分别确定 greenStart 和 whiteStart 的值。

```dart
class _VerticalTextLineState extends State<VerticalTextLine> {
  List<String> _characters = ['T', 'E', 'S', 'T'];

  late int _maxLength;

  @override
  void initState() {
    _maxLength = widget.maxLength;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [Colors.transparent, Colors.green, Colors.green, Colors.white];
    double greenStart;
    double whiteStart;

    whiteStart = (_characters.length - 1) / (_characters.length);
    if (((_characters.length - _maxLength) / _characters.length) < 0.3) {
      greenStart = 0.3;
    }
    else {
      greenStart = (_characters.length - _maxLength) / _characters.length;
    }
    List<double> stops = [0, greenStart, whiteStart, whiteStart];
    return _getShaderMask(stops, colors);
  }

  ShaderMask _getShaderMask(List<double> stops, List<Color> colors) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: stops,
          colors: colors,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: _getCharacters(),
      ),
    );
  }
  
  List<Widget> _getCharacters() {
    ...
  }
}
```

接下来使用 Timer 按照固定间隔动态生成代码雨中的字符：

```dart
class _VerticalTextLineState extends State<VerticalTextLine> {
  List<String> _characters = [];
  ...
  late Duration _stepInterval;
  late Timer timer;

  @override
  void initState() {
    ...
    _stepInterval = Duration(milliseconds: (1000 ~/ widget.speed));
    _startTimer();
    super.initState();
  }
  ...
  void _startTimer() {
    timer = Timer.periodic(_stepInterval, (timer) {
      final _random = new Random();
      String element = String.fromCharCode(
              _random.nextInt(512)
      );
      setState(() {
        _characters.add(element);
      });
    });
  }
  ...
}
```

最后需要创建一个 Widget ，将动态创建“代码雨”：
- 使用 Timer 每隔 300ms 生成一个“代码雨”
- 使用 Positioned 包裹 VerticalTextLine 对象，左对齐 left 位置在 0 到屏幕宽度之间随机生成
- “代码雨”的 speed 为 1.0 到 10.0 之间的随机数
- “代码雨”的 maxLength 为 10 到 15 之间的随机数

```dart
class MatrixEffect extends StatefulWidget {
  const MatrixEffect({Key? key}) : super(key: key);

  @override
  _MatrixEffectState createState() => _MatrixEffectState();
}

class _MatrixEffectState extends State<MatrixEffect> {
  List<Widget> _verticalLines = [];
  late Timer timer;

  @override
  void initState() {
    _startTimer();
    super.initState();
  }

  void _startTimer() {
    timer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      setState(() {
        _verticalLines.add(
            _getVerticalTextLine(context)
        );
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: _verticalLines
    );
  }

  Widget _getVerticalTextLine(BuildContext context) {
    Key key = GlobalKey();
    return Positioned(
      key: key,
      left: Random().nextDouble() * MediaQuery.of(context).size.width,
      child: VerticalTextLine(
          speed: 1 + Random().nextDouble() * 9,
          maxLength: Random().nextInt(10) + 5
      ),
    );
  }
}
```

## 优化

第一个问题：

我们生成的每一个代码雨，都永远留在 Widget 树中，总是会占用内存。这导致应用程序在短时间内变得非常滞后。

需要 VerticalTextLine 来决定何时清理，并通过回调在父容器中执行清理操作。

消失的条件是当前渲染的 VerticalTextLine 的大小是当前屏幕高度的两倍时。

这样，消失的那一刻应该足够平滑，不会被用户注意到。计时器不需要手动取消，因为 onDispose 无论如何我们都会这样做。

```dart
class VerticalTextLine extends StatefulWidget {
  const VerticalTextLine({
    required this.onFinished,
    ...
  }) : super(key: key);

  ...
  final VoidCallback onFinished;
  ...
}

class _VerticalTextLineState extends State<VerticalTextLine> {
  ...

  void _startTimer() {
    timer = Timer.periodic(_stepInterval, (timer) {
      ...

      final box = context.findRenderObject() as RenderBox;
      if (box.size.height > MediaQuery.of(context).size.height * 2) {
        widget.onFinished();
        return;
      }
      ...
    });
  }
  ...
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

class _MatrixEffectState extends State<MatrixEffect> {
  List<Widget> _verticalLines = [];
  ...
  Widget _getVerticalTextLine(BuildContext context) {
    ...
    return Positioned(
      ...
      child: VerticalTextLine(
              onFinished: () {
                setState(() {
                  _verticalLines.removeWhere((element) {
                    return element.key == key;
                  });
                });
              },
              ...
      ),
    );
  }
}
```

第二个问题:

应用挂入后台后 timer 需要取消，需要使用 WidgetsBinding 监听 WidgetsBindingObserver 。

WidgetsBindingObserver是一个 Widgets 绑定观察器，通过它来监听应用的生命周期，使用混入的方式绑定观察器，并且需要在 dispose 回调方法中移除这个监听。

由于 VerticalTextLine 和 MatrixEffect 这两个 Widget 都需要监听 WidgetsBindingObserver ，这里定义 LifecycleState 泛型类继承 State ，并混入 WidgetsBindingObserver 实现对生命周期的监听。

```dart
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
```

Widget 中则继承 LifecycleState ，并设置 LifecycleStateHandler 实现根据 LifecycleState 变化操作 timer 。

```dart
class _MatrixEffectState extends LifecycleState<MatrixEffect> {
  ...
  late Timer timer;

  @override
  void setLifecycleStateHandler() {
    lifecycleStateHandler = LifecycleStateHandler(
      onResumed: () => _startTimer(),
      onPaused: () => _cancelTimer(),
      onInactive: () => _cancelTimer(),
      onDetached: () => _cancelTimer(),
    );
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        _verticalLines.add(
                _getVerticalTextLine(context)
        );
      });
    });
  }

  void _cancelTimer() {
    timer.cancel();
  }
  ...
}
```

## 总结 

使用 ShaderMask、 LinearGradient、 Timer 和 GlobalKey，能够快速实现 Matrix 中“代码雨”效果，通过监听 WidgetsBindingObserver 获取 AppLifecycleState 变化操作 timer 可以优化此效果运行。