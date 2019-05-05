library slick.util;

import 'dart:html';
import 'dart:math';
import 'dart:collection';
import 'package:logging/logging.dart';
import 'slick_core.dart' as core;
import 'dart:convert';
import 'slick_column.dart' show TFormatter, Column;

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
  //CssStyleDeclaration style = $c.getComputedStyle();
  Map<String, int> dim = {
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
Element findClosestAncestor(Element element, String cssSelector,
    [String scope]) {
  assert(element is Element);
  // if (element == null) return null;
  return element?.closest(cssSelector);
  // do {
  //   if (element.matches(cssSelector)) return element;
  //   element = element.parent;
  // } while (element != null);
  // return null;
}

/// ### Give grid class illusion of data
/// * filter is active by setting [keyword],
/// * Filtered View is readonly for grid
/// * when no filter, using default data set, which allow to add data
///
/// _note_: any operation to list will forward to  src list
///
class FilteredList extends ListBase {
  /// prvoide sub class to alter behavior
  List srcList, viewList;

  /// default: case sensitive
  bool ignoreCase = false;
  /**
   * field name ->  condition or function
   */
  Map<String, dynamic> filter = {};

  FilteredList([this.srcList, this.ignoreCase = false]) {
    srcList ??= new List();
  }
  //Constructor from a Map
  FilteredList.fromMap(Map map) {
    srcList = map == null ? new List() : new List.from(map.values);
  }

  ///
  /// create new view base on filter, only matched item will show
  /// string is partial matching
  /// [m] is {column_name: condition} ,condition can be string, bool or number
  ///
  set keyword(Map<String, dynamic> m) {
    if (m == null) return;
    filter = m;
    viewList = _foldHelper();
  }

  ///
  /// add filter:[val] by [key]  column field,
  /// Only support one keyword per column,
  /// if [val] is empty string, then remove the filter
  ///
  void addKeyword(String key, Object val) {
    //_viewList=[];
    if (val is String && val.isEmpty) {
      filter.remove(key);
    } else {
      filter[key] = val;
    }
    viewList = _foldHelper();
  }

  /// conflict with setter
  @deprecated
  void setKeyword(String key, Object val) => addKeyword(key, val);

  ///
  /// when src is changed, regenerate view
  ///
  void invalidate() {
    viewList = _foldHelper();
  }

  void removeKeyword(String key) {
    filter.remove(key);
  }

  _foldHelper() {
    return new UnmodifiableListView(srcList.fold([], (List init, val) {
      var test = filter.keys.every((k) {
        _log.finest("${val[k]} ${filter[k]}");
        if (val[k] is String) {
          return val[k].contains(filter[k]) ||
              this.ignoreCase &&
                  "${val[k]}"
                      .toUpperCase()
                      .contains(filter[k].toString().toUpperCase());
        } else if (val[k] is bool) {
          return val[k] == filter[k];
        } else {
          try {
            var _num = num.parse(filter[k]);
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

  operator [](index) => filter.isEmpty ? srcList[index] : viewList[index];
  operator []=(index, value) => srcList[index] = (value);
  //for grid internal mask
  get length => filter.isEmpty ? srcList.length : viewList.length;
  set length(val) {
    srcList.length = val;
  }

  add(val) {
    srcList.add(val);
  }

  addAll(val) {
    srcList.addAll(val);
  }

  clear() {
    srcList.clear();
    viewList = new UnmodifiableListView([]);
  }

  bool remove(Object element) {
    return srcList.remove(element);
  }

  void sort([int compare(a, b)]) {
    srcList.sort(compare);
    if (viewList != null && viewList.isNotEmpty) viewList = _foldHelper();
  }

  Iterable get reversed => srcList.reversed;
  void shuffle([Random random]) {
    srcList.shuffle(random);
    viewList.shuffle(random);
  }

  int indexOf(element, [int start = 0]) => srcList.indexOf(element, start);
  int lastIndexOf(element, [int start]) => srcList.lastIndexOf(element, start);
  void insert(int index, element) => srcList.insert(index, element);

  void insertAll(int index, Iterable iterable) =>
      srcList.insertAll(index, iterable);

  void setAll(int index, Iterable iterable) => srcList.setAll(index, iterable);

  removeAt(int index) => srcList.removeAt(index);

  removeLast() => srcList.removeLast();
  void removeWhere(bool test(element)) => srcList.removeWhere(test);

  void retainWhere(bool test(element)) => retainWhere(test);
  List sublist(int start, [int end]) => srcList.sublist(start, end);
  Iterable getRange(int start, int end) => srcList.getRange(start, end);

  void setRange(int start, int end, Iterable iterable, [int skipCount = 0]) =>
      srcList.setRange(start, end, iterable, skipCount);
  void removeRange(int start, int end) => srcList.removeRange(start, end);
  void fillRange(int start, int end, [fillValue]) =>
      srcList.fillRange(start, end, fillValue);
  void replaceRange(int start, int end, Iterable replacement) =>
      srcList.replaceRange(start, end, replacement);
  Map<int, dynamic> asMap() => srcList.asMap();
}

/**
 * test input object is match filter condition
 * return true : show row
 *        false: hide row
 */
typedef bool testShowItemFun(obj);
typedef MetaRowCfg rowParFun(String colId);

/// ### DataList in TREE View
///  filter follow up rows base on [_parent] and [_collapsed] and id field to render tree view
///
class HierarchFilterList extends FilteredList {
  List<testShowItemFun> filterFun = [];
  String _parentField;
  String _idField;
  String _collapsedField;
  HierarchFilterList._([List items]) : super(items) {}

  ///
  /// * [parentField] field that describe parent row id, default is '_parent'
  /// * [idField] unique id for each row, default is 'id' in [Column]
  /// * [collapsedField] field describe collapsed(true) or expand(false)
  /// * [items] List of row
  ///
  factory HierarchFilterList.withKeyField(
      [String parentField = '_parent',
      String idField = 'id',
      String collapsedField = '_collapsed',
      List items]) {
    HierarchFilterList hier = new HierarchFilterList._(items);
    hier._parentField = parentField;
    hier._idField = idField;
    hier._collapsedField = collapsedField;
    return hier;
  }

  _foldHelper() {
    Map tMap = {'parents': new Set(), 'list': []};
    return new UnmodifiableListView(srcList.fold(tMap, (Map init, val) {
      //_filter.keys.every(test)
      bool showRow = filter.keys.every((k) {
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
        } else if (filter[k] is Function) {
          bool isShow = filter[k](val[k]);
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

typedef Map<String, dynamic> metaFun(int rowId);

class MetaRowCfg {
  const MetaRowCfg([this.colSpan = 1, this.rowSpan = 1, this.cssStr = ""]);
  final int rowSpan;
  final int colSpan;
  final String cssStr;
}

/**
 * meta data interface for data
 * Meta data is a list wrappper that provide getMetaData when need override style in row rendering
 */
abstract class IMetaData {
  /// per row configuration.
  /// return Map<feature, configuration>.
  /// feature:
  ///  * 'cssClasses' to add style to row, value is css style name,
  ///  function body looking for target row and check condition meet or not and then return
  /// ```
  ///  {"cssClasses":'highlight'}
  /// ```
  ///  * 'columns'  to add span for column, value is {'column_name': span_cell_count}
  /// configuration example:
  /// ```
  ///  {'columns': {"first_column": 2, 'second_col': 3}, columns_css:{"first_column":"style1", "second_col":"style2"}}
  /// ```
  /// to customize cell style using [setCellCssStyles] function
  Map<String, dynamic> getMetaData(int rowId);

  ///
  /// per cell style, row,col span and css, also update cache
  ///
  MetaRowCfg getCellCfg(int rowId, String columnId);

  ///
  /// minimal row to render if row span from previous rows
  ///
  int minRowToRender(int curRowId);

  ///
  ///  return partial function for client to process columns
  ///
  rowParFun getMetaRow(int rowId);
  void setMetaData(metaFun fun);
}

class MetaList<T> extends ListBase<T> with IMetaData {
  static const COLUMN = 'columns';
  static const COLUMN_CSS = 'columns_css';
  metaFun _func;
  List<T> innerList;
  MetaList(this.innerList, [this._func]) {}

  Map<String, dynamic> getMetaData(int rowId) {
    return _func(rowId);
  }

  void setMetaData(metaFun _) {
    _func = _;
  }

  int get length => innerList.length;
  // int get rowSpan(int row, int cell);
  set length(int length) {
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
  void sort([int compare(T a, T b)]) => innerList.sort(compare);
  rowParFun getMetaRow(int rowId) => (String col) => getCellCfg(rowId, col);
  static rowParFun simpleRow() => (String col) {
        return MetaRowCfg();
      };
  // scroll  performance sensitive
  // return max row span id from current row (for row cache clean up)
  //
  int curRowMaxSpan(int rowId) {
    if (_maxRowSpan[rowId] == null) return rowId;
    return _maxRowSpan[rowId] + rowId;
  }

  int minRowToRender(int curRowId) {
    return _preRenderforRowSpan[curRowId] ?? curRowId;
  }

  // row Id, to spaned row count
  Map<int, int> _maxRowSpan = {};
  // cur Row id -> smallest row id that have cell overlay on this row
  Map<int, int> _preRenderforRowSpan = {};
  MetaRowCfg getCellCfg(int rowId, String columnId) {
    var row = getMetaData(rowId);
    var colspan = 1, rowspan = 1, css = "";
    if (row[COLUMN] != null) {
      colspan = row[COLUMN][columnId] ?? 1;
      rowspan = row[COLUMN][columnId + "!"] ?? 1;
    }
    if (row[COLUMN_CSS] != null) {
      css = row[COLUMN_CSS][columnId] ?? "";
    }
    if (rowspan > 1) {
      _maxRowSpan[rowId] ??= 1;
      if (_maxRowSpan[rowId] < rowspan) {
        _maxRowSpan[rowId] = rowspan;
        _preRenderforRowSpan[rowId + rowspan] = rowId;
      }
    }
    return MetaRowCfg(colspan, rowspan, css);
  }
}

// code hint for setup grid

///
///   Grid Configuration
///   Example:
///     var opt = new GridOptions()..explicitInitialization=false
///                                ..multiColumnSort=true
///                                ..editable=true
///                                ..autoEdit=true
///                                ..frozenColumn = 1
///                                ..enableColumnReorder=true;
///
///     var sg= new SlickGrid.fromOpt(el,makeData(500),column,opt);
///
///
///
class GridOptions {
  bool explicitInitialization = false;
  int rowHeight = 25;
  int defaultColumnWidth = 0;

  /// extra one row  on end of data row, the new added row have renedered cells */
  bool enableAddRow = false;

  /// true, add a blank empty row hight space after last rendered row
  ///   default: false
  ///
  bool leaveSpaceForNewRows = false;
  bool editable = false;
  /** single click on editable cell will load editor */
  bool autoEdit = true;

  /// commit current
  bool autoCommitOnBlur = false;
  //  keyboard up,down,left,right, page up , page down
  // set to false also disable edit mode
  // default: true
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

  ///  Formatter factory, specify by -->
  ///  column_id : TFormatter function
  ///
  Map<String, TFormatter> formatterFactory = <String, TFormatter>{};
  var editorFactory; // = null;
  String cellFlashingCssClass = "flashing";
  String selectedCellCssClass = "selected";
  bool multiSelect = true;
  bool enableTextSelectionOnCells = false;
  Function dataItemColumnValueExtractor; // = null; //function to extract value
  /** true: canvas width or all column width, false: all column sum width */
  bool fullWidthRows = false;
  bool multiColumnSort = false;
  TFormatter defaultFormatter = _defaultFormatter;
  // force viewport render row on scrolling
  // false: delegate to timer also cause empty view port on long scrolling
  // default: false
  //
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
  Function editCommandHandler;
  GridOptions([Map<String, dynamic> opt]) {
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
    if (opt['explicitInitialization'] != null)
      this.explicitInitialization = opt['explicitInitialization'];
    if (opt['rowHeight'] != null) this.rowHeight = opt['rowHeight'];
    if (opt['defaultColumnWidth'] != null)
      this.defaultColumnWidth = opt['defaultColumnWidth'];
    if (opt['enableAddRow'] != null) this.enableAddRow = opt['enableAddRow'];
    if (opt['leaveSpaceForNewRows'] != null)
      this.leaveSpaceForNewRows = opt['leaveSpaceForNewRows'];
    if (opt['editable'] != null) this.editable = opt['editable'];
    if (opt['autoEdit'] != null) this.autoEdit = opt['autoEdit'];
    if (opt['enableCellNavigation'] != null)
      this.enableCellNavigation = opt['enableCellNavigation'];
    if (opt['enableColumnReorder'] != null)
      this.enableColumnReorder = opt['enableColumnReorder'];
    if (opt['asyncEditorLoading'] != null)
      this.asyncEditorLoading = opt['asyncEditorLoading'];
    if (opt['asyncEditorLoadDelay'] != null)
      this.asyncEditorLoadDelay = opt['asyncEditorLoadDelay'];
    if (opt['forceFitColumns'] != null)
      this.forceFitColumns = opt['forceFitColumns'];
    if (opt['enableAsyncPostRender'] != null)
      this.enableAsyncPostRender = opt['enableAsyncPostRender'];
    if (opt['asyncPostRenderDelay'] != null)
      this.asyncPostRenderDelay = opt['asyncPostRenderDelay'];
    if (opt['autoHeight'] != null) this.autoHeight = opt['autoHeight'];
    if (opt['editorLock'] != null) this.editorLock = opt['editorLock'];
    if (opt['showHeaderRow'] != null) this.showHeaderRow = opt['showHeaderRow'];
    if (opt['headerRowHeight'] != null)
      this.headerRowHeight = opt['headerRowHeight'];
    if (opt['showTopPanel'] != null) this.showTopPanel = opt['showTopPanel'];
    if (opt['topPanelHeight'] != null)
      this.topPanelHeight = opt['topPanelHeight'];
    if (opt['formatterFactory'] != null)
      this.formatterFactory =
          opt['formatterFactory'] as Map<String, TFormatter>;
    if (opt['editorFactory'] != null) this.editorFactory = opt['editorFactory'];
    if (opt['cellFlashingCssClass'] != null)
      this.cellFlashingCssClass = opt['cellFlashingCssClass'];
    if (opt['selectedCellCssClass'] != null)
      this.selectedCellCssClass = opt['selectedCellCssClass'];
    if (opt['multiSelect'] != null) this.multiSelect = opt['multiSelect'];
    if (opt['enableTextSelectionOnCells'] != null)
      this.enableTextSelectionOnCells = opt['enableTextSelectionOnCells'];
    if (opt['dataItemColumnValueExtractor'] != null)
      this.dataItemColumnValueExtractor = opt['dataItemColumnValueExtractor'];
    if (opt['fullWidthRows'] != null) this.fullWidthRows = opt['fullWidthRows'];
    if (opt['multiColumnSort'] != null)
      this.multiColumnSort = opt['multiColumnSort'];
    if (opt['defaultFormatter'] != null)
      this.defaultFormatter = opt['defaultFormatter'] as TFormatter;
    if (opt['forceSyncScrolling'] != null)
      this.forceSyncScrolling = opt['forceSyncScrolling'];
    if (opt['frozenColumn'] != null) this.frozenColumn = opt['frozenColumn'];
    if (opt['frozenRow'] != null) this.frozenRow = opt['frozenRow'];
    if (opt['frozenBottom'] != null) this.frozenBottom = opt['frozenBottom'];
    if (opt['dynamicHeight'] != null) this.dynamicHeight = opt['dynamicHeight'];
    if (opt['syncColumnCellResize'] != null)
      this.syncColumnCellResize = opt['syncColumnCellResize'];
    if (opt['editCommandHandler'] != null)
      this.editCommandHandler = opt['editCommandHandler'];

//      editCommandHandler
  }
}

TFormatter get _defaultFormatter =>
    (int row, int cell, dynamic value, Column columnDef, Map dataContext) {
      if (value == null) {
        return "";
      }
      if (value is num || value is bool) return value.toString();
      return htmlEscape.convert(value);
    };
