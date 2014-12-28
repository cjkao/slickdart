library slick.util;
import 'dart:html';
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
    _viewList=[];
    _foldHelper();
  }
  void setKeyword(String key, String val){
    _viewList=[];
    if(val.length==0){
      _filter.remove(key);
    }else{
      _filter[key]=val;
    }
    _foldHelper();
  }
  _foldHelper(){
    _srcList.fold(_viewList, (init,val){
                var item = _filter.keys.firstWhere((k){
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
                  }
                  , orElse: ()=>null);
                if(item!=null) _viewList.add(val);
                return _viewList;
        });
  }
  operator [](index) => _filter.length==0 ? _srcList[index] : _viewList[index];
  operator []=(index,value) => _srcList.add(value);
  get length => _filter.length==0 ? _srcList.length : _viewList.length;
  set length(val){}
  add(val){
    _srcList.add(val);
  }
  addAll(val){
    _srcList.addAll(val);
  }
  clear(){
    _srcList.clear();
    _viewList.clear();
  }


  void sort([int compare(a, b)]) {
    if(_viewList!=null && _viewList.length>0)
     _viewList.sort(compare);
    else
    _srcList.sort(compare);
  }
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
