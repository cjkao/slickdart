library slick.core2;

import 'dart:async';
import "slick_core.dart";
//import  'slick_grid.dart';
typedef EventFun=void Function(dynamic);
/**
 * consider refactor this to stream
 */
class EventStream  {
  Map<Function,StreamSubscription> handlers2 = {};
  StreamController _controller = new StreamController();
  //StreamController sc;
  /***
   * Adds an event handler to be called when the event is fired.
   * <p>Event handler will receive two arguments - an <code>EventData</code> and the <code>data</code>
   * object the event was fired with.<p>
   * @method subscribe
   * @param fn {Function} Event handler.
   */
   subscribe2(EventFun fun){
     var subscribe= _controller.stream.listen(fun);
     handlers2[fun]=subscribe;
   }
  /***
   * Removes an event handler added with <code>subscribe(fn)</code>.
   * @method unsubscribe
   * @param fn {Function} Event handler to be removed.
   */
  unsubscribe(Function fn) {
    handlers2.remove(fn)?.cancel();
  }

  /***
   * Fires an event notifying all subscribers.
   * @method notify
   * @param args {Object} Additional data object to be passed to all handlers.
   * @param e {EventData}
   *      Optional.
   *      An <code>EventData</code> object to be passed to all handlers.
   *      For DOM events, an existing W3C/jQuery event object can be passed in.
   * @param scope {Object}
   *      Optional.
   *      The scope ("this") within which the handler will be executed.
   *      If not specified, the scope will be set to the <code>Event</code> instance.
   */
  notify(EvtArgs args, [EventData e]){
    e ??= new EventData();
    args.eventData=e;
    _controller.add(args);
  }
  ///
  ///  for range change notification
  ///
  ///
  notifyList(List<Range> args) {
    EventData e = new EventData();
    EvtArgs gargs=new EvtArgs(null);

    gargs.eventData=e;
    _controller.add(args);
  }
}


