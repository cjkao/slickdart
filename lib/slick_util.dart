library slick.util;
import 'dart:html';
import 'dart:math';
import 'dart:collection';
import 'package:logging/logging.dart';
Logger _log = new Logger('slick_util');
/** TODO add scope
 * find element's cloest parent of target css selector rule
 * ancestorClzName : query condition
 *
 */
Element findClosestAncestor(Element element, String cssSelector, [String scope]) {
  assert(element is Element);
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
 * Filtered View is readonly for grid
 * any operation to list => src list
 */
class FilteredList extends ListBase{
  List _srcList, _viewList;
  Map _filter={};

  FilteredList([this._srcList]){
      if(_srcList==null) _srcList=new List();

  }
  /**
   * create new view base on filter,
   * string is partial matching
   * {column: condition}
   */
  set keyword(Map m){
    if(m==null) return;
    _filter =m;
    _viewList=_foldHelper();
  }
  void setKeyword(String key, String val){
    //_viewList=[];
    if(val.length==0){
      _filter.remove(key);
    }else{
      _filter[key]=val;
    }
    _viewList=_foldHelper();
  }
  _foldHelper(){
    List tList=[];
    return new UnmodifiableListView(_srcList.fold(tList, (init,val){
                //_filter.keys.every(test)
                var test = _filter.keys.every((k){
                  if(val[k] is String){
                    return val[k].contains(_filter[k]) ;
                  }else{
                    try{
                      var _num=num.parse(_filter[k]);
                      return  val[k] == _num;
                    }catch(e){
                      return false;
                    }
                  }
                  //return val[k] is String ? val[k].contains(_filter[k]) : val[k] == _filter[k];
                  });
                //  , orElse: ()=>null);
                if(test) tList.add(val);
                return tList;
        }));
  }
  operator [](index) => _filter.length==0 ? _srcList[index] : _viewList[index];
  operator []=(index,value) => _srcList.add(value);
  //for grid internal mask
  get length => _filter.length==0 ? _srcList.length : _viewList.length;
  set length(val){_srcList.length=val;}
  add(val){
    _srcList.add(val);
  }
  addAll(val){
    _srcList.addAll(val);
  }
  clear(){
    _srcList.clear();
    _viewList=new UnmodifiableListView([]);
  }
  bool remove(Object element){
    return _srcList.remove(element);
  }
  void sort([int compare(a, b)]) {
    _srcList.sort(compare);
    if(_viewList!=null && _viewList.length>0)
      _viewList=_foldHelper();
  }

  Iterable get reversed => _srcList.reversed;
  void shuffle([Random random]) {
    _srcList.shuffle(random);
    _viewList.shuffle(random);
  }

  int indexOf(element, [int start = 0]) => _srcList.indexOf(element, start);
  int lastIndexOf(element, [int start]) => _srcList.lastIndexOf(element, start);
  void insert(int index,  element) => _srcList.insert(index, element);

  void insertAll(int index, Iterable iterable) => _srcList.insertAll(index, iterable);

  void setAll(int index, Iterable iterable) => _srcList.setAll(index, iterable);

  removeAt(int index) => _srcList.removeAt(index);

  removeLast() => _srcList.removeLast();
  void removeWhere(bool test( element))=> _srcList.removeWhere(test);

  void retainWhere(bool test(element)) => retainWhere(test);
  List sublist(int start, [int end]) => _srcList.sublist(start,end);
  Iterable getRange(int start, int end) => _srcList.getRange(start,end);

  void setRange(int start, int end, Iterable iterable, [int skipCount = 0]) => _srcList.setRange(start, end, iterable, skipCount);
  void removeRange(int start, int end) => _srcList.removeRange(start,end);
  void fillRange(int start, int end, [fillValue]) => _srcList.fillRange(start, end, fillValue);
  void replaceRange(int start, int end, Iterable replacement) => _srcList.replaceRange(start, end, replacement);
  Map asMap() => _srcList.asMap();



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
