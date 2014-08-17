library slick.grid;
import 'slick_core.dart' as core;
import 'slick_editor.dart' as editor;
import 'slick_selectionmodel.dart';
import 'slick_util.dart';
import 'dart:html';
import 'dart:math' as math;
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
//import 'dart:mirrors';
import 'slick_dnd.dart';



/**
 * plug-in interface
 */
abstract class IPlugin{
  init(SlickGrid grid);
  void destroy();
}

Map<String,int> scrollbarDimensions;  //width and height
int maxSupportedCssHeight;  // browser's breaking point



//tailer for html style
var _treeSanitizer = new NullTreeSanitizer();
/**
 * Sanitizer which does nothing.
 */
class NullTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(Node node) {
  //  print(node);
  }
}
class RowCache{
  int columnCount;
  RowCache (this.rowNode,columnCount){
//     cellColSpans= [];
    cellColSpans=new List.filled(columnCount,1);
//        <int>(columnCount);
//    cellColSpans.fillRange(start, end)
  }
  //rowNode[0] => frozend column
  //rowNode[1] => main view
  List<Element> rowNode =[]; // left view, and right view
  // ColSpans of rendered cells (by column idx).
  // Can also be used for checking whether a cell has been rendered.
  List<int> cellColSpans;

  // Cell nodes (by column idx).  Lazy-populated by ensureCellNodesInRowsCache().
  //not dense array, use map to replae
  Map<int,Element> cellNodesByColumnIdx = {};

  // Column indices of cell nodes that have been rendered, but not yet indexed in
  // cellNodesByColumnIdx.  These are in the same order as cell nodes added at the
  // end of the row.
  Queue<int> cellRenderQueue =new Queue<int>();
}
class Column{
  Column(){
    _src.addAll(_columnDefaults);
  }
  Map<String,dynamic > _src={};
  Function get asyncPostRender => _src['asyncPostRender'];
  bool get  defaultSortAsc => _src['defaultSortAsc'];
  Function get editor => _src['editor'];
  bool get focusable => _src['focusable'];
  Function get formatter => _src['formatter'];
  String get headerCssClass => _src['headerCssClass'];
  String get cssClass => _src['cssClass'];
  int get previousWidth => _src['previousWidth'];

  String get toolTip => _src['toolTip'];
  String get id => _src['id'];// "range"
  int get minWidth => _src['minWidth'];//: 30
  String get name => _src['name']; //: "Range"
  bool get rerenderOnResize => _src['rerenderOnResize'];
  bool get resizable => _src['resizable'];
  bool get selectable => _src['selectable'];
  bool get sortable => _src['sortable'];
  int  get width => _src['width'];
  int get maxWidth => _src['maxWidth'];
  String get field => _src['field'];
        get validator => _src['validator'];


  bool get cannotTriggerInsert => _src['cannotTriggerInsert'];
  void set asyncPostRender(item) { _src['asyncPostRender'] = item;}
  void set toolTip(item) {_src['toolTip']=item;}
  void set cannotTriggerInsert(item){ _src['cannotTriggerInsert']= item;}
  void set defaultSortAsc(item) {_src['defaultSortAsc']=item;}
  void set editor(Function item) {_src['editor']=item;}
  void set focusable(bool item) {_src['focusable']=item;}
  void set formatter(Function item) { _src['formatter']=item;}
  void set headerCssClass(String item) { _src['headerCssClass']=item;}
  void set cssClass(String item) { _src['cssClass']=item;}
  void set id(String item) { _src['id']=item;}// "range"
  void set previousWidth(int item) { _src['previousWidth']=item;}// "range"
  void set minWidth(int item) { _src['minWidth']=item;}//: 30
  void set name (String item) { _src['name']=item;} //: "Range"
  void set rerenderOnResize(bool item) { _src['rerenderOnResize']=item;}
  void set resizable(bool item) { _src['resizable']=item;}
  void set selectable(bool item) { _src['selectable']=item;}
  void set sortable(bool item) { _src['sortable']=item;}
  void  set width(int item) { _src['width']=item;}
  void set maxWidth(int item){_src['maxWidth']=item;}
  void set field(String item){_src['field']=item;}

  factory Column.fromMap(Map<String,dynamic> src){
    Column c = new Column();
    c._src..addAll(src) ;
    return c;
  }

  factory Column.fromJSON(String src){
    Map m=JSON.decode(src);
    return new Column.fromMap(m) ; //c._src..addAll(src) ;
  }

  factory Column.fromColumn(Column old){
    Column c = new Column();
    c._src..addAll(old._src);
    return c;
  }
  dynamic operator[](String crit){
      return _src[crit];
  }
  Column merge(Column newCol){
     this._src.addAll(newCol._src);
     return this;
  }
  Map _columnDefaults = {
                    'name': "",
                    'resizable': true,
                    'sortable': false,
                    'minWidth': 30,
                    'rerenderOnResize': false,
                    'headerCssClass': null,
                    'defaultSortAsc': true,
                    'focusable': true,
                    'selectable': true,
                    'cannotTriggerInsert': false
  };
 String toString(){
   return _src.toString();
 }
}
class SlickGrid {
  //attach column to header element
  Expando<Column> _headExt= new Expando<Column>();

  Element container;
  List data;
  List<Column> columns;
  Map options;
  StreamSubscription<Event> _ancestorScrollSubscribe;


  core.Event onScroll = new core.Event();
  core.Event onSort = new core.Event();
  core.Event onHeaderMouseEnter = new core.Event();
  core.Event onHeaderMouseLeave = new core.Event();
  core.Event onHeaderContextMenu = new core.Event();
  core.Event onHeaderClick = new core.Event();
  core.Event onHeaderCellRendered = new core.Event();
  core.Event onBeforeHeaderCellDestroy = new core.Event();
  core.Event onHeaderRowCellRendered = new core.Event();
  core.Event onBeforeHeaderRowCellDestroy = new core.Event();
  core.Event onMouseEnter = new core.Event();
  core.Event onMouseLeave = new core.Event();
  core.Event onClick = new core.Event();
  core.Event onDblClick = new core.Event();
  core.Event onContextMenu = new core.Event();
  core.Event onKeyDown = new core.Event();
  core.Event onAddNewRow = new core.Event();
  core.Event onValidationError = new core.Event();
  core.Event onViewportChanged = new core.Event();
  core.Event onColumnsReordered = new core.Event();
  core.Event onColumnsResized = new core.Event();
  core.Event onCellChange = new core.Event();
  core.Event onBeforeEditCell = new core.Event();
  core.Event onBeforeCellEditorDestroy = new core.Event();
  core.Event onBeforeDestroy = new core.Event();
  core.Event onActiveCellChanged = new core.Event();
  core.Event onActiveCellPositionChanged = new core.Event();
  core.Event onDragInit = new core.Event();
  core.Event onDragStart = new core.Event();
  core.Event onDrag = new core.Event();
  core.Event onDragEnd = new core.Event();
  /**
   *
   * param e:  EventData
   * param args: {rows:[...], grid: SlickGrid }
   */
  core.Event onSelectedRowsChanged = new core.Event();
  core.Event onCellCssStylesChanged = new core.Event();


  SlickGrid(this.container, this.data, this.columns, this.options){
    defaults = {
                'explicitInitialization': false,
                'rowHeight': 25,
                'defaultColumnWidth': 80,
                'enableAddRow': false,
                'leaveSpaceForNewRows': false,
                'editable': false,
                'autoEdit': true,
                'enableCellNavigation': true,
                'enableColumnReorder': true,
                'asyncEditorLoading': false,
                'asyncEditorLoadDelay': 100,
                'forceFitColumns': false,
                'enableAsyncPostRender': false,
                'asyncPostRenderDelay': 50,
                'autoHeight': false,
                'editorLock': core.GlobalEditorLock,
                'showHeaderRow': false,
                'headerRowHeight': 25,
                'showTopPanel': false,
                'topPanelHeight': 25,
                'formatterFactory': null,
                'editorFactory': null,
                'cellFlashingCssClass': "flashing",
                'selectedCellCssClass': "selected",
                'multiSelect': true,
                'enableTextSelectionOnCells': false,
                'dataItemColumnValueExtractor': null,
                'fullWidthRows': false,
                'multiColumnSort': false,
                'defaultFormatter': defaultFormatter,
                'forceSyncScrolling': false,
                'frozenColumn': -1,   //frozen index
                'frozenRow' : -1,
                'frozenBottom':false
    };
  }
  Map<String,dynamic> defaults ;
  Column columnDefaults= new Column();
// scroller
  int th;   // virtual height
  int h;    // real scrollable height
  int ph;   // page height
  int n;    // number of pages
  var cj;   // "jumpiness" coefficient

  int page = 0;       // current page
  int offset = 0;     // current page offset
  var vScrollDir = 1;

  // private
  bool initialized = false;
//  var $container;
  var uid = "slickgrid_" + new math.Random().nextInt(10000000).toString();

  DivElement $focusSink, $focusSink2;
  List $headerScroller = [];
  List<Element> $headers = [];
  List $headerRow = [];
  DivElement  $headerRowSpacerL, $headerRowSpacerR;
  List $headerRowScroller = [];
  List<Element> $topPanelScroller= [];
  List $topPanel=[];
  List<Element> $viewport = [];
  DivElement $viewportL;
  List<Element> $canvas =[];  //all columns
  DivElement $canvasL; //left frozen columns
  Element $style;
  List<Element> $boundAncestors;
  CssStyleSheet stylesheet;
  List<CssStyleRule> columnCssRulesL, columnCssRulesR;
  int viewportH=0, viewportW =0;
  int viewportWL;
  int canvasWidth , canvasWidthL, canvasWidthR;
  int  headersWidth,headersWidthL, headersWidthR;
  bool viewportHasHScroll=false, viewportHasVScroll=false;
  int headerColumnWidthDiff = 0, headerColumnHeightDiff = 0, // border+padding
      cellWidthDiff = 0, cellHeightDiff = 0;
  int absoluteColumnMinWidth;
  bool hasFrozenRows = false;
  int frozenRowsHeight = 0;
  int actualFrozenRow = -1;
  int paneTopH = 0;
  int paneBottomH = 0;
  int viewportTopH = 0;
  int viewportBottomH = 0;
  int topPanelH = 0;
  int headerRowH = 0;



  int tabbingDirection = 1;
  Element $activeCanvasNode;
  Element $activeViewportNode;
  int activePosX;
  int activeRow, activeCell;
  Element activeCellNode = null;
  editor.Editor currentEditor = null;
  var serializedEditorValue;
  Map editController;

  Map<int,RowCache> rowsCache = {};
  int renderedRows = 0;
  int numVisibleRows;
  int prevScrollTop = 0;
  int scrollTop = 0;
  int lastRenderedScrollTop = 0;
  int lastRenderedScrollLeft = 0;
  int prevScrollLeft = 0;
  int scrollLeft = 0;

  SelectionModel selectionModel;
  List selectedRows = [];

  List<IPlugin> plugins = [];
  /**
   * css name =>
   * { row id :
   *    { column Id: string name  }
   * }
   *
   *
   */
  Map<String,Map<int,Map<String,String>>> cellCssClasses = {};

  Map columnsById = {};
  List sortColumns = [];
  //cache column left,right pos to determine which cell to render
  List<int> columnPosLeft = [];
  List<int> columnPosRight = [];


  // async call handles
  Timer h_editorLoader = null;
  Timer h_render = null;
  Timer h_postrender = null;
  Map<int,dynamic> postProcessedRows = {};
  var postProcessToRow = null;
  var postProcessFromRow = null;

  // perf counters
  int counter_rows_rendered = 0;
  int counter_rows_removed = 0;

  //frozen column & header

  Element $paneHeaderL;
  Element $paneHeaderR;
  Element $paneTopL;
  Element $paneTopR;
  Element $paneBottomL;
  Element $paneBottomR;

  Element $headerScrollerL;
  Element $headerScrollerR;

 Element $headerL;
 Element $headerR;

 Element $headerRowScrollerL;
 Element $headerRowScrollerR;

 Element $headerRowL;
 Element $headerRowR;

 Element $topPanelScrollerL;
 Element $topPanelScrollerR;

 Element $topPanelL;
 Element $topPanelR;

 Element $viewportTopL;
 Element $viewportTopR;
 Element $viewportBottomL;
 Element $viewportBottomR;

 Element $canvasTopL;
 Element $canvasTopR;
 Element $canvasBottomL;
 Element $canvasBottomR;

 Element $viewportScrollContainerX;
 Element $viewportScrollContainerY;
 Element $headerScrollContainer;
 Element $headerRowScrollContainer;




  /////////////////////////////one line accessoe
  int getDataLength(){
    return  data.length;
  }

  int getColumnIndex(id) {
    return columnsById[id];
  }
  List getSortColumns() => sortColumns;

  handleSelectedRangesChanged(core.EventData e, List<core.Range> ranges) {
    selectedRows = [];
    var hash = {};
    for (var i = 0; i < ranges.length; i++) {
      for (var j = ranges[i].fromRow; j <= ranges[i].toRow; j++) {
        if (!hash.containsKey(j)) {  // prevent duplicates
          selectedRows.add(j);
          hash[j] = {};
        }
        for (var k = ranges[i].fromCell; k <= ranges[i].toCell; k++) {
          if (canCellBeSelected(j, k)) {
            hash[j][columns[k].id] = options['selectedCellCssClass'];
          }
        }
      }
    }

    setCellCssStyles(options['selectedCellCssClass'], hash);

    trigger(onSelectedRowsChanged, {'rows': getSelectedRows()}, e);
  }

  /**
   * hash
   * {
   *   11: {columnName : css_class_name }
   *   12: {... }
   *   13: {... }
   * }
   *
   *
   */
  setCellCssStyles(String key, Map<int,Map<String,String>> hash) {
    Map prevHash = cellCssClasses[key];

    cellCssClasses[key] = hash;
    updateCellCssStylesOnRenderedRows(hash, prevHash);

    trigger(onCellCssStylesChanged, { "key": key, "hash": hash });
  }
  updateCellCssStylesOnRenderedRows(Map<int,Map<String,String>> addedHash,Map<int,Map<String,String>> removedHash) {
    Element node;
    String columnId;
    Map<String,String> addedRowHash, removedRowHash;
    for (int row in rowsCache.keys) {
      removedRowHash = removedHash ==null ? null : removedHash[row];
      addedRowHash = addedHash ==null ? null : addedHash[row];

      if (removedRowHash!=null) {
        for (columnId in removedRowHash.keys) {
          if (addedRowHash ==null || removedRowHash[columnId] != addedRowHash[columnId]) {
            node = getCellNode(row, getColumnIndex(columnId));
            if (node!=null) {
              node.classes.remove(removedRowHash[columnId]);
            }
          }
        }
      }

      if (addedRowHash!=null) {
        for (columnId in addedRowHash.keys) {
          if (removedRowHash==null || removedRowHash[columnId] != addedRowHash[columnId]) {
            node = getCellNode(row, getColumnIndex(columnId));
            if (node!=null) {
              node.classes.add(addedRowHash[columnId]);
            }
          }
        }
      }
    }
  }

  Map<String,CssStyleRule> getColumnCssRules(idx) {
    if (stylesheet==null) {
      List<CssStyleSheet> sheets = document.styleSheets;

      for (int i = 0; i < sheets.length; i++) {
        if (sheets[i].ownerNode !=null && sheets[i].ownerNode == $style) {   //|| sheets[i].owningElement for IE8
          stylesheet = sheets[i];
          break;
        }
      }

      if (stylesheet==null) {
        throw new ArgumentError("Cannot find stylesheet.");
      }

      // find and cache column CSS rules
      columnCssRulesL = [];
      columnCssRulesR = [];
      List<CssStyleRule> cssRules = stylesheet.cssRules;

      var matches, columnIdx;
      RegExp reg=new RegExp(r"\.l(\d+)");
      RegExp regR=new RegExp(r'\.r(\d+)');
      for (int i = 0; i < cssRules.length; i++) {
        String selector = cssRules[i].selectorText;
        if (reg.hasMatch(selector)){
          Match match=reg.firstMatch(selector);
          columnCssRulesL.insert(int.parse(match.group(0).substring(2)), cssRules[i]);
        } else if(regR.hasMatch(selector)){
          Match match=regR.firstMatch(selector);
          columnCssRulesR.insert(int.parse(match.group(0).substring(2)), cssRules[i]);
        }
      }
    }

    return {
      "left": columnCssRulesL[idx],
      "right": columnCssRulesR[idx]
    };
  }

  void applyColumnHeaderWidths() {
    if (!initialized) { return; }
    Element h;
    List<Element> headers =$headers.expand((i)=>i.children).toList();
    for (int i = 0,  ii = headers.length; i < ii; i++) {
        h = headers[i];
        int hWidth = core.Dimension.getCalcWidth(h);
        if (hWidth != columns[i].width - headerColumnWidthDiff) {
          h.style.width= (columns[i].width - headerColumnWidthDiff).toString() + 'px';
        }
    };

    updateColumnCaches();
  }
  /**
   * SET all column width via css
   * 1. extra column csss
   * 2. apply width
   */
  void applyColumnWidths() {
    int x = 0, w;
    Map<String,CssStyleRule> rule;
    for (int i = 0; i < columns.length; i++) {
      w = columns[i].width;

      rule = getColumnCssRules(i);
      rule['left'].style.left = x.toString() + "px";
      rule['right'].style.right =
          "${ (((options['frozenColumn'] != -1 && i > options['frozenColumn']) ? canvasWidthR : canvasWidthL) - x - w) }px";
      //
      //rule['right'].style.right = (canvasWidth - x - w).toString() + "px";
      if (options['frozenColumn'] == i) {
        x = 0;
      } else {
        x += columns[i].width;
      }
    }
  }

  Map<String,int> getVisibleRange([int viewportTop, int viewportLeft]) {
    if (viewportTop == null) {
      viewportTop = scrollTop;
    }
    if (viewportLeft == null) {
      viewportLeft = scrollLeft;
    }

    return {
      'top': getRowFromPosition(viewportTop),
      'bottom': getRowFromPosition(viewportTop + viewportH) + 1,
      'leftPx': viewportLeft,
      'rightPx': viewportLeft + viewportW
    };
  }
    /**
     * calculate render areas
     */
   Map<String,int> getRenderedRange([int viewportTop, int viewportLeft]) {
    Map<String,int> range = getVisibleRange(viewportTop, viewportLeft);
    int buffer = (viewportH / options['rowHeight']).round();
    int minBuffer = 3;

    if (vScrollDir == -1) {
      range['top'] -= buffer;
      range['bottom'] += minBuffer;
    } else if (vScrollDir == 1) {
      range['top']  -= minBuffer;
      range['bottom'] += buffer;
    } else {
      range['top']  -= minBuffer;
      range['bottom'] += minBuffer;
    }

    range['top'] = math.max(0, range['top']);
    range['bottom'] = math.min(getDataLengthIncludingAddNew() - 1, range['bottom']);

    range['leftPx'] -= viewportW;
    range['rightPx'] += viewportW;

    range['leftPx'] = math.max(0, range['leftPx']);
    range['rightPx'] = math.min(canvasWidth, range['rightPx']);

    return range;
  }



  void render([Timer timer]) {
    if (!initialized) { return; }
    Map<String,int> visible = getVisibleRange();
    Map<String,int> rendered = getRenderedRange();

    // remove rows no longer in the viewport
    cleanupRows(rendered);

    // add new rows & missing cells in existing rows
    if (lastRenderedScrollLeft != scrollLeft) {
      cleanUpAndRenderCells(rendered);
    }

    // render missing rows
    renderRows(rendered);
    //render missing frozenCol
    if(this.hasFrozenRows){
      rendered['top']=0;
      rendered['bottom']=options['frozenRow'];
      renderRows(rendered);
    }

    postProcessFromRow = visible['top'];
    postProcessToRow = math.min(getDataLengthIncludingAddNew() - 1, visible['bottom']);
    startPostProcessing();

    lastRenderedScrollTop = scrollTop;
    lastRenderedScrollLeft = scrollLeft;
    if(h_render!=null && h_render.isActive) h_render.cancel();
    h_render = null;
  }

  void autosizeColumns() {
    var i,
    widths = [],
    shrinkLeeway = 0,
    prevTotal,
    availWidth = viewportHasVScroll ? viewportW - scrollbarDimensions['width'] : viewportW;
    int total = 0;
    Column c;

    for (i = 0; i < columns.length; i++) {
      c = columns[i];
      widths.add(c['width']);
      total += c['width'];
      if (c['resizable']!=null) {
        shrinkLeeway += c['width'] - math.max(c['minWidth'], absoluteColumnMinWidth);
      }
    }

    // shrink
    prevTotal = total;
    while (total > availWidth && shrinkLeeway) {
      double shrinkProportion = (total - availWidth) / shrinkLeeway;
      for (i = 0; i < columns.length && total > availWidth; i++) {
        c = columns[i];
        int width = widths[i];
        if (c['resizable']!=null || width <= c['minWidth'] || width <= absoluteColumnMinWidth) {
          continue;
        }
        var absMinWidth = math.max(c['minWidth'], absoluteColumnMinWidth);
        int shrinkSize = (shrinkProportion * (width - absMinWidth)).floor();
        if (shrinkSize==0) shrinkSize= 1;
        shrinkSize = math.min(shrinkSize, width - absMinWidth);
        total -= shrinkSize;
        shrinkLeeway -= shrinkSize;
        widths[i] -= shrinkSize;
      }
      if (prevTotal == total) {  // avoid infinite loop
        break;
      }
      prevTotal = total;
    }

    // grow
    prevTotal = total;
    while (total < availWidth) {
      double growProportion = availWidth / total;
      for (i = 0; i < columns.length && total < availWidth; i++) {
        c = columns[i];
        if (c['resizable'] !=null || c['maxWidth'] <= c['width']) {
          continue;
        }
        int cWidth= (c['maxWidth'] - c['width']) == 0 ?   1000000 : ( c['maxWidth'] - c['width']);
        int growSize = math.min((growProportion * c['width']).floor() - c['width'], cWidth);
        if (growSize==0) growSize= 1;
        total += growSize;
        widths[i] += growSize;
      }
      if (prevTotal == total) {  // avoid infinite loop
        break;
      }
      prevTotal = total;
    }

    bool reRender = false;
    for (i = 0; i < columns.length; i++) {
      if (columns[i]['rerenderOnResize']!=null && columns[i].width != widths[i]) {
        reRender = true;
      }
      columns[i].width = widths[i];
    }

    applyColumnHeaderWidths();
    updateCanvasWidth(true);
    if (reRender) {
      invalidateAllRows();
      render();
    }
  }
  getViewportWidth() {
    viewportW = core.Dimension.getCalcWidth(container);
       // container.style.width; //parseFloat($.css($container[0], "width", true));
  }
  void resizeCanvas([Event e]) {
    if (!initialized) { return; }
    paneTopH = 0;
    paneBottomH = 0;
    viewportTopH = 0;
    viewportBottomH = 0;
    getViewportWidth();
    getViewportHeight();


//    if (options['autoHeight']==true) {
//      viewportH = options['rowHeight'] * getDataLengthIncludingAddNew();
//    } else {
//      viewportH = getViewportHeight();
//    }
// Account for Frozen Rows
     if (hasFrozenRows) {
         if (options['frozenBottom']) {
             paneTopH = viewportH - frozenRowsHeight - scrollbarDimensions['height'];
             paneBottomH = frozenRowsHeight + scrollbarDimensions['height'];
         } else {
             paneTopH = frozenRowsHeight;
             paneBottomH = viewportH - frozenRowsHeight;
         }
     } else {
         paneTopH = viewportH;
     }

// The top pane includes the top panel and the header row
     paneTopH += topPanelH + headerRowH;

     if (options['frozenColumn'] > -1 && options['autoHeight']) {
         paneTopH += scrollbarDimensions['height'];
     }

     // The top viewport does not contain the top panel or header row
     viewportTopH = paneTopH - topPanelH - headerRowH;

     if (options['autoHeight']==true) {
         if (options['frozenColumn'] > -1) {
             container.style.height = '${paneTopH + int.parse($headerScrollerL.style.height.replaceFirst("px", ""))}px';
         }
         $paneTopL.style.position= 'relative';
     }
     $paneTopL.style.top= '${$paneHeaderL.contentEdge.height}px';
     $paneTopL.style.height= '${paneTopH}px';
     int paneBottomTop = ($paneTopL.offsetTo($paneTopL.parent).y + paneTopH).round();

     $viewportTopL.style.height ='${viewportTopH}px';

     if (options['frozenColumn'] > -1) {
         $paneTopR.style.top='${$paneHeaderL.contentEdge.height}px';
         $paneTopR.style.height='${paneTopH}px';

         $viewportTopR.style.height = '${viewportTopH}px';

         if (hasFrozenRows) {
           $paneBottomL.style.top='${paneBottomTop}px';
           $paneBottomL.style.height='${paneBottomH}px';
           $paneBottomR.style.top='${paneBottomTop}px';
           $paneBottomR.style.height='${paneBottomH}px';
           $viewportBottomR.style.height ='${paneBottomH}px';
         }
     } else {
         if (hasFrozenRows) {
             $paneBottomL.style.width='100%';
             $paneBottomL.style.height='${paneBottomH}px';
             $paneBottomL.style.top='${paneBottomTop}px';
         }
     }

     if (hasFrozenRows) {
         $viewportBottomL.style.height =  '${paneBottomH}px';

         if (options['frozenBottom']) {
             $canvasBottomL.style.height = '${frozenRowsHeight}px';

             if (options['frozenColumn'] > -1) {
                 $canvasBottomR.style.height = '${frozenRowsHeight}px';
             }
         } else {
             $canvasTopL.style.height =  '${frozenRowsHeight}px';

             if (options['frozenColumn'] > -1) {
                 $canvasTopR.style.height ='${frozenRowsHeight}px'; //(frozenRowsHeight);
             }
         }
     } else {
         $viewportTopR.style.height = '${viewportTopH}px'; //(viewportTopH);
     }

     if (options['forceFitColumns']==true) {
         autosizeColumns();
     }

//    viewportW = core.Dimension.getCalcWidth(container);
////    viewportW =  double.parse(container.getComputedStyle().width.replaceAll("px", '')).ceil() ;//parseFloat($.css($container[0], "width", true));
//    if (options['autoHeight']==false) {
//      $viewport.style.height = '$viewportH' + 'px';
//      $viewportL.style.height = '$viewportH' + 'px';
//    }

    if (options['forceFitColumns']==true ) {
      autosizeColumns();
    }

    updateRowCount();
    handleScroll();
    // Since the width has changed, force the render() to reevaluate virtually rendered cells.
    lastRenderedScrollLeft = -1;
    render();
  }
  /**
   * append templat to parent Node
   * return created element
   */
  Element _createElem(Element parentNode,String templateStr){
    Element elem = container.createFragment(templateStr
            ,treeSanitizer :_treeSanitizer).children.first;
    parentNode.append(elem);
    return elem;
  }
  void init() {

    // calculate these only once and share between grid instances
    if(maxSupportedCssHeight == null) maxSupportedCssHeight = getMaxSupportedCssHeight();
    if(scrollbarDimensions ==null)scrollbarDimensions = measureScrollbar();
    defaults.forEach( (k,v) =>
        options.putIfAbsent(k, ()=> v)
    );
    validateAndEnforceOptions();
    columnDefaults.width = options['defaultColumnWidth'];

    columnsById = {};

    for (int i = 0; i < columns.length; i++) {
      var tmp = new Column.fromColumn(columnDefaults);

      tmp.merge(columns[i]);
      Column m = columns[i] = tmp;
      columnsById[m.id] = i;
      if (m['minWidth']!=null && m['width'] < m['minWidth']) {
        m.width = m.minWidth;
      }
      if (m['maxWidth']!=null && m['width'] > m['maxWidth']) {
        m.width = m.maxWidth;
      }
    }

    editController = {
                      "commitCurrentEdit": commitCurrentEdit,
                      "cancelCurrentEdit": cancelCurrentEdit
    };

    container..children.clear()
      ..style.outline = '0'
      ..style.overflow = 'hidden'
      ..classes.add(uid)
      ..classes.add("ui-widget");

    if (! new RegExp(r'relative|absolute|fixed').hasMatch(container.style.position )){
      container.style.position= "relative";
    }
    $focusSink = container.createFragment("<div tabIndex='0' hideFocus style='position:fixed;width:0;height:0;top:0;left:0;outline:0;'></div>", treeSanitizer: _treeSanitizer)
                         .children.first;
    container.append($focusSink);

    $paneHeaderL = _createElem(container,"<div class='slick-pane slick-pane-header slick-pane-left' tabIndex='0' />");
    $paneHeaderR = _createElem(container,"<div class='slick-pane slick-pane-header slick-pane-right' tabIndex='0' />");
    $paneTopL = _createElem(container,"<div class='slick-pane slick-pane-top slick-pane-left' tabIndex='0' />");
    $paneTopR = _createElem(container,"<div class='slick-pane slick-pane-top slick-pane-right' tabIndex='0' />");
    $paneBottomL = _createElem(container,"<div class='slick-pane slick-pane-bottom slick-pane-left' tabIndex='0' />");
    $paneBottomR= _createElem(container,"<div class='slick-pane slick-pane-bottom slick-pane-right' tabIndex='0' />");

    $headerScrollerL = _createElem($paneHeaderL,"<div class='ui-state-default slick-header slick-header-left' />");
    $headerScrollerR = _createElem($paneHeaderR,"<div class='ui-state-default slick-header slick-header-right' />");

    //container.append($headerScroller);
    $headerScroller..add($headerScrollerL)..add($headerScrollerR);
     // Append the header scroller containers

     // Append the columnn containers to the headers
     $headerL = _createElem($headerScrollerL,"<div class='slick-header-columns slick-header-columns-left' style='left:-1000px' />");
     $headerR = _createElem($headerScrollerR,"<div class='slick-header-columns slick-header-columns-right' style='left:-1000px' />");
     $headers..add($headerL)..add($headerR);
      $headerRowScrollerL = _createElem($paneTopL,"<div class='ui-state-default slick-headerrow' />");
      $headerRowScrollerR = _createElem($paneTopR,"<div class='ui-state-default slick-headerrow' />");

      $headerRowScroller..add($headerRowScrollerL)..add($headerRowScrollerR);

      $headerRowSpacerL = _createElem($headerRowScrollerL,"<div style='display:block;height:1px;position:absolute;top:0;left:0;'></div>")
                           ..style.width = "${getCanvasWidth() + scrollbarDimensions['width']}px";

      $headerRowSpacerR = _createElem($headerRowScrollerR,"<div style='display:block;height:1px;position:absolute;top:0;left:0;'></div>")
          ..style.width = "${getCanvasWidth() + scrollbarDimensions['width']}px";

      $headerRowL = _createElem($headerRowScrollerL,"<div class='slick-headerrow-columns slick-headerrow-columns-left' />");
      $headerRowR = _createElem($headerRowScrollerR,"<div class='slick-headerrow-columns slick-headerrow-columns-right' />");

      $headerRow..add($headerRowL)..add($headerRowR);

      // Append the top panel scroller
      $topPanelScrollerL = _createElem($paneTopL,"<div class='ui-state-default slick-top-panel-scroller' />");
      $topPanelScrollerR = _createElem($paneTopR,"<div class='ui-state-default slick-top-panel-scroller' />");

      $topPanelScroller..add($topPanelScrollerL)..add($topPanelScrollerR);

      // Append the top panel
      $topPanelL = _createElem($topPanelScrollerL,"<div class='slick-top-panel' style='width:10000px' />");
      $topPanelR = _createElem($topPanelScrollerR,"<div class='slick-top-panel' style='width:10000px' />");

      $topPanel..add($topPanelL)..add($topPanelR);

      if (!options['showTopPanel']) {
          $topPanelScroller.forEach((_) => _.style.display='none');
      }

      if (!options['showHeaderRow']) {
          $headerRowScroller.forEach((_) => _.style.display='none');
      }

      // Append the viewport containers
      $viewportTopL = _createElem($paneTopL,"<div class='slick-viewport slick-viewport-top slick-viewport-left' tabIndex='0' hideFocus />");
      $viewportTopR = _createElem($paneTopR,"<div class='slick-viewport slick-viewport-top slick-viewport-right' tabIndex='0' hideFocus />");
      $viewportBottomL = _createElem($paneBottomL,"<div class='slick-viewport slick-viewport-bottom slick-viewport-left' tabIndex='0' hideFocus />");
      $viewportBottomR = _createElem($paneBottomR,"<div class='slick-viewport slick-viewport-bottom slick-viewport-right' tabIndex='0' hideFocus />");

      // Cache the viewports
      $viewport..add($viewportTopL)..add($viewportTopR)..add($viewportBottomL)..add($viewportBottomR);

      // Default the active viewport to the top left
      $activeViewportNode = $viewportTopL;

      // Append the canvas containers
      $canvasTopL = _createElem($viewportTopL,"<div class='grid-canvas grid-canvas-top grid-canvas-left' tabIndex='0' hideFocus />");
      $canvasTopR = _createElem($viewportTopR,"<div class='grid-canvas grid-canvas-top grid-canvas-right' tabIndex='0' hideFocus />");
      $canvasBottomL = _createElem($viewportBottomL,"<div class='grid-canvas grid-canvas-bottom grid-canvas-left' tabIndex='0' hideFocus />");
      $canvasBottomR = _createElem($viewportBottomR,"<div class='grid-canvas grid-canvas-bottom grid-canvas-right' tabIndex='0' hideFocus />");

      // Cache the canvases
      $canvas..add($canvasTopL)..add($canvasTopR)..add($canvasBottomL)..add($canvasBottomR);

      // Default the active canvas to the top left
      $activeCanvasNode = $canvasTopL;




//      $headerRowScroller = container.createFragment("<div class='slick-headerrow ui-state-default' style='overflow:hidden;position:relative;' />"
//          ,treeSanitizer :_treeSanitizer).children.first;
//      container.append($headerRowScroller);
//
//      $headerRow = container.createFragment("<div class='slick-headerrow-columns' />"
//          ,treeSanitizer :_treeSanitizer).children.first;
//
//      $headerRowScroller.append($headerRow);
//
//      $headerRowSpacerL = container.createFragment("<div style='display:block;height:1px;position:absolute;top:0;left:0;'></div>"
//          ,treeSanitizer :_treeSanitizer).children.first;
//      $headerRowSpacerL.style.width= (getCanvasWidth() + scrollbarDimensions['width']).toString() + "px";
//      $headerRowScroller.append( $headerRowSpacerL);

//      $topPanelScroller = container.createFragment("<div class='slick-top-panel-scroller ui-state-default' style='overflow:hidden;position:relative;' />"
//          ,treeSanitizer :_treeSanitizer).children.first;
//      container.append($topPanelScroller);
//      $topPanel = container.createFragment("<div class='slick-top-panel' style='width:10000px' />"
//          ,treeSanitizer :_treeSanitizer).children.first;
//
//      $topPanelScroller.append($topPanel);

//      if (!options['showTopPanel']) {
//        $topPanelScroller.style.display='none';
//      }
//
//      if (!options['showHeaderRow']) {
//        $headerRowScroller.style.display='none';
//      }

//      $viewport = container.createFragment("<div class='slick-viewport' style='width:100%;overflow:auto;outline:0;position:relative;'>"
//          ,treeSanitizer :_treeSanitizer).children.first;
//      container.append($viewport);
//
//      $viewport.style.overflowY =  options['autoHeight'] ? "hidden" : "auto";
//
//      $canvas = container.createFragment("<div class='grid-canvas' />" ,treeSanitizer :_treeSanitizer).children.first;
//      $viewport.append($canvas);


      //Add viewport L
//      $viewportL = container.createFragment("<div class='slick-viewport pane-left' style='width:100%;overflow:auto;outline:0;position:relative;'>"
//                ,treeSanitizer :_treeSanitizer).children.first;
//      container.append($viewportL);
//
//      $viewportL.style.overflowY =  options['autoHeight'] ? "hidden" : "auto";
//
//      $canvasL = container.createFragment("<div class='grid-canvas' />" ,treeSanitizer :_treeSanitizer).children.first;
//      $viewportL.append($canvasL);


      $focusSink2 = $focusSink.clone(true);
      container.append($focusSink2);

      if (options['explicitInitialization']!=true) {
        finishInitialization();
      }
    }

  void finishInitialization() {
    if (!initialized) {
      initialized = true;
//      print(container.getBoundingClientRect().width);
      viewportW = core.Dimension.getCalcWidth(container);
      getViewportHeight();
//      viewportW = int.parse(container.getComputedStyle().width.replaceAll('px', ''));
      measureCellPaddingAndBorder();

      // for usability reasons, all text selection in SlickGrid is disabled
      // with the exception of input and textarea elements (selection must
      // be enabled there so that editors work as expected); note that
      // selection in grid cells (grid body) is already unavailable in
      // all browsers except IE
      disableSelection($headers); // disable all text selection in header (including input and textarea)

      if (options['enableTextSelectionOnCells']==false) {
        // disable text selection in grid cells except in input and textarea elements
        $viewport.forEach((item){
          item.onSelectStart.listen((event){
            if(event.target is InputElement || event.target is TextAreaElement){

            }else{
              event.preventDefault();
            }
          });

        });
      }
      setFrozenOptions();
      setPaneVisibility();
      setScroller();
      setOverflow();


      updateColumnCaches();
      createColumnHeaders();
      setupColumnSort();
      createCssRules();
      resizeCanvas();
      bindAncestorScrollEvents();

      window.onResize.listen(resizeCanvas);
//      $container
//          .bind("resize.slickgrid", resizeCanvas);
      $viewport.forEach((_)=> _.onScroll.matches('*').listen(handleScroll));

      //TODO tets
      $headerScroller.forEach((_)=> _..onContextMenu.listen(handleHeaderContextMenu)
      ..onClick.listen(handleHeaderClick));
      $headerScroller.forEach((_)=> _.querySelectorAll('.slick-header-column').onMouseEnter.listen(handleHeaderMouseEnter));
      $headerScroller.forEach((_)=> _.querySelectorAll('.slick-header-column').onMouseLeave.listen(handleHeaderMouseLeave));
      $headerRowScroller.forEach((_)=> _.onScroll.listen(handleHeaderRowScroll));
      $focusSink.onKeyDown.listen(handleKeyDown);
      $focusSink2.onKeyDown.listen(handleKeyDown);

      $canvas.forEach((_)=> _..onKeyDown.listen(handleKeyDown)
      ..onClick.listen(handleClick)
      ..onDoubleClick.listen(handleDblClick)
      );
//TODO fix me
//      ..onContextMenu.listen(handleContextMenu)
      $canvas.forEach((_)=> _
      ..onDragStart.listen(handleDragStart)
      ..onDrag.listen(handleDrag)
      ..onDragEnd.listen(handleDragEnd));
      $canvas.forEach((_)=> _.onMouseEnter.matches('.slick-cell').listen(handleMouseEnter));
      $canvas.forEach((_)=> _.onMouseLeave.matches('.slick-cell').listen(handleMouseLeave));

    }
  }  //end of initialize

    void registerPlugin(IPlugin plugin) {
      plugins.add(plugin);
      plugin.init(this);
    }

    void unregisterPlugin(IPlugin plugin) {
      plugins.remove(plugin);
      plugin.destroy();
    }
    void setSelectionModel(SelectionModel model) {
      if (selectionModel!=null ) {
        selectionModel.onSelectedRangesChanged.unsubscribe(handleSelectedRangesChanged);
        //if (selectionModel.destroy) {
          selectionModel.destroy();
        //}
      }

      selectionModel = model;
      if (selectionModel!=null) {
        selectionModel.init(this);
        selectionModel.onSelectedRangesChanged.subscribe(handleSelectedRangesChanged);
      }
    }
//    void setSelectionModel( model) {
      //TODO model : selection model
//      if (selectionModel) {
//        selectionModel.onSelectedRangesChanged.unsubscribe(handleSelectedRangesChanged);
//        if (selectionModel.destroy) {
//          selectionModel.destroy();
//        }
//      }
//
//      selectionModel = model;
//      if (selectionModel) {
//        selectionModel.init(this);
//        selectionModel.onSelectedRangesChanged.subscribe(handleSelectedRangesChanged);
//      }
//    }


    getSelectionModel() {
      return selectionModel;
    }

    Element getCanvasNode() {
      return $canvas[0];
    }
    /**
     * for cell selection
     */
    Element getActiveCanvasNode([Event element]) {
        setActiveCanvasNode(element);
        return $activeCanvasNode;
    }
    setActiveCanvasNode([Event element]) {
        if (element!=null) {
            $activeCanvasNode = findClosestAncestor(element.target ,'.grid-canvas');
        }
    }

    getViewportNode() {
        return $viewport[0];
    }

    Element getActiveViewportNode(Event element) {
        setActiveViewPortNode(element);
        return $activeViewportNode;
    }

    void setActiveViewPortNode(Event element) {
        if (element!=null) {
            $activeViewportNode = findClosestAncestor(element.target,'.slick-viewport');
        }
    }

    Map<String,int> measureScrollbar() {
      var $c =  querySelector('body').createFragment("<div style='position:absolute; top:-10000px; left:-10000px; width:100px; height:100px; overflow:scroll;'></div>"
          ,treeSanitizer : _treeSanitizer).children.first;

      querySelector('body').append($c);
      CssStyleDeclaration style=$c.getComputedStyle();
      Map dim = {
        'width': core.Dimension.getCalcWidth($c) - $c.clientWidth,
        'height': core.Dimension.getCalcHeight($c) - $c.clientHeight
        //'width': int.parse(style.width.replaceAll('px','')) -  $c.clientWidth, // $c[0].clientWidth,
        //'height': int.parse(style.height.replaceAll('px','')) - $c.clientHeight
      };
      $c.remove();
      return dim;
    }




    String defaultFormatter(int row,int  cell,dynamic value,[ columnDef, dataContext]) {
      if (value == null) {
        return "";
      }
      if(value is num || value is bool) return value.toString();
      return HTML_ESCAPE.convert(value);
    }


    void getHeadersWidth() {
      headersWidth = headersWidthL = headersWidthR = 0;
//      int headersWidth = 0;
      for (int i = 0, ii = columns.length; i < ii; i++) {
        var width = columns[i].width;
        if ( options['frozenColumn']  > -1 &&  i > options['frozenColumn'] ) {
             headersWidthR += width;
         } else {
             headersWidthL += width;
         }
      }
      if (options['frozenColumn'] > -1) {
          headersWidthL = headersWidthL + 1000;

          headersWidthR = math.max(headersWidthR, viewportW) + headersWidthL;
          headersWidthR += scrollbarDimensions['width'];
      } else {
          headersWidthL += scrollbarDimensions['width'];
          headersWidthL = math.max(headersWidthL, viewportW) + 1000;
      }

      headersWidth = headersWidthL + headersWidthR;
    }

    int getCanvasWidth() {
      int availableWidth = viewportHasVScroll ? viewportW - scrollbarDimensions['width'] : viewportW;
      //int rowWidth = 0;
      int i = columns.length;
      canvasWidthL = canvasWidthR = 0;

      while (i-- >0) {
        if ((options['frozenColumn'] > -1) && (i > options['frozenColumn'])) {
            canvasWidthR += columns[i].width;
        } else {
            canvasWidthL += columns[i].width;
        }
        //rowWidth += columns[i].width;
      }
      var totalRowWidth = canvasWidthL + canvasWidthR;
      return options['fullWidthRows'] ? math.max(totalRowWidth, availableWidth) : totalRowWidth;
    }

    void updateCanvasWidth(bool forceColumnWidthsUpdate) {
      var oldCanvasWidth = canvasWidth;
      var oldCanvasWidthL = canvasWidthL;
      var oldCanvasWidthR = canvasWidthR;
      bool widthChanged;
      canvasWidth = getCanvasWidth();
      widthChanged = canvasWidth != oldCanvasWidth || canvasWidthL != oldCanvasWidthL || canvasWidthR != oldCanvasWidthR;
      if (widthChanged || options['frozenColumn'] >-1  || hasFrozenRows) {
        $canvasTopL.style.width ='${canvasWidthL}px';
        getHeadersWidth();
        $headerL.style.width = "${headersWidthL}px";
        $headerR.style.width = "${headersWidthR}px";
        if (options['frozenColumn'] > -1) {
            $canvasTopR.style.width ="${canvasWidthR}px";
            $paneHeaderL.style.width="${canvasWidthL}px";
            $paneHeaderR.style.left = "${canvasWidthL}px";
            $paneHeaderR.style.width = "${viewportW - canvasWidthL}px";
            $paneTopL.style.width= "${canvasWidthL}px";
            $paneTopR.style.left = "${canvasWidthL}px";
            $paneTopR.style.width = "${viewportW - canvasWidthL}px";
            $headerRowScrollerL.style.width="${canvasWidthL}px";
            $headerRowScrollerR.style.width="${viewportW- canvasWidthL}px";
            $headerRowL.style.width = "${canvasWidthL}px";
            $headerRowR.style.width = "${canvasWidthR}px";
            $viewportTopL.style.width = "${canvasWidthL}px";
            $viewportTopR.style.width = "${viewportW - canvasWidthL}px";

            if (hasFrozenRows) {
                $paneBottomL.style.width = "${canvasWidthL}px";
                $paneBottomR.style.left = "${canvasWidthL}px";
                $viewportBottomL.style.width = "${canvasWidthL}px";
                $viewportBottomR.style.width = "${viewportW - canvasWidthL}px";
                $canvasBottomL.style.width = "${canvasWidthL}px";
                $canvasBottomR.style.width = "${canvasWidthR}px";
            }
        }else {
          $paneHeaderL.style.width ='100%';
          $paneTopL.style.width ='100%';
          $headerRowScrollerL.style.width='100%';
          $headerRowL.style.width="${canvasWidth}px";
          $viewportTopL.style.width = '100%';
          if (hasFrozenRows) {
              $viewportBottomL.style.width ='100%';
              $canvasBottomL.style.width = "${canvasWidthL}px";
          }
      }
        viewportHasHScroll = (canvasWidth > viewportW - scrollbarDimensions['width']);
      }
      $headerRowSpacerL.style.width = "${canvasWidth + (viewportHasVScroll ? scrollbarDimensions["width"] : 0)}px";
      $headerRowSpacerR.style.width = "${canvasWidth + (viewportHasVScroll ? scrollbarDimensions['width'] : 0)}px";
//      $headerRowSpacer.style.width =(canvasWidth + (viewportHasVScroll ?  scrollbarDimensions['width']: 0)).toString() +'px';

      if (widthChanged || forceColumnWidthsUpdate) {
        applyColumnWidths();
      }
    }
    /**
     * disable header teselection
     */
    void disableSelection(List<Element> list) {
      list.forEach(($target) {
          if ($target !=null) {
            $target.attributes['unselectable'] = 'on';
            $target.style.userSelect = 'none';
    //for IE, not tested
            ElementStream<Event> stream =$target.onSelectStart;
            stream.matches('.ui').listen(
                (Event e){
                  print('nonselect');
                  e.preventDefault();
                  e.stopImmediatePropagation();
                }, onDone : ()=> print('done'));

          }
      });
    }

    /**
     * when height not enought, keyboard scroll up/down may cause data high > suporttedHeight and cause exception
     */
    getMaxSupportedCssHeight() {
      int supportedHeight = 1000000;
      // FF reports the height back but still renders blank after ~6M px
      int testUpTo = 1000000000; // : 1000000000;
      Element div =  querySelector('body').createFragment("<div style='display:none' />",treeSanitizer: _treeSanitizer).children.first;
      document.body.append(div);
      while (true) {
        var test = supportedHeight * 2;
        div.style.height = "$test" +'px';

        if (test > testUpTo || int.parse( div.getComputedStyle().height.replaceFirst('px', '')) != test) {
          break;
        } else {
          supportedHeight = test;
        }
      }

      div.remove();
      return supportedHeight;
    }
// TODO:  this is static.  need to handle page mutation.
    bindAncestorScrollEvents() {
      Element elem = (hasFrozenRows && !options['frozenBottom']) ? $canvasBottomL : $canvasTopL;
//      while (!(elem.parent is ShadowRoot) && (elem = elem.parentNode) != document.body && elem != null) {
//        // bind to scroll containers only
//        if (elem == $viewportTopL || elem.scrollWidth != elem.clientWidth || elem.scrollHeight != elem.clientHeight) {
//          if ($boundAncestors==null) {
//            $boundAncestors = [elem];
//          } else {
//            $boundAncestors.add(elem);  //TODO
//          }
//          _ancestorScrollSubscribe = elem.onScroll.matches('.$uid' ).listen(handleActiveCellPositionChange);
//
//        }
//      }
 //     _ancestorScrollSubscribe = container.querySelectorAll('.slick-pane').onScroll.listen(handleActiveCellPositionChange);
   //   _ancestorScrollSubscribe = this.$viewportBottomL.onScroll.listen(handleActiveCellPositionChange);
    }

    unbindAncestorScrollEvents() {
      _ancestorScrollSubscribe.cancel();
    }

    updateColumnHeader(String columnId,String title, toolTip) {
      if (!initialized) { return; }
      int idx = getColumnIndex(columnId);
      if (idx == null) {
        return;
      }

      Column columnDef = columns[idx];

      Element $header = $headers.expand((i)=>i.children).toList()[idx];
      if ($header !=null) {
        if (title != null) {
          columns[idx].name = title;
        }
        if (toolTip != null) {
          columns[idx].toolTip = toolTip;
        }

        trigger(this.onBeforeHeaderCellDestroy, {
          "node": $header,
          "column": columnDef
        });

        $header.attributes.putIfAbsent('title', () => toolTip);
        $header.children.first.innerHtml=title;

        trigger(this.onHeaderCellRendered, {
          "node": $header,
          "column": columnDef
        });
      }
    }

    getHeaderRow() {
      return $headerRow;
    }

    getHeaderRowColumn(columnId) {
      int idx = getColumnIndex(columnId);
      Element $headerRowTarget;
      if (options['frozenColumn'] > -1) {
          if (idx <= options['frozenColumn']) {
              $headerRowTarget = $headerRowL;
          } else {
              $headerRowTarget = $headerRowR;
              idx -= options['frozenColumn'] + 1;
          }
      } else {
          $headerRowTarget = $headerRowL;
      }
      var $header = $headerRowTarget.children[idx];
      return $header;
//      var idx = getColumnIndex(columnId);
//      var $header = $headerRow.children[idx];
//      return $header;
    }

    createColumnHeaders() {
      void onMouseEnter(MouseEvent e) {
        Element el =e.currentTarget;
        el.classes.add("ui-state-hover");
      }

      void onMouseLeave(MouseEvent e) {
         Element el =e.currentTarget;
         el.classes.remove("ui-state-hover");
      }
      $headers.forEach((hItem){
        hItem.querySelectorAll(".slick-header-column")
          .forEach( (Element item) {
            var columnDef = item.dataset["column"];
            if (columnDef!=null) {
              trigger(this.onBeforeHeaderCellDestroy, {
                "node": this,
                "column": columnDef
              });
            }
          });
      });
      $headerL.children.clear();
      $headerR.children.clear();
      getHeadersWidth();
      $headerL.style.width = '${headersWidthL}px';
      $headerR.style.width ='${headersWidthR}px';
     // hItem.style.width =getHeadersWidth().toString() + 'px';
      $headerRow.forEach((item){
        item.querySelectorAll(".slick-headerrow-column").forEach((Element item){
          String columnDef =item.dataset['column'];
          if(columnDef!=null) trigger(onBeforeHeaderRowCellDestroy,
              { "node": this,
                "column": columnDef}
          );
        });
      });

      $headerRowL.children.clear();
      $headerRowR.children.clear();

      for (int i = 0; i < columns.length; i++) {
        Column m = columns[i];
        var $headerTarget = (options['frozenColumn'] > -1) ? ((i <= options['frozenColumn']) ? $headerL : $headerR) : $headerL;
        var $headerRowTarget = (options['frozenColumn'] > -1) ? ((i <= options['frozenColumn']) ? $headerRowL : $headerRowR) : $headerRowL;

        Element header =  container.createFragment("<div class='ui-state-default slick-header-column' />").children.first;

        header.append( container.createFragment("<span class='slick-column-name'>" + m['name'] + "</span>").children.first);
        header.style.width = (m['width'] - headerColumnWidthDiff).toString() + 'px';
        header.attributes['id']= uid + m.id;
        if(m.toolTip!=null) header.attributes['title']=m.toolTip;
        //header.dataset['column']=JSON.encode(m._src);
        _headExt[header] = m;

        if (m['headerCssClass'] !=null) header.classes.add(m['headerCssClass']);
        header.classes.add(m['headerCssClass'] == null ? '': m['headerCssClass'] );
        $headerTarget.append(header);
        if (options['enableColumnReorder'] ==true || m['sortable'] == true) {
          header.onMouseEnter.listen(onMouseEnter);
          header.onMouseLeave.listen(onMouseLeave);
        }

        if (m['sortable']) {
          header.classes.add("slick-header-sortable");
          header.append( container.createFragment("<span class='slick-sort-indicator' />").children.first);
        }

        trigger(onHeaderCellRendered, {
          "node": header,
          "column": m
        });

        if (options['showHeaderRow']) {
          Element headerRowCell =  container.createFragment("<div class='ui-state-default slick-headerrow-column l" + i.toString() + " r" + i.toString() + "'></div>"
              ,treeSanitizer:_treeSanitizer).children.first;
          headerRowCell.dataset['column']=JSON.encode(m);
          $headerRowTarget.append(headerRowCell);

          trigger(onHeaderRowCellRendered, {
            "node": headerRowCell,
            "column": m
          });
        }
        new DragAndDrop($headerRowTarget).install();
      }
//      new DragAndDrop($headerRowTarget).install();
      setSortColumns(sortColumns);
      setupColumnResize();
      if (options['enableColumnReorder']) {
        setupColumnReorder();
      }
    }

    measureCellPaddingAndBorder() {
      Element el;
      //List h = ["borderLeftWidth", "borderRightWidth", "paddingLeft", "paddingRight"];
      //List v = ["borderTopWidth", "borderBottomWidth", "paddingTop", "paddingBottom"];

      el = container.createFragment("<div class='ui-state-default slick-header-column' style='visibility:hidden'>-</div>"
          ,treeSanitizer: _treeSanitizer ).children.first;
      $headers.first.append(el);
      headerColumnWidthDiff = headerColumnHeightDiff = 0;
      if (el.style.boxSizing != "border-box"  ) {
          headerColumnWidthDiff += int.parse(el.getComputedStyle().borderLeftWidth.replaceAll('px',''),onError:(src)=>0);
          headerColumnWidthDiff += int.parse(el.getComputedStyle().borderRightWidth.replaceAll('px',''),onError:(src)=>0);
          headerColumnWidthDiff += int.parse(el.getComputedStyle().paddingLeft.replaceAll('px',''),onError:(src)=>0);
          headerColumnWidthDiff += int.parse(el.getComputedStyle().paddingRight.replaceAll('px',''),onError:(src)=>0);

          headerColumnHeightDiff += int.parse(el.getComputedStyle().borderTopWidth.replaceAll('px',''),onError:(src)=>0);
          headerColumnHeightDiff += int.parse(el.getComputedStyle().borderBottomWidth.replaceAll('px',''),onError:(src)=>0);
          headerColumnHeightDiff += int.parse(el.getComputedStyle().paddingTop.replaceAll('px',''),onError:(src)=>0);
          headerColumnHeightDiff += int.parse(el.getComputedStyle().paddingBottom.replaceAll('px',''),onError:(src)=>0);
      }
      el.remove();

      var r = container.createFragment("<div class='slick-row' />",treeSanitizer: _treeSanitizer ).children.first;
      $canvas.first.append(r); //appendTo($canvas);

      el =  container.createFragment("<div class='slick-cell' id='' style='visibility:hidden'>-</div>"
          ,treeSanitizer: _treeSanitizer).children.first;
      r.append(el);

      cellWidthDiff = cellHeightDiff = 0;
      if (el.style.boxSizing != "border-box") {
        cellWidthDiff += int.parse(el.getComputedStyle().borderLeftWidth.replaceAll('px',''),onError:(src)=>0);
        cellWidthDiff += int.parse(el.getComputedStyle().borderRightWidth.replaceAll('px',''),onError:(src)=>0);
        cellWidthDiff += int.parse(el.getComputedStyle().paddingLeft.replaceAll('px',''),onError:(src)=>0);
        cellWidthDiff += int.parse(el.getComputedStyle().paddingRight.replaceAll('px',''),onError:(src)=>0);

        cellHeightDiff += int.parse(el.getComputedStyle().borderTopWidth.replaceAll('px',''),onError:(src)=>0);
        cellHeightDiff += int.parse(el.getComputedStyle().borderBottomWidth.replaceAll('px',''),onError:(src)=>0);
        cellHeightDiff += int.parse(el.getComputedStyle().paddingTop.replaceAll('px',''),onError:(src)=>0);
        cellHeightDiff += int.parse(el.getComputedStyle().paddingBottom.replaceAll('px',''),onError:(src)=>0);
      }
      r.remove();

      absoluteColumnMinWidth = math.max(headerColumnWidthDiff, cellWidthDiff);
    }
//TODO reimplement using html5 dnd
    void setupColumnReorder() {
//      $headers.filter(":ui-sortable").sortable("destroy");
//      $headers.sortable({
//        containment: "parent",
//        distance: 3,
//        axis: "x",
//        cursor: "default",
//        tolerance: "intersection",
//        helper: "clone",
//        placeholder: "slick-sortable-placeholder ui-state-default slick-header-column",
//        start: (e, ui) {
//          ui.placeholder.width(ui.helper.outerWidth() - headerColumnWidthDiff);
//          $(ui.helper).addClass("slick-header-column-active");
//        },
//        beforeStop: (e, ui) {
//          $(ui.helper).removeClass("slick-header-column-active");
//        },
//        stop: (e) {
//          if (!getEditorLock().commitCurrentEdit()) {
//            $(this).sortable("cancel");
//            return;
//          }
//
//          var reorderedIds = $headers.sortable("toArray");
//          var reorderedColumns = [];
//          for (var i = 0; i < reorderedIds.length; i++) {
//            reorderedColumns.push(columns[getColumnIndex(reorderedIds[i].replace(uid, ""))]);
//          }
//          setColumns(reorderedColumns);
//
//          trigger(onColumnsReordered, {});
//          e.stopPropagation();
//          setupColumnResize();
//        }
//      });
    }

    void setupColumnResize() {

      List<Element> columnElements=[];
      Column c;
      var $col, j, pageX,  minPageX, maxPageX, firstResizable, lastResizable;
      $headers.forEach((_) => columnElements.addAll(_.children));
      columnElements.forEach((item)=> querySelectorAll(".slick-resizable-handle").forEach((Element itemB) => itemB.remove()));
      int i=0;
      columnElements.forEach( (item) {
        if (columns[i].resizable) {
          if (firstResizable == null) {
            firstResizable = i;
          }
          lastResizable = i;
        }
        i++;
      });
      if (firstResizable == null) {
        return;
      }

      for(i=0;i<columnElements.length;++i){
        Element item =columnElements[i];
        if (i < firstResizable || (options['forceFitColumns'] && i >= lastResizable)) {
          continue;
        }
        $col = item;
        Element resizeItem = new DivElement();
        resizeItem.classes.add('slick-resizable-handle');
        item.append(resizeItem);
        resizeItem.draggable=true;
        resizeItem.onDragStart.listen((MouseEvent e){
          int i=columnElements.indexOf((e.target as Element).parent);
          print('drag begin');
          if (!getEditorLock().commitCurrentEdit()) {
            return false;
          }
          pageX = e.page.x;
          print('pageX $pageX');
          resizeItem.parent.classes.add("slick-header-column-active");
          var shrinkLeewayOnRight = null, stretchLeewayOnRight = null;
          // lock each column's width option to current width

          for(int cnt=0;cnt<columnElements.length;cnt++){
            columns[cnt].previousWidth = columnElements[cnt].borderEdge.width;
          }
          if (options['forceFitColumns']) {
            shrinkLeewayOnRight = 0;
            stretchLeewayOnRight = 0;
            // colums on right affect maxPageX/minPageX
            for (j = i + 1; j < columnElements.length; j++) {
              c = columns[j];
              if (c.resizable) {
                if (stretchLeewayOnRight != null) {
                  if (c.maxWidth!=null) {
                    stretchLeewayOnRight += c.maxWidth - c.previousWidth;
                  } else {
                    stretchLeewayOnRight = null;
                  }
                }
                shrinkLeewayOnRight += c.previousWidth - math.max(c.minWidth , absoluteColumnMinWidth);
              }
            }
          }
          int shrinkLeewayOnLeft = 0, stretchLeewayOnLeft = 0;
          for (j = 0; j <= i; j++) {
            // columns on left only affect minPageX
            c = columns[j];
            if (c.resizable) {
              if (stretchLeewayOnLeft != null) {
                if (c.maxWidth!=null) {
                  stretchLeewayOnLeft += c.maxWidth - c.previousWidth;
                } else {
                  stretchLeewayOnLeft = null;
                }
              }
              shrinkLeewayOnLeft += c.previousWidth - math.max(c.minWidth , absoluteColumnMinWidth);
            }
          }
          if (shrinkLeewayOnRight == null) {
            shrinkLeewayOnRight = 100000;
          }
          if (shrinkLeewayOnLeft == null) {
            shrinkLeewayOnLeft = 100000;
          }
          if (stretchLeewayOnRight == null) {
            stretchLeewayOnRight = 100000;
          }
          if (stretchLeewayOnLeft == null) {
            stretchLeewayOnLeft = 100000;
          }
          maxPageX = pageX + math.min(shrinkLeewayOnRight, stretchLeewayOnLeft);
          minPageX = pageX - math.min(shrinkLeewayOnLeft, stretchLeewayOnRight);

        });

        resizeItem.onDrag.listen((MouseEvent e){
          //print('dragging ${e.page.x}');
          if(e.page.x==0) {  //TODO found onDrag end still trigger onDrag and with page.x=0, is it bug?
            e.preventDefault();
            return;
          }
          int i=columnElements.indexOf((e.target as Element).parent);
          int actualMinWidth, d = math.min(maxPageX, math.max(minPageX, e.page.x)) - pageX, x;
          if (d < 0) { // shrink column
            x = d;
            for (j = i; j >= 0; j--) {

              c = columns[j];
              if (c.resizable) {
                actualMinWidth = math.max(c.minWidth !=null ? c.minWidth: 0, absoluteColumnMinWidth);
                if (x!=0 && c.previousWidth + x < actualMinWidth) {
                  x += c.previousWidth - actualMinWidth;
                  c.width = actualMinWidth;
                } else {
                  c.width = c.previousWidth + x;
                  x = 0;
                }
              }
              //print('apply5 ${c.width} ${maxPageX} ${minPageX} ${d} ${c.previousWidth} ${actualMinWidth}');
            }

            if (options['forceFitColumns']) {
              print('apply4');
              x = -d;
              for (j = i + 1; j < columnElements.length; j++) {
                c = columns[j];
                if (c.resizable) {
                  if (x !=0 && c.maxWidth!=null  && (c.maxWidth - c.previousWidth < x)) {
                    x -= c.maxWidth - c.previousWidth;
                    c.width = c.maxWidth;
                  } else {
                    c.width = c.previousWidth + x;
                    x = 0;
                  }
                }
              }
            }
          } else { // stretch column
            //print('apply3');
            x = d;
            for (j = i; j >= 0; j--) {
              c = columns[j];
              if (c.resizable) {
                if (x !=0 && c.maxWidth!=null && (c.maxWidth - c.previousWidth < x)) {
                  x -= c.maxWidth - c.previousWidth;
                  c.width = c.maxWidth;
                } else {
                  c.width = c.previousWidth + x;
                  x = 0;
                }
              }
            }

            if (options['forceFitColumns']) {
             // print('apply1');
              x = -d;
              for (j = i + 1; j < columnElements.length; j++) {
                c = columns[j];
                if (c.resizable) {
                  actualMinWidth = math.max(c.minWidth !=null ? c.minWidth: 0, absoluteColumnMinWidth);
                  if (x !=0 && c.previousWidth + x < actualMinWidth) {
                    x += c.previousWidth - actualMinWidth;
                    c.width = actualMinWidth;
                  } else {
                    c.width = c.previousWidth + x;
                    x = 0;
                  }
                }
              }
            }
          }
          applyColumnHeaderWidths();
          if (options['syncColumnCellResize']!=null && options['syncColumnCellResize']==true) {
            //print('apply');
            applyColumnWidths();
          }
         // print('onDraging leave' + columnElements[i].borderEdge.width.toString());
        });
        resizeItem.onDragEnd.listen((MouseEvent e){
          print('drag End ${e.page.x}' );
          int i=columnElements.indexOf((e.target as Element).parent);
          var newWidth;
          item.parent.classes.remove("slick-header-column-active");
          for (j = 0; j < columnElements.length; j++) {
            c = columns[j];
            newWidth = columnElements[j].borderEdge.width;
            if (c.previousWidth != newWidth && c.rerenderOnResize) {
              invalidateAllRows();
            }
          }
          updateCanvasWidth(true);
          render();
          trigger(onColumnsResized, {});
        } );
      }

    }

    /////////////////////////////////////// general
    // event could be event data or dom event
    trigger(core.Event evt,[ Map<String,dynamic> args, dynamic e]) {   //[core.EventData e]
      if (e ==null) e =  new core.EventData();
      if(args ==null) args = {};
      args['grid']=this;
      return evt.notify(args, e, this);
    }
    void validateAndEnforceOptions() {
      if (options['autoHeight'] ) {
        options['leaveSpaceForNewRows'] = false;
      }
    }

    void updateColumnCaches() {
      // Pre-calculate cell boundaries.
      columnPosLeft = [];
      columnPosRight = [];
      int x = 0;
      for (int i = 0, ii = columns.length; i < ii; i++) {
        columnPosLeft.insert(i, x);
        columnPosRight.insert(i,x + columns[i].width);
        if (options['frozenColumn'] == i) {
             x = 0;
         } else {
             x += columns[i].width;
         }
      }
    }
    setColumns(List<Column> columnDefinitions) {
      columns = columnDefinitions;

      this.columnsById = {};
      for (var i = 0; i < columns.length; i++) {
        var m = columns[i] = new Column.fromColumn(columnDefaults).merge(columns[i]);
        columnsById[m.id] = i;
        if (m.minWidth && m.width < m.minWidth) {
          m.width = m.minWidth;
        }
        if (m.maxWidth && m.width > m.maxWidth) {
          m.width = m.maxWidth;
        }
      }

      updateColumnCaches();

      if (initialized) {
        invalidateAllRows();
        createColumnHeaders();
        removeCssRules();
        createCssRules();
        resizeCanvas();
        applyColumnWidths();
        handleScroll();
      }
    }

    Map getOptions() {
      return options;
    }

    void setOptions(args) {
      if (!getEditorLock().commitCurrentEdit()) {
        return;
      }

      makeActiveCellNormal();

      if (options['enableAddRow'] != args['enableAddRow']) {
        invalidateRow(getDataLength());
      }
      options.addAll(args);
//      options = $.extend(options, args);
      validateAndEnforceOptions();

      setFrozenOptions();
      setScroller();
      setColumns(columns); // TODO: Is this necessary?
//      $viewport.style.overflowY =  options['autoHeight']  ? "hidden" : "auto";
//      $viewportL.style.overflowY =  options['autoHeight']  ? "hidden" : "auto";
      render();
    }

    int getVBoxDelta(Element $el) {
      int delta =
      int.parse($el.getComputedStyle().borderTopWidth.replaceAll("px", ''))
       + int.parse($el.getComputedStyle().borderBottomWidth.replaceAll('px', ''))
       +  int.parse($el.getComputedStyle().paddingTop.replaceAll('px', ''))
       +  int.parse($el.getComputedStyle().paddingBottom.replaceAll('px', ''));
      return delta;
    }

    void setFrozenOptions() {
      options['frozenColumn'] = ( options['frozenColumn'] >= 0
          && options['frozenColumn'] < columns.length  )
          ? options['frozenColumn'] : -1;

      options['frozenRow'] = ( options['frozenRow'] >= 0
          && options['frozenRow'] < numVisibleRows      )
          ? options['frozenRow'] : -1;

      if (options['frozenRow'] > -1) {
          hasFrozenRows = true;
          frozenRowsHeight = ( options['frozenRow'] ) * options['rowHeight'];

          actualFrozenRow = ( options['frozenBottom'] ==true)
              ? ( data.length - options['frozenRow'] )
              : options['frozenRow'];
      } else {
          hasFrozenRows = false;
      }
  }

  setPaneVisibility() {
      if (options['frozenColumn'] > -1) {
        $paneHeaderR.hidden=false;
        $paneTopR.hidden=false;
          if (hasFrozenRows) {
              $paneBottomL.hidden=false;
              $paneBottomR.hidden=false;
          } else {
              $paneBottomR.hidden=true;
              $paneBottomL.hidden=true;
          }
      } else {
          $paneHeaderR.hidden=true;
          $paneTopR.hidden=true;
          $paneBottomR.hidden=true;

          if (hasFrozenRows) {
              $paneBottomL.hidden=false;
          } else {
              $paneBottomR.hidden=true;
              $paneBottomL.hidden=true;
          }
      }
  }

  setOverflow() {
    $viewportTopL.style.overflowX= ( options['frozenColumn'] > -1 )    ?  hasFrozenRows ==true ? 'hidden' : 'scroll' :  hasFrozenRows ==true ? 'hidden' : 'auto';
    $viewportTopL.style.overflowY= ( options['frozenColumn'] > -1 )    ?  hasFrozenRows ==true ? 'hidden' : 'hidden' :  hasFrozenRows ==true ? 'scroll' : 'auto';

    $viewportTopR.style.overflowX= ( options['frozenColumn'] > -1 )    ?  hasFrozenRows ==true ? 'hidden' : 'scroll' :  hasFrozenRows ==true ? 'hidden' : 'auto';
    $viewportTopR.style.overflowY= ( options['frozenColumn'] > -1 )    ?  hasFrozenRows ==true ? 'scroll' : 'auto'   :  hasFrozenRows ==true ? 'scroll' : 'auto';

    $viewportBottomL.style.overflowX= ( options['frozenColumn'] > -1 ) ?  hasFrozenRows ==true ? 'hidden' : 'auto'   :  hasFrozenRows ==true ? 'auto'   : 'auto';
    $viewportBottomL.style.overflowY= ( options['frozenColumn'] > -1 ) ?  hasFrozenRows ==true ? 'hidden' : 'hidden' :  hasFrozenRows ==true ? 'scroll' : 'auto';

    $viewportBottomR.style.overflowX= ( options['frozenColumn'] > -1 ) ?  hasFrozenRows ==true ? 'scroll' : 'auto'   :  hasFrozenRows ==true ? 'auto'   : 'auto';
    $viewportBottomR.style.overflowY= ( options['frozenColumn'] > -1 ) ?  hasFrozenRows ==true ? 'auto'   : 'auto'   :  hasFrozenRows ==true ? 'auto'   : 'auto';

  }

  setScroller() {
      if (options['frozenColumn'] > -1) {
          $headerScrollContainer = $headerScrollerR;
          $headerRowScrollContainer = $headerRowScrollerR;

          if (hasFrozenRows) {
              if (options['frozenBottom']) {
                  $viewportScrollContainerX = $viewportBottomR;
                  $viewportScrollContainerY = $viewportTopR;
              } else {
                  $viewportScrollContainerX = $viewportScrollContainerY = $viewportBottomR;
              }
          } else {
              $viewportScrollContainerX = $viewportScrollContainerY = $viewportTopR;
          }
      } else {
          $headerScrollContainer = $headerScrollerL;
          $headerRowScrollContainer = $headerRowScrollerL;

          if (hasFrozenRows) {
              if (options['frozenBottom']) {
                  $viewportScrollContainerX = $viewportBottomL;
                  $viewportScrollContainerY = $viewportTopL;
              } else {
                  $viewportScrollContainerX = $viewportScrollContainerY = $viewportBottomL;
              }
          } else {
              $viewportScrollContainerX = $viewportScrollContainerY = $viewportTopL;
          }
      }
  }


    void invalidate() {
      updateRowCount();
      invalidateAllRows();
      render();
    }

    void invalidateAllRows() {
      if (currentEditor!=null) {
        makeActiveCellNormal();
      }
//      rowsCache.clear();
      List tmp=rowsCache.keys.toList(growable: false);
      tmp.forEach((item) => removeRowFromCache(item)) ;
      if (this.selectionModel!=null && this.selectedRows.length>0) {
        this.setSelectedRows([]);
      }
    }

    void removeRowFromCache(int row) {
      RowCache cacheEntry = rowsCache[row];
      //$canvas.children.remove(cacheEntry.rowNode);

      cacheEntry.rowNode[0].parent.children.remove(cacheEntry.rowNode[0]);
      // Remove the row from the right viewport
      if (cacheEntry.rowNode.length>1) {
         cacheEntry.rowNode[1].parent.children.remove(cacheEntry.rowNode[1]);
      }


      rowsCache.remove(row);
//      delete rowsCache[row];
      postProcessedRows.remove(row);
//      delete postProcessedRows[row];
      renderedRows--;
      counter_rows_removed++;
    }

    void invalidateRows(rows) {
      var i, rl;
      if (rows==null || rows.length==0) {
        return;
      }
      vScrollDir = 0;
      for (int i = 0, rl = rows.length; i < rl; i++) {
        if (currentEditor!=null && activeRow == rows[i]) {
          makeActiveCellNormal();
        }
        if (rowsCache[rows[i]]!=null) {
          removeRowFromCache(rows[i]);
        }
      }
    }
    void invalidateRow(row) {
      invalidateRows([row]);
    }

    void updateCell(row, cell) {
      Element cellNode = getCellNode(row, cell);
      if (cellNode==null) {
        return;
      }

      Column m = columns[cell], d = getDataItem(row);
      if (currentEditor !=null && activeRow == row && activeCell == cell) {
        currentEditor.loadValue(d);
      } else {
        cellNode.setInnerHtml( d!=null ? getFormatter(row, m)(row, cell, getDataItemValueForColumn(d, m), m, d) : ""
          , treeSanitizer: _treeSanitizer );
        invalidatePostProcessingResults(row);
      }
    }

    void updateRow(row) {
      RowCache cacheEntry = rowsCache[row];
      if (cacheEntry==null) {
        return;
      }

      ensureCellNodesInRowsCache(row);

      var d = getDataItem(row);
      for(int columnIdx=0;columnIdx < cacheEntry.cellNodesByColumnIdx.length ; columnIdx++){
        Column m = columns[columnIdx];
        Element    node = cacheEntry.cellNodesByColumnIdx[columnIdx];
        if (row == activeRow && columnIdx == activeCell && currentEditor !=null) {
          currentEditor.loadValue(d);
        } else if (d) {
          node.setInnerHtml(
              getFormatter(row, m)(row, columnIdx, getDataItemValueForColumn(d, m), m, d) ,
              treeSanitizer: _treeSanitizer);
        } else {
          node.setInnerHtml("") ;
        }

      }
//+      for (var columnIdx in cacheEntry.cellNodesByColumnIdx) {
//        if (!cacheEntry.cellNodesByColumnIdx.hasOwnProperty(columnIdx)) {
//          continue;
//        }

//        columnIdx = columnIdx | 0;
//      }

      invalidatePostProcessingResults(row);
    }

    getViewportHeight() {

        if (options['autoHeight']!=null && options['autoHeight']) {
            viewportH = options['rowHeight']  * getDataLengthIncludingAddNew()
                + ( ( options['frozenColumn'] == -1 ) ? $headers.first.borderEdge.height : 0 );
        } else {
            CssStyleDeclaration csd = container.getComputedStyle();
            int height=core.Dimension.getCalcHeight(container);
            int paddingTop = int.parse(csd.paddingTop.replaceAll('px', ''));
            int paddingBottom = int.parse(csd.paddingBottom.replaceAll('px', ''));
            int headerScrollerHeight = core.Dimension.getCalcHeight($headerScroller.first);
            int vboxDelta =  getVBoxDelta($headerScroller.first) ;
            int topPanelHeight = options['showTopPanel'] ==true ?  options['topPanelHeight'] + getVBoxDelta($topPanelScroller.first) : 0;
            int headerRowHeight= options['showHeaderRow'] ==true ?  options['headerRowHeight'] + getVBoxDelta($headerRowScroller.first) : 0;
            viewportH= height - paddingTop - paddingBottom
                              - headerScrollerHeight - vboxDelta
                              - topPanelHeight - headerRowHeight;
         }

        numVisibleRows = (viewportH / options['rowHeight']).ceil();
        return viewportH;
    }






    setSortColumn(columnId, ascending) {
      setSortColumns([{ 'columnId': columnId, 'sortAsc': ascending}]);
    }

    setSortColumns(List<Map<String,dynamic>> cols) {
      sortColumns = cols;

      List<Element> headerColumnEls=[];
      $headers.forEach((_) => headerColumnEls.addAll(_.children));
      headerColumnEls.forEach((Element item){
        item.classes.remove("slick-header-column-sorted");
        Element chlidIndicator =item.querySelector('.slick-sort-indicator');
            if(  chlidIndicator!=null ){
              item.querySelector('.slick-sort-indicator').classes.
                removeAll(["slick-sort-indicator-asc", "slick-sort-indicator-desc"]);
            }
      });
      sortColumns.forEach((Map<String,dynamic> col){
        if (col['sortAsc']==null){
          col['sortAsc'] = true;
        }
        int columnIndex = getColumnIndex(col['columnId']);
        if (columnIndex != null) {
              List<Element> headers =$headers.expand((_) => _.children).toList();
              headers[columnIndex].classes.add('slick-header-column-sorted');
              headers[columnIndex].querySelector('.slick-sort-indicator')
                        .classes.add(col['sortAsc'] ==true ? "slick-sort-indicator-asc" : "slick-sort-indicator-desc");
        }
      });
    }
//////////////////////////////////////////////////////////////////////////////////////////////
    // Rendering / Scrolling

    int getRowTop(int row) {
      return options['rowHeight'] * row - offset;
    }

    int getRowFromPosition(y) {
      return ((y + offset) / options['rowHeight']).floor();
    }

    void scrollTo(int y) {
      y = math.max(y, 0);
      y = math.min(y, th - viewportH + (viewportHasHScroll ? scrollbarDimensions['height'] : 0));

      int oldOffset = offset;

      page = math.min(n - 1, (y / ph).floor());
      offset = (page * cj).round();
      int newScrollTop = y - offset;

      if (offset != oldOffset) {
        var range = getVisibleRange(newScrollTop);
        cleanupRows(range);
        updateRowPositions();
      }

      if (prevScrollTop != newScrollTop) {
        vScrollDir = (prevScrollTop + oldOffset < newScrollTop + offset) ? 1 : -1;
        lastRenderedScrollTop = ( scrollTop = prevScrollTop = newScrollTop );

        if (options['frozenColumn'] > -1) {
            $viewportTopL.scrollTop = newScrollTop;
        }

        if (hasFrozenRows) {
            $viewportBottomL.scrollTop = $viewportBottomR.scrollTop = newScrollTop;
        }

        $viewportScrollContainerY.scrollTop = newScrollTop;
//        $viewport.scrollTop = (lastRenderedScrollTop = scrollTop = prevScrollTop = newScrollTop);
        //$viewportL.scrollTop=$viewport.scrollTop;
        trigger(this.onViewportChanged, {});
      }
    }
    void cleanupRows(Map<String,int> rangeToKeep) {
      for (int i in new List.from(rowsCache.keys)) {

        var removeFrozenRow = true;

        if (hasFrozenRows
            && ( ( options['frozenBottom'] && i > actualFrozenRow ) // Frozen bottom rows
            || ( !options['frozenBottom'] && i < actualFrozenRow ) // Frozen top rows
            )
            ) {
            removeFrozenRow = false;
        }

        if ((i != activeRow) && (i < rangeToKeep['top'] || i > rangeToKeep['bottom']) && removeFrozenRow) {
          removeRowFromCache(i);
        }
      }
    }

//////////////////////////////////////////////////////////////////////////////////////////////
    // IEditor implementation for the editor lock

    commitCurrentEdit() {
      var item = getDataItem(activeRow);
      var column = columns[activeCell];

      if (currentEditor!=null) {
        if (currentEditor.isValueChanged()) {
          var validationResults = currentEditor.validate();

          if (validationResults['valid']) {
            if (activeRow < getDataLength()) {
              var editCommand = {
                'row': activeRow,
                'cell': activeCell,
                'editor': currentEditor,
                'serializedValue': currentEditor.serializeValue(),
                'prevSerializedValue': serializedEditorValue,
                'execute':  () {
                  currentEditor.applyValue(item, currentEditor.serializeValue());
//                  updateRow(this.row);
                },
                'undo':  () {
//                  this.editor.applyValue(item, this.prevSerializedValue);
//                  updateRow(this.row);
                }
              };

              if (options['editCommandHandler']!=null) {
                makeActiveCellNormal();
                options['editCommandHandler'](item, column, editCommand);
              } else {
                editCommand['execute']();
                makeActiveCellNormal();
              }

              trigger(this.onCellChange, {
                'row': activeRow,
                'cell': activeCell,
                'item': item
              });
            } else {
              var newItem = {};
              currentEditor.applyValue(newItem, currentEditor.serializeValue());
              makeActiveCellNormal();
              trigger(this.onAddNewRow, {item: newItem, column: column});
            }

            // check whether the lock has been re-acquired by event handlers
            return !getEditorLock().isActive();
          } else {
            // Re-add the CSS class to trigger transitions, if any.
            activeCellNode.classes.remove("invalid");
            activeCellNode.getComputedStyle();  // force layout
            activeCellNode.classes.add("invalid");

            trigger(this.onValidationError, {
              ['editor']: currentEditor,
              ['cellNode']: activeCellNode,
              ['validationResults']: validationResults,
              ['row']: activeRow,
              ['cell']: activeCell,
              ['column']: column
            });

            currentEditor.focus();
            return false;
          }
        }

        makeActiveCellNormal();
      }
      return true;
    }

    bool cancelCurrentEdit() {
      makeActiveCellNormal();
      return true;
    }


    /**
     * Range:  [fromCell,fromRow, toCell, toRow....]
     */
    List rowsToRanges(rows) {
      var ranges = [];
      var lastCell = columns.length - 1;
      for (int i = 0; i < rows.length; i++) {
        ranges.add(new core.Range(rows[i], 0, rows[i], lastCell));
      }
      return ranges;
    }
    /**
     * selection row model
     */
    List getSelectedRows() {
      if (selectionModel==null) {
        throw "Selection model is not set";
      }
      return selectedRows;
    }

    void setSelectedRows(rows) {
      if (selectionModel==null) {
        throw "Selection model is not set";
      }
      selectionModel.setSelectedRanges(rowsToRanges(rows));
    }



    int getDataLengthIncludingAddNew() {
      return getDataLength() + (options['enableAddRow']  ? 1 : 0);
    }
    List getData() {
      return data;
    }


    getDataItem(int i) {
        if(i>=data.length) return null;
        return data[i];
    }

    getTopPanel() {
      return $topPanel;
    }
    void updateRowPositions() {
      for (var row in rowsCache.keys) {
        rowsCache[row].rowNode.forEach((_)=> _.style.top = getRowTop(row).toString() + "px");
      }
    }


    cleanUpAndRenderCells(Map<String,int> range) {
      RowCache cacheEntry;
      List<String> stringArray = [];
      Queue processedRows = new Queue();
      var cellsAdded;
      int totalCellsAdded = 0;
      var colspan;
      //reuse for frozen rows
      _helper(int row){
            if(!rowsCache.keys.contains(row)){  return;    }
            cacheEntry = rowsCache[row];
            // cellRenderQueue populated in renderRows() needs to be cleared first
            ensureCellNodesInRowsCache(row);
            cleanUpCells(range, row);
            // Render missing cells.
            cellsAdded = 0;
            var d = getDataItem(row);
            // TODO:  shorten this loop (index? heuristics? binary search?)
            for (int cell = 0, ii = columns.length; cell < ii; cell++) {
              // Cells to the right are outside the range.
              if (columnPosLeft[cell] > range['rightPx']) {
                break;
              }
              // Already rendered.
              if(cacheEntry.cellNodesByColumnIdx.keys.contains(cell)){
                colspan = cacheEntry.cellColSpans[cell];
                cell += (colspan > 1 ? colspan - 1 : 0);
                continue;
              }
              colspan = 1;
              if (columnPosRight[math.min(ii - 1, cell + colspan - 1)] > range['leftPx']  ||
              options['frozenColumn']>=cell
              ) {
                appendCellHtml(stringArray, row, cell, colspan, d);
                cellsAdded++;
              }
              cell += (colspan > 1 ? colspan - 1 : 0);
            }

            if (cellsAdded >0) {
              totalCellsAdded += cellsAdded;
              processedRows.add(row);
            }
      }

      for (int row = range['top'], btm = range['bottom']; row <= btm; row++) {
        _helper(row);
      }
      if(this.hasFrozenRows && range['top'] >actualFrozenRow ){ //not count frozen bottom
        for (int row = 0, btm = this.actualFrozenRow; row < btm; row++) {
            _helper(row);
        }
      }


      if (stringArray.length==0) {
        return;
      }

      Element x = new DivElement();
      x.setInnerHtml(stringArray.join(""),  treeSanitizer: _treeSanitizer );

      var processedRow;
      var node;

      while (!processedRows.isEmpty) {
        processedRow = processedRows.removeLast();
        cacheEntry = rowsCache[processedRow];
        var columnIdx;
        while (!cacheEntry.cellRenderQueue.isEmpty) {
          columnIdx=cacheEntry.cellRenderQueue.removeLast();
          node = x.lastChild;
          if (( options['frozenColumn'] > -1 ) && ( columnIdx > options['frozenColumn'] )) {
              cacheEntry.rowNode[1].append(node);
          } else {
              cacheEntry.rowNode[0].append(node);
          }
//          cacheEntry.rowNode.append(node);
          cacheEntry.cellNodesByColumnIdx[columnIdx] = node;
        }
      }
    }

    void ensureCellNodesInRowsCache(row) {
      RowCache cacheEntry = rowsCache[row];
      if (cacheEntry!=null && cacheEntry.rowNode !=null) {
        if (cacheEntry.cellRenderQueue.length>0) {
          Element lastChild = cacheEntry.rowNode.last.lastChild;
          while (cacheEntry.cellRenderQueue.length>0) {
            int columnIdx = cacheEntry.cellRenderQueue.removeLast();
            cacheEntry.cellNodesByColumnIdx[columnIdx]=lastChild;

            lastChild = lastChild.previousNode; //previousSibling;
            // Hack to retrieve the frozen columns because
            if (lastChild==null) {
                lastChild = cacheEntry.rowNode.first.lastChild;
            }
          }
        }
      }
    }

     void cleanUpCells(range, int row) {
       if (hasFrozenRows  // Ignore frozen rows
             && ( ( options['frozenBottom'] && row > actualFrozenRow ) // Frozen bottom rows
             || ( row <= actualFrozenRow )                     // Frozen top rows
             )
             ) {
             return;
       }

      int totalCellsRemoved = 0;
      RowCache cacheEntry = rowsCache[row];

      // Remove cells outside the range.
      List cellsToRemove = [];
      for (var i in cacheEntry.cellNodesByColumnIdx.keys) {
        // Ignore frozen columns
//        if (i <= options['frozenColumn']) {
//            continue;
//        }
        var colspan = cacheEntry.cellColSpans[i];
        if (columnPosLeft[i] > range['rightPx'] ||
          columnPosRight[math.min(columns.length - 1, i + colspan - 1)] < range['leftPx']) {
          if (!(row == activeRow && i == activeCell)) {
            cellsToRemove.add(i);
          }
        }
      }

      var cellToRemove;

     cellsToRemove.forEach((item){
       cacheEntry.rowNode.forEach((_)=> _.children.remove(cacheEntry.cellNodesByColumnIdx[item]));
//       cacheEntry.cellColSpans.removeAt(item);
       cacheEntry.cellColSpans[item]=1;
       cacheEntry.cellNodesByColumnIdx.remove(item);
       if (postProcessedRows[row]!=null) {
          postProcessedRows[row].removeAt(cellToRemove);
       }
       totalCellsRemoved++;
     });


    }



    void  handleClick(MouseEvent e) {
      core.EventData evt = new core.EventData.fromDom(e);
       if (currentEditor==null) {
         // if this click resulted in some cell child node getting focus,
         // don't steal it back - keyboard events will still bubble up
         // IE9+ seems to default DIVs to tabIndex=0 instead of -1, so check for cell clicks directly.
         if (evt.target != document.activeElement || (evt.target as Element).classes.contains("slick-cell")) {
           setFocus();
         }
       }

       Map<String,int> cell = getCellFromEvent(evt);
       if (cell==null || (currentEditor != null && activeRow == cell['row'] && activeCell == cell['cell'])) {
         return;
       }

       trigger(this.onClick, {'row': cell['row'], 'cell': cell['cell']}, evt);
       //TODO not available
       if (evt.isImmediatePropagationStopped()) {
         return;
       }

       if ((activeCell != cell['cell'] || activeRow != cell['row']) && canCellBeActive(cell['row'], cell['cell'])) {
         if (!getEditorLock().isActive() || getEditorLock().commitCurrentEdit()) {
           if (hasFrozenRows) {
               if (( !( options['frozenBottom'] ) && ( cell['row'] >= actualFrozenRow ) )
                   || ( options['frozenBottom'] && ( cell['row'] < actualFrozenRow ) )
                   ) {
                   scrollRowIntoView(cell['row'], false);
               }
               setActiveCellInternal(getCellNode(cell['row'], cell['cell']));
           }
//           scrollRowIntoView(cell['row'], false);
//           setActiveCellInternal(getCellNode(cell['row'], cell['cell']));
         }
       }
     }
    void handleDblClick(MouseEvent e) {
      core.EventData evt = new core.EventData.fromDom(e);
        var cell = getCellFromEvent(evt);
        if (cell==null || (currentEditor != null && activeRow == cell['row'] && activeCell == cell['cell'])) {
            return;
        }

        trigger(this.onDblClick, {  'row': cell['row'],   'cell': cell['cell']  }, evt);
        if (evt.isImmediatePropagationStopped()) {
            return;
        }

        if (options['editable']) {
            gotoCell(cell['row'], cell['cell'], true);
        }
    }

    void setFocus() {
       if (tabbingDirection == -1) {
         $focusSink.focus();
       } else {
         $focusSink2.focus();
       }
     }

    Map<String,int> getCellFromEvent(core.EventData e) {
      Element elem=e.target;
//      var $expcell = elem.matchesWithAncestors('.slick-cell');
      var $cell = findClosestAncestor(e.target,'.slick-cell');
      if ($cell==null) {
        return null;
      }

      var row = getRowFromNode($cell.parentNode);
      var cell = getCellFromNode($cell);

      if (row == null || cell == null) {
        return null;
      } else {
        return {
          "row": row,
          "cell": cell
        };
      }
    }
    /**
     * use for cell range selector
     */
    Map getCellNodeBox(row, cell) {
      if (!cellExists(row, cell)) {
        return null;
      }
      int frozenRowOffset = getFrozenRowOffset(row);


      var y1 = getRowTop(row) -frozenRowOffset;
      var y2 = y1 + options['rowHeight']- 1;
      var x1 = 0;
      for (var i = 0; i < cell; i++) {
        x1 += columns[i].width;
        if (options['frozenColumn'] == i) {
            x1 = 0;
        }
      }
      var x2 = x1 + columns[cell].width;

      return {
        ['top']: y1,
        ['left']: x1,
       ['bottom']: y2,
       ['right']: x2
      };
    }




    int getCellFromNode(Element cellNode) {
      // read column number from .l<columnNumber> CSS class
      RegExp reg= new RegExp(r'l\d+');
      String cls=cellNode.classes.firstWhere((item)=> reg.hasMatch(item));
      if (cls ==null) {
        throw "getCellFromNode: cannot get cell - " + cellNode.className;
      }
      return int.parse(cls.substring(1));
    }

    int getRowFromNode(Element rowNode) {
      for (int row in rowsCache.keys) {
        if (rowsCache[row].rowNode[0] == rowNode) {
          return row;
        }
        if(options['frozenColumn']>=0){
          if (rowsCache[row].rowNode[1] == rowNode) {
            return row;
          }
        }
      //  if(this.has)
      }

      return null;
    }


    int getFrozenRowOffset(row) {
       int offset =
           ( hasFrozenRows )
               ? ( options['frozenBottom'] )
               ? ( row >= actualFrozenRow )
               ? ( h < viewportTopH )
               ? ( actualFrozenRow * options['rowHeight'] )
               : h
               : 0
               : ( row >= actualFrozenRow )
               ? frozenRowsHeight
               : 0
               : 0;

       return offset;
   }


    core.EditorLock getEditorLock() {
      return options['editorLock'];
    }


    bool canCellBeActive(int row, int cell) {
      if (!options['enableCellNavigation'] || row >= getDataLengthIncludingAddNew() ||
          row < 0 || cell >= columns.length || cell < 0) {
        return false;
      }
      return columns[cell].focusable;
    }

    bool canCellBeSelected(int row,int  cell) {
      if (row >= getDataLength() || row < 0 || cell >= columns.length || cell < 0) {
        return false;
      }
      return columns[cell].selectable;
    }
    gotoCell(int row,int  cell, bool forceEdit) {
      if (!initialized) {
          return;
      }
      if (!canCellBeActive(row, cell)) {
          return;
      }

      if (!getEditorLock().commitCurrentEdit()) {
          return;
      }

      scrollCellIntoView(row, cell, false);

      var newCell = getCellNode(row, cell);

      // if selecting the 'add new' row, start editing right away
      setActiveCellInternal(newCell, forceEdit || (row == getDataLength()) || options['autoEdit']);

      // if no editor was created, set the focus back on the grid
      if (currentEditor==null) {
          setFocus();
      }
    }
    /**
     * column Column object
     */
    Function getFormatter(int row, Column column) {
        return  column.formatter !=null ? column.formatter : options['defaultFormatter'];
    }


    scrollRowIntoView(int row, [doPaging]) {
      var rowAtTop = row * options['rowHeight'];
      var rowAtBottom = (row + 1) * options['rowHeight'] - viewportH + (viewportHasHScroll ? scrollbarDimensions['height'] : 0);

      // need to page down?
      if ((row + 1) * options['rowHeight'] > scrollTop + viewportH + offset) {
        scrollTo(doPaging !=null ? rowAtTop : rowAtBottom);
        render();
      }
      // or page up?
      else if (row * options['rowHeight'] < scrollTop + offset) {
        scrollTo(doPaging!=null ? rowAtBottom : rowAtTop);
        render();
      }
    }

     void scrollRowToTop(int row) {
      scrollTo(row * options['rowHeight']);
      render();
    }

     void scrollPage(dir) {
      int deltaRows = dir * numVisibleRows;
      scrollTo((getRowFromPosition(scrollTop) + deltaRows) * options['rowHeight']);
      render();

      if (options['enableCellNavigation']!=null && activeRow != null) {
        int row = activeRow + deltaRows;
        int dataLengthIncludingAddNew = getDataLengthIncludingAddNew();
        if (row >= dataLengthIncludingAddNew) {
          row = dataLengthIncludingAddNew - 1;
        }
        if (row < 0) {
          row = 0;
        }

        int cell = 0, prevCell = null;
        int prevActivePosX = activePosX;
        while (cell <= activePosX) {
          if (canCellBeActive(row, cell)) {
            prevCell = cell;
          }
          cell += getColspan(row, cell);
        }

        if (prevCell != null) {
          setActiveCellInternal(getCellNode(row, prevCell));
          activePosX = prevActivePosX;
        } else {
          resetActiveCell();
        }
      }
    }

    void navigatePageDown() {
      scrollPage(1);
    }

    void  navigatePageUp() {
      scrollPage(-1);
    }
    Element getCellNode(int row,int  cell) {
      if (rowsCache[row]!=null) {
        ensureCellNodesInRowsCache(row);
        return rowsCache[row].cellNodesByColumnIdx[cell];
      }
      return null;
    }

    void setActiveCell(int row, int cell) {
      if (!initialized) { return; }
      if (row > getDataLength() || row < 0 || cell >= columns.length || cell < 0) {
        return;
      }

      if (options['enableCellNavigation']!=null) {
        return;
      }

      scrollCellIntoView(row, cell, false);
      setActiveCellInternal(getCellNode(row, cell), false);
    }
    void scrollCellIntoView(int row,int cell,bool doPaging) {
      if (cell <= options['frozenColumn']) {
          return;
      }

      if (row < actualFrozenRow) {
          scrollRowIntoView(row, doPaging);
      }

      var colspan = getColspan(row, cell);
      int left = columnPosLeft[cell],
        right = columnPosRight[cell + (colspan > 1 ? colspan - 1 : 0)],
        scrollRight = scrollLeft + viewportW;

      if (left < scrollLeft) {
        $viewportScrollContainerX.scrollLeft =left;
        handleScroll();
        render();
      } else if (right > scrollRight) {
        $viewportScrollContainerX.scrollLeft=math.min(left, right - $viewportScrollContainerX.clientWidth);
        handleScroll();
        render();
      }
    }
    setActiveCellInternal(Element newCell,[bool opt_editMode]) {
      if (activeCellNode != null) {
        makeActiveCellNormal();
        activeCellNode.classes.remove("active");
        if (rowsCache[activeRow]!=null) {
          rowsCache[activeRow].rowNode.forEach((_)=> _.classes.remove("active"));
        }
      }

      bool activeCellChanged = (activeCellNode != newCell);
      activeCellNode = newCell;

      if (activeCellNode != null) {
        activeRow = getRowFromNode(activeCellNode.parentNode);
        activeCell = activePosX = getCellFromNode(activeCellNode);
        //TODO unclear
        if (opt_editMode == null) {
          opt_editMode = (activeRow == getDataLength()) || options['autoEdit']==true;
        }

        activeCellNode.classes.add("active");
        rowsCache[activeRow].rowNode.forEach((_)=> _.classes.add("active"));

        if (options['editable']==true && opt_editMode && isCellPotentiallyEditable(activeRow, activeCell)) {
          if(h_editorLoader!=null){
            h_editorLoader.cancel();
            h_editorLoader=null;
          }
//          clearTimeout(h_editorLoader);

          if (options['asyncEditorLoading']) {
            h_editorLoader = new Timer(new Duration(milliseconds:options['asyncEditorLoadDelay']),makeActiveCellEditable());
//            h_editorLoader = setTimeout( () {
//              makeActiveCellEditable();
//            }, );
          } else {
            makeActiveCellEditable();
          }
        }
      } else {
        activeRow = activeCell = null;
      }

      if (activeCellChanged) {
        trigger(onActiveCellChanged, getActiveCell());
      }
    }
    int getColspan(row, cell) {
      return 1;
//      var metadata = data.getItemMetadata && data.getItemMetadata(row);
//      if (!metadata || !metadata.columns) {
//        return 1;
//      }
//
//      var columnData = metadata.columns[columns[cell].id] || metadata.columns[cell];
//      var colspan = (columnData && columnData.colspan);
//      if (colspan === "*") {
//        colspan = columns.length - cell;
//      } else {
//        colspan = colspan || 1;
//      }
//
//      return colspan;
    }
    Map<String, int >getActiveCell() {
      if (activeCellNode==null) {
        return null;
      } else {
        return {'row': activeRow, 'cell': activeCell};
      }
    }
    void makeActiveCellNormal() {
      if (currentEditor==null) {
        return;
      }
      trigger(onBeforeCellEditorDestroy, {'editor': currentEditor});
      currentEditor.destroy();
      currentEditor = null;

      if (activeCellNode!=null) {
        var d = getDataItem(activeRow);
        activeCellNode.classes.removeAll(['editable','invalid']);
        if (d!=null) {
          var column = columns[activeCell];
          var formatter = getFormatter(activeRow, column);
          activeCellNode.setInnerHtml( formatter(activeRow, activeCell, getDataItemValueForColumn(d, column), column, d),
              treeSanitizer: _treeSanitizer);
          invalidatePostProcessingResults(activeRow);
        }
      }
      // if there previously was text selected on a page (such as selected text in the edit cell just removed),
      // IE can't set focus to anything else correctly
      if (window.navigator.userAgent.toLowerCase().contains('msie')) {
        clearTextSelection();
      }

      getEditorLock().deactivate(editController);
    }

    dynamic getDataItemValueForColumn(item, Column columnDef) {
      if (options['dataItemColumnValueExtractor']!=null) {
        return options['dataItemColumnValueExtractor'](item, columnDef);
      }
      return item[columnDef.field];
    }

    void invalidatePostProcessingResults(int row) {
      postProcessedRows.remove(row);
      postProcessFromRow = math.min(postProcessFromRow, row);
      postProcessToRow = math.max(postProcessToRow, row);
      startPostProcessing();
    }

    void startPostProcessing() {
      if (options['enableAsyncPostRender']==false) {
        return;
      }
      if (h_postrender!=null) h_postrender.cancel();
//      clearTimeout(h_postrender);
      h_postrender = new Timer( new Duration (milliseconds:options['asyncPostRenderDelay'] ),asyncPostProcessRows);
      print (h_postrender.isActive);
    }

    asyncPostProcessRows() {
      int dataLength = getDataLength();
      while (postProcessFromRow <= postProcessToRow) {
        int row = (vScrollDir >= 0) ? postProcessFromRow++ : postProcessToRow--;
        RowCache cacheEntry = rowsCache[row];
        if (cacheEntry==null || row >= dataLength) {
          continue;
        }

        if (postProcessedRows[row]==null) {
          postProcessedRows[row] = {};
        }

        ensureCellNodesInRowsCache(row);
        for (var columnIdx in cacheEntry.cellNodesByColumnIdx) {
//          if (!cacheEntry.cellNodesByColumnIdx.hasOwnProperty(columnIdx)) {
//            continue;
//          }

//          columnIdx = columnIdx | 0;

          Column m = columns[columnIdx];
          if (m.asyncPostRender!=null && !postProcessedRows[row][columnIdx]) {
            var node = cacheEntry.cellNodesByColumnIdx[columnIdx];
            if (node) {
              m.asyncPostRender(node, row, getDataItem(row), m);
            }
            postProcessedRows[row][columnIdx] = true;
          }
        }

        h_postrender = new Timer( options['asyncPostRenderDelay'],asyncPostProcessRows);
        return;
      }
    }

    renderRows(Map range) {
      //Element parentNode = $canvas;

      List stringArrayL = [],stringArrayR = [],   rows = [];
      bool needToReselectCell = false;
      int    dataLength = getDataLength();


      //find uncached rows and add to buffer
      for (int i = range['top'], ii = range['bottom']; i <= ii; i++) {
        if (rowsCache.keys.contains(i) || (hasFrozenRows && options['frozenBottom'] && i==data.length)) {
                  continue;
        }
        renderedRows++;
        rows.add(i);

        // Create an entry right away so that appendRowHtml() can
        // start populatating it.
        rowsCache[i] = new RowCache(null,this.columns.length);

        appendRowHtml(stringArrayL,stringArrayR, i, range, dataLength);
        if (activeCellNode !=null && activeRow == i) {
          needToReselectCell = true;
        }
        counter_rows_rendered++;
    }
    if (rows.length==0) { return; }
    //generate tags for new rows
    Element x = new Element.div();
    x.setInnerHtml(stringArrayL.join(""), treeSanitizer: _treeSanitizer )  ;
    Element xRight = new Element.div();
    xRight.setInnerHtml(stringArrayR.join(""), treeSanitizer: _treeSanitizer )  ;

    for (var i = 0, ii = rows.length; i < ii; i++) {
        if ( hasFrozenRows  &&  rows[i] >= actualFrozenRow ) {
            if (options['frozenColumn'] > -1) {
                rowsCache[rows[i]].rowNode = [x.firstChild,xRight.firstChild];
                $canvasBottomL.children.add(x.firstChild);
                $canvasBottomR.children.add(xRight.firstChild);
            } else {
                rowsCache[rows[i]].rowNode = [x.firstChild];
                $canvasBottomL.children.add(x.firstChild);
            }
        } else if (options['frozenColumn'] > -1) {
            rowsCache[rows[i]].rowNode = [x.firstChild,xRight.firstChild];
            $canvasTopL.children.add(x.firstChild);
            $canvasTopR.children.add(xRight.firstChild);
        } else {
            rowsCache[rows[i]].rowNode = [x.firstChild];
            $canvasTopL.children.add(x.firstChild);
        }
    }

    if (needToReselectCell) {
        activeCellNode = getCellNode(activeRow, activeCell);
    }

    }
    appendRowHtml(List<String> stringArrayL,List<String> stringArrayR, int row, Map<String,int> range,int dataLength) {
      var d = getDataItem(row);
      var dataLoading = row < dataLength && d==null;
      String rowCss = "slick-row" +
          (dataLoading ? " loading" : "") +
          (row == activeRow ? " active" : "") +
          (row % 2 == 1 ? " odd" : " even");

//      var metadata = data.getItemMetadata && data.getItemMetadata(row);
//
//      if (metadata && metadata.cssClasses) {
//        rowCss += " " + metadata.cssClasses;
//      }

      var frozenRowOffset = getFrozenRowOffset(row);
      String rowHtml = "<div class='ui-widget-content ${rowCss}' style='top: ${getRowTop(row) - frozenRowOffset}px'>";
      stringArrayL.add(rowHtml);
      if (options['frozenColumn'] > -1) {
          stringArrayR.add(rowHtml);
      }

      var colspan;
      Column m;
      for (var i = 0, ii = columns.length; i < ii; i++) {
        m = columns[i];
        colspan = 1;
        if (columnPosRight[math.min(ii - 1, i + colspan - 1)] > range['leftPx']) {
          if (columnPosLeft[i] > range['rightPx']) {
            // All columns to the right are outside the range.
            break;
          }
          if (( options['frozenColumn'] > -1 ) && ( i > options['frozenColumn'] )) {
              appendCellHtml(stringArrayR, row, i, colspan, d);
          } else {
              appendCellHtml(stringArrayL, row, i, colspan, d);
          }

        }else if (( options['frozenColumn'] > -1 ) && ( i <= options['frozenColumn'] )) {
          appendCellHtml(stringArrayL, row, i, colspan,d);
        }

        if (colspan > 1) {
          i += (colspan - 1);
        }
      }

      stringArrayL.add("</div>");
      if (options['frozenColumn'] > -1) {
        stringArrayR.add("</div>");
      }
    }
    /**
     * generate cell html tag
     * stringArray: output value
     * item : data item
     */
    appendCellHtml(List<String> stringArray,int row,int cell,int colspan, var item) {
      Column m = columns[cell];
      String cellCss = "slick-cell l$cell r" + math.min(columns.length - 1, cell + colspan - 1).toString() +
          (m.cssClass!=null ? " " + m.cssClass : "");
      if (row == activeRow && cell == activeCell) {
        cellCss += (" active");
      }

      // TODO:  merge them together in the setter
      for (var key in cellCssClasses.keys) {
        if (cellCssClasses[key].containsKey(row) && cellCssClasses[key][row].containsKey(m.id)) {
          cellCss += (" " + cellCssClasses[key][row][m.id]);
        }
      }

      stringArray.add("<div class='" + cellCss + "'>");

      // if there is a corresponding row (if not, this is the Add New row or this data hasn't been loaded yet)
      if (item!=null) {
        var value = getDataItemValueForColumn(item, m);
        stringArray.add(getFormatter(row, m)(row, cell, value, m, item));
      }

      stringArray.add("</div>");

      rowsCache[row].cellRenderQueue.addLast(cell);
//      rowsCache[row].cellColSpans.insert(cell,colspan);
      rowsCache[row].cellColSpans[cell]=colspan;
    }
    void clearTextSelection() {
      window.getSelection().removeAllRanges();
//      if (document.selection!=null && document.selection.empty) {
//        try {
//          //IE fails here if selected element is not in dom
//          document.selection.empty();
//        } catch (e) { }
//      } else if (window.getSelection) {
//        var sel = window.getSelection();
//        if (sel && sel.removeAllRanges) {
//          sel.removeAllRanges();
//        }
//      }
    }

    void setupColumnSort() {
      $headers.forEach((_)=> _.onClick.listen((MouseEvent e){
        // temporary workaround for a bug in jQuery 1.7.1 (http://bugs.jquery.com/ticket/11328)
        bool isMetaKey = e.metaKey || e.ctrlKey;

        if ((e.target as Element).classes.contains("slick-resizable-handle")) {
          return;
        }

        Element $col = findClosestAncestor(e.target, ".slick-header-column");
        if($col ==null ) return; //when click to columns element

        //Column column = new Column.fromMap(JSON.decode($col.dataset["column"]));
        Column column = this._headExt[$col];
        if (column.sortable) {
          if (!getEditorLock().commitCurrentEdit()) {
            return;
          }

          var sortOpts = null;
          var i = 0;
          for (; i < sortColumns.length; i++) {
            if (sortColumns[i]['columnId'] == column.id) {
              sortOpts = sortColumns[i];
              sortOpts['sortAsc'] = !sortOpts['sortAsc'];
              break;
            }
          }

          if (isMetaKey && options['multiColumnSort']) {
            if (sortOpts!=null) {
              sortColumns.removeAt(i);
            }
          }
          else {
            if ((!e.shiftKey && !e.metaKey) || options['multiColumnSort']!=true) {
              sortColumns = [];
            }

            if (sortOpts==null) {
              sortOpts = { 'columnId': column.id, 'sortAsc': column.defaultSortAsc };
              sortColumns.add(sortOpts);
            } else if (sortColumns.length == 0) {
              sortColumns.add(sortOpts);
            }
          }

          setSortColumns(sortColumns);

          if (options['multiColumnSort']==false) {
            trigger(onSort, {
              'multiColumnSort': false,
              'sortCol': column,
              'sortAsc': sortOpts['sortAsc']}, e);
          } else {
            trigger(onSort, {
              'multiColumnSort': true,
              'sortCols': new List.from(sortColumns.map(
                  (item) =>{'sortCol': columns[getColumnIndex(item['columnId'])],
                             'sortAsc': item['sortAsc']} ))}, e);
          }
        }
      }));
    }


    void updateRowCount() {
      if (!initialized) { return; }

      int dataLengthIncludingAddNew = getDataLengthIncludingAddNew();
      int numberOfRows = dataLengthIncludingAddNew +
          (options['leaveSpaceForNewRows'] ? numVisibleRows - 1 : 0);

      bool oldViewportHasVScroll = viewportHasVScroll;
      // with autoHeight, we do not need to accommodate the vertical scroll bar
      viewportHasVScroll = options['autoHeight'] == false && (numberOfRows * options['rowHeight'] > viewportH);

      // remove the rows that are now outside of the data range
      int l = dataLengthIncludingAddNew - 1;
      new List.from(rowsCache.keys.where((e)=> e >= l )).forEach((e) => removeRowFromCache(e));
//      for (var i in rowsCache.keys) {
//        if (i >= l) {
//          removeRowFromCache(i);
//        }
//      }

      if (activeCellNode!=null && activeRow > l) {
        resetActiveCell();
      }

      int oldH = h;
      th = math.max(options['rowHeight'] * numberOfRows, viewportH - scrollbarDimensions['height']);
      if (th < maxSupportedCssHeight) {
        // just one page
        h = ph = th;
        n = 1;
        cj = 0;
      } else {
        // break into pages
        h = maxSupportedCssHeight;
        ph = h ~/ 100;
        n = (th / ph).floor();
        cj = (th - h) / (n - 1);
      }

      if (h != oldH) {
        if (hasFrozenRows && !options['frozenBottom']) {
            $canvasBottomL.style.height= '${h}px';

            if (options['frozenColumn'] > -1) {
                $canvasBottomR.style.height = '${h}px';
            }
        } else {
            $canvasTopL.style.height ='${h}px';
            $canvasTopR.style.height = '${h}px';
        }

        scrollTop = $viewportScrollContainerY.scrollTop;

//        $canvas.style.height= h.toString()+ 'px';
//        scrollTop = $viewport.scrollTop;
      }

      bool oldScrollTopInRange = (scrollTop + offset <= th - viewportH);

      if (th == 0 || scrollTop == 0) {
        page = offset = 0;
      } else if (oldScrollTopInRange) {
        // maintain virtual position
        scrollTo(scrollTop + offset);
      } else {
        // scroll to bottom
        scrollTo(th - viewportH);
      }

      if (h != oldH && options['autoHeight']) {
        resizeCanvas();
      }

      if (options['forceFitColumns'] && oldViewportHasVScroll != viewportHasVScroll) {
        autosizeColumns();
      }
      updateCanvasWidth(false);
    }


    void resetActiveCell() {
      setActiveCellInternal(null, false);
    }

    void  handleHeaderRowScroll(Event e) {
      var scrollLeft = $headerRowScrollContainer.scrollLeft;
      if (scrollLeft != $viewportScrollContainerX.scrollLeft) {
          $viewportScrollContainerX.scrollLeft = scrollLeft;
      }


//      var scrollLeft = $headerRowScroller.scrollLeft;
//      if (scrollLeft != $viewport.scrollLeft) {
//        $viewport.scrollLeft = scrollLeft;
//      }
    }

    void handleScroll([Event e]) {
      scrollTop = $viewportScrollContainerY.scrollTop;
      scrollLeft = $viewportScrollContainerX.scrollLeft;
      _handleScroll(false);
    }
    _handleScroll(bool isMouseWheel) {
        var maxScrollDistanceY = $viewportScrollContainerY.scrollHeight - $viewportScrollContainerY.clientHeight;
        var maxScrollDistanceX = $viewportScrollContainerY.scrollWidth - $viewportScrollContainerY.clientWidth;

        // Ceiling the max scroll values
        if (scrollTop > maxScrollDistanceY) {
            scrollTop = maxScrollDistanceY;
        }
        if (scrollLeft > maxScrollDistanceX) {
            scrollLeft = maxScrollDistanceX;
        }

        int vScrollDist = (scrollTop - prevScrollTop).abs();
        int hScrollDist = (scrollLeft - prevScrollLeft).abs();

        if (hScrollDist>0) {
            prevScrollLeft = scrollLeft;

            $viewportScrollContainerX.scrollLeft = scrollLeft;
            $headerScrollContainer.scrollLeft = scrollLeft;
            $topPanelScroller..first.scrollLeft = scrollLeft..last.scrollLeft=scrollLeft;
            $headerRowScrollContainer.scrollLeft = scrollLeft;

            if (options['frozenColumn'] > -1) {
                if (hasFrozenRows) {
                    $viewportTopR.scrollLeft = scrollLeft;
                }
            } else {
                if (hasFrozenRows) {
                    $viewportTopL.scrollLeft = scrollLeft;
                }
            }
        }

        if (vScrollDist>0) {
            vScrollDir = prevScrollTop < scrollTop ? 1 : -1;
            prevScrollTop = scrollTop;

            if (isMouseWheel) {
                $viewportScrollContainerY.scrollTop = scrollTop;
            }

            if (options['frozenColumn'] > -1) {
                if (hasFrozenRows && !options['frozenBottom']) {
                    $viewportBottomL.scrollTop = scrollTop;
                } else {
                    $viewportTopL.scrollTop = scrollTop;
                }
            }

            // switch virtual pages if needed
            if (vScrollDist < viewportH) {
                scrollTo(scrollTop + offset);
            } else {
                var oldOffset = offset;
                if (h == viewportH) {
                    page = 0;
                } else {
                    page = math.min(n - 1, (scrollTop * ((th - viewportH) / (h - viewportH)) * (1 / ph)).floor());
                }
                offset = (page * cj).round();
                if (oldOffset != offset) {
                    invalidateAllRows();
                }
            }
        }

        if (hScrollDist>0 || vScrollDist >0) {
            if (h_render!=null) {
                h_render.cancel();
            }
            //how many distance is enought to scroll?
            if ((lastRenderedScrollTop - scrollTop).abs() > 120 ||
                (lastRenderedScrollLeft - scrollLeft).abs() > 120) {
                if (options['forceSyncScrolling'] || (
                    (lastRenderedScrollTop - scrollTop).abs() < viewportH &&
                        (lastRenderedScrollLeft - scrollLeft).abs() < viewportW)) {
                    render();
                } else {
                    h_render=new Timer.periodic(new Duration(milliseconds:50),render);
                   // h_render = setTimeout(render, 50);
                }

                trigger(onViewportChanged, {});
            }
        }

        trigger(onScroll, {'scrollLeft': scrollLeft, 'scrollTop': scrollTop});
    }




//    void __handleScroll([Event e]) {
//      scrollTop = $viewport.scrollTop;
//      scrollLeft = $viewport.scrollLeft;
//      int vScrollDist = (scrollTop - prevScrollTop).abs();
//      int hScrollDist = (scrollLeft - prevScrollLeft).abs();
//
//      if (hScrollDist>0) {
//        prevScrollLeft = scrollLeft;
//        $headerScroller.scrollLeft = scrollLeft;
//        $topPanelScroller.scrollLeft = scrollLeft;
//        $headerRowScroller.scrollLeft = scrollLeft;
//      }
//
//      if (vScrollDist>0) {
//        vScrollDir = prevScrollTop < scrollTop ? 1 : -1;
//        prevScrollTop = scrollTop;
//
//        // switch virtual pages if needed
//        if (vScrollDist < viewportH) {
//          scrollTo(scrollTop + offset);
//        } else {
//          var oldOffset = offset;
//          if (h == viewportH) {
//            page = 0;
//          } else {
//            page = math.min(n - 1, (scrollTop * ((th - viewportH) / (h - viewportH)) * (1 / ph)).floor());
//          }
//          offset = (page * cj).round();
//          if (oldOffset != offset) {
//            invalidateAllRows();
//          }
//        }
//      }
//
//      if (hScrollDist>0 || vScrollDist>0) {
//        if (h_render!=null) {
//          h_render.cancel();
//        }
//
//        if ((lastRenderedScrollTop - scrollTop).abs() > 20 ||
//            (lastRenderedScrollLeft - scrollLeft).abs() > 20) {
//          if (options['forceSyncScrolling']==true || (
//              (lastRenderedScrollTop - scrollTop).abs() < viewportH &&
//              (lastRenderedScrollLeft - scrollLeft).abs() < viewportW)) {
//            render();
//          } else {
//
//            h_render = new Timer.periodic(new Duration(milliseconds:50),render);
//          }
//
//          trigger(onViewportChanged, {});
//        }
//      }
//
//      trigger(onScroll, {'scrollLeft': scrollLeft, 'scrollTop': scrollTop});
//    }
    // todo shaodw fix
    void createCssRules() {
      $style =  container.createFragment("<style type='text/css' rel='stylesheet' />", treeSanitizer : _treeSanitizer).children.first;
      querySelector('head').append($style);
      int rowHeight = (options['rowHeight'] - cellHeightDiff);
      List rules = [
        "." + uid + " .slick-header-column { left: 1000px; }",
        "." + uid + " .slick-top-panel { height:" + options['topPanelHeight'].toString() + "px; }",
        "." + uid + " .slick-headerrow-columns { height:" + options['headerRowHeight'].toString() + "px; }",
        "." + uid + " .slick-cell { height:" + rowHeight.toString() + "px; }",
        "." + uid + " .slick-row { height:" + options['rowHeight'].toString() + "px; }"
      ];

      for (int i = 0; i < columns.length; i++) {
        rules.add("." + uid + " .l" + i.toString() + " { }");
        rules.add("." + uid + " .r" + i.toString() + " { }");
      }

//      if ($style.style!=null) { // IE
//        $style.style.cssText = rules.join(" ");
//      } else {
        $style.appendText(rules.join(' '));
//      }
    }


    void handleHeaderMouseEnter(MouseEvent e) {
      trigger(onHeaderMouseEnter, {
        //"column": (e.target as Element).dataset["column"]
        "column": _headExt[e.target as Element] //.dataset["column"]
      }, e);
    }

    void handleHeaderMouseLeave(e) {
      trigger(onHeaderMouseLeave, {
        //"column": (e.target as Element).dataset["column"]
        "column": _headExt[e.target as Element]
      }, e);
    }

     handleHeaderContextMenu(Event e) {
       Element $header = findClosestAncestor(e.target,'slick-header-column',".slick-header-columns");
       Column c;
       if( $header !=null) {
         //c = new Column.fromJSON($header.dataset["column"]);
         c= this._headExt[$header];
       }
       trigger(onHeaderContextMenu, {'column': c}, e);
     }

     void handleHeaderClick(Event e) {
       print('header clicked');
       Element header = findClosestAncestor(e.target,'.slick-header-column',".slick-header-columns");
       Column c;
       if( header !=null) {
         //c = new Column.fromJSON(header.dataset["column"]);
         c= this._headExt[header];
       }
       if (c!=null) { //TODO fix me
         trigger(onHeaderClick, {'column': c}, e);
       }
     }


     makeActiveCellEditable([editor.Editor ed]) {
       if (activeCellNode==null) {
         return;
       }
       if (options['editable']==false) {
         throw "Grid : makeActiveCellEditable : should never get called when options.editable is false";
       }

       // cancel pending async call if there is one
       if(h_editorLoader!=null)
          h_editorLoader.cancel();

       if (!isCellPotentiallyEditable(activeRow, activeCell)) {
         return;
       }

       Column columnDef = columns[activeCell];
       var item = getDataItem(activeRow);

       if (trigger(onBeforeEditCell, {'row': activeRow, 'cell': activeCell, 'item': item, 'column': columnDef}) == false) {
         setFocus();
         return;
       }

       getEditorLock().activate(editController);
       activeCellNode.classes.add("editable");

       // don't clear the cell if a custom editor is passed through
       if (ed==null) {
         activeCellNode.setInnerHtml('');
       }


       var editorParm =new editor.EditorParm({
         'grid': this,
         'gridPosition': absBox(container),
         'position': absBox(activeCellNode),
         'activeCellNode': activeCellNode,
         'columnDef': columnDef,
         'item': item == null ?{} : item,
         'commitChanges': commitEditAndSetFocus,
         'cancelChanges': cancelEditAndSetFocus
       });
       currentEditor= getEditorInstance(activeRow,activeCell,editorParm);
       //currentEditor = editor==null ?   getEditor(activeRow, activeCell) : editor;

       if (item!=null) {
         currentEditor.loadValue(item);
       }

       serializedEditorValue = currentEditor.serializeValue();

//TODO not implement
//       if (currentEditor.position) {
//         handleActiveCellPositionChange();
//       }
     }

     void commitEditAndSetFocus() {
       // if the commit fails, it would do so due to a validation error
       // if so, do not steal the focus from the editor
       if (getEditorLock().commitCurrentEdit()) {
         setFocus();
         if (options['autoEdit']) {
           navigateDown();
         }
       }
     }

     void cancelEditAndSetFocus() {
       if (getEditorLock().cancelCurrentEdit()) {
         setFocus();
       }
     }

     Map<String,dynamic> absBox(Element elem) {
       var box = {
                  'top': elem.offsetTop,
                  'left': elem.offsetLeft,
                  'bottom': 0,
                  'right': 0,
                  'width': elem.borderEdge.width,
                  'height': elem.borderEdge.height,
                  'visible': true};
       box['bottom'] = box['top'] + box['height'];
       box['right'] = box['left'] + box['width'];

       // walk up the tree
       var offsetParent = elem.offsetParent;
       while (!(elem.parent is ShadowRoot) && (elem = elem.parentNode) != document.body) {
         if (box['visible'] !=null && elem.scrollHeight != elem.offsetHeight && elem.style.overflowY != "visible") {
           box['visible'] = box['bottom'] > elem.scrollTop && box['top'] < elem.scrollTop + elem.clientHeight;
         }

         if (box['visible'] !=null && elem.scrollWidth != elem.offsetWidth && elem.style.overflowX != "visible") {
           box['visible'] = box['right'] > elem.scrollLeft && box['left'] < elem.scrollLeft + elem.clientWidth;
         }

         box['left'] -= elem.scrollLeft;
         box['top'] -= elem.scrollTop;

         if (elem == offsetParent) {
           box['left'] += elem.offsetLeft;
           box['top'] += elem.offsetTop;
           offsetParent = elem.offsetParent;
         }

         box['bottom'] = box['top'] + box['height'];
         box['right'] = box['left'] + box['width'];
       }

       return box;
     }

     Map<String,dynamic> getActiveCellPosition() {
       return absBox(activeCellNode);
     }

     Map<String,dynamic> getGridPosition() {
       return absBox(container);
     }

     void handleActiveCellPositionChange(Event e) {
       if (activeCellNode==null) {
         return;
       }

     trigger(onActiveCellPositionChanged, {});

       if (currentEditor!=null) {
         var cellBox = getActiveCellPosition();
//         if (currentEditor.show && currentEditor.hide ) {
           if (!cellBox['visible']) {
             currentEditor.hide();
           } else {
             currentEditor.show();
           }
//         }
//TODO not implement
//         if (currentEditor.position) {
//           currentEditor.position(cellBox);
//         }
       }
     }
     navigateRight() {
       return navigate("right");
     }

     navigateLeft() {
       return navigate("left");
     }

     navigateDown() {
       return navigate("down");
     }

     navigateUp() {
       return navigate("up");
     }

     navigateNext() {
       return navigate("next");
     }

     navigatePrev() {
       return navigate("prev");
     }

     navigate(String dir) {
       if (options['enableCellNavigation']==false) {
         return false;
       }

       if (activeCellNode ==null && dir != "prev" && dir != "next") {
         return false;
       }

       if (!getEditorLock().commitCurrentEdit()) {
         return true;
       }
       setFocus();

       Map tabbingDirections = {
                                "up": -1,
                                "down": 1,
                                "left": -1,
                                "right": 1,
                                "prev": -1,
                                "next": 1
       };
       tabbingDirection = tabbingDirections[dir];

       Map stepFunctions = {
                            "up": gotoUp,
                            "down": gotoDown,
                            "left": gotoLeft,
                            "right": gotoRight,
                            "prev": gotoPrev,
                            "next": gotoNext
       };
       var stepFn = stepFunctions[dir];
       var pos = stepFn(activeRow, activeCell, activePosX);
       if (pos!=null) {
         var isAddNewRow = (pos['row'] == getDataLength());
         scrollCellIntoView(pos['row'], pos['cell'], !isAddNewRow);
         setActiveCellInternal(getCellNode(pos['row'], pos['cell']));
         activePosX = pos['posX'];
         return true;
       } else {
         setActiveCellInternal(getCellNode(activeRow, activeCell));
         return false;
       }
     }

     Map gotoUp(int row,int cell,int  posX) {
       int prevCell;
       while (true) {
         if (--row < 0) {
           return null;
         }

         prevCell = cell = 0;
         while (cell <= posX) {
           prevCell = cell;
           cell += getColspan(row, cell);
         }

         if (canCellBeActive(row, prevCell)) {
           return {
             "row": row,
             "cell": prevCell,
             "posX": posX
           };
         }
       }
     }


     gotoNext(int row,int cell,int posX) {
       if (row == null && cell == null) {
         row = cell = posX = 0;
         if (canCellBeActive(row, cell)) {
           return {
             "row": row,
             "cell": cell,
             "posX": cell
           };
         }
       }

       Map pos = gotoRight(row, cell, posX);
       if (pos!=null) {
         return pos;
       }

       var firstFocusableCell = null;
       int dataLengthIncludingAddNew = getDataLengthIncludingAddNew();
       while (++row < dataLengthIncludingAddNew) {
         firstFocusableCell = findFirstFocusableCell(row);
         if (firstFocusableCell != null) {
           return {
             "row": row,
             "cell": firstFocusableCell,
             "posX": firstFocusableCell
           };
         }
       }
       return null;
     }
     Map gotoPrev(int row,int cell,int posX) {
       if (row == null && cell == null) {
         row = getDataLengthIncludingAddNew() - 1;
         cell = posX = columns.length - 1;
         if (canCellBeActive(row, cell)) {
           return {
             "row": row,
             "cell": cell,
             "posX": cell
           };
         }
       }

       Map pos;
       int lastSelectableCell;
       while (pos==null) {
         pos = gotoLeft(row, cell, posX);
         if (pos!=null) {
           break;
         }
         if (--row < 0) {
           return null;
         }

         cell = 0;
         lastSelectableCell = findLastFocusableCell(row);
         if (lastSelectableCell != null) {
           pos = {
                  "row": row,
                  "cell": lastSelectableCell,
                  "posX": lastSelectableCell
           };
         }
       }
       return pos;
     }
     Map gotoRight(int row, int cell,int  posX) {
       if (cell >= columns.length) {
         return null;
       }

       do {
         cell += getColspan(row, cell);
       }
       while (cell < columns.length && !canCellBeActive(row, cell));

       if (cell < columns.length) {
         return {
           "row": row,
           "cell": cell,
           "posX": cell
         };
       }else{
         //accept navigate to next row's first col
         if(row<this.data.length){
           return {
             "row": row+1,
             "cell": 0,
             "posX": 0
           };
         }
       }
       return null;
     }

      Map gotoLeft(int row,int  cell,int  posX) {
       if (cell <= 0) {
         if(row>=1 && cell==0){
           return {
                        "row": row-1,
                        "cell": this.columns.length-1,
                        "posX":  this.columns.length-1
            };
         }
         return null;
       }

       int firstFocusableCell = findFirstFocusableCell(row);
       if (firstFocusableCell == null || firstFocusableCell >= cell) {
         return null;
       }

       Map prev = {
                   "row": row,
                   "cell": firstFocusableCell,
                   "posX": firstFocusableCell
       };
       var pos;
       while (true) {
         pos = gotoRight(prev['row'], prev['cell'], prev['posX']);
         if (pos==null) {
           return null;
         }
         if (pos['cell'] >= cell) {
           return prev;
         }
         prev = pos;
       }
     }

      Map gotoDown(int row,int  cell,int posX) {
        int prevCell;
       int dataLengthIncludingAddNew = getDataLengthIncludingAddNew();
       while (true) {
         if (++row >= dataLengthIncludingAddNew) {
           return null;
         }

          prevCell = cell = 0;
         while (cell <= posX) {
           prevCell = cell;
           cell += getColspan(row, cell);
         }

         if (canCellBeActive(row, prevCell)) {
           return {
             "row": row,
             "cell": prevCell,
             "posX": posX
           };
         }
       }
     }

      int findFirstFocusableCell(int row) {
        int cell = 0;
        while (cell < columns.length) {
          if (canCellBeActive(row, cell)) {
            return cell;
          }
          cell += getColspan(row, cell);
        }
        return null;
      }

      int findLastFocusableCell(int row) {
        var cell = 0;
        var lastFocusableCell = null;
        while (cell < columns.length) {
          if (canCellBeActive(row, cell)) {
            lastFocusableCell = cell;
          }
          cell += getColspan(row, cell);
        }
        return lastFocusableCell;
      }


      String getEditor(row, cell) {
        Column column = columns[cell];
        if(column['editor']!=null) return column['editor'] ;
        if(options['editorFactory']!=null){
          return options['editorFactory'].getEditor(column);
        }
        return null;
      }

      editor.Editor getEditorInstance(row, cell, editor.EditorParm editorParm) {
        Column column = columns[cell]; //column['editor']
        String editorStr=column['editor'];
        switch(editorStr){
          case 'TextEditor':
            return new editor.TextEditor(editorParm);
          case 'CheckboxEditor':
            return new editor.CheckboxEditor(editorParm);

          default:
            return null;
        }


//
//        LibraryMirror lib = currentMirrorSystem().
//            findLibrary(const Symbol('slick.editor'));
//        ClassMirror c = lib.declarations[new Symbol(editor)];
//        var o = c.newInstance(const Symbol(''),[editorParm]).reflectee;
//        return o;
      }


      isCellPotentiallyEditable(int row,int  cell) {
        int dataLength = getDataLength();
        // is the data for this row loaded?
        if (row < dataLength && getDataItem(row)==null) {
          return false;
        }

        // are we in the Add New row?  can we create new from this cell?
        if (columns[cell].cannotTriggerInsert && row >= dataLength) {
          return false;
        }

        // does this cell have an editor?
        if (getEditor(row, cell)==null) {
          return false;
        }

        return true;
      }


      void handleMouseEnter(e) {
        trigger(onMouseEnter, {}, e);
      }

      void handleMouseLeave(e) {
        trigger(onMouseLeave, {}, e);
      }
      bool cellExists(int row,int  cell) {
        return !(row < 0 || row >= getDataLength() || cell < 0 || cell >= columns.length);
      }

      Map getCellFromPoint(int x, int y) {
        int row = getRowFromPosition(y);
        int cell = 0;

        int w = 0;
        for (int i = 0; i < columns.length && w < x; i++) {
          w += columns[i].width;
          cell++;
        }

        if (cell < 0) {
          cell = 0;
        }

        return {'row': row, 'cell': cell - 1};
      }

      handleDragStart(Event e) {
        core.EventData cevt=new core.EventData.fromDom(e);
        Map<String,int> cell = getCellFromEvent(cevt);
        if (cell!=null || !cellExists(cell['row'], cell['cell'])) {
          return false;
        }
        //TOOD fix me
        //dd drag call back from jquery.dnd
//        var retval = trigger(onDragStart, dd, e);
//        if (e.isImmediatePropagationStopped()) {
//          return retval;
//        }

        return false;
      }
// dd drag call back
//$special.drag.callback
//available: Array[0]
//deltaX: 0
//deltaY: 0
//drag: div.grid-canvas
//drop: Array[0]
//grid: SlickGrid
//offsetX: 9
//offsetY: -179
//originalX: 9
//originalY: -179
//proxy: div.grid-canvas
//startX: 87
//startY: 51
//target: div.grid-canvas


       handleDrag(e, [dd]) {
        return trigger(this.onDrag, dd, e);
      }

      handleDragEnd(e, [dd]) {
        trigger(onDragEnd, dd, e);
      }

      /**
       * e : keyboard event or EventData
       */
      void handleKeyDown(var e, [args]) {
        trigger(onKeyDown, {'row': activeRow, 'cell': activeCell}, e);

        bool handled = e is core.EventData ? e.isImmediatePropagationStopped() : false;

        if (!handled) {
          if (!e.shiftKey && !e.altKey && !e.ctrlKey) {
            if (e.which == 27) {
              if (!getEditorLock().isActive()) {
                return; // no editing mode to cancel, allow bubbling and default processing (exit without cancelling the event)
              }
              cancelEditAndSetFocus();
            } else if (e.which == 34) {
              navigatePageDown();
              handled = true;
            } else if (e.which == 33) {
              navigatePageUp();
              handled = true;
            } else if (e.which == 37) {
              handled = navigateLeft();
            } else if (e.which == 39) {
              handled = navigateRight();
            } else if (e.which == 38) {
              handled = navigateUp();
            } else if (e.which == 40) {
              handled = navigateDown();
            } else if (e.which == 9) {
              handled = navigateNext();
            } else if (e.which == 13) {
              if (options['editable']) {
                if (currentEditor!=null) {
                  // adding new row
                  if (activeRow == getDataLength()) {
                    navigateDown();
                  } else {
                    commitEditAndSetFocus();
                  }
                } else {
                  if (getEditorLock().commitCurrentEdit()) {
                    makeActiveCellEditable();
                  }
                }
              }
              handled = true;
            }
          } else if (e.which == 9 && e.shiftKey && !e.ctrlKey && !e.altKey) {
            handled = navigatePrev();
          }
        }

        if (handled) {
          // the event has been handled so don't let parent element (bubbling/propagation) or browser (default) handle it
          e.stopPropagation();
          e.preventDefault();
          try {

//            e.originalEvent.keyCode = 0; // prevent default behaviour for special keys in IE browsers (F3, F5, etc.)
          }
          // ignore exceptions - setting the original event's keycode throws access denied exception for "Ctrl"
          // (hitting control key only, nothing else), "Shift" (maybe others)
          catch (error) {
          }
        }
      }

      void removeCssRules() {
        $style.remove();
        stylesheet = null;
      }


}




