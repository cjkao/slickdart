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




/**
 * meta data interface for data
 * Meta data is a list wrappper that provide getMetaData when need override style in row rendering
 */
abstract class IMetaData{
  Map getMetaData(int rowId);
  void setMetaData(Function metaFunc);
}
class MetaList<T> extends ListBase<T> with IMetaData{
  Function _func;
  List<T> innerList;
  MetaList(this.innerList, [this._func]){

  }

  Map getMetaData(int rowId){
    return _func(rowId);
  }
  void setMetaData(_) => _func = _;

  int get length => innerList.length;

  void set length(int length) {
        innerList.length = length;
  }
  void operator[]=(int index, T value) {
    innerList[index] = value;
  }
  T operator [](int index) => innerList[index];

  // Though not strictly necessary, for performance reasons
  // you should implement add and addAll.

  void add(T value) => innerList.add(value);

  void addAll(Iterable<T> all) => innerList.addAll(all);



}
