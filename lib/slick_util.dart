library slick.util;
import 'dart:html';
import 'package:logging/logging.dart';
var log = new Logger('JGrid');
/** TODO add scope
 * find element's cloest parent of target css selector rule
 * ancestorClzName : query condition
 *
 */
Element findClosestAncestor(Element element, String cssSelector, [String scope]) {
  if (element == null) return null;
  do {
    if (element.matches(cssSelector)) return element;
    element = element.parent;
  } while (element != null);
  return null;
}

//
//class Throttler{
//
//  Duration delay;
//  var callback;
//  //List args;
//  bool noTrailing;
//
//  Throttler(this.delay, this.callback, [this.noTrailing=false]);
//
//  var timeoutId=null;
//
//  DateTime lastExec = new DateTime.now();
//
//  void throttle(args) {
//
//    Duration elapsed = new DateTime.now().difference(lastExec);
//
//    void exec() {
//      lastExec = new DateTime.now();
//      callback(args);
//    }
//
//    if(elapsed.compareTo(delay) >= 0) {
//      exec();
//    }
//    //cancel the timeout scheduled for trailing callback
//    if(timeoutId != null)
//      timeoutId.cancel();
//
//    if( noTrailing == false) {
//      //there should be a trailing callback, so schedule one
//      //buggy here, should be 'delay - elasped' but dart async only supports const Duration for delay
//      timeoutId = new Timer(delay, exec);
//    }
//  }
//}
