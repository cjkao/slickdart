import 'dart:html';
import 'dart:math' as math;

class MyWorker {
  DedicatedWorkerGlobalScope dws = DedicatedWorkerGlobalScope.instance;

  MyWorker() {
    print('Worker Running');

    dws.onMessage.listen((MessageEvent evt) {
      print(evt.data);
      print(evt.data.runtimeType);
      MessagePort port = evt.data["port"];
      print(port);
      port.postMessage(makeData(100));
    });
  }
}

List makeData(int len) {
  List _data = [];
  for (var i = 0; i < len; i++) {
    _data.add({
      'title': i,
      'duration': math.Random().nextInt(20),
      'percent': i % 10,
      'pc': (math.Random().nextInt(10) * 100).toString(),
      'start': "01/01/2009",
      'finish': (math.Random().nextInt(10) + 10).toString() + "/05/2013",
      'effortDriven': (i % 5 == 0)
    });
  }
  return _data;
}

main() {
  MyWorker();
}
