library slick.grid;
import 'slick.core.dart' as core;
import 'slick.editor.dart' as editor;
import 'dart:html';
import 'dart:math' as math;
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
Map<String,int> scrollbarDimensions;  //width and height
int maxSupportedCssHeight;  // browser's breaking point

//tailer for html style
var _treeSanitizer = new NullTreeSanitizer();
/**
 * Sanitizer which does nothing.
 */
class NullTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(Node node) {
    print(node);
  }
}
class RowCache{
  RowCache (this.rowNode);
  Element rowNode;
  // ColSpans of rendered cells (by column idx).
  // Can also be used for checking whether a cell has been rendered.
  List<int> cellColSpans = [];

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
                'forceSyncScrolling': false
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
  DivElement $headerScroller;
  DivElement $headers;
  DivElement $headerRow, $headerRowScroller, $headerRowSpacer;
  DivElement $topPanelScroller;
  DivElement $topPanel;
  DivElement $viewport;
  DivElement $canvas;
  Element $style;
  List<Element> $boundAncestors;
  CssStyleSheet stylesheet;
  List<CssStyleRule> columnCssRulesL, columnCssRulesR;
  int viewportH=0, viewportW =0;
  int canvasWidth;
  bool viewportHasHScroll=false, viewportHasVScroll=false;
  int headerColumnWidthDiff = 0, headerColumnHeightDiff = 0, // border+padding
      cellWidthDiff = 0, cellHeightDiff = 0;
  int absoluteColumnMinWidth;

  int tabbingDirection = 1;
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

  var selectionModel;
  List selectedRows = [];

  List plugins = [];
  Map cellCssClasses = {};

  Map columnsById = {};
  List sortColumns = [];
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
  /////////////////////////////one line accessoe
  int getDataLength(){
    return  data.length;
  }

  int getColumnIndex(id) {
    return columnsById[id];
  }
  List getSortColumns() => sortColumns;

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
//          match.group(0)
          columnCssRulesL.insert(int.parse(match.group(0).substring(2)), cssRules[i]);
//          columnCssRulesL.add( int.parse(selector.substring(2)));
        } else if(regR.hasMatch(selector)){
          Match match=regR.firstMatch(selector);
          columnCssRulesR.insert(int.parse(match.group(0).substring(2)), cssRules[i]);
//          columnCssRulesR.add( int.parse(selector.substring(2)));
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
    List<Element> headers = $headers.children;
    for (int i = 0,  ii = headers.length; i < ii; i++) {
      h = headers[i];
      if (int.parse(h.getComputedStyle().width.replaceAll("px", '')) != columns[i].width - headerColumnWidthDiff) {
        h.style.width= (columns[i].width - headerColumnWidthDiff).toString() + 'px';
      }
    }

    updateColumnCaches();
  }
  void applyColumnWidths() {
    int x = 0, w;
    Map<String,CssStyleRule> rule;
    for (int i = 0; i < columns.length; i++) {
      w = columns[i].width;

      rule = getColumnCssRules(i);
      rule['left'].style.left = x.toString() + "px";
      rule['right'].style.right = (canvasWidth - x - w).toString() + "px";

      x += columns[i].width;
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

  void resizeCanvas([Event e]) {
    if (!initialized) { return; }
    if (options['autoHeight']==true) {
      viewportH = options['rowHeight'] * getDataLengthIncludingAddNew();
    } else {
      viewportH = getViewportHeight();
    }

    numVisibleRows = (viewportH / options['rowHeight']).ceil();
    viewportW =  int.parse(container.getComputedStyle().width.replaceAll("px", '')) ;//parseFloat($.css($container[0], "width", true));
    if (options['autoHeight']==false) {
      $viewport.style.height = '$viewportH' + 'px';
    }

    if (options['forceFitColumns']==true ) {
      autosizeColumns();
    }

    updateRowCount();
    handleScroll();
    // Since the width has changed, force the render() to reevaluate virtually rendered cells.
    lastRenderedScrollLeft = -1;
    render();
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
      $headerScroller = container.createFragment("<div class='slick-header ui-state-default' style='overflow:hidden;position:relative;' />"
          ,treeSanitizer :_treeSanitizer).children.first;
      container.append($headerScroller);

      $headers = container.createFragment("<div class='slick-header-columns' style='left:-1000px' />"
          ,treeSanitizer :_treeSanitizer).children.first;
      $headerScroller.append($headers);
      $headers.style.width=getHeadersWidth().toString() + 'px';
      $headerRowScroller = container.createFragment("<div class='slick-headerrow ui-state-default' style='overflow:hidden;position:relative;' />"
          ,treeSanitizer :_treeSanitizer).children.first;
      container.append($headerRowScroller);

      $headerRow = container.createFragment("<div class='slick-headerrow-columns' />"
          ,treeSanitizer :_treeSanitizer).children.first;

      $headerRowScroller.append($headerRow);

      $headerRowSpacer = container.createFragment("<div style='display:block;height:1px;position:absolute;top:0;left:0;'></div>"
          ,treeSanitizer :_treeSanitizer).children.first;
      $headerRowSpacer.style.width= (getCanvasWidth() + scrollbarDimensions['width']).toString() + "px";
      $headerRowScroller.append( $headerRowSpacer);

      $topPanelScroller = container.createFragment("<div class='slick-top-panel-scroller ui-state-default' style='overflow:hidden;position:relative;' />"
          ,treeSanitizer :_treeSanitizer).children.first;
      container.append($topPanelScroller);
      $topPanel = container.createFragment("<div class='slick-top-panel' style='width:10000px' />"
          ,treeSanitizer :_treeSanitizer).children.first;

      $topPanelScroller.append($topPanel);

      if (!options['showTopPanel']) {
        $topPanelScroller.style.display='none';
      }

      if (!options['showHeaderRow']) {
        $headerRowScroller.style.display='none';
      }

      $viewport = container.createFragment("<div class='slick-viewport' style='width:100%;overflow:auto;outline:0;position:relative;'>"
          ,treeSanitizer :_treeSanitizer).children.first;
      container.append($viewport);

      $viewport.style.overflowY =  options['autoHeight'] ? "hidden" : "auto";

      $canvas = container.createFragment("<div class='grid-canvas' />" ,treeSanitizer :_treeSanitizer).children.first;
      $viewport.append($canvas);

      $focusSink2 = $focusSink.clone(true);
      container.append($focusSink2);

      if (options['explicitInitialization']!=true) {
        finishInitialization();
      }
    }

  void finishInitialization() {
    if (!initialized) {
      initialized = true;

      viewportW = int.parse(container.getComputedStyle().width.replaceAll('px', ''));
      measureCellPaddingAndBorder();

      // for usability reasons, all text selection in SlickGrid is disabled
      // with the exception of input and textarea elements (selection must
      // be enabled there so that editors work as expected); note that
      // selection in grid cells (grid body) is already unavailable in
      // all browsers except IE
      disableSelection($headers); // disable all text selection in header (including input and textarea)

      if (options['enableTextSelectionOnCells']==false) {
        // disable text selection in grid cells except in input and textarea elements
        // (this is IE-specific, because selectstart event will only fire in IE)
//        $viewport.onSelectStart.matches('.ui').listen((event){
//            if( event.target is InputElement || event.target is TextAreaElement){
//              return true;
//            } else {
//              return false;
//            }
//        });
      }
      updateColumnCaches();
      createColumnHeaders();
      setupColumnSort();
      createCssRules();
      resizeCanvas();
      bindAncestorScrollEvents();

      window.onResize.listen(resizeCanvas);
//      $container
//          .bind("resize.slickgrid", resizeCanvas);
      $viewport.onClick.listen(handleClick);
      $viewport.onScroll.matches('*').listen(handleScroll);

//      $viewport
//          .bind("click", handleClick)
//          .bind("scroll", handleScroll);
      $headerScroller..onContextMenu.listen(handleHeaderContextMenu)
      ..onClick.listen(handleHeaderClick);
      $headerScroller.queryAll('.slick-header-column').onMouseEnter.listen(handleHeaderMouseEnter);
      $headerScroller.queryAll('.slick-header-column').onMouseLeave.listen(handleHeaderMouseLeave);
//      $headerScroller.onMouseEnter.matches('.slick-header-column').listen(handleHeaderMouseEnter);
//      $headerScroller.onMouseEnter.matches('.slick-header-column').listen((e) => print("mouse enter"));
//      $headerScroller.onMouseLeave.matches('.slick-header-column').listen(handleHeaderMouseLeave);
//
//      $headerScroller
//          .bind("contextmenu", handleHeaderContextMenu)
//          .bind("click", handleHeaderClick)
//          .delegate(".slick-header-column", "mouseenter", handleHeaderMouseEnter)
//          .delegate(".slick-header-column", "mouseleave", handleHeaderMouseLeave);
      $headerRowScroller.onScroll.listen(handleHeaderRowScroll);
//      $headerRowScroller
//          .bind("scroll", handleHeaderRowScroll);
      $focusSink.onKeyDown.listen(handleKeyDown);
      $focusSink2.onKeyDown.listen(handleKeyDown);
//      $focusSink.add($focusSink2)
//          .bind("keydown", handleKeyDown);

      $canvas..onKeyDown.listen(handleKeyDown)
      ..onClick.listen(handleClick);
//TODO fix me
//      ..onDoubleClick.listen(handleDblClick)
//      ..onContextMenu.listen(handleContextMenu)
      $canvas
      ..onDragStart.listen(handleDragStart)
      ..onDrag.listen(handleDrag)
      ..onDragEnd.listen(handleDragEnd);
      $canvas.onMouseEnter.matches('.slick-cell').listen(handleMouseEnter);
      $canvas.onMouseLeave.matches('.slick-cell').listen(handleMouseLeave);
//
//      $canvas
//          .bind("keydown", handleKeyDown)
//          .bind("click", handleClick)
//          .bind("dblclick", handleDblClick)
//          .bind("contextmenu", handleContextMenu)
//          .bind("draginit", handleDragInit)
//          .bind("dragstart", {distance: 3}, handleDragStart)
//          .bind("drag", handleDrag)
//          .bind("dragend", handleDragEnd)
//          .delegate(".slick-cell", "mouseenter", handleMouseEnter)
//          .delegate(".slick-cell", "mouseleave", handleMouseLeave);


    }
  }  //end of initialize

    void registerPlugin(plugin) {
      plugins.add(plugin);
      plugin.init(this);
    }

    void unregisterPlugin(plugin) {
      plugins.remove(plugin);
      plugin.destroy();
    }

    void setSelectionModel( model) {
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
    }


    getSelectionModel() {
      return selectionModel;
    }

    Element getCanvasNode() {
      return $canvas;
    }

    Map<String,int> measureScrollbar() {
      var $c =  query('body').createFragment("<div style='position:absolute; top:-10000px; left:-10000px; width:100px; height:100px; overflow:scroll;'></div>"
          ,treeSanitizer : _treeSanitizer).children.first;

      query('body').append($c);
      CssStyleDeclaration style=$c.getComputedStyle();
      Map dim = {
        'width': int.parse(style.width.replaceAll('px','')) -  $c.clientWidth, // $c[0].clientWidth,
        'height': int.parse(style.height.replaceAll('px','')) - $c.clientHeight
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


    int getHeadersWidth() {
      int headersWidth = 0;
      for (int i = 0, ii = columns.length; i < ii; i++) {
        var width = columns[i].width;
        headersWidth += width;
      }
      headersWidth += scrollbarDimensions['width'];
      return math.max(headersWidth, viewportW) + 1000;
    }

    int getCanvasWidth() {
      int availableWidth = viewportHasVScroll ? viewportW - scrollbarDimensions['width'] : viewportW;
      int rowWidth = 0;
      int i = columns.length;
      while (i-- >0) {
        rowWidth += columns[i].width;
      }
      return options['fullWidthRows'] ? math.max(rowWidth, availableWidth) : rowWidth;
    }

    void updateCanvasWidth(forceColumnWidthsUpdate) {
      var oldCanvasWidth = canvasWidth;
      canvasWidth = getCanvasWidth();

      if (canvasWidth != oldCanvasWidth) {
        $canvas.style.width = canvasWidth.toString() + 'px';
        $headerRow.style.width = canvasWidth.toString() + 'px';
        $headers.style.width = getHeadersWidth().toString() + 'px';
        viewportHasHScroll = (canvasWidth > viewportW - scrollbarDimensions['width']);
      }

      $headerRowSpacer.style.width =(canvasWidth + (viewportHasVScroll ?  scrollbarDimensions['width']: 0)).toString() +'px';

      if (canvasWidth != oldCanvasWidth || forceColumnWidthsUpdate) {
        applyColumnWidths();
      }
    }

//TODO not really work
    void disableSelection(Element $target) {
      if ($target !=null) {
        $target.attributes.putIfAbsent('unselectable',() =>'on');
        ElementStream<Event> stream =$target.onSelectStart;
        stream.matches('.ui').listen(
            (Event e){
              e.preventDefault();
              e.stopImmediatePropagation();
            }, onDone : ()=> print('done'));

//        Element el =new Element.html("<div class='ui'>zzzzzzzz</div>");
//        $target.append(el);
      }
    }


    getMaxSupportedCssHeight() {
      int supportedHeight = 1000000;
      // FF reports the height back but still renders blank after ~6M px
      int testUpTo = 6000000; // : 1000000000;
      Element div =  query('body').createFragment("<div style='display:none' />",treeSanitizer: _treeSanitizer).children.first;

      while (true) {
        var test = supportedHeight * 2;
        div.style.height = "$test" +'px';
        if (test > testUpTo || div.getComputedStyle().height != test) {
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
      Element elem = $canvas;
      while ((elem = elem.parentNode) != document.body && elem != null) {
        // bind to scroll containers only
        if (elem == $viewport || elem.scrollWidth != elem.clientWidth || elem.scrollHeight != elem.clientHeight) {
//          var $elem = $(elem);
          if ($boundAncestors==null) {
            $boundAncestors = [elem];
          } else {
            $boundAncestors.add(elem);  //TODO
          }
          _ancestorScrollSubscribe = elem.onScroll.matches('scroll.$uid' ).listen(handleActiveCellPositionChange);

        }
      }
    }

    unbindAncestorScrollEvents() {
      _ancestorScrollSubscribe.cancel();
    }

    updateColumnHeader(columnId, title, toolTip) {
      if (!initialized) { return; }
      int idx = getColumnIndex(columnId);
      if (idx == null) {
        return;
      }

      Column columnDef = columns[idx];

      Element $header = $headers.children[idx];
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
      var idx = getColumnIndex(columnId);
      var $header = $headerRow.children[idx];
      return $header;
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

      $headers.queryAll(".slick-header-column")
        .forEach( (Element item) {
          var columnDef = item.dataset["column"];
          if (columnDef!=null) {
            trigger(this.onBeforeHeaderCellDestroy, {
              "node": this,
              "column": columnDef
            });
          }
        });
      $headers.children.clear(); //empty();
      $headers.style.width =getHeadersWidth().toString() + 'px';

      $headerRow.queryAll(".slick-headerrow-column").forEach((Element item){
        String columnDef =item.dataset['column'];
        if(columnDef!=null) trigger(onBeforeHeaderRowCellDestroy,
            { "node": this,
              "column": columnDef}
        );

      });
//        .each(() {
//          var columnDef = $(this).data("column");
//          if (columnDef) {
//            trigger(self.onBeforeHeaderRowCellDestroy, {
//              "node": this,
//              "column": columnDef
//            });
//          }
//        });
      $headerRow.children.clear();

      for (int i = 0; i < columns.length; i++) {
        Column m = columns[i];

        Element header =  container.createFragment("<div class='ui-state-default slick-header-column' />").children.first;

        header.append( container.createFragment("<span class='slick-column-name'>" + m['name'] + "</span>").children.first);
        header.style.width = (m['width'] - headerColumnWidthDiff).toString() + 'px';
        header.attributes['id']= uid + m.id;
        if(m.toolTip!=null) header.attributes['title']=m.toolTip;
        header.dataset['column']=JSON.encode(m._src);
        if (m['headerCssClass'] !=null) header.classes.add(m['headerCssClass']);
        header.classes.add(m['headerCssClass'] == null ? '': m['headerCssClass'] );
        $headers.append(header);
           // .html("<span class='slick-column-name'>" + m.name + "</span>")
//            .width(m['width'] - headerColumnWidthDiff)
//            .attr("id", "" + uid + m.id)
//            .attr("title", m.toolTip || "")
//            .data("column", m)
//            .addClass(m.headerCssClass || "")
//            .appendTo($headers);

        if (options['enableColumnReorder'] ==true || m['sortable'] == true) {
          header.onMouseEnter.listen(onMouseEnter);
          header.onMouseLeave.listen(onMouseLeave);
//            .on('mouseenter', onMouseEnter)
//            .on('mouseleave', onMouseLeave);
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
          $headerRow.append(headerRowCell);
//              .data("column", m)
//              .appendTo($headerRow);

          trigger(onHeaderRowCellRendered, {
            "node": headerRowCell,
            "column": m
          });
        }
      }

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
      $headers.append(el);
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
      $canvas.append(r); //appendTo($canvas);

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

      List<Element> columnElements;
      Column c;
      var $col, j, pageX,  minPageX, maxPageX, firstResizable, lastResizable;
      columnElements = $headers.children;
      columnElements.forEach((item)=> queryAll(".slick-resizable-handle").forEach((Element itemB) => itemB.remove()));
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

      for(i=0;i<columnElements.length;i++){
        Element item =columnElements[i];
        if (i < firstResizable || (options['forceFitColumns'] && i >= lastResizable)) {
          return;
        }
        $col = item;
        item.appendHtml("<div class='slick-resizable-handle' />");
//            .appendTo(e)
        item.onDragStart.listen((MouseEvent e){
          if (!getEditorLock().commitCurrentEdit()) {
            return false;
          }
          pageX = e.page.x;
          item.parent.classes.add("slick-header-column-active");
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
//            .bind("dragstart",  (e, dd) {
//                       })
        item.onDrag.listen((MouseEvent e){
          int actualMinWidth, d = math.min(maxPageX, math.max(minPageX, e.page.x)) - pageX, x;
          if (d < 0) { // shrink column
            x = d;
            for (j = i; j >= 0; j--) {
              c = columns[j];
              if (c.resizable) {
                actualMinWidth = math.max(c.minWidth !=null ? c.minWidth: 0, absoluteColumnMinWidth);
                if (x && c.previousWidth + x < actualMinWidth) {
                  x += c.previousWidth - actualMinWidth;
                  c.width = actualMinWidth;
                } else {
                  c.width = c.previousWidth + x;
                  x = 0;
                }
              }
            }

            if (options['forceFitColumns']) {
              x = -d;
              for (j = i + 1; j < columnElements.length; j++) {
                c = columns[j];
                if (c.resizable) {
                  if (x >0 && c.maxWidth!=null  && (c.maxWidth - c.previousWidth < x)) {
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
            x = d;
            for (j = i; j >= 0; j--) {
              c = columns[j];
              if (c.resizable) {
                if (x !=null && c.maxWidth && (c.maxWidth - c.previousWidth < x)) {
                  x -= c.maxWidth - c.previousWidth;
                  c.width = c.maxWidth;
                } else {
                  c.width = c.previousWidth + x;
                  x = 0;
                }
              }
            }

            if (options['forceFitColumns']) {
              x = -d;
              for (j = i + 1; j < columnElements.length; j++) {
                c = columns[j];
                if (c.resizable) {
                  actualMinWidth = math.max(c.minWidth !=null ? c.minWidth: 0, absoluteColumnMinWidth);
                  if (x && c.previousWidth + x < actualMinWidth) {
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
          if (options['syncColumnCellResize']) {
            applyColumnWidths();
          }

        });
//            .bind("drag",  (e, dd) {
//                      })
        item.onDragEnd.listen((e){
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
//      columnElements.forEach( (Element item) {
//
//
//      });
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
        x += columns[i].width;
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

    getOptions() {
      return options;
    }

    setOptions(args) {
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

      $viewport.style.overflowY =  options['autoHeight']  ? "hidden" : "auto";
      render();
    }

    int getVBoxDelta(Element $el) {
//      var p = ["borderTopWidth", "borderBottomWidth", "paddingTop", "paddingBottom"];
      int delta =
      int.parse($el.getComputedStyle().borderTopWidth.replaceAll("px", ''))
       + int.parse($el.getComputedStyle().borderBottomWidth.replaceAll('px', ''))
       +  int.parse($el.getComputedStyle().paddingTop.replaceAll('px', ''))
       +  int.parse($el.getComputedStyle().paddingBottom.replaceAll('px', ''));
//      $.each(p, function (n, val) {
//        delta += parseFloat($el.css(val)) || 0;
//      });
      return delta;
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
      rowsCache.clear();
//      for (var row in rowsCache.keys) {
//        removeRowFromCache(row);
//      }
    }

    void removeRowFromCache(int row) {
      var cacheEntry = rowsCache[row];
//      if (!cacheEntry) {
//        return;
//      }
      $canvas.children.remove(cacheEntry.rowNode);
      rowsCache.remove(row);
//      delete rowsCache[row];
      postProcessedRows.remove(row);
//      delete postProcessedRows[row];
      renderedRows--;
      counter_rows_removed++;
    }

    void invalidateRows(rows) {
      var i, rl;
      if (!rows || !rows.length) {
        return;
      }
      vScrollDir = 0;
      for (int i = 0, rl = rows.length; i < rl; i++) {
        if (currentEditor && activeRow == rows[i]) {
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
      if (!cellNode) {
        return;
      }

      Column m = columns[cell], d = getDataItem(row);
      if (currentEditor && activeRow == row && activeCell == cell) {
        currentEditor.loadValue(d);
      } else {
        cellNode.setInnerHtml( d!=null ? getFormatter(row, m)(row, cell, getDataItemValueForColumn(d, m), m, d) : ""
          , treeSanitizer: _treeSanitizer );
        invalidatePostProcessingResults(row);
      }
    }

    void updateRow(row) {
      RowCache cacheEntry = rowsCache[row];
      if (!cacheEntry) {
        return;
      }

      ensureCellNodesInRowsCache(row);

      var d = getDataItem(row);
      for(int columnIdx=0;columnIdx < cacheEntry.cellNodesByColumnIdx.length ; columnIdx++){
        Column m = columns[columnIdx];
        Element    node = cacheEntry.cellNodesByColumnIdx[columnIdx];
        if (row == activeRow && columnIdx == activeCell && currentEditor) {
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




    int getViewportHeight() {
      CssStyleDeclaration csd = container.getComputedStyle();
      int height=int.parse(csd.height.replaceAll('px', ''));
      int paddingTop = int.parse(csd.paddingTop.replaceAll('px', ''));
      int paddingBottom = int.parse(csd.paddingBottom.replaceAll('px', ''));
      int headerScrollerHeight = int.parse($headerScroller.getComputedStyle().height.replaceAll('px', ''));
      int vboxDelta =  getVBoxDelta($headerScroller) ;
      int topPanelHeight = options['showTopPanel'] ==true ?  options['topPanelHeight'] + getVBoxDelta($topPanelScroller) : 0;
      int headerRowHeight= options['showHeaderRow'] ==true ?  options['headerRowHeight'] + getVBoxDelta($headerRowScroller) : 0;
      return height - paddingTop - paddingBottom - headerScrollerHeight - vboxDelta - topPanelHeight - headerRowHeight;
//      return parseFloat($.css($container[0], "height", true)) -
//          parseFloat($.css($container[0], "paddingTop", true)) -
//          parseFloat($.css($container[0], "paddingBottom", true)) -
//          parseFloat($.css($headerScroller[0], "height")) - getVBoxDelta($headerScroller) -
//          (options.showTopPanel ? options.topPanelHeight + getVBoxDelta($topPanelScroller) : 0) -
//          (options.showHeaderRow ? options.headerRowHeight + getVBoxDelta($headerRowScroller) : 0);
    }



    setSortColumn(columnId, ascending) {
      setSortColumns([{ 'columnId': columnId, 'sortAsc': ascending}]);
    }

    setSortColumns(List<Map<String,dynamic>> cols) {
      sortColumns = cols;

      List<Element> headerColumnEls = $headers.children;
      headerColumnEls.forEach((item){
        item.classes.remove("slick-header-column-sorted");
        if (item.classes.contains('.slick-sort-indicator')){
          item.classes.removeAll(["slick-sort-indicator-asc", "slick-sort-indicator-desc"]);
        }

      });
//          .removeClass("slick-header-column-sorted")
//          .find(".slick-sort-indicator")
//              .removeClass("slick-sort-indicator-asc slick-sort-indicator-desc");
      sortColumns.forEach((Map<String,dynamic> col){
        if (col['sortAsc']==null){
          col['sortAsc'] = true;
        }
        var columnIndex = getColumnIndex(col['columnId']);
        if (columnIndex != null) {
          headerColumnEls[columnIndex].classes.add('slick-header-column-sorted');
          headerColumnEls[columnIndex].query('.slick-sort-indicator')
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
        $viewport.scrollTop = (lastRenderedScrollTop = scrollTop = prevScrollTop = newScrollTop);

        trigger(this.onViewportChanged, {});
      }
    }
    void cleanupRows(Map<String,int> rangeToKeep) {
      for (int i in new List.from(rowsCache.keys)) {
        if ((i != activeRow) && (i < rangeToKeep['top'] || i > rangeToKeep['bottom'])) {
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
//                  this.editor.applyValue(item, this.serializedValue);
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
      for (var row in rowsCache) {
        rowsCache[row].rowNode.style.top = getRowTop(row).toString() + "px";
      }
    }


    cleanUpAndRenderCells(Map<String,int> range) {
      var cacheEntry;
      List<String> stringArray = [];
      Queue processedRows = new Queue();
      var cellsAdded;
      int totalCellsAdded = 0;
      var colspan;

      for (int row = range['top'], btm = range['bottom']; row <= btm; row++) {
        if(!rowsCache.keys.contains(row)){
          continue;
        }
        cacheEntry = rowsCache[row];
//        if (!cacheEntry) {
//          continue;
//        }

        // cellRenderQueue populated in renderRows() needs to be cleared first
        ensureCellNodesInRowsCache(row);

        cleanUpCells(range, row);

        // Render missing cells.
        cellsAdded = 0;

        //TODO unless data is object
//        var metadata = data.getItemMetadata !=null && data.getItemMetadata(row);
//        metadata = metadata && metadata.columns;

        var d = getDataItem(row);

        // TODO:  shorten this loop (index? heuristics? binary search?)
        for (int i = 0, ii = columns.length; i < ii; i++) {
          // Cells to the right are outside the range.
          if (columnPosLeft[i] > range['rightPx']) {
            break;
          }

          // Already rendered.
          if ((colspan = cacheEntry.cellColSpans[i]) != null) {
            i += (colspan > 1 ? colspan - 1 : 0);
            continue;
          }

          colspan = 1;
          //TODO unless data is object
//          if (metadata) {
//            var columnData = metadata[columns[i].id] || metadata[i];
//            colspan = (columnData && columnData.colspan) || 1;
//            if (colspan == "*") {
//              colspan = ii - i;
//            }
//          }

          if (columnPosRight[math.min(ii - 1, i + colspan - 1)] > range['leftPx']) {
            appendCellHtml(stringArray, row, i, colspan, d);
            cellsAdded++;
          }

          i += (colspan > 1 ? colspan - 1 : 0);
        }

        if (cellsAdded >0) {
          totalCellsAdded += cellsAdded;
          processedRows.add(row);
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
          cacheEntry.rowNode.append(node);
          cacheEntry.cellNodesByColumnIdx[columnIdx] = node;
        }
      }
    }

    void ensureCellNodesInRowsCache(row) {
      RowCache cacheEntry = rowsCache[row];
      if (cacheEntry!=null) {
        if (cacheEntry.cellRenderQueue.length>0) {
          Element lastChild = cacheEntry.rowNode.lastChild;
          while (cacheEntry.cellRenderQueue.length>0) {
            int columnIdx = cacheEntry.cellRenderQueue.removeLast();
            cacheEntry.cellNodesByColumnIdx[columnIdx]=lastChild;
            lastChild = lastChild.previousNode; //previousSibling;
          }
        }
      }
    }

     void cleanUpCells(range, row) {
      int totalCellsRemoved = 0;
      RowCache cacheEntry = rowsCache[row];

      // Remove cells outside the range.
      List cellsToRemove = [];
      for (var i in cacheEntry.cellNodesByColumnIdx.keys) {
        // I really hate it when people mess with Array.prototype.
//        if (!cacheEntry.cellNodesByColumnIdx.(i)) {
//          continue;
//        }

        // This is a string, so it needs to be cast back to a number.
//        i = i | 0;

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
       cacheEntry.rowNode.children.remove(cacheEntry.cellNodesByColumnIdx[item]);
       cacheEntry.cellColSpans.removeAt(item);
       cacheEntry.cellNodesByColumnIdx.remove(item);
       if (postProcessedRows[row]) {
          postProcessedRows[row].removeAt(cellToRemove);
       }
       totalCellsRemoved++;
     });


    }



    void  handleClick(MouseEvent e) {
       if (currentEditor==null) {
         // if this click resulted in some cell child node getting focus,
         // don't steal it back - keyboard events will still bubble up
         // IE9+ seems to default DIVs to tabIndex=0 instead of -1, so check for cell clicks directly.
         if (e.target != document.activeElement || (e.target as Element).classes.contains("slick-cell")) {
           setFocus();
         }
       }

       Map<String,int> cell = getCellFromEvent(e);
       if (cell==null || (currentEditor != null && activeRow == cell['row'] && activeCell == cell['cell'])) {
         return;
       }

       trigger(this.onClick, {'row': cell['row'], 'cell': cell['cell']}, e);
       //TODO not available
//       if (e.isImmediatePropagationStopped()) {
//         return;
//       }

       if ((activeCell != cell['cell'] || activeRow != cell['row']) && canCellBeActive(cell['row'], cell['cell'])) {
         if (!getEditorLock().isActive() || getEditorLock().commitCurrentEdit()) {
           scrollRowIntoView(cell['row'], false);
           setActiveCellInternal(getCellNode(cell['row'], cell['cell']));
         }
       }
     }

    void setFocus() {
       if (tabbingDirection == -1) {
         $focusSink.focus();
       } else {
         $focusSink2.focus();
       }
     }

    Map<String,int> getCellFromEvent(Event e) {

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
     * ancestorClzName : query condition
     */
    Element findClosestAncestor(Element element, String ancestorClzName,[String scope]) {
      if (element == null ) return null;

//      if (scope!=null && element.classes.contains(scope)) return element.query(ancestorClzName);
      //TODO no matched function to check current node
      if( element.classes.contains(ancestorClzName.toString().substring(1)) ) return element;
      Element elem =element.query(ancestorClzName);
      if(elem !=null) {
        return elem;
      } else {
        return findClosestAncestor(element.parent,ancestorClzName);
      }
//      Element parent = element.parent;
//      while (!parent.classes.contains(ancestorClzName)) {
//        parent = parent.parent;
//        if (parent == null || parent == container) {
//          // Throw, or find some other way to handle the tagName not being found.
//          return null;
//        }
//      }
//      return parent;
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
        if (rowsCache[row].rowNode == rowNode) {
          return row;
        }
      }

      return null;
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
    /**
     * column Column object
     */
    Function getFormatter(int row, Column column) {
        return  column.formatter !=null ? column.formatter : options['defaultFormatter'];
    }


    scrollRowIntoView(int row, doPaging) {
      var rowAtTop = row * options['rowHeight'];
      var rowAtBottom = (row + 1) * options['rowHeight'] - viewportH + (viewportHasHScroll ? scrollbarDimensions['height'] : 0);

      // need to page down?
      if ((row + 1) * options['rowHeight'] > scrollTop + viewportH + offset) {
        scrollTo(doPaging ? rowAtTop : rowAtBottom);
        render();
      }
      // or page up?
      else if (row * options['rowHeight'] < scrollTop + offset) {
        scrollTo(doPaging ? rowAtBottom : rowAtTop);
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
      scrollRowIntoView(row, doPaging);

      var colspan = getColspan(row, cell);
      int left = columnPosLeft[cell],
        right = columnPosRight[cell + (colspan > 1 ? colspan - 1 : 0)],
        scrollRight = scrollLeft + viewportW;

      if (left < scrollLeft) {
        $viewport.scrollLeft =left;
        handleScroll();
        render();
      } else if (right > scrollRight) {
        $viewport.scrollLeft=math.min(left, right - $viewport.clientWidth);
        handleScroll();
        render();
      }
    }
    setActiveCellInternal(Element newCell,[ opt_editMode]) {
      if (activeCellNode != null) {
        makeActiveCellNormal();
        activeCellNode.classes.remove("active");
        if (rowsCache[activeRow]!=null) {
          rowsCache[activeRow].rowNode.classes.remove("active");
        }
      }

      var activeCellChanged = (activeCellNode != newCell);
      activeCellNode = newCell;

      if (activeCellNode != null) {
        activeRow = getRowFromNode(activeCellNode.parentNode);
        activeCell = activePosX = getCellFromNode(activeCellNode);
        //TODO unclear
        if (opt_editMode == null) {
          opt_editMode = (activeRow == getDataLength()) || options['autoEdit']==true;
        }

        activeCellNode.classes.add("active");
        rowsCache[activeRow].rowNode.classes.add("active");

        if (options['editable']==true && opt_editMode && isCellPotentiallyEditable(activeRow, activeCell)) {
          h_editorLoader.cancel();
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
        activeCellNode.classes.remove("editable invalid");
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

    renderRows(range) {
      Element parentNode = $canvas;
      List stringArray = [],   rows = [];
      bool needToReselectCell = false;
      int    dataLength = getDataLength();

      for (int i = range['top'], ii = range['bottom']; i <= ii; i++) {
        if (rowsCache.keys.contains(i)) {
          continue;
        }
        renderedRows++;
        rows.add(i);

        // Create an entry right away so that appendRowHtml() can
        // start populatating it.
        rowsCache[i] = new RowCache(null);
        appendRowHtml(stringArray, i, range, dataLength);
        if (activeCellNode !=null && activeRow == i) {
          needToReselectCell = true;
        }
        counter_rows_rendered++;
      }

      if (rows.length==0) { return; }

      Element x = new Element.div();
      x.setInnerHtml(stringArray.join(""), treeSanitizer: _treeSanitizer )  ;

      for (int i = 0, ii = rows.length; i < ii; i++) {
        rowsCache[rows[i]].rowNode = x.firstChild;
        parentNode.children.add(x.firstChild);
      }

      if (needToReselectCell) {
        activeCellNode = getCellNode(activeRow, activeCell);
      }
    }
    appendRowHtml(List<String> stringArray, int row, Map<String,int> range,int dataLength) {
      var d = getDataItem(row);
      var dataLoading = row < dataLength && d!=null;
      String rowCss = "slick-row" +
          (dataLoading ? " loading" : "") +
          (row == activeRow ? " active" : "") +
          (row % 2 == 1 ? " odd" : " even");

//      var metadata = data.getItemMetadata && data.getItemMetadata(row);
//
//      if (metadata && metadata.cssClasses) {
//        rowCss += " " + metadata.cssClasses;
//      }

      stringArray.add("<div class='ui-widget-content " + rowCss + "' style='top:" + getRowTop(row).toString() + "px'>");

      var colspan;
      Column m;
      for (var i = 0, ii = columns.length; i < ii; i++) {
        m = columns[i];
        colspan = 1;
//        if (metadata && metadata.columns) {
//          var columnData = metadata.columns[m.id] || metadata.columns[i];
//          colspan = (columnData && columnData.colspan) || 1;
//          if (colspan === "*") {
//            colspan = ii - i;
//          }
//        }

        // Do not render cells outside of the viewport.
        if (columnPosRight[math.min(ii - 1, i + colspan - 1)] > range['leftPx']) {
          if (columnPosLeft[i] > range['rightPx']) {
            // All columns to the right are outside the range.
            break;
          }

          appendCellHtml(stringArray, row, i, colspan, d);
        }

        if (colspan > 1) {
          i += (colspan - 1);
        }
      }

      stringArray.add("</div>");
    }

    appendCellHtml(List<String> stringArray,int row,int cell,int colspan, item) {
      Column m = columns[cell];
      String cellCss = "slick-cell l" + cell.toString() + " r" + math.min(columns.length - 1, cell + colspan - 1).toString() +
          (m.cssClass!=null ? " " + m.cssClass : "");
      if (row == activeRow && cell == activeCell) {
        cellCss += (" active");
      }

      // TODO:  merge them together in the setter
      for (var key in cellCssClasses.keys) {
        if (cellCssClasses[key][row] && cellCssClasses[key][row][m.id]) {
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
      rowsCache[row].cellColSpans.insert(cell,colspan);
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
      $headers.onClick.listen((MouseEvent e){
        // temporary workaround for a bug in jQuery 1.7.1 (http://bugs.jquery.com/ticket/11328)
        bool isMetaKey = e.metaKey || e.ctrlKey;

        if ((e.target as Element).classes.contains("slick-resizable-handle")) {
          return;
        }

        Element $col = this.findClosestAncestor(e.target, ".slick-header-column");

            //$(e.target).closest(".slick-header-column");
//        if ($col.length) {
//          return;
//        }

        Column column = new Column.fromMap(JSON.decode($col.dataset["column"]));
        if (column.sortable) {
          if (!getEditorLock().commitCurrentEdit()) {
            return;
          }

          var sortOpts = null;
          var i = 0;
          for (; i < sortColumns.length; i++) {
            if (sortColumns[i].columnId == column.id) {
              sortOpts = sortColumns[i];
              sortOpts.sortAsc = !sortOpts.sortAsc;
              break;
            }
          }

          if (isMetaKey && options['multiColumnSort']) {
            if (sortOpts) {
              sortColumns.removeAt(i);
            }
          }
          else {
            if ((!e.shiftKey && !e.metaKey) || options['multiColumnSort']!=null) {
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

          if (options['multiColumnSort']==null) {
            trigger(onSort, {
              'multiColumnSort': false,
              'sortCol': column,
              'sortAsc': sortOpts.sortAsc}, e);
          } else {
            trigger(onSort, {
              'multiColumnSort': true,
              'sortCols': new List.from(sortColumns.map(
                  (item) =>{'sortCol': columns[getColumnIndex(item['columnId'])],
                             'sortAsc': item['sortAsc']} ))}, e);
          }
        }
      });
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
      // this helps avoid redundant calls to .removeRow() when the size of the data decreased by thousands of rows
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
        $canvas.style.height= h.toString()+ 'px';
        scrollTop = $viewport.scrollTop;
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
      var scrollLeft = $headerRowScroller.scrollLeft;
      if (scrollLeft != $viewport.scrollLeft) {
        $viewport.scrollLeft = scrollLeft;
      }
    }
    void handleScroll([Event e]) {
      scrollTop = $viewport.scrollTop;
      scrollLeft = $viewport.scrollLeft;
      int vScrollDist = (scrollTop - prevScrollTop).abs();
      int hScrollDist = (scrollLeft - prevScrollLeft).abs();

      if (hScrollDist>0) {
        prevScrollLeft = scrollLeft;
        $headerScroller.scrollLeft = scrollLeft;
        $topPanelScroller.scrollLeft = scrollLeft;
        $headerRowScroller.scrollLeft = scrollLeft;
      }

      if (vScrollDist>0) {
        vScrollDir = prevScrollTop < scrollTop ? 1 : -1;
        prevScrollTop = scrollTop;

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

      if (hScrollDist>0 || vScrollDist>0) {
        if (h_render!=null) {
          h_render.cancel();
        }

        if ((lastRenderedScrollTop - scrollTop).abs() > 20 ||
            (lastRenderedScrollLeft - scrollLeft).abs() > 20) {
          if (options['forceSyncScrolling']!=null || (
              (lastRenderedScrollTop - scrollTop).abs() < viewportH &&
              (lastRenderedScrollLeft - scrollLeft).abs() < viewportW)) {
            render();
          } else {

            h_render = new Timer.periodic(new Duration(milliseconds:50),render);
          }

          trigger(onViewportChanged, {});
        }
      }

      trigger(onScroll, {'scrollLeft': scrollLeft, 'scrollTop': scrollTop});
    }
    void createCssRules() {
      $style =  container.createFragment("<style type='text/css' rel='stylesheet' />", treeSanitizer : _treeSanitizer).children.first;
      query('head').append($style);
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
        "column": (e.target as Element).dataset["column"]
      }, e);
    }

    void handleHeaderMouseLeave(e) {
      trigger(onHeaderMouseLeave, {
        "column": (e.target as Element).dataset["column"]
      }, e);
    }

     handleHeaderContextMenu(Event e) {
       Element $header = findClosestAncestor(e.target,'slick-header-column',".slick-header-columns");
       Column c;
       if( $header !=null) {
         c = new Column.fromJSON($header.dataset["column"]);
       }
       trigger(onHeaderContextMenu, {'column': c}, e);
     }

     void handleHeaderClick(Event e) {
       print('header clicked');
       Element header = findClosestAncestor(e.target,'.slick-header-column',".slick-header-columns");
       Column c;
       if( header !=null) {
         c = new Column.fromJSON(header.dataset["column"]);
       }
       if (c!=null) { //TODO fix me
         trigger(onHeaderClick, {'column': c}, e);
       }
     }


     makeActiveCellEditable([editor.Editor editor]) {
       if (!activeCellNode) {
         return;
       }
       if (options['editable']!=null) {
         throw "Grid : makeActiveCellEditable : should never get called when options.editable is false";
       }

       // cancel pending async call if there is one
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
       if (editor!=null) {
         activeCellNode.setInnerHtml('');
       }

       currentEditor = editor==null ?   getEditor(activeRow, activeCell) : editor;

       currentEditor.editorParm ={
         'grid': this,
         'gridPosition': absBox(container),
         'position': absBox(activeCellNode),
         'container': activeCellNode,
         'column': columnDef,
         'item': item == null ?{} : item,
         'commitChanges': commitEditAndSetFocus,
         'cancelChanges': cancelEditAndSetFocus
       };

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
       while ((elem = elem.parentNode) != document.body) {
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
       if (!activeCellNode) {
         return;
       }

     trigger(onActiveCellPositionChanged, {});

       if (currentEditor!=null) {
         var cellBox = getActiveCellPosition();
         if (currentEditor.show && currentEditor.hide) {
           if (!cellBox['visible']) {
             currentEditor.hide();
           } else {
             currentEditor.show();
           }
         }
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
       if (options['enableCellNavigation']!=null) {
         return false;
       }

       if (activeCellNode !=null && dir != "prev" && dir != "next") {
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
       if (pos) {
         var isAddNewRow = (pos.row == getDataLength());
         scrollCellIntoView(pos.row, pos.cell, !isAddNewRow);
         setActiveCellInternal(getCellNode(pos.row, pos.cell));
         activePosX = pos.posX;
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
       while (!pos) {
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
       }
       return null;
     }

      Map gotoLeft(int row,int  cell,int  posX) {
       if (cell <= 0) {
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


      Function getEditor(row, cell) {
        Column column = columns[cell];
//        var rowMetadata = data.getItemMetadata && data.getItemMetadata(row);
//        var columnMetadata = rowMetadata && rowMetadata.columns;

//        if (columnMetadata && columnMetadata[column.id] && columnMetadata[column.id].editor != null) {
//          return columnMetadata[column.id].editor;
//        }
//        if (columnMetadata && columnMetadata[cell] && columnMetadata[cell].editor != null) {
//          return columnMetadata[cell].editor;
//        }
        if(column['editor']!=null) return column['editor'] ;
        if(options['editorFactory']!=null){
          options['editorFactory'].getEditor(column);
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


      void handleMouseEnter(e) {
        trigger(onMouseEnter, {}, e);
      }

      void handleMouseLeave(e) {
        trigger(onMouseLeave, {}, e);
      }
      bool cellExists(int row,int  cell) {
        return !(row < 0 || row >= getDataLength() || cell < 0 || cell >= columns.length);
      }



      handleDragStart(Event e) {
        Map<String,int> cell = getCellFromEvent(e);
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


      void handleKeyDown(KeyboardEvent e) {
        trigger(onKeyDown, {'row': activeRow, 'cell': activeCell}, e);
           bool handled = false;
//        var handled = e.isImmediatePropagationStopped();

//        if (!handled) {
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
//        }

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




