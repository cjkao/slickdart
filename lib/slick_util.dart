library slick.util;
import 'dart:html';
import 'dart:collection';
import 'package:logging/logging.dart';
Logger log = new Logger('JGrid');
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
/**
 * when no filter, using default data set, which allow add data
 * filter is active by keyword,
 */
class FilteredList extends ListBase{
  List _srcList, _viewList;
  Map _filter=null;

  FilteredList([this._srcList]){
      if(_srcList==null) _srcList=new List();

  }
  /**
   * create new view base on filter,
   * string is partial matching
   * {column: condition}
   */
  set keyword(Map m){
    _filter =m;
    _viewList=[];
    if(m==null) return;
    _srcList.fold(_viewList, (init,val){
            var item = _filter.keys.firstWhere((k){
              return val[k] is String ? val[k].contains(_filter[k]) : val[k] == _filter[k]; }
              , orElse: ()=>null);
            if(item!=null) _viewList.add(val);
            return _viewList;
    });
  }
  operator [](index) => _filter==null ? _srcList[index] : _viewList[index];
  operator []=(index,value) => _srcList.add(value);
  get length => _filter==null ? _srcList.length : _viewList.length;
  set length(val){}

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
