library slick.grid;
import 'dart:html';
import 'dart:math' as math;
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'slick_core.dart' as core;
import 'slick_editor.dart' as editor;
import 'slick_selectionmodel.dart';
//import 'slick_formatters.dart';
import 'slick_util.dart';
import 'slick_dnd.dart';
import 'slick_column.dart';
import 'row_height.dart' as heightIdx;
final Logger _log = new Logger('cj.grid');
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
var _treeSanitizer = new _NullTreeSanitizer();
/**
 * Sanitizer which does nothing.
 */
class _NullTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(Node node) {
  }
}
class _RowCache{
  int columnCount;
  _RowCache (this.rowNode,columnCount){
    cellColSpans=new List.filled(columnCount,1);
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
/**
 * Grid that inheritance from SlickGrid
 */
class SlickGrid {
  final _style_id='init-style';
  //attach column to header element
  Expando<Column> _headExt= new Expando<Column>();
  //root container of grid
  Element container;
  //each item will render as row
  List _data;
  /**
   * setter to data, if apply new, all exist selected row are removed
   */
  set data(_) {
    if(selectionModel!=null){
      this.setSelectedRows([]);
    }
    _data=_;
  }
  List get data => _data;
  List<Column> columns;     // columns that are visible
  List<Column> allColumns;  //all columns
  Map get options => _options.toJson();
  GridOptions _options=new GridOptions();

  //Warning!!!, for compare value, not for change value
  //update options => [setOptions]
  GridOptions get gridOptions => _options;

 // StreamSubscription<Event> _ancestorScrollSubscribe;
  List _subscriptionList=[];

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

  /**
   * constructure
   * @param container target html node
   * @param data List of object
   * @param columns column definition
   */
  SlickGrid(this.container, this._data, this.allColumns, [Map options]){
    this.columns = new List<Column>.from(this.allColumns.where((c) => c.visible));
    this._options.addAll(options);
    _storeFormatter();
  }
  /**
   * construct from GridOption class
   */
  SlickGrid.fromOpt(this.container, this._data, this.allColumns, [GridOptions options]){
      this.columns = new List<Column>.from(this.allColumns.where((c) => c.visible));
      this._options=options;
      _storeFormatter();
  }
  /**
   * append formatter to option's internal formatter factory
   * replace formatter instance to grid's in
   */
  _storeFormatter(){
    allColumns.where((_)=> _.formatter!=null).forEach((_){
      _options.formatterFactory[_.id] = _.formatter;
      _.formatter = _.id;
    });
  }
 // Map<String,dynamic> defaults ;
  Column _columnDefaults= new Column();

  heightIdx.Node _yLookup=null;
// scroller
  int _th;   // virtual height
  int _h;    // real scrollable height
  int _ph;   // page height
  int _n;    // number of pages
  var _cj;   // "jumpiness" coefficient

  int page = 0;       // current page
  int offset = 0;     // current page offset
  var vScrollDir = 1;

  // private
  bool initialized = false;
  var _uid = "slickgrid_" + new math.Random().nextInt(10000000).toString();

  DivElement _$focusSink, _$focusSink2;
  List $headerScroller = [];
  List<Element> $headers = [];
  List<Element> $headerRow = [];
  DivElement  $headerRowSpacerL, $headerRowSpacerR;
  List $headerRowScroller = [];
  List<Element> $topPanelScroller= [];
  List $topPanel=[];
  List<Element> $viewport = [];
  DivElement $viewportL;
  List<Element> $canvas =[];  //all columns
  DivElement $canvasL; //left frozen columns
  StyleElement $style;
  List<Element> $boundAncestors;
  CssStyleSheet stylesheet;
  List<CssStyleRule> columnCssRulesL, columnCssRulesR;
  int viewportH=0, viewportW =0;
  int viewportWL;
  int canvasWidth , canvasWidthL, canvasWidthR;
  int  headersWidth,headersWidthL, headersWidthR;
  bool viewportHasHScroll=false, viewportHasVScroll=false;
  int _headerColumnWidthDiff = 0, _headerColumnHeightDiff = 0, // border+padding
      _cellWidthDiff = 0, _cellHeightDiff = 0;
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
  var _serializedEditorValue;
  Map editController;

  Map<int,_RowCache> _rowsCache = {};
  int renderedRows = 0;
  /** for fixed row hight that get visible row,  */
  int numVisibleRows;
  int prevScrollTop = 0;
  int scrollTop = 0;
  int lastRenderedScrollTop = 0;
  int lastRenderedScrollLeft = 0;
  int prevScrollLeft = 0;
  int scrollLeft = 0;

  SelectionModel selectionModel;
  //selected row index
  List<int> selectedRows = [];

  List<IPlugin> plugins = [];
  /**
   * customize all cell style when need
   * css_key =>
   * { row id :
   *    { string_column_Id: string_css_class_name  }
   * }
   *
   *
   */
  Map<String,Map<int,Map<String,String>>> _cellCssClasses = {};
  /**
   * Column ID to column object
   * if id no specify, using field instead
   */
  Map columnsById = {};
  List sortColumns = [];
  //cache column left,right pos to determine which cell to render
  List<int> _columnPosLeft = [];
  List<int> _columnPosRight = [];


  // async call handles
  Timer h_editorLoader = null;
  Timer h_render = null;
  Timer h_postrender = null;
  Map<int,dynamic> postProcessedRows = {};
  int postProcessToRow = null;
  int postProcessFromRow = null;

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

 // canvas,
 // very long and wide area that hold real row elements
 Element $canvasTopL;
 Element $canvasTopR;
 Element $canvasBottomL;
 Element $canvasBottomR;

 Element $viewportScrollContainerX;
 Element $viewportScrollContainerY;
 Element $headerScrollContainer;
 Element $headerRowScrollContainer;

 //  {}
 //   1~N => block
 //   N+1 ~ 2N => block
 //  2N+1 ~ 3N => block
 // sort => re calculat every row
 // insert => increase height of block and shift of each block
 //


  /////////////////////////////one line accesser
  int getDataLength()=> _data.length;
  int getColumnIndex(String id) =>columnsById[id];
  List getSortColumns() => sortColumns;
  List<Column> getColumns() => columns;
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
            hash[j][columns[k].id] = _options.selectedCellCssClass;
          }
        }
      }
    }

    setCellCssStyles(_options.selectedCellCssClass, hash);

    trigger(onSelectedRowsChanged, {'rows': getSelectedRows()}, e);
  }

  /**
   * render by cell style on demand
   * @param key: a unique id
   * @param hash
   * {
   *   row_id: { columnFieldName : css_class_name },
   *   12: {... },
   *   13: {... }
   * }
   *
   *
   */
  setCellCssStyles(String key, Map<int,Map<String,String>> hash) {
    Map prevHash = _cellCssClasses[key];

    _cellCssClasses[key] = hash;
    _updateCellCssStylesOnRenderedRows(hash, prevHash);

    trigger(onCellCssStylesChanged, { "key": key, "hash": hash });
  }
  _updateCellCssStylesOnRenderedRows(Map<int,Map<String,String>> addedHash,Map<int,Map<String,String>> removedHash) {
    Element node;
    String columnId;
    Map<String,String> addedRowHash, removedRowHash;
    for (int row in _rowsCache.keys) {
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
      if(container.parent==null){ //shadowRoot   && (container.parentNode as ShadowRoot).firstChild is StyleElement
        stylesheet=((container.parentNode as ShadowRoot).querySelector('style#$_style_id') as StyleElement).sheet;
      }else{
        List<CssStyleSheet> sheets = [];
        document.styleSheets.forEach((s) => sheets.add(s as CssStyleSheet));
        for (int i = 0; i < sheets.length; i++) {
          if (sheets[i].ownerNode !=null && sheets[i].ownerNode == $style) {   //|| sheets[i].owningElement for IE8
            stylesheet = sheets[i];
            break;
          }
        }
      }


      //    stylesheet=$style;

      if (stylesheet==null) {
        throw new ArgumentError("Cannot find stylesheet.");
      }

      // find and cache column CSS rules
      columnCssRulesL = [];
      columnCssRulesR = [];
      List<CssRule> cssRules = stylesheet.cssRules;

      //var matches, columnIdx;
      RegExp reg=new RegExp(r"\.l(\d+)");
      RegExp regR=new RegExp(r'\.r(\d+)');
      for (int i = 0; i < cssRules.length; i++) {
        String selector = cssRules[i] is CssStyleRule ? (cssRules[i] as CssStyleRule).selectorText : "";
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
        if (hWidth != columns[i].width - _headerColumnWidthDiff) {
          h.style.width= (columns[i].width - _headerColumnWidthDiff).toString() + 'px';
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
          "${ (((_options.frozenColumn!= -1 && i > _options.frozenColumn) ? canvasWidthR : canvasWidthL) - x - w) }px";
      //
      //rule['right'].style.right = (canvasWidth - x - w).toString() + "px";
      if (_options.frozenColumn== i) {
        x = 0;
      } else {
        x += columns[i].width;
      }
    }
  }
  /**
   * @input top,left of view
   * @return top row id ~ buttom row id, left to right pixel for current view
   */
  Map<String,int> getVisibleRange([int viewportTop, int viewportLeft]) {
    viewportTop ??= scrollTop;
    viewportLeft ??= scrollLeft;

    return {
      'top': getRowFromPosition(viewportTop),
      'bottom': getRowFromPosition(viewportTop + viewportH) + 1,
      'leftPx': viewportLeft,
      'rightPx': viewportLeft + viewportW
    };
  }
    /**
     * calculate render areas
     * when dyn height, if we keep min height of row = option[rowHeight], the only waste is over renedered block
     * @return num of rows from top to bottom , pixels from left to right
     */
   Map<String,int> getRenderedRange([int viewportTop, int viewportLeft]) {
    Map<String,int> vrange = getVisibleRange(viewportTop, viewportLeft);
    Map<String,int> outRange = {}..addAll(vrange);
    _log.finest('vis range:${vrange}');
    int buffer= (vrange['bottom'] - vrange['top']) *2;
    outRange['top'] -= buffer;
    outRange['bottom'] += buffer;
    if(outRange['top'] <0) outRange['top'] = 0;
    int maxRow=getDataLengthIncludingAddNew() - 1;
    if(outRange['bottom'] > maxRow) outRange['bottom'] = maxRow;
//    int buffer = (viewportH / _options.rowHeight).round();
//    int minBuffer = 100;
//
//    if (vScrollDir == -1) {
//      outRange['top'] -= buffer;
//      outRange['bottom'] += minBuffer;
//    } else if (vScrollDir == 1) {
//      outRange['top']  -= minBuffer;
//      outRange['bottom'] += buffer*3;
//    } else {
//      outRange['top']  -= minBuffer;
//      outRange['bottom'] += minBuffer;
//    }
//
//    outRange['top'] = math.max(0, outRange['top']);
//    outRange['bottom'] = math.min(getDataLengthIncludingAddNew() - 1, outRange['bottom']);

    outRange['leftPx'] -= viewportW*2;
    outRange['rightPx'] += viewportW*2;

    outRange['leftPx'] = math.max(0, outRange['leftPx']);
    outRange['rightPx'] = math.min(canvasWidth, outRange['rightPx']);
    _log.finest('adjust range:${outRange}');
    return outRange;
  }


  /**
   * drow canvas using current scroll position
   */
  void render([Timer timer]) {
    if (!initialized) { return; }
    Map<String,int> visible = getVisibleRange();
    Map<String,int> rendered = getRenderedRange();

    // remove rows no longer in the viewport
    cleanupRows(rendered);

    // add new rows & missing cells in existing rows
    if (lastRenderedScrollLeft != scrollLeft) {
      _cleanUpAndRenderCells(rendered);
    }

    // render missing rows
    renderRows(rendered);
    //render missing frozenCol
    if(this.hasFrozenRows){
      rendered['top']=0;
      rendered['bottom']=_options.frozenRow;
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
  /**
   * for forceFitColumns
   */
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
      widths.add(c.width);
      total += c.width;
      if (c.resizable) {
        shrinkLeeway += c.width - math.max(c.minWidth, absoluteColumnMinWidth);
      }
    }

    // shrink
    prevTotal = total;
    while (total > availWidth && shrinkLeeway>0) {
      double shrinkProportion = (total - availWidth) / shrinkLeeway;
      for (i = 0; i < columns.length && total > availWidth; i++) {
        c = columns[i];
        int width = widths[i];
        if (!c.resizable || width <= c.minWidth || width <= absoluteColumnMinWidth) {
          continue;
        }
        var absMinWidth = math.max(c.minWidth, absoluteColumnMinWidth);
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
        if (!c.resizable || c.maxWidth <= c.width) {
          continue;
        }
        int cWidth= (c.maxWidth - c.width) == 0 ?   1000000 : ( c.maxWidth - c.width);
        int growSize = math.min((growProportion * c.width).floor() - c.width, cWidth);
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
      if (columns[i].rerenderOnResize && columns[i].width != widths[i]) {
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
  /**
   * When window scroll bar added to document and grid div container is percentage,
   * we need to redraw canvas to reflect change of viewport size
   */
  void resizeCanvas([Event e]) {
    if (!initialized) { return; }
    paneTopH = 0;
    paneBottomH = 0;
    viewportTopH = 0;
    viewportBottomH = 0;
    getViewportWidth();
    _getViewportHeight();
// Account for Frozen Rows
     if (hasFrozenRows) {
         if (_options.frozenBottom) {
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

     if (_options.frozenColumn> -1 && _options.autoHeight) {
         paneTopH += scrollbarDimensions['height'];
     }

     // The top viewport does not contain the top panel or header row
     viewportTopH = paneTopH - topPanelH - headerRowH;

     if (_options.autoHeight==true) {
         if (_options.frozenColumn> -1) {
             container.style.height = '${paneTopH + int.parse($headerScrollerL.style.height.replaceFirst("px", ""), onError: (_)=>0)}px';
         }
         $paneTopL.style.position= 'relative';
     }
     $paneTopL.style.top= '${$paneHeaderL.contentEdge.height}px';
     $paneTopL.style.height= '${paneTopH}px';
     //fix me, replase offsetTo to other
    // int paneBottomTop = ($paneTopL.offsetTo($paneTopL.parent).y + paneTopH).round();
     int paneBottomTop = ($paneTopL.offset.top + paneTopH).round();
     $viewportTopL.style.height ='${viewportTopH}px';

     if (_options.frozenColumn> -1) {
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

         if (_options.frozenBottom) {
             $canvasBottomL.style.height = '${frozenRowsHeight}px';

             if (_options.frozenColumn> -1) {
                 $canvasBottomR.style.height = '${frozenRowsHeight}px';
             }
         } else {
             $canvasTopL.style.height =  '${frozenRowsHeight}px';

             if (_options.frozenColumn> -1) {
                 $canvasTopR.style.height ='${frozenRowsHeight}px'; //(frozenRowsHeight);
             }
         }
     } else {
       if (_options.frozenColumn> -1) {//no frozen row, but frozen column
                        $viewportTopR.style.height = '${viewportTopH}px'; //(viewportTopH);
       }
     }

     if (_options.forceFitColumns==true) {
         autosizeColumns();
     }

    /* this looks like duplicate code from line #761.
     * It is very hard to tell if this is outside of the last closing }

    if (_options.forceFitColumns==true ) {
      autosizeColumns();
    }
    * */

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
  Element _createElem(Element parentNode,{String templateStr, String clz:'', int tabIndex:0,Map style,bool hideFocus:false}){
    DivElement div=new DivElement();
    if(style!=null)
      style.forEach((key,value)=> div.style.setProperty(key, value));
    if(clz.trim().length>0)
      div.classes.addAll(clz.split(' '));
    if(tabIndex>0) div.tabIndex=tabIndex;
    if(hideFocus) div.attributes['hideFocus']='true';
    if(parentNode!=null){
      parentNode.append(div);
    }
    return div;
  }
  /**
   * main entry point to init the element to grid
   * 2 step initialize
   * 1. construct elements
   * 2. link element to event listeners
   */
  void init() {

    // calculate these only once and share between grid instances
    if(maxSupportedCssHeight == null) maxSupportedCssHeight = getMaxSupportedCssHeight();
    if(scrollbarDimensions ==null)scrollbarDimensions = measureScrollbar();
//    defaults.forEach( (k,v) =>
//        options.putIfAbsent(k, ()=> v)
//    );
    validateAndEnforceOptions();
    _columnDefaults.width = _options.defaultColumnWidth;
    updateColumnIndex();
//    columnsById = {};
//
//    for (int i = 0; i < columns.length; i++) {
//      Column m = columns[i];// = tmp;
//      columnsById[m.id] = i;
//      if (m['minWidth']!=null && m['width'] < m['minWidth']) {
//        m.width = m.minWidth;
//      }
//      if (m['maxWidth']!=null && m['width'] > m['maxWidth']) {
//        m.width = m.maxWidth;
//      }
//    }

    editController = {
                      "commitCurrentEdit": commitCurrentEdit,
                      "cancelCurrentEdit": cancelCurrentEdit
    };

    container..children.clear()
      ..style.outline = '0'
      ..style.overflow = 'hidden'
      ..classes.add(_uid)
      ..classes.add("ui-widget");

    if (! new RegExp(r'relative|absolute|fixed').hasMatch(container.style.position )){
      container.style.position= "relative";
    }
    _$focusSink = new DivElement();
    _$focusSink.attributes['hideFocus']='true';
    _$focusSink.style..position='fixed'
        ..width='0'
        ..height='0'
        ..top='0'
        ..left='0'
        ..outline='0';
    container.append(_$focusSink);

    $paneHeaderL = _createElem(container,clz:'slick-pane slick-pane-header slick-pane-left', tabIndex:0);
    $paneHeaderR = _createElem(container,clz:'slick-pane slick-pane-header slick-pane-right', tabIndex:0);
    $paneTopL = _createElem(container,clz:'slick-pane slick-pane-top slick-pane-left', tabIndex:0);
    $paneTopR = _createElem(container,clz:'slick-pane slick-pane-top slick-pane-right',tabIndex:0);
    $paneBottomL = _createElem(container,clz:'slick-pane slick-pane-bottom slick-pane-left',tabIndex:0);
    $paneBottomR= _createElem(container,clz:'slick-pane slick-pane-bottom slick-pane-right',tabIndex:0);

    $headerScrollerL = _createElem($paneHeaderL,clz:'ui-state-default slick-header slick-header-left');
    $headerScrollerR = _createElem($paneHeaderR,clz:'ui-state-default slick-header slick-header-right');

    //container.append($headerScroller);
    $headerScroller..add($headerScrollerL)..add($headerScrollerR);
     // Append the header scroller containers

     // Append the columnn containers to the headers
     $headerL = _createElem($headerScrollerL,clz:'slick-header-columns slick-header-columns-left', style:{'left':'-1000px'});
     $headerR = _createElem($headerScrollerR,clz:'slick-header-columns slick-header-columns-right', style:{'left':'-1000px'});
     $headers..add($headerL)..add($headerR);
      $headerRowScrollerL = _createElem($paneTopL,clz:'ui-state-default slick-headerrow' );
      $headerRowScrollerR = _createElem($paneTopR,clz:'ui-state-default slick-headerrow' );

      $headerRowScroller..add($headerRowScrollerL)..add($headerRowScrollerR);

      $headerRowSpacerL = _createElem($headerRowScrollerL,style:{'display':'block','height':'1px','position':'absolute','top':'0','left':'0'})
                           ..style.width = "${getCanvasWidth() + scrollbarDimensions['width']}px"
                           ..style.zIndex='10';

      $headerRowSpacerR = _createElem($headerRowScrollerR,style:{'display':'block','height':'1px','position':'absolute','top':'0','left':'0'})
          ..style.width = "${getCanvasWidth() + scrollbarDimensions['width']}px"
          ..style.zIndex='10';

      $headerRowL = _createElem($headerRowScrollerL,clz:'slick-headerrow-columns slick-headerrow-columns-left' );
      $headerRowR = _createElem($headerRowScrollerR,clz:'slick-headerrow-columns slick-headerrow-columns-right');

      $headerRow..add($headerRowL)..add($headerRowR);

      // Append the top panel scroller
      $topPanelScrollerL = _createElem($paneTopL,clz:'ui-state-default slick-top-panel-scroller');
      $topPanelScrollerR = _createElem($paneTopR,clz:'ui-state-default slick-top-panel-scroller');

      $topPanelScroller..add($topPanelScrollerL)..add($topPanelScrollerR);

      // Append the top panel
      $topPanelL = _createElem($topPanelScrollerL,clz:'slick-top-panel', style:{'width':'10000px'});
      $topPanelR = _createElem($topPanelScrollerR,clz:'slick-top-panel', style:{'width':'10000px'});

      $topPanel..add($topPanelL)..add($topPanelR);

      if (!_options.showTopPanel) {
          $topPanelScroller.forEach((Element _) => _.style.display='none');
      }

      if (!_options.showHeaderRow) {
          $headerRowScroller.forEach((_) => _.style.display='none');
      }

      // Append the viewport containers
      $viewportTopL = _createElem($paneTopL,clz:'slick-viewport slick-viewport-top slick-viewport-left', tabIndex:0, hideFocus:true);
      $viewportTopR = _createElem($paneTopR,clz:'slick-viewport slick-viewport-top slick-viewport-right', tabIndex:0, hideFocus:true);
      $viewportBottomL = _createElem($paneBottomL,clz:'slick-viewport slick-viewport-bottom slick-viewport-left', tabIndex:0, hideFocus:true);
      $viewportBottomR = _createElem($paneBottomR,clz:'slick-viewport slick-viewport-bottom slick-viewport-right', tabIndex:0,hideFocus:true);

      // Cache the viewports
      $viewport..add($viewportTopL)..add($viewportTopR)..add($viewportBottomL)..add($viewportBottomR);

      // Default the active viewport to the top left
      $activeViewportNode = $viewportTopL;

      // Append the canvas containers
      $canvasTopL = _createElem($viewportTopL,clz:'grid-canvas grid-canvas-top grid-canvas-left', tabIndex:0, hideFocus:true);
      $canvasTopR = _createElem($viewportTopR,clz:'grid-canvas grid-canvas-top grid-canvas-right', tabIndex:0, hideFocus:true);
      $canvasBottomL = _createElem($viewportBottomL,clz:'grid-canvas grid-canvas-bottom grid-canvas-left', tabIndex:0, hideFocus:true);
      $canvasBottomR = _createElem($viewportBottomR,clz:'grid-canvas grid-canvas-bottom grid-canvas-right', tabIndex:0 ,hideFocus:true);

      // Cache the canvases
      $canvas..add($canvasTopL)..add($canvasTopR)..add($canvasBottomL)..add($canvasBottomR);

      // Default the active canvas to the top left
      $activeCanvasNode = $canvasTopL;




      _$focusSink2 = _$focusSink.clone(true);
      container.append(_$focusSink2);

      if (_options.explicitInitialization!=true) {
        finishInitialization();
      }
    }


  /**
   * when add or remove row or change row height, we should re-calculate it's height
   * TODO add/remove single row, should we do it?
   */
  void resetDynHeight(){
    _getViewportHeight();
    if(_options.dynamicHeight==true){
            this._yLookup = new heightIdx.Root(_data,_options.rowHeight );
    }
    resizeCanvas();
  }
  /**
   * wire event listeners
   */
  void finishInitialization() {
    if (!initialized) {
      viewportW = core.Dimension.getCalcWidth(container);
      if(viewportW==0) {
        new Future.delayed(new Duration(milliseconds:100),finishInitialization);
        return;
      }
      assert(viewportW>0);
      initialized = true;
//      _log.finest(container.getBoundingClientRect().width);
      _getViewportHeight();
//      viewportW = int.parse(container.getComputedStyle().width.replaceAll('px', ''));
      _measureCellPaddingAndBorder();

      if(_options.dynamicHeight==true){
        this._yLookup = new heightIdx.Root(_data,_options.rowHeight );
      }


      // for usability reasons, all text selection in SlickGrid is disabled
      // with the exception of input and textarea elements (selection must
      // be enabled there so that editors work as expected); note that
      // selection in grid cells (grid body) is already unavailable in
      // all browsers except IE
      disableSelection($headers); // disable all text selection in header (including input and textarea)

      if (_options.enableTextSelectionOnCells==false) {
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

      _subscriptionList.add(window.onResize.listen(resizeCanvas));
      $viewport.forEach((_)=> _.onScroll.matches('*').listen(handleScroll));
//      $viewport.forEach((_)=> _.onTouchMove.listen(handleTouch));
//      $viewport.forEach((_)=> _.onTouchStart.listen(handleTouch));
//      $viewport.forEach((_) => _.onTouchMove.matches('*').listen(handleScroll));
// throttler impact smoothness of desktop header
//      var throttler = new Throttler(new Duration(milliseconds:250), handleScroll,false);
//      $viewport.forEach((_)=> _.onScroll.matches('*').listen( (e)=> throttler.throttle(e) ));

      //TODO tets
      $headerScroller.forEach((_)=> _..onContextMenu.listen(handleHeaderContextMenu)
      ..onClick.listen(handleHeaderClick));
      $headerScroller.forEach((_)=> _.querySelectorAll('.slick-header-column').onMouseEnter.listen(handleHeaderMouseEnter));
      $headerScroller.forEach((_)=> _.querySelectorAll('.slick-header-column').onMouseLeave.listen(handleHeaderMouseLeave));
      $headerRowScroller.forEach((_)=> _.onScroll.listen(handleHeaderRowScroll));
      _$focusSink.onKeyDown.listen(handleKeyDown);
      _$focusSink2.onKeyDown.listen(handleKeyDown);

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
        selectionModel.destroy();
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
      };
      $c.remove();
      return dim;
    }




    String defaultFormatter(int row,int  cell,dynamic value,[Column columnDef, dataContext]) {
      if (value == null) {
        return "";
      }
      if(value is num || value is bool) return value.toString();
      return HTML_ESCAPE.convert(value);
    }

    /**
     * update sum of header width on left and right
     */
    void updateHeadersWidth() {
      headersWidth = headersWidthL = headersWidthR = 0;
//      int headersWidth = 0;
      for (int i = 0, ii = columns.length; i < ii; i++) {
        var width = columns[i].width;
        if ( _options.frozenColumn > -1 &&  i > _options.frozenColumn) {
             headersWidthR += width;
         } else {
             headersWidthL += width;
         }
      }
      if (_options.frozenColumn> -1) {
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
        if ((_options.frozenColumn> -1) && (i > _options.frozenColumn)) {
            canvasWidthR += columns[i].width;
        } else {
            canvasWidthL += columns[i].width;
        }
        //rowWidth += columns[i].width;
      }
      var totalRowWidth = canvasWidthL + canvasWidthR;
      return _options.fullWidthRows ? math.max(totalRowWidth, availableWidth) : totalRowWidth;
    }

    void updateCanvasWidth(bool forceColumnWidthsUpdate) {
      var oldCanvasWidth = canvasWidth;
      var oldCanvasWidthL = canvasWidthL;
      var oldCanvasWidthR = canvasWidthR;
      bool widthChanged;
      canvasWidth = getCanvasWidth();
      widthChanged = canvasWidth != oldCanvasWidth || canvasWidthL != oldCanvasWidthL || canvasWidthR != oldCanvasWidthR;
      if (widthChanged || _options.frozenColumn>-1  || hasFrozenRows) {
        $canvasTopL.style.width ='${canvasWidthL}px';
        updateHeadersWidth();
        $headerL.style.width = "${headersWidthL}px";
        $headerR.style.width = "${headersWidthR}px";
        if (_options.frozenColumn> -1) {
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
//            ElementStream<Event> stream =$target.onSelectStart;
//            stream.matches('.ui').listen(
//                (Event e){
//                  _log.finest('nonselect');
//                  e.preventDefault();
//                  e.stopImmediatePropagation();
//                }, onDone : ()=> _log.finest('done'));

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
        //parseInt from getComputedStyle cause dart2js exception on firefox and IE
        // parseInt reply float
        if (test > testUpTo ||  num.parse(div.getComputedStyle().height.replaceFirst('px','')) != test) {
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
      Element elem = (hasFrozenRows && !_options.frozenBottom) ? $canvasBottomL : $canvasTopL;
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

//    unbindAncestorScrollEvents() {
//      _ancestorScrollSubscribe.cancel();
//    }
    /**
     * [title] String in normal case, InputElement if using checkboxSelector
     *
     */
    updateColumnHeader(String columnId,var title, toolTip) {
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
          $header.attributes['title']=toolTip;
        }

        trigger(this.onBeforeHeaderCellDestroy, {
          "node": $header,
          "column": columnDef
        });

       // $header.attributes.putIfAbsent('title', () => toolTip);
        $header.children.first..children.clear()..append(title);
//        if(title is Element){
//
//        }else{
//          $header.children.first.innerHtml=title;
//        }


        trigger(this.onHeaderCellRendered, {
          "node": $header,
          "column": columnDef
        });
      }
    }

    List<Element> getHeaderRow() {
      return $headerRow;
    }
    /**
     * [columnId] is field name or [Column].id
     * element of column
     */
    Element getHeaderRowColumn(columnId) {
      int idx = getColumnIndex(columnId);
      Element $headerRowTarget;
      if (_options.frozenColumn> -1) {
          if (idx <= _options.frozenColumn) {
              $headerRowTarget = $headerRowL;
          } else {
              $headerRowTarget = $headerRowR;
              idx -= _options.frozenColumn+ 1;
          }
      } else {
          $headerRowTarget = $headerRowL;
      }
      var $header = $headerRowTarget.children[idx];
      return $header;
    }
    /**
     * create Column headers using [columns]
     */
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
      updateHeadersWidth();
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
        var $headerTarget = (_options.frozenColumn> -1) ? ((i <= _options.frozenColumn) ? $headerL : $headerR) : $headerL;
        var $headerRowTarget = (_options.frozenColumn> -1) ? ((i <= _options.frozenColumn) ? $headerRowL : $headerRowR) : $headerRowL;

        Element header =  _createElem(null,clz:'ui-state-default slick-header-column');
        SpanElement spanEl=new SpanElement();
        spanEl..classes.add('slick-column-name');
        if(m['name'] is Element){
          spanEl.children.add(m['name']);
        }else{
          spanEl.text=m['name'];
        }


        header.append(spanEl);
        header.style.width = (m['width'] - _headerColumnWidthDiff).toString() + 'px';
        header.attributes['id']= '$_uid${m.id}';
        header.dataset['id']=m.id;
        if(m.toolTip!=null) header.attributes['title']=m.toolTip;
        //header.dataset['column']=JSON.encode(m._src);
        _headExt[header] = m;

        if (m['headerCssClass'] !=null) header.classes.add(m['headerCssClass']);
        if(m['headerCssClass'] != null){
          header.classes.add(m['headerCssClass'] );
        }
        $headerTarget.append(header);
        if (_options.enableColumnReorder ==true || m['sortable'] == true) {
          header.onMouseEnter.listen(onMouseEnter);
          header.onMouseLeave.listen(onMouseLeave);
        }

        if (m['sortable']) {
          header.classes.add("slick-header-sortable");
          var spanEl=new SpanElement()..classes.add('slick-sort-indicator');
          header.append(spanEl);
          //header.append( container.createFragment("<span class='slick-sort-indicator' />").children.first);
        }

        trigger(onHeaderCellRendered, {
          "node": header,
          "column": m
        });

        if (_options.showHeaderRow) {
          Element headerRowCell =  this._createElem($headerRowTarget,
              clz:'ui-state-default slick-headerrow-column l$i r$i', tabIndex:i);
          //headerRowCell.dataset['column']=JSON.encode(m);
          //$headerRowTarget.append(headerRowCell);

          trigger(onHeaderRowCellRendered, {
            "node": headerRowCell,
            "column": m
          });
        }
       // new DragAndDrop($headerRowTarget).install();
      }
      setSortColumns(sortColumns);
      setupColumnResize();
      if (_options.enableColumnReorder) {

        setupColumnReorder();
      }
    }

    _measureCellPaddingAndBorder() {
      Element el;
      el = _createElem($headers.first, clz:'ui-state-default slick-header-column', style:{'visibility':'hidden'});
      el.text='-';
      _headerColumnWidthDiff = _headerColumnHeightDiff = 0;
      assert(el.getComputedStyle().paddingTop.length !='0px');
      if (el.style.boxSizing != "border-box"  ) {
          _headerColumnWidthDiff += num.parse(el.getComputedStyle().borderLeftWidth.replaceAll('px',''),(src)=>0).round();
          _headerColumnWidthDiff += num.parse(el.getComputedStyle().borderRightWidth.replaceAll('px',''),(src)=>0).round();
          _headerColumnWidthDiff += num.parse(el.getComputedStyle().paddingLeft.replaceAll('px',''),(src)=>0).round();
          _headerColumnWidthDiff += num.parse(el.getComputedStyle().paddingRight.replaceAll('px',''),(src)=>0).round();

          _headerColumnHeightDiff += num.parse(el.getComputedStyle().borderTopWidth.replaceAll('px',''),(src)=>0).round();
          _headerColumnHeightDiff += num.parse(el.getComputedStyle().borderBottomWidth.replaceAll('px',''),(src)=>0).round();
          _headerColumnHeightDiff += num.parse(el.getComputedStyle().paddingTop.replaceAll('px',''),(src)=>0).round();
          _headerColumnHeightDiff += num.parse(el.getComputedStyle().paddingBottom.replaceAll('px',''),(src)=>0).round();
      }
      el.remove();
      var r=_createElem($canvas.first, clz:'slick-row');
      el=_createElem(r, clz:'slick-cell', style: {'visibility':'hidden'});
      el.text='-';

      _cellWidthDiff = _cellHeightDiff = 0;
      if (el.style.boxSizing != "border-box") {
        _cellWidthDiff += num.parse(el.getComputedStyle().borderLeftWidth.replaceAll('px',''),(src)=>0).round();
        _cellWidthDiff += num.parse(el.getComputedStyle().borderRightWidth.replaceAll('px',''),(src)=>0).round();
        _cellWidthDiff += num.parse(el.getComputedStyle().paddingLeft.replaceAll('px',''),(src)=>0).round();
        _cellWidthDiff += num.parse(el.getComputedStyle().paddingRight.replaceAll('px',''),(src)=>0).round();

        _cellHeightDiff += num.parse(el.getComputedStyle().borderTopWidth.replaceAll('px',''),(src)=>0).round();
        _cellHeightDiff += num.parse(el.getComputedStyle().borderBottomWidth.replaceAll('px',''),(src)=>0).round();
        _cellHeightDiff += num.parse(el.getComputedStyle().paddingTop.replaceAll('px',''),(src)=>0).round();
        _cellHeightDiff += num.parse(el.getComputedStyle().paddingBottom.replaceAll('px',''),(src)=>0).round();
      }
      r.remove();

      absoluteColumnMinWidth = math.max(_headerColumnWidthDiff, _cellWidthDiff);
    }
    /**
     * apply html5 DND
     */
    void setupColumnReorder() {
      if(_options.frozenColumn>-1){
           new DragAndDrop(this,$headerR).install();
      }else{
           new DragAndDrop(this,$headerL).install();
      }
    }

    void setupColumnResize() {

      List<Element> columnElements=[];
      Column c;
      var $col, j, pageX,  minPageX, maxPageX, firstResizable, lastResizable;
      $headers.forEach((_) => columnElements.addAll(_.children));
      columnElements.forEach((item)=> container.querySelectorAll(".slick-resizable-handle").forEach((Element itemB) => itemB.remove()));
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
        if (i < firstResizable || (_options.forceFitColumns && i >= lastResizable)) {
          continue;
        }
        $col = item;
        Element resizeItem = new DivElement();
        resizeItem.classes.add('slick-resizable-handle');
        item.append(resizeItem);
        resizeItem.draggable=true;
        resizeItem.onDragStart.listen((MouseEvent e){
          int i=columnElements.indexOf((e.target as Element).parent);
          _log.finest('drag begin');
          if (!getEditorLock().commitCurrentEdit()) {
            return false;
          }
          pageX = e.page.x;
          _log.finest('pageX $pageX');
          resizeItem.parent.classes.add("slick-header-column-active");
          var shrinkLeewayOnRight = null, stretchLeewayOnRight = null;
          // lock each column's width option to current width

          for(int cnt=0;cnt<columnElements.length;cnt++){
            columns[cnt].previousWidth = columnElements[cnt].borderEdge.width;
          }
          if (_options.forceFitColumns) {
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
          //_log.finest('dragging ${e.page.x}');
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
              //_log.finest('apply5 ${c.width} ${maxPageX} ${minPageX} ${d} ${c.previousWidth} ${actualMinWidth}');
            }

            if (_options.forceFitColumns) {
              _log.finest('apply4');
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
            //_log.finest('apply3');
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

            if (_options.forceFitColumns) {
             // _log.finest('apply1');
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
          if (_options.syncColumnCellResize!=null && _options.syncColumnCellResize==true) {
            //_log.finest('apply');
            applyColumnWidths();
          }
         // _log.finest('onDraging leave' + columnElements[i].borderEdge.width.toString());
        });
        resizeItem.onDragEnd.listen((MouseEvent e){
          _log.finest('drag End ${e.page.x}' );
          int i=columnElements.indexOf((e.target as Element).parent);
          var newWidth;
          columnElements[i].classes.remove("slick-header-column-active");
//          item.parent.classes.remove("slick-header-column-active");
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
    trigger(core.Event evt,[ Map<String,dynamic> args, var e]) {   //[core.EventData e]
      if (e ==null) e =  new core.EventData();
      if(args ==null) args = {};
      args['grid']=this;
      return evt.notify(args, e, this);
    }
    void validateAndEnforceOptions() {
      if (_options.autoHeight==true ) {
        _options.leaveSpaceForNewRows = false;
      }
    }

    void updateColumnCaches() {
      // Pre-calculate cell boundaries.
      _columnPosLeft = [];
      _columnPosRight = [];
      int x = 0;
      for (int i = 0, ii = columns.length; i < ii; i++) {
        _columnPosLeft.insert(i, x);
        _columnPosRight.insert(i,x + columns[i].width);
        if (_options.frozenColumn== i) {
             x = 0;
         } else {
             x += columns[i].width;
         }
      }
    }


  /**
   * map column elem id to sequence index(nth column in grid)
   */
  void  updateColumnIndex(){
      this.columnsById = {};
      for (var i = 0; i < columns.length; i++) {
        var m = columns[i];//new Column.fromColumn(columnDefaults).merge(columns[i]);
        columnsById[m.id] = i;
        if ( m.width < m.minWidth) { //m.minWidth &&
          m.width = m.minWidth;
        }
        if (m.maxWidth!=null && m.width > m.maxWidth) {
          m.width = m.maxWidth;
        }
      }
    }
    /**
     * [columnDefinitions] all columns
     */
    setColumns(List<Column> columnDefinitions) {
      allColumns = columnDefinitions;
      columns = new List<Column>.from(columnDefinitions.where((c) => c.visible));
      //columns = columnDefinitions;
      updateColumnIndex();


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
    /**
     * read only option
     */
    Map getOptions() {
      return _options.toJson();
    }

    /**
     * modify options and let grid reflect the change
     */
    void setOptions(Map args) {
      core.EditorLock editLock=getEditorLock();
      if (editLock!=null && !editLock.commitCurrentEdit()) {
        return;
      }

      makeActiveCellNormal();

      if (_options.enableAddRow != args['enableAddRow']) {
        invalidateRow(getDataLength());
      }
      _options.addAll(args);
//      options = $.extend(options, args);
      validateAndEnforceOptions();

      setFrozenOptions();
//      setScroller();
//      setColumns(columns); // TODO: Is this necessary?
//      $viewport.style.overflowY =  _options.autoHeight  ? "hidden" : "auto";
//      $viewportL.style.overflowY =  _options.autoHeight  ? "hidden" : "auto";
      render();
    }

    int getVBoxDelta(Element $el) {
      int delta =
      int.parse($el.getComputedStyle().borderTopWidth.replaceAll("px", ''), onError: (_)=>0)
       + int.parse($el.getComputedStyle().borderBottomWidth.replaceAll('px', ''), onError: (_)=>0)
       +  int.parse($el.getComputedStyle().paddingTop.replaceAll('px', ''), onError: (_)=>0)
       +  int.parse($el.getComputedStyle().paddingBottom.replaceAll('px', ''), onError: (_)=>0);
      return delta;
    }

    void setFrozenOptions() {
      _options.frozenColumn= ( _options.frozenColumn>= 0
          && _options.frozenColumn< columns.length  )
          ? _options.frozenColumn: -1;

      _options.frozenRow = ( _options.frozenRow >= 0
          && _options.frozenRow < numVisibleRows      )
          ? _options.frozenRow : -1;

      if (_options.frozenRow > -1) {
          hasFrozenRows = true;
          if(_options.dynamicHeight){
            frozenRowsHeight = this._yLookup.getPosition(_options.frozenRow+1);
          }else{
            frozenRowsHeight = ( _options.frozenRow ) * _options.rowHeight;
          }

          actualFrozenRow = ( _options.frozenBottom ==true)
              ? ( _data.length - _options.frozenRow )
              : _options.frozenRow;
      } else {
          hasFrozenRows = false;
      }
  }

  setPaneVisibility() {
      if (_options.frozenColumn> -1) {
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
    $viewportTopL.style.overflowX= ( _options.frozenColumn> -1 )    ?  hasFrozenRows ==true ? 'hidden' : 'scroll' :  hasFrozenRows ==true ? 'hidden' : 'auto';
    $viewportTopL.style.overflowY= ( _options.frozenColumn> -1 )    ?  hasFrozenRows ==true ? 'hidden' : 'hidden' :  hasFrozenRows ==true ? 'scroll' : 'auto';

    $viewportTopR.style.overflowX= ( _options.frozenColumn> -1 )    ?  hasFrozenRows ==true ? 'hidden' : 'scroll' :  hasFrozenRows ==true ? 'hidden' : 'auto';
    $viewportTopR.style.overflowY= ( _options.frozenColumn> -1 )    ?  hasFrozenRows ==true ? 'scroll' : 'auto'   :  hasFrozenRows ==true ? 'scroll' : 'auto';

    $viewportBottomL.style.overflowX= ( _options.frozenColumn> -1 ) ?  hasFrozenRows ==true ? 'hidden' : 'auto'   :  hasFrozenRows ==true ? 'auto'   : 'auto';
    $viewportBottomL.style.overflowY= ( _options.frozenColumn> -1 ) ?  hasFrozenRows ==true ? 'hidden' : 'hidden' :  hasFrozenRows ==true ? 'scroll' : 'auto';

    $viewportBottomR.style.overflowX= ( _options.frozenColumn> -1 ) ?  hasFrozenRows ==true ? 'scroll' : 'auto'   :  hasFrozenRows ==true ? 'auto'   : 'auto';
    $viewportBottomR.style.overflowY= ( _options.frozenColumn> -1 ) ?  hasFrozenRows ==true ? 'auto'   : 'auto'   :  hasFrozenRows ==true ? 'auto'   : 'auto';

  }

  setScroller() {
      if (_options.frozenColumn> -1) {
          $headerScrollContainer = $headerScrollerR;
          $headerRowScrollContainer = $headerRowScrollerR;

          if (hasFrozenRows) {
              if (_options.frozenBottom) {
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
              if (_options.frozenBottom) {
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

    /**
     * clear scroller, cache and current editor
     */
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
      List tmp=_rowsCache.keys.toList(growable: false);
      tmp.forEach((item) => removeRowFromCache(item)) ;
//      if (this.selectionModel!=null && this.selectedRows.length>0) {
//        this.setSelectedRows([]);
//      }
    }

    void removeRowFromCache(int row) {
      _RowCache cacheEntry = _rowsCache[row];
      //$canvas.children.remove(cacheEntry.rowNode);

      cacheEntry.rowNode[0].parent.children.remove(cacheEntry.rowNode[0]);
      // Remove the row from the right viewport
      if (cacheEntry.rowNode.length>1) {
         cacheEntry.rowNode[1].parent.children.remove(cacheEntry.rowNode[1]);
      }


      _rowsCache.remove(row);
//      delete rowsCache[row];
      postProcessedRows.remove(row);
//      delete postProcessedRows[row];
      renderedRows--;
      counter_rows_removed++;
    }

    void invalidateRows(rows) {
//      var i, rl;
      if (rows==null || rows.length==0) {
        return;
      }
      vScrollDir = 0;
      for (int i = 0, rl = rows.length; i < rl; i++) {
        if (currentEditor!=null && activeRow == rows[i]) {
          makeActiveCellNormal();
        }
        if (_rowsCache[rows[i]]!=null) {
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

      Column m = columns[cell];
      var d = getDataItem(row);
      if (currentEditor !=null && activeRow == row && activeCell == cell) {
        currentEditor.loadValue(d);
      } else {
        cellNode.setInnerHtml( d!=null ? getFormatter(row, m)(row, cell, getDataItemValueForColumn(d, m), m, d) : ""
          , treeSanitizer: _treeSanitizer );
        invalidatePostProcessingResults(row);
      }
    }

    void updateRow(row) {
      _RowCache cacheEntry = _rowsCache[row];
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
        } else if (d!=null) {
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
    /**
     * calculate view port height and determine number of row need to render
     */
    _getViewportHeight() {

        if (_options.autoHeight!=null && _options.autoHeight) {
            viewportH = _options.rowHeight  * getDataLengthIncludingAddNew()
                + ( ( _options.frozenColumn== -1 ) ? $headers.first.borderEdge.height : 0 );
        } else {
            CssStyleDeclaration csd = container.getComputedStyle();
            int height=core.Dimension.getCalcHeight(container);
            int paddingTop = int.parse(csd.paddingTop.replaceAll('px', ''), onError: (_)=>0);
            int paddingBottom = int.parse(csd.paddingBottom.replaceAll('px', ''), onError: (_)=>0);
            int headerScrollerHeight = core.Dimension.getCalcHeight($headerScroller.first);
            int vboxDelta =  getVBoxDelta($headerScroller.first) ;
            int topPanelHeight = _options.showTopPanel ==true ?  _options.topPanelHeight + getVBoxDelta($topPanelScroller.first) : 0;
            int headerRowHeight= _options.showHeaderRow ==true ?  _options.headerRowHeight + getVBoxDelta($headerRowScroller.first) : 0;
            viewportH= height - paddingTop - paddingBottom
                              - headerScrollerHeight - vboxDelta
                              - topPanelHeight - headerRowHeight;
            headerRowH=headerRowHeight;
         }

        numVisibleRows = (viewportH / _options.rowHeight).ceil();
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
    /**
     * @return position of row relative to container
     */
    int getRowTop(int row) {
      if(_options.dynamicHeight==true){
        int pos=_yLookup.getPosition(row);
        return pos;
      }else{
        return _options.rowHeight * row - offset;
      }
    }

    int getRowFromPosition(y) {
      if(_options.dynamicHeight==true){
        int rowIdx=_yLookup.getRowId(y);
        return rowIdx;
      }else{
        return ((y + offset) / _options.rowHeight).floor();
      }
    }
    /**
     * scroll viewport to target y axis
     */
    void scrollTo(int y) {
     // _log.finest('scroll to ${y}');
      y = math.max(y, 0);
      y = math.min(y, _th - viewportH + (viewportHasHScroll ? scrollbarDimensions['height'] : 0));

      int oldOffset = offset;

     // page = math.min(n - 1, (y / ph).floor());
     // offset = (page * cj).round();
      int newScrollTop = y - offset;

      if (offset != oldOffset) {//not possible here
        _log.finest('clean');
        var range = getVisibleRange(newScrollTop);
        cleanupRows(range);
        updateRowPositions();
      }

      if (prevScrollTop != newScrollTop) {
        vScrollDir = (prevScrollTop + oldOffset < newScrollTop + offset) ? 1 : -1;
        lastRenderedScrollTop = ( scrollTop = prevScrollTop = newScrollTop );

        if (_options.frozenColumn> -1) {
            $viewportTopL.scrollTop = newScrollTop;
        }

        if (hasFrozenRows) {
            $viewportBottomL.scrollTop = $viewportBottomR.scrollTop = newScrollTop;
        }

        $viewportScrollContainerY.scrollTop = newScrollTop;
//        $viewport.scrollTop = (lastRenderedScrollTop = scrollTop = prevScrollTop = newScrollTop);
        //$viewportL.scrollTop=$viewport.scrollTop;
        trigger(this.onViewportChanged, {});
        _log.finest('viewChange');
      }
    }
    void cleanupRows(Map<String,int> rangeToKeep) {
      for (int i in new List.from(_rowsCache.keys)) {

        var removeFrozenRow = true;

        if (hasFrozenRows
            && ( ( _options.frozenBottom && i > actualFrozenRow ) // Frozen bottom rows
            || ( !_options.frozenBottom && i < actualFrozenRow ) // Frozen top rows
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

   bool commitCurrentEdit() {
      if(activeRow ==null) return false;
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
                'prevSerializedValue': _serializedEditorValue,
                'execute':  () {
                  currentEditor.applyValue(item, currentEditor.serializeValue());
//                  updateRow(this.row);
                },
                'undo':  () {
//                  this.editor.applyValue(item, this.prevSerializedValue);
//                  updateRow(this.row);
                }
              };

              if (_options.editCommandHandler!=null) {
                makeActiveCellNormal();
                _options.editCommandHandler(item, column, editCommand);
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
     * return list of index of row in data
     */
    List<int> getSelectedRows() {
      if (selectionModel==null) {
        throw "Selection model is not set";
      }
      return selectedRows;
    }
    /**
     * update selected rows,
     * to unset all selected items, set [rows] to empty List
     *
     */
    void setSelectedRows(List<int> rows) {
      if (selectionModel==null) {
        throw "Selection model is not set";
      }
      selectionModel.setSelectedRanges(rowsToRanges(rows));
    }



    int getDataLengthIncludingAddNew() {
      return getDataLength() + (_options.enableAddRow  ? 1 : 0);
    }
    List getData() {
      return data;
    }

    /**
     * @return object
     * @TODO return list
     */
    getDataItem(int i) {
        if(i>=_data.length) return null;
        return _data[i];
    }

    getTopPanel() {
      return $topPanel;
    }
    void updateRowPositions() {
      for (var row in _rowsCache.keys) {
        _rowsCache[row].rowNode.forEach((_)=> _.style.top = getRowTop(row).toString() + "px");
      }
    }

    /**
     * for unrendered cells
     */
    _cleanUpAndRenderCells(Map<String,int> range) {
      _RowCache cacheEntry;
      List<String> stringArray = [];
      Queue processedRows = new Queue();
      var cellsAdded;
//      int totalCellsAdded = 0;
      var colspan;
      //reuse for frozen rows
      _helper(int row){
            if(!_rowsCache.keys.contains(row)){  return;    }
            cacheEntry = _rowsCache[row];
            // cellRenderQueue populated in renderRows() needs to be cleared first
            ensureCellNodesInRowsCache(row);
            cleanUpCells(range, row);
            // Render missing cells.
            cellsAdded = 0;
            var d = getDataItem(row);
            // TODO:  shorten this loop (index? heuristics? binary search?)
            for (int cell = 0, ii = columns.length; cell < ii; cell++) {
              // Cells to the right are outside the range.
              if (_columnPosLeft[cell] > range['rightPx']) {
                break;
              }
              // Already rendered.
              if(cacheEntry.cellNodesByColumnIdx.keys.contains(cell)){
                colspan = cacheEntry.cellColSpans[cell];
                cell += (colspan > 1 ? colspan - 1 : 0);
                continue;
              }
              colspan = 1;
              if (_columnPosRight[math.min(ii - 1, cell + colspan - 1)] > range['leftPx']  ||
              _options.frozenColumn>=cell
              ) {
                _appendCellHtml(stringArray, row, cell, colspan, d);
                cellsAdded++;
              }
              cell += (colspan > 1 ? colspan - 1 : 0);
            }

            if (cellsAdded >0) {
              //totalCellsAdded += cellsAdded;
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
        cacheEntry = _rowsCache[processedRow];
        var columnIdx;
        while (!cacheEntry.cellRenderQueue.isEmpty) {
          columnIdx=cacheEntry.cellRenderQueue.removeLast();
          node = x.lastChild;
          if (( _options.frozenColumn> -1 ) && ( columnIdx > _options.frozenColumn)) {
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
      _RowCache cacheEntry = _rowsCache[row];
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
             && ( ( _options.frozenBottom && row > actualFrozenRow ) // Frozen bottom rows
             || ( row <= actualFrozenRow )                     // Frozen top rows
             )
             ) {
             return;
       }

//      int totalCellsRemoved = 0;
      _RowCache cacheEntry = _rowsCache[row];

      // Remove cells outside the range.
      List cellsToRemove = [];
      for (var i in cacheEntry.cellNodesByColumnIdx.keys) {
        // Ignore frozen columns
//        if (i <= _options.frozenColumn) {
//            continue;
//        }
        var colspan = cacheEntry.cellColSpans[i];
        if (_columnPosLeft[i] > range['rightPx'] ||
          _columnPosRight[math.min(columns.length - 1, i + colspan - 1)] < range['leftPx']) {
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
       //totalCellsRemoved++;
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
               if (( !( _options.frozenBottom ) && ( cell['row'] >= actualFrozenRow ) )
                   || ( _options.frozenBottom && ( cell['row'] < actualFrozenRow ) )
                   ) {
                   scrollRowIntoView(cell['row'], false);
               }
               setActiveCellInternal(getCellNode(cell['row'], cell['cell']));
           }else{
               scrollRowIntoView(cell['row'], false);
               setActiveCellInternal(getCellNode(cell['row'], cell['cell']));
           }
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

        if (_options.editable) {
            gotoCell(cell['row'], cell['cell'], true);
        }
    }

    void setFocus() {
       if (tabbingDirection == -1) {
         _$focusSink.focus();
       } else {
         _$focusSink2.focus();
       }
     }

    Map<String,int> getCellFromEvent(core.EventData e) {
      assert(! (e.target is Text));
      //Element elem=e.target;
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
      var y2 = y1 + _options.rowHeight- 1;
      if(_options.dynamicHeight && _data[row]['_height']!=null){
        y2= y1+_data[row]['_height'];
      }
      var x1 = 0;
      for (var i = 0; i < cell; i++) {
        x1 += columns[i].width;
        if (_options.frozenColumn== i) {
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
      for (int row in _rowsCache.keys) {
        if (_rowsCache[row].rowNode[0] == rowNode) {
          return row;
        }
        if(_options.frozenColumn>=0){
          if (_rowsCache[row].rowNode[1] == rowNode) {
            return row;
          }
        }
      //  if(this.has)
      }

      return null;
    }


    int getFrozenRowOffset(row) {
      int distY = _options.dynamicHeight
                    ? this._yLookup.getPosition(actualFrozenRow +1)
                    : actualFrozenRow * _options.rowHeight ;

       int offset =
           ( hasFrozenRows )
               ? ( _options.frozenBottom )
               ? ( row >= actualFrozenRow )
               ? ( _h < viewportTopH )
               ? ( distY)
               : _h
               : 0
               : ( row >= actualFrozenRow )
               ? frozenRowsHeight
               : 0
               : 0;

       return offset;
   }


    core.EditorLock getEditorLock() {
      return _options.editorLock;
    }


    bool canCellBeActive(int row, int cell) {
      if (!_options.enableCellNavigation || row >= getDataLengthIncludingAddNew() ||
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
      setActiveCellInternal(newCell, forceEdit || (row == getDataLength()) || _options.autoEdit);

      // if no editor was created, set the focus back on the grid
      if (currentEditor==null) {
          setFocus();
      }
    }
    /**
     * column Column object
     * @return function object
     */
    TFormatter getFormatter(int row, Column column) {
        if(column.formatter==null) return _options.defaultFormatter;

        if(column.formatter is String){//fecth it from formatterFactorys
          return _options.formatterFactory[column.id];
        }else //this only happen when suppply a new column is not from grid constructor
           return  column.formatter;
    }


    scrollRowIntoView(int row, [doPaging]) {
      int rowTopDist = _options.dynamicHeight ? this._yLookup.getPosition(row+1) : row * _options.rowHeight;
      //int rowBottomDist = _options.dynamicHeight ? this.yLookup.getPosition(row+2) : (row + 1) * _options.rowHeight;

      var rowAtTop = rowTopDist;
      var rowAtBottom = rowTopDist - viewportH + (viewportHasHScroll ? scrollbarDimensions['height'] : 0);

      // need to page down?
      if (rowTopDist > scrollTop + viewportH + offset) {
        scrollTo(doPaging !=null ? rowAtTop : rowAtBottom);
        render();
      }
      // or page up?
      else if (rowTopDist < scrollTop + offset) {
        scrollTo(doPaging!=null ? rowAtBottom : rowAtTop);
        render();
      }
    }

     void scrollRowToTop(int row) {
       int distToMove = _options.dynamicHeight ? this._yLookup.getPosition(row+1) : row * _options.rowHeight;
      scrollTo(distToMove);
      render();
    }

     void scrollPage(dir) {
      int deltaRows = dir * numVisibleRows;
      scrollTo((getRowFromPosition(scrollTop) + deltaRows) * _options.rowHeight);
      render();

      if (_options.enableCellNavigation==true && activeRow != null) {
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
      if (_rowsCache[row]!=null) {
        ensureCellNodesInRowsCache(row);
        return _rowsCache[row].cellNodesByColumnIdx[cell];
      }
      return null;
    }

    void setActiveCell(int row, int cell) {
      if (!initialized) { return; }
      if (row > getDataLength() || row < 0 || cell >= columns.length || cell < 0) {
        return;
      }

      if (_options.enableCellNavigation!=null) {
        return;
      }

      scrollCellIntoView(row, cell, false);
      setActiveCellInternal(getCellNode(row, cell), false);
    }
    void scrollCellIntoView(int row,int cell,bool doPaging) {
      if (cell <= _options.frozenColumn) {
          return;
      }

      if (row < actualFrozenRow) {
          scrollRowIntoView(row, doPaging);
      }

      var colspan = getColspan(row, cell);
      int left = _columnPosLeft[cell],
        right = _columnPosRight[cell + (colspan > 1 ? colspan - 1 : 0)],
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
        if (_rowsCache[activeRow]!=null) {
          _rowsCache[activeRow].rowNode.forEach((_)=> _.classes.remove("active"));
        }
      }

      bool activeCellChanged = (activeCellNode != newCell);
      activeCellNode = newCell;

      if (activeCellNode != null) {
        activeRow = getRowFromNode(activeCellNode.parentNode);
        activeCell = activePosX = getCellFromNode(activeCellNode);
        //last row or current row
        if (opt_editMode == null) {
          opt_editMode = (activeRow == getDataLength()) || _options.autoEdit==true;
        }

        activeCellNode.classes.add("active");
        _rowsCache[activeRow].rowNode.forEach((_)=> _.classes.add("active"));

        if (_options.editable==true && opt_editMode && isCellPotentiallyEditable(activeRow, activeCell)) {
          if(h_editorLoader!=null){
            h_editorLoader.cancel();
            h_editorLoader=null;
          }
//          clearTimeout(h_editorLoader);

          if (_options.asyncEditorLoading) {
            h_editorLoader = new Timer(new Duration(milliseconds:_options.asyncEditorLoadDelay),makeActiveCellEditable());
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
          TFormatter formatter = getFormatter(activeRow, column);
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
      if (_options.dataItemColumnValueExtractor!=null) {
        return _options.dataItemColumnValueExtractor(item, columnDef);
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
      if (_options.enableAsyncPostRender==false) {
        return;
      }
      if (h_postrender!=null) h_postrender.cancel();
//      clearTimeout(h_postrender);
      h_postrender = new Timer( new Duration (milliseconds:_options.asyncPostRenderDelay ),asyncPostProcessRows);
      _log.finest (h_postrender.isActive);
    }

    asyncPostProcessRows() {
      int dataLength = getDataLength();
      while (postProcessFromRow <= postProcessToRow) {
        int row = (vScrollDir >= 0) ? postProcessFromRow++ : postProcessToRow--;
        _RowCache cacheEntry = _rowsCache[row];
        if (cacheEntry==null || row >= dataLength) {
          continue;
        }

        if (postProcessedRows[row]==null) {
          postProcessedRows[row] = {};
        }

        ensureCellNodesInRowsCache(row);
        for (var columnIdx in cacheEntry.cellNodesByColumnIdx) {

          Column m = columns[columnIdx];
          if (m.asyncPostRender!=null && !postProcessedRows[row][columnIdx]) {
            var node = cacheEntry.cellNodesByColumnIdx[columnIdx];
            if (node) {
              m.asyncPostRender(node, row, getDataItem(row), m);
            }
            postProcessedRows[row][columnIdx] = true;
          }
        }

        h_postrender = new Timer(new Duration(milliseconds: _options.asyncPostRenderDelay ),asyncPostProcessRows);
        return;
      }
    }
    /**
     * @input {top: 24, bottom: 50, leftPx: 0, rightPx: 1204}
     * top >=0
     * bottom  <=max row count , when equal to row count,....
     * @TODO add new row handling
     */
    renderRows(Map range) {
      //Element parentNode = $canvas;

      List stringArrayL = [],stringArrayR = [],   rows = [];
      bool needToReselectCell = false;
      int    dataLength = getDataLength();


      //find uncached rows and add to buffer
      for (int i = range['top'], ii = range['bottom']; i <= ii; i++) {
        if (_rowsCache.keys.contains(i) || (hasFrozenRows && _options.frozenBottom && i==_data.length)) {
                  continue;
        }
        renderedRows++;
        rows.add(i);

        // Create an entry right away so that appendRowHtml() can
        // start populatating it.
        _rowsCache[i] = new _RowCache(null,this.columns.length);

        _appendRowHtml(stringArrayL,stringArrayR, i, range, dataLength);
        if (activeCellNode !=null && activeRow == i) {
          needToReselectCell = true;
        }
        counter_rows_rendered++;
    }
    if (rows.length==0) { return; }
    //generate tags for new rows
    //TODO disable for mobile device
    Element x = new Element.div();
    x.setInnerHtml(stringArrayL.join(""), treeSanitizer: _treeSanitizer )  ;
    x.querySelectorAll(".slick-cell").onMouseEnter.listen(handleMouseEnter);
    x.querySelectorAll(".slick-cell").onMouseLeave.listen(handleMouseLeave);
    Element xRight = new Element.div();
    xRight.setInnerHtml(stringArrayR.join(""), treeSanitizer: _treeSanitizer )  ;
    xRight.querySelectorAll(".slick-cell").onMouseEnter.listen(handleMouseEnter);
    xRight.querySelectorAll(".slick-cell").onMouseLeave.listen(handleMouseLeave);
    for (var i = 0, ii = rows.length; i < ii; i++) {
        if ( hasFrozenRows  &&  rows[i] >= actualFrozenRow ) {
            if (_options.frozenColumn> -1) {
                _rowsCache[rows[i]].rowNode = [x.firstChild,xRight.firstChild];
                $canvasBottomL.children.add(x.firstChild);
                $canvasBottomR.children.add(xRight.firstChild);
            } else {
                _rowsCache[rows[i]].rowNode = [x.firstChild];
                $canvasBottomL.children.add(x.firstChild);
            }
        } else if (_options.frozenColumn> -1) {
            _rowsCache[rows[i]].rowNode = [x.firstChild,xRight.firstChild];
            $canvasTopL.children.add(x.firstChild);
            $canvasTopR.children.add(xRight.firstChild);
        } else {
            _rowsCache[rows[i]].rowNode = [x.firstChild];
            $canvasTopL.children.add(x.firstChild);
        }
    }

    if (needToReselectCell) {
        activeCellNode = getCellNode(activeRow, activeCell);
    }

    }
    /**
     * row render loop,
     * [row] may exceed number of [_data] element
     */
    _appendRowHtml(List<String> stringArrayL,List<String> stringArrayR, int row, Map<String,int> range,int dataLength) {
      var d = getDataItem(row);
      var dataLoading = row < dataLength && d==null;
      String rowCss = "slick-row" +
          (dataLoading ? " loading" : "") +
          (row == activeRow ? " active" : "") +
          (row % 2 == 1 ? " odd" : " even");

      if(_data is MetaList){
        //implement metadata interface
        Map metadata = (_data as MetaList).getMetaData(row);
        if(metadata.containsKey("cssClasses")){
          rowCss += " " + metadata['cssClasses'];
        }
      }
      var frozenRowOffset = getFrozenRowOffset(row);
      var rHeight= (_data.length > row && _data[row]['_height']!=null) ?  "height:${_data[row]['_height']}px" : '';
      String rowHtml = """<div class='ui-widget-content ${rowCss}' style='top: ${getRowTop(row) - frozenRowOffset}px;  ${rHeight }'>""";
      stringArrayL.add(rowHtml);
      if (_options.frozenColumn> -1) {
          stringArrayR.add(rowHtml);
      }

      var colspan;
      //Column m;
      for (var i = 0, ii = columns.length; i < ii; i++) {
       //Column m = columns[i];
        colspan = 1;
        if (_columnPosRight[math.min(ii - 1, i + colspan - 1)] > range['leftPx']) {
          if (_columnPosLeft[i] > range['rightPx']) {
            // All columns to the right are outside the range.
            break;
          }
          if (( _options.frozenColumn> -1 ) && ( i > _options.frozenColumn)) {
              _appendCellHtml(stringArrayR, row, i, colspan, d);
          } else {
              _appendCellHtml(stringArrayL, row, i, colspan, d);
          }

        }else if (( _options.frozenColumn> -1 ) && ( i <= _options.frozenColumn)) {
          _appendCellHtml(stringArrayL, row, i, colspan,d);
        }

        if (colspan > 1) {
          i += (colspan - 1);
        }
      }

      stringArrayL.add("</div>");
      if (_options.frozenColumn> -1) {
        stringArrayR.add("</div>");
      }
    }
    /**
     * cell render loop, generate cell html tag
     * stringArray: output value
     * item : data item
     */
    _appendCellHtml(List<String> stringArray,int row,int cell,int colspan, var item) {
      Column m = columns[cell];
      String cellCss = "slick-cell l$cell r" + math.min(columns.length - 1, cell + colspan - 1).toString() +
          (m.cssClass!=null ? " " + m.cssClass : "");
      if (row == activeRow && cell == activeCell) {
        cellCss += (" active");
      }

      // TODO:  merge them together in the setter
      for (var key in _cellCssClasses.keys) {
        if (_cellCssClasses[key].containsKey(row) && _cellCssClasses[key][row].containsKey(m.id)) {
          cellCss += (" " + _cellCssClasses[key][row][m.id]);
        }
      }
      String style='';
      if(_data.length>row && _data[row]['_height']!=null){
        style="style='height:${_data[row]['_height']-this._cellHeightDiff}px'";
      }
      stringArray.add("<div class='${cellCss}' ${style}>");

      // if there is a corresponding row (if not, this is the Add New row or this data hasn't been loaded yet)
      if (item!=null) {
        var value = getDataItemValueForColumn(item, m);
        stringArray.add(getFormatter(row, m)(row, cell, value, m, item));
      }

      stringArray.add("</div>");

      _rowsCache[row].cellRenderQueue.addLast(cell);
//      rowsCache[row].cellColSpans.insert(cell,colspan);
      _rowsCache[row].cellColSpans[cell]=colspan;
    }
    void clearTextSelection() {
      window.getSelection().removeAllRanges();
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

          if (isMetaKey && _options.multiColumnSort) {
            if (sortOpts!=null) {
              sortColumns.removeAt(i);
            }
          }
          else {
            if ((!e.shiftKey && !e.metaKey) || _options.multiColumnSort!=true) {
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
          core.EventData evt = new core.EventData.fromDom(e);
          if (_options.multiColumnSort==false) {
            trigger(onSort, {
              'multiColumnSort': false,
              'sortCol': column,
              'sortAsc': sortOpts['sortAsc'],
              'sortCols': [{'sortCol': column, 'sortAsc':sortOpts['sortAsc'] }]
              }, evt);

          } else {
            trigger(onSort, {
              'multiColumnSort': true,
              'sortCols': new List.from(sortColumns.map(
                  (item) =>{'sortCol': columns[getColumnIndex(item['columnId'])],
                             'sortAsc': item['sortAsc']} ))}, evt);
          }
        }
      }));
    }

    /**
     * setup large canvas height that enable native scroll
     */
    void updateRowCount() {
      if (!initialized) { return; }

      int dataLengthIncludingAddNew = getDataLengthIncludingAddNew();
      int numberOfRows = dataLengthIncludingAddNew +
          (_options.leaveSpaceForNewRows ?  1 : 0);
          //(_options.leaveSpaceForNewRows ? numVisibleRows - 1 : 0);

      bool oldViewportHasVScroll = viewportHasVScroll;
      // with autoHeight, we do not need to accommodate the vertical scroll bar
      viewportHasVScroll = _options.autoHeight == false && (numberOfRows * _options.rowHeight > viewportH);

      // remove the rows that are now outside of the data range
      int l = dataLengthIncludingAddNew - 1;
      new List.from(_rowsCache.keys.where((e)=> e >= l )).forEach((e) => removeRowFromCache(e));

      if (activeCellNode!=null && activeRow > l) {
        resetActiveCell();
      }

      int oldH = _h;
      if(_options.dynamicHeight==true){ //total length must match, or we may not able to scroll to last row
        _th = _yLookup.height;
      }else{
        _th = math.max(_options.rowHeight * numberOfRows, viewportH - scrollbarDimensions['height']);
      }

      if (_th < maxSupportedCssHeight) {
        // just one page
        _h = _ph = _th;
        _n = 1;
        _cj = 0;
      } else {
        // break into pages
        _h = maxSupportedCssHeight;
        _ph = _h ~/ 100;
        _n = (_th / _ph).floor();
        _cj = (_th - _h) / (_n - 1);
      }

      if (_h != oldH) {
        if (hasFrozenRows && !_options.frozenBottom) {
            $canvasBottomL.style.height= '${_h}px';

            if (_options.frozenColumn> -1) {
                $canvasBottomR.style.height = '${_h}px';
            }
        } else {
            $canvasTopL.style.height ='${_h}px';
           if (_options.frozenColumn> -1) {
                $canvasTopR.style.height = '${_h}px';
           }
        }
        scrollTop = $viewportScrollContainerY.scrollTop;
      }

      bool oldScrollTopInRange = (scrollTop + offset <= _th - viewportH);

      if (_th == 0 || scrollTop == 0) {
        page = offset = 0;
      } else if (oldScrollTopInRange) {
        // maintain virtual position
        scrollTo(scrollTop + offset);
      } else {
        // scroll to bottom
        scrollTo(_th - viewportH);
      }

      if (_h != oldH && _options.autoHeight) {
        resizeCanvas();
      }

      if (_options.forceFitColumns && oldViewportHasVScroll != viewportHasVScroll) {
        autosizeColumns();
      }
      updateCanvasWidth(false);
    }

    /// remove active cell
    /// enable click event re-trigger on same e
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
    int scount=0;
//    void handleTouch(e){
//      if (_options.frozenColumn> -1) {
//           if (hasFrozenRows) {
//                   $viewportTopR.scrollLeft = scrollLeft;
//             }
//     } else {
//           if (hasFrozenRows) {
//               $viewportTopL.scrollLeft = scrollLeft;
//             }
//     }
//    }
    /**
     * 1 second emit 15 events
     * performance killer
     */
    void handleScroll([Event e]) {
      scrollTop = $viewportScrollContainerY.scrollTop;
      scrollLeft = $viewportScrollContainerX.scrollLeft;


      //scount++;
      _log.finer('s event ${scount}' + new DateTime.now().toString() );
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
      //  _log.finest('pre scroll top: ${prevScrollTop}');
        int vScrollDist = (scrollTop - prevScrollTop).abs();
        int hScrollDist = (scrollLeft - prevScrollLeft).abs();

        if (hScrollDist>0) { //create scroll linkage between upperleft, upperRight, lowerLeft view
            prevScrollLeft = scrollLeft;

            //$viewportScrollContainerX.scrollLeft = scrollLeft;
            $headerScrollContainer.scrollLeft = scrollLeft;
            $topPanelScroller..first.scrollLeft = scrollLeft..last.scrollLeft=scrollLeft;
            $headerRowScrollContainer.scrollLeft = scrollLeft;

            if (_options.frozenColumn> -1) {
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

            if (_options.frozenColumn> -1) {
                if (hasFrozenRows && !_options.frozenBottom) {
                    $viewportBottomL.scrollTop = scrollTop;
                } else {
                    $viewportTopL.scrollTop = scrollTop;
                }
            }

            // switch virtual pages if needed
            if (vScrollDist < viewportH) {
               // _log.finest('v scr dist: ${vScrollDist} ${viewportH}');
                scrollTo(scrollTop + offset);
            }
        }

        if (hScrollDist>0 || vScrollDist >0) {
            if (h_render!=null) {
                h_render.cancel();
                _log.finest("cancel scroll");
                h_render=null;
            }
            //how many distance is enought to scroll?
            if ((lastRenderedScrollTop - scrollTop).abs() > 220 ||
                (lastRenderedScrollLeft - scrollLeft).abs() > 220) {
                if (_options.forceSyncScrolling|| (
                    (lastRenderedScrollTop - scrollTop).abs() < viewportH &&
                        (lastRenderedScrollLeft - scrollLeft).abs() < viewportW)) {
                    render();
                } else {
                  _log.finest("new timer");
                    h_render=new Timer(new Duration(milliseconds:50),render);
                   // h_render = setTimeout(render, 50);
                }
                if(onViewportChanged.handlers.length>0){
                  trigger(onViewportChanged, {});
                }
            }
        }
        if(onScroll.handlers.length>0){//may i avoid high scroller event cost
          trigger(onScroll, {'scrollLeft': scrollLeft, 'scrollTop': scrollTop});
        }
    }

    // todo shaodw fix
    // todo dynmic height , remove height
    void createCssRules() {
       $style=new StyleElement();
       $style.id=_style_id;
//      $style =  container.createFragment("<style type='text/css' rel='stylesheet' />", treeSanitizer : _treeSanitizer).children.first;
      if(container.parent ==null){
        _log.finest('it is shadow');
        (container.parentNode as ShadowRoot).children.insert(0,$style);
      }else{
        querySelector('head').append($style);
      }
      int rowHeight = (_options.rowHeight - _cellHeightDiff);
      List rules = [
        "." + _uid + " .slick-header-column { left: 1000px; }",
        "." + _uid + " .slick-top-panel { height:" + _options.topPanelHeight.toString() + "px; }",
        "." + _uid + " .slick-headerrow-columns { height:" + _options.headerRowHeight.toString() + "px; }",
        "." + _uid + " .slick-cell { height:" + rowHeight.toString() + "px; }",
        "." + _uid + " .slick-row { height:" + _options.rowHeight.toString() + "px; }"
      ];

      if(window.navigator.userAgent.contains("Android") && window.navigator.userAgent.contains("Chrome")  ){
        rules.add( '.${_uid} .slick-viewport { -webkit-transform: translateZ(0);}' );
      }

      for (int i = 0; i < columns.length; i++) {
        rules.add("." + _uid + " .l" + i.toString() + " { }");
        rules.add("." + _uid + " .r" + i.toString() + " { }");
      }
        $style.appendText(rules.join(' '));
    }


    void handleHeaderMouseEnter(MouseEvent e) {
      core.EventData evt = new core.EventData.fromDom(e);
      trigger(onHeaderMouseEnter, {
        //"column": (e.target as Element).dataset["column"]
        "column": _headExt[e.target as Element] //.dataset["column"]
      }, evt);
    }

    void handleHeaderMouseLeave(MouseEvent e) {
      core.EventData evt = new core.EventData.fromDom(e);
      trigger(onHeaderMouseLeave, {
        //"column": (e.target as Element).dataset["column"]
        "column": _headExt[e.target as Element]
      }, evt);
    }

     handleHeaderContextMenu(Event e) {
       Element $header = findClosestAncestor(e.target,'slick-header-column',".slick-header-columns");
       core.EventData evt = new core.EventData.fromDom(e);
       Column c;
       if( $header !=null) {
         //c = new Column.fromJSON($header.dataset["column"]);
         c= this._headExt[$header];
       }
       trigger(onHeaderContextMenu, {'column': c}, evt);
     }

     void handleHeaderClick(Event e) {
       _log.finest('header clicked');
       Element header = findClosestAncestor(e.target,'.slick-header-column',".slick-header-columns");
       core.EventData evt = new core.EventData.fromDom(e);
       Column c;
       if( header !=null) {
         //c = new Column.fromJSON(header.dataset["column"]);
         c= this._headExt[header];
       }
       if (c!=null) { //TODO fix me
         trigger(onHeaderClick, {'column': c}, evt);
       }
     }


     makeActiveCellEditable([editor.Editor ed]) {
       if (activeCellNode==null) {
         return;
       }
       if (_options.editable==false) {
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

       _serializedEditorValue = currentEditor.serializeValue();

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
         if (_options.autoEdit) {
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
       while ( (elem.parent is Element && elem.parent != document.body) ||
               (elem.parentNode is Element  )) {
         elem=elem.parent!=null ? elem.parent : elem.parentNode ;
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
       if (_options.enableCellNavigation==false) {
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
         if(row<this._data.length){
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
      /** keyboard navigation down **/
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


      getEditor(row, cell) {
        Column column = columns[cell];
        if(column['editor']!=null) return column['editor'] ;
        if(_options.editorFactory!=null){
          return _options.editorFactory.getEditor(column);
        }
        return null;
      }

      editor.Editor getEditorInstance(row, cell, editor.EditorParm editorParm) {
        Column column = columns[cell]; //column['editor']
        var editorStr=column['editor'];
        if(editorStr is String){
          switch(editorStr){
            case 'IntEditor':
              return new editor.IntEditor(editorParm)..editorParm=editorParm;
            case 'DoubleEditor':
              return new editor.DoubleEditor(editorParm)..editorParm=editorParm;
            case 'TextEditor':
              return new editor.TextEditor(editorParm)..editorParm=editorParm;
            case 'CheckboxEditor':
              return new editor.CheckboxEditor(editorParm);

            default:
              return null;
          }
        }else{
          editor.Editor item=column['editor'];
          item.editorParm=editorParm;
          return item;
        }
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


      void handleMouseEnter(MouseEvent e) {
        //_log.finest('handle');
        core.EventData evt = new core.EventData.fromDom(e);
        trigger(onMouseEnter, {}, evt);
      }

      void handleMouseLeave(MouseEvent e) {
        core.EventData evt = new core.EventData.fromDom(e);
        trigger(onMouseLeave, {}, evt);
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
              if (_options.editable) {
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
      /**
       * clean listeners
       */
      unSubscribe(){
        this._subscriptionList.forEach((_)=> _.cancel());
      }

}
