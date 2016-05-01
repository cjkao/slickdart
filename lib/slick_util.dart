library slick.util;

import 'dart:html';
import 'dart:math';
import 'dart:collection';
import 'package:logging/logging.dart';
import 'slick_core.dart' as core;
import 'dart:convert';
import 'slick_column.dart' show TFormatter;
Logger _log = new Logger('slick.util');

///
/// compute scrollbar width
///
/*
int getScrollbarWidth() {
  var outer = document.createElement("div");
  outer.style.visibility = "hidden";
  outer.style.width = "100px";
  document.body.append(outer);

  var widthNoScroll = outer.offsetWidth;
  // force scrollbars
  outer.style.overflow = "scroll";

  // add innerdiv
  var inner = document.createElement("div");
  inner.style.width = "100%";
  outer.append(inner);

  var widthWithScroll = inner.offsetWidth;

  // remove divs
  outer.remove();

  return widthNoScroll - widthWithScroll;
}
*/

//tailer for html style
NullTreeSanitizer nullTreeSanitizer = new NullTreeSanitizer();

///
///Sanitizer which does nothing.
///
class NullTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(Node node) {}
}

Map<String, int> measureScrollbar() {
  var $c = querySelector('body')
      .createFragment(
          "<div style='position:absolute; top:-10000px; left:-10000px; width:100px; height:100px; overflow:scroll;'></div>",
          treeSanitizer: nullTreeSanitizer)
      .children
      .first;

  querySelector('body').append($c);
  CssStyleDeclaration style = $c.getComputedStyle();
  Map<String,int> dim = {
    'width': core.Dimension.getCalcWidth($c) - $c.clientWidth,
    'height': core.Dimension.getCalcHeight($c) - $c.clientHeight
  };
  $c.remove();
  return dim;
}

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
class FilteredList extends ListBase {
  List _srcList, _viewList;
  /**
   * field name ->  condition or function
   */
  Map<String, dynamic> _filter = {};

  FilteredList([this._srcList]) {
    _srcList ??= new List();
  }
  //Constructor from a Map
  FilteredList.fromMap(Map map) {
    _srcList = map == null ? new List() : new List.from(map.values);
  }
  /**
   * create new view base on filter, only matched item will show
   * string is partial matching
   * {column: condition}
   */
  set keyword(Map<String, dynamic> m) {
    if (m == null) return;
    _filter = m;
    _viewList = _foldHelper();
  }

  void setKeyword(String key, Object val) {
    //_viewList=[];
    if (val is String && val.length == 0) {
      _filter.remove(key);
    } else {
      _filter[key] = val;
    }
    _viewList = _foldHelper();
  }

  /**
   * when src is changed, regenerate view
   */
  void invalidate() {
    _viewList = _foldHelper();
  }

  void removeKeyword(String key) {
    _filter.remove(key);
  }

  _foldHelper() {
    return new UnmodifiableListView(_srcList.fold([], (List init, val) {
      var test = _filter.keys.every((k) {
        if (val[k] is String) {
          return val[k].contains(_filter[k]);
        } else if (val[k] is bool) {
          return val[k] == _filter[k];
        } else {
          try {
            var _num = num.parse(_filter[k]);
            return val[k] == _num;
          } catch (e) {
            return false;
          }
        }
      });
      if (test) init.add(val);
      return init;
    }));
  }

  operator [](index) => _filter.length == 0 ? _srcList[index] : _viewList[index];
  operator []=(index, value) => _srcList.add(value);
  //for grid internal mask
  get length => _filter.length == 0 ? _srcList.length : _viewList.length;
  set length(val) {
    _srcList.length = val;
  }

  add(val) {
    _srcList.add(val);
  }

  addAll(val) {
    _srcList.addAll(val);
  }

  clear() {
    _srcList.clear();
    _viewList = new UnmodifiableListView([]);
  }

  bool remove(Object element) {
    return _srcList.remove(element);
  }

  void sort([int compare(a, b)]) {
    _srcList.sort(compare);
    if (_viewList != null && _viewList.length > 0) _viewList = _foldHelper();
  }

  Iterable get reversed => _srcList.reversed;
  void shuffle([Random random]) {
    _srcList.shuffle(random);
    _viewList.shuffle(random);
  }

  int indexOf(element, [int start = 0]) => _srcList.indexOf(element, start);
  int lastIndexOf(element, [int start]) => _srcList.lastIndexOf(element, start);
  void insert(int index, element) => _srcList.insert(index, element);

  void insertAll(int index, Iterable iterable) => _srcList.insertAll(index, iterable);

  void setAll(int index, Iterable iterable) => _srcList.setAll(index, iterable);

  removeAt(int index) => _srcList.removeAt(index);

  removeLast() => _srcList.removeLast();
  void removeWhere(bool test(element)) => _srcList.removeWhere(test);

  void retainWhere(bool test(element)) => retainWhere(test);
  List sublist(int start, [int end]) => _srcList.sublist(start, end);
  Iterable getRange(int start, int end) => _srcList.getRange(start, end);

  void setRange(int start, int end, Iterable iterable, [int skipCount = 0]) =>
      _srcList.setRange(start, end, iterable, skipCount);
  void removeRange(int start, int end) => _srcList.removeRange(start, end);
  void fillRange(int start, int end, [fillValue]) => _srcList.fillRange(start, end, fillValue);
  void replaceRange(int start, int end, Iterable replacement) => _srcList.replaceRange(start, end, replacement);
  Map<int, dynamic> asMap() => _srcList.asMap();
}

/**
 * test input object is match filter condition
 * return true : show row
 *        false: hide row
 */
typedef bool testShowItemFun(obj);

/**
 * filter follow up rows base on '_parent' and '_collapsed' and id field to render tree view
 */
class HierarchFilterList extends FilteredList {
  List<testShowItemFun> filterFun = [];
  String _parentField;
  String _idField;
  String _collapsedField;
  HierarchFilterList._([List items]) : super(items) {}

  /**
   * [parentField] field that describe parent row id, default is '_parent'
   * [idField] unique id for each row, default is 'id'
   * [collapsedField] field describe collapsed(true) or expand(false)
   * [items] List of row
   */
  factory HierarchFilterList.withKeyField(
      [String parentField = '_parent', String idField = 'id', String collapsedField = '_collapsed', List items]) {
    HierarchFilterList hier = new HierarchFilterList._(items);
    hier._parentField = parentField;
    hier._idField = idField;
    hier._collapsedField = collapsedField;
    return hier;
  }

  _foldHelper() {
    Map tMap = {'parents': new Set(), 'list': []};
    return new UnmodifiableListView(_srcList.fold(tMap, (Map init, val) {
      //_filter.keys.every(test)
      bool showRow = _filter.keys.every((k) {
        if (k == _collapsedField) {
          //filter by tree hierarchical
          if (init['parents'].contains(val[_parentField])) {
            init['parents'].add(val[_idField]);
            return false;
          } else if (val[k] == true) {
            init['parents'].add(val[_idField]);
            return true;
          } else {
            return true;
          }
        } else if (_filter[k] is Function) {
          bool isShow = _filter[k](val[k]);
          if (!isShow) init['parents'].add(val[_idField]);
          return isShow;
        } else {
          return true;
        }
      });
      if (showRow) init['list'].add(val);
      return init;
    })['list']);
  }
}

typedef Map<String, String> metaFun(int rowId);

/**
 * meta data interface for data
 * Meta data is a list wrappper that provide getMetaData when need override style in row rendering
 */
abstract class IMetaData {
  Map getMetaData(int rowId);
  void setMetaData(metaFun fun);
}

class MetaList<T> extends ListBase<T> with IMetaData {
  metaFun _func;
  List<T> innerList;
  MetaList(this.innerList, [this._func]) {}

  Map getMetaData(int rowId) {
    return _func(rowId);
  }

  void setMetaData(metaFun _) {
    _func = _;
  }

  int get length => innerList.length;

  void set length(int length) {
    innerList.length = length;
  }

  void operator []=(int index, T value) {
    innerList[index] = value;
  }

  T operator [](int index) => innerList[index];

  // Though not strictly necessary, for performance reasons
  // you should implement add and addAll.

  void add(T value) => innerList.add(value);

  void addAll(Iterable<T> all) => innerList.addAll(all);
  void sort([int compare(T a,T b)]) => innerList.sort(compare);
}

// code hint for setup grid

/**
 * Grid Configuration
 * Example:
 *   var opt = new GridOptions()..explicitInitialization=false
                                ..multiColumnSort=true
                                ..editable=true
                                ..autoEdit=true
                                ..frozenColumn = 1
                                ..enableColumnReorder=true;

     var sg= new SlickGrid.fromOpt(el,makeData(500),column,opt);
 *
 *
 */
class GridOptions {
  bool explicitInitialization = false;
  int rowHeight = 25;
  int defaultColumnWidth = 80;
  /** extra one row  on end of data row, the new added row have renedered cells */
  bool enableAddRow = false;
  /** true, add a blank empty row hight space after last rendered row
   *  default: false
   */
  bool leaveSpaceForNewRows = false;
  bool editable = false;
  /** single click on editable cell will load editor */
  bool autoEdit = true;
  /**  keyboard up,down,left,right, page up , page down
   *  set to false also disable edit mode
   *  default: true
   */
  bool enableCellNavigation = true;
  /** drag and drop column to reorder rendered column */
  bool enableColumnReorder = false;
  bool asyncEditorLoading = false;
  int asyncEditorLoadDelay = 100;
  /** when true,force maximum column width to sum of total column width */
  bool forceFitColumns = false;
  bool enableAsyncPostRender = false;
  int asyncPostRenderDelay = 50;
  bool autoHeight = false;
  var editorLock = core.GlobalEditorLock;
  bool showHeaderRow = false;
  /** a row before data row and frozen row , after top panel, not header*/
  int headerRowHeight = 25;
  bool showTopPanel = false;
  int topPanelHeight = 25;
  Map<String,TFormatter> formatterFactory = {};
  var editorFactory = null;
  String cellFlashingCssClass = "flashing";
  String selectedCellCssClass = "selected";
  bool multiSelect = true;
  bool enableTextSelectionOnCells = false;
  Function dataItemColumnValueExtractor = null; //function to extract value
  /** true: canvas width or all column width, false: all column sum width */
  bool fullWidthRows = false;
  bool multiColumnSort = false;
  TFormatter defaultFormatter = _defaultFormatter;
  /** force viewport render row on scrolling
   *  false: delegate to timer also cause empty view port on long scrolling
   *  default: false
   */
  bool forceSyncScrolling = false;
  /** frozen column index, 0 base */
  int frozenColumn = -1; //frozen index
  /** frozen row index , 0 base */
  int frozenRow = -1;
  bool frozenBottom = false;
  /** enable or disable [yPos] lookup for rendering */
  bool dynamicHeight = false;
  /**
   * render cells on column resize, low performance
   */
  bool syncColumnCellResize = false;
  //for commit current editor
  Function editCommandHandler = null;
  GridOptions([Map<String,dynamic> opt]) {
    //adapt map config
    if (opt != null) {
      _processMap(opt);
    }
  }
  operator [](String key) {}
  //duplicate configura,
  Map toJson() {
    return {
      'explicitInitialization': this.explicitInitialization,
      'rowHeight': this.rowHeight,
      'defaultColumnWidth': this.defaultColumnWidth,
      'enableAddRow': this.enableAddRow,
      'leaveSpaceForNewRows': this.leaveSpaceForNewRows,
      'editable': this.editable,
      'autoEdit': this.autoEdit,
      'enableCellNavigation': this.enableCellNavigation,
      'enableColumnReorder': this.enableColumnReorder,
      'asyncEditorLoading': this.asyncEditorLoading,
      'asyncEditorLoadDelay': this.asyncEditorLoadDelay,
      'forceFitColumns': this.forceFitColumns,
      'enableAsyncPostRender': this.enableAsyncPostRender,
      'asyncPostRenderDelay': this.asyncPostRenderDelay,
      'autoHeight': this.autoHeight,
      'editorLock': this.editorLock,
      'showHeaderRow': this.showHeaderRow,
      'headerRowHeight': this.headerRowHeight,
      'showTopPanel': this.showTopPanel,
      'topPanelHeight': this.topPanelHeight,
      'formatterFactory': this.formatterFactory,
      'editorFactory': this.editorFactory,
      'cellFlashingCssClass': this.cellFlashingCssClass,
      'selectedCellCssClass': this.selectedCellCssClass,
      'multiSelect': this.multiSelect,
      'enableTextSelectionOnCells': this.enableTextSelectionOnCells,
      'dataItemColumnValueExtractor': this.dataItemColumnValueExtractor,
      'fullWidthRows': this.fullWidthRows,
      'multiColumnSort': this.multiColumnSort,
      'defaultFormatter': this.defaultFormatter,
      'forceSyncScrolling': this.forceSyncScrolling,
      'frozenColumn': this.frozenColumn,
      'frozenRow': this.frozenRow,
      'frozenBottom': this.frozenBottom,
      'dynamicHeight': this.dynamicHeight,
      'syncColumnCellResize': this.syncColumnCellResize,
      'editCommandHandler': this.editCommandHandler
    };
  }

  addAll(Map opt) {
    _processMap(opt);
  }

  _processMap(Map opt) {
    if (opt['explicitInitialization'] != null) this.explicitInitialization = opt['explicitInitialization'];
    if (opt['rowHeight'] != null) this.rowHeight = opt['rowHeight'];
    if (opt['defaultColumnWidth'] != null) this.defaultColumnWidth = opt['defaultColumnWidth'];
    if (opt['enableAddRow'] != null) this.enableAddRow = opt['enableAddRow'];
    if (opt['leaveSpaceForNewRows'] != null) this.leaveSpaceForNewRows = opt['leaveSpaceForNewRows'];
    if (opt['editable'] != null) this.editable = opt['editable'];
    if (opt['autoEdit'] != null) this.autoEdit = opt['autoEdit'];
    if (opt['enableCellNavigation'] != null) this.enableCellNavigation = opt['enableCellNavigation'];
    if (opt['enableColumnReorder'] != null) this.enableColumnReorder = opt['enableColumnReorder'];
    if (opt['asyncEditorLoading'] != null) this.asyncEditorLoading = opt['asyncEditorLoading'];
    if (opt['asyncEditorLoadDelay'] != null) this.asyncEditorLoadDelay = opt['asyncEditorLoadDelay'];
    if (opt['forceFitColumns'] != null) this.forceFitColumns = opt['forceFitColumns'];
    if (opt['enableAsyncPostRender'] != null) this.enableAsyncPostRender = opt['enableAsyncPostRender'];
    if (opt['asyncPostRenderDelay'] != null) this.asyncPostRenderDelay = opt['asyncPostRenderDelay'];
    if (opt['autoHeight'] != null) this.autoHeight = opt['autoHeight'];
    if (opt['editorLock'] != null) this.editorLock = opt['editorLock'];
    if (opt['showHeaderRow'] != null) this.showHeaderRow = opt['showHeaderRow'];
    if (opt['headerRowHeight'] != null) this.headerRowHeight = opt['headerRowHeight'];
    if (opt['showTopPanel'] != null) this.showTopPanel = opt['showTopPanel'];
    if (opt['topPanelHeight'] != null) this.topPanelHeight = opt['topPanelHeight'];
    if (opt['formatterFactory'] != null) this.formatterFactory = opt['formatterFactory'] as Map<String,TFormatter>;
    if (opt['editorFactory'] != null) this.editorFactory = opt['editorFactory'];
    if (opt['cellFlashingCssClass'] != null) this.cellFlashingCssClass = opt['cellFlashingCssClass'];
    if (opt['selectedCellCssClass'] != null) this.selectedCellCssClass = opt['selectedCellCssClass'];
    if (opt['multiSelect'] != null) this.multiSelect = opt['multiSelect'];
    if (opt['enableTextSelectionOnCells'] != null) this.enableTextSelectionOnCells = opt['enableTextSelectionOnCells'];
    if (opt['dataItemColumnValueExtractor'] != null)
      this.dataItemColumnValueExtractor = opt['dataItemColumnValueExtractor'];
    if (opt['fullWidthRows'] != null) this.fullWidthRows = opt['fullWidthRows'];
    if (opt['multiColumnSort'] != null) this.multiColumnSort = opt['multiColumnSort'];
    if (opt['defaultFormatter'] != null) this.defaultFormatter = opt['defaultFormatter'] as TFormatter;
    if (opt['forceSyncScrolling'] != null) this.forceSyncScrolling = opt['forceSyncScrolling'];
    if (opt['frozenColumn'] != null) this.frozenColumn = opt['frozenColumn'];
    if (opt['frozenRow'] != null) this.frozenRow = opt['frozenRow'];
    if (opt['frozenBottom'] != null) this.frozenBottom = opt['frozenBottom'];
    if (opt['dynamicHeight'] != null) this.dynamicHeight = opt['dynamicHeight'];
    if (opt['syncColumnCellResize'] != null) this.syncColumnCellResize = opt['syncColumnCellResize'];
    if (opt['editCommandHandler'] != null) this.editCommandHandler = opt['editCommandHandler'];

//      editCommandHandler
  }
}

String _defaultFormatter(int row, int cell, dynamic value, columnDef, dataContext) {
  if (value == null) {
    return "";
  }
  if (value is num || value is bool) return value.toString();
  return HTML_ESCAPE.convert(value);
}
