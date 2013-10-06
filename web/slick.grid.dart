library slick.grid;
import 'slick.core.dart' as core;
import 'dart:html';
import 'dart:math' as math;
import 'dart:async';
Map<String,int> scrollbarDimensions;  //width and height
int maxSupportedCssHeight;  // browser's breaking point

//tailer for html style
var _treeSanitizer = new NullTreeSanitizer();
/**
 * Sanitizer which does nothing.
 */
class NullTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(Node node) {}
}
class SlickGrid {
  Element container;
  List data;
  List<Map<String, dynamic>> columns;
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
  Map<String,dynamic> columnDefaults = {
    'name': "",
    'resizable': true,
    'sortable': false,
    'minWidth': 30,
    'rerenderOnResize': false,
    'headerCssClass': null,
    'defaultSortAsc': true,
    'focusable': true,
    'selectable': true
  };
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
  var initialized = false;
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
  var $style;
  Element $boundAncestors;
  var stylesheet, columnCssRulesL, columnCssRulesR;
  int viewportH=0, viewportW =0;
  int canvasWidth;
  bool viewportHasHScroll=false, viewportHasVScroll=false;
  int headerColumnWidthDiff = 0, headerColumnHeightDiff = 0, // border+padding
      cellWidthDiff = 0, cellHeightDiff = 0;
  int absoluteColumnMinWidth;

  int tabbingDirection = 1;
  int activePosX;
  int activeRow, activeCell;
  var activeCellNode = null;
  var currentEditor = null;
  var serializedEditorValue;
  Map editController;

  Map rowsCache = {};
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
  var h_editorLoader = null;
  var h_render = null;
  var h_postrender = null;
  Map postProcessedRows = {};
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


   autosizeColumns() {
    var i, c,
    widths = [],
    shrinkLeeway = 0,
    total = 0,
    prevTotal,
    availWidth = viewportHasVScroll ? viewportW - scrollbarDimensions.width : viewportW;

    for (i = 0; i < columns.length; i++) {
      c = columns[i];
      widths.push(c.width);
      total += c.width;
      if (c.resizable) {
        shrinkLeeway += c.width - Math.max(c.minWidth, absoluteColumnMinWidth);
      }
    }

    // shrink
    prevTotal = total;
    while (total > availWidth && shrinkLeeway) {
      var shrinkProportion = (total - availWidth) / shrinkLeeway;
      for (i = 0; i < columns.length && total > availWidth; i++) {
        c = columns[i];
        var width = widths[i];
        if (!c.resizable || width <= c.minWidth || width <= absoluteColumnMinWidth) {
          continue;
        }
        var absMinWidth = Math.max(c.minWidth, absoluteColumnMinWidth);
        var shrinkSize = Math.floor(shrinkProportion * (width - absMinWidth)) || 1;
        shrinkSize = Math.min(shrinkSize, width - absMinWidth);
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
      var growProportion = availWidth / total;
      for (i = 0; i < columns.length && total < availWidth; i++) {
        c = columns[i];
        if (!c.resizable || c.maxWidth <= c.width) {
          continue;
        }
        var growSize = Math.min(Math.floor(growProportion * c.width) - c.width, (c.maxWidth - c.width) || 1000000) || 1;
        total += growSize;
        widths[i] += growSize;
      }
      if (prevTotal == total) {  // avoid infinite loop
        break;
      }
      prevTotal = total;
    }

    var reRender = false;
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

  void resizeCanvas() {
    if (!initialized) { return; }
    if (options['autoHeight']!=null) {
      viewportH = options['rowHeight'] * getDataLengthIncludingAddNew();
    } else {
      viewportH = getViewportHeight();
    }

    numVisibleRows = (viewportH / options['rowHeight']).ceil();
    viewportW =  int.parse(container.getComputedStyle().width.replaceAll("px", '')) ;//parseFloat($.css($container[0], "width", true));
    if (options['autoHeight']==true) {
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
    columnDefaults['width'] = options['defaultColumnWidth'];

    columnsById = {};

    for (int i = 0; i < columns.length; i++) {
      var tmp = new Map.from(columnDefaults);
      tmp.addAll(columns[i]);
      var m = columns[i] = tmp;
//      var m =   new Map.from(columnDefaults);
//      m.addAll(columns[i]);  ///$.extend({}, columnDefaults, columns[i]);
      columnsById[m['id']] = i;
      if (m['minWidth']!=null && m['width'] < m['minWidth']) {
        m['width'] = m['minWidth'];
      }
      if (m['maxWidth']!=null && m['width'] > m['maxWidth']) {
        m['width'] = m['maxWidth'];
      }
    }

    // validate loaded JavaScript modules against requested options
//    if (options['enableColumnReorder'] && !$.fn.sortable) {
//      throw new Error("SlickGrid's 'enableColumnReorder = true' option requires jquery-ui.sortable module to be loaded");
//    }

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

    $focusSink  = new Element.html("<div tabIndex='0' hideFocus style='position:fixed;width:0;height:0;top:0;left:0;outline:0;'></div>"
        ,treeSanitizer :_treeSanitizer);
    container.append($focusSink );

      $headerScroller = new Element.html("<div class='slick-header ui-state-default' style='overflow:hidden;position:relative;' />"
          ,treeSanitizer :_treeSanitizer);
      container.append($headerScroller);

      $headers = new Element.html("<div class='slick-header-columns' style='left:-1000px' />" ,treeSanitizer :_treeSanitizer);
      $headerScroller.append($headers);
      $headers.style.width=getHeadersWidth().toString() + 'px';
      $headerRowScroller = new Element.html("<div class='slick-headerrow ui-state-default' style='overflow:hidden;position:relative;' />"
          ,treeSanitizer :_treeSanitizer);
      container.append($headerRowScroller);

      $headerRow = new Element.html("<div class='slick-headerrow-columns' />" ,treeSanitizer :_treeSanitizer);

      $headerRowScroller.append($headerRow);

      $headerRowSpacer = new Element.html("<div style='display:block;height:1px;position:absolute;top:0;left:0;'></div>" ,treeSanitizer :_treeSanitizer);
      $headerRowSpacer.style.width= (getCanvasWidth() + scrollbarDimensions['width']).toString() + "px";
      $headerRowScroller.append( $headerRowSpacer);

      $topPanelScroller = new Element.html("<div class='slick-top-panel-scroller ui-state-default' style='overflow:hidden;position:relative;' />"
          ,treeSanitizer :_treeSanitizer);
      container.append($topPanelScroller);
      $topPanel = new Element.html("<div class='slick-top-panel' style='width:10000px' />" ,treeSanitizer :_treeSanitizer);

      $topPanelScroller.append($topPanel);

      if (options['showTopPanel']==null) {
        $topPanelScroller.style.visibility='hidden';
      }

      if (options['showHeaderRow']==null) {
        $headerRowScroller.style.visibility='hidden';
      }

      $viewport = new Element.html("<div class='slick-viewport' style='width:100%;overflow:auto;outline:0;position:relative;'>"
          ,treeSanitizer :_treeSanitizer);
      container.append($viewport);

      $viewport.style.overflowY =  options['autoHeight'] ? "hidden" : "auto";

      $canvas = new Element.html("<div class='grid-canvas' />" ,treeSanitizer :_treeSanitizer);
      $viewport.append($canvas);

      $focusSink2 = $focusSink.clone(true);
      container.append($focusSink2);

      if (options['explicitInitialization']==null) {
        finishInitialization();
      }
    }

  void finishInitialization() {
    if (!initialized) {
      initialized = true;

      viewportW = int.parse(container.style.width.replaceAll('px', ''));
      measureCellPaddingAndBorder();

      // for usability reasons, all text selection in SlickGrid is disabled
      // with the exception of input and textarea elements (selection must
      // be enabled there so that editors work as expected); note that
      // selection in grid cells (grid body) is already unavailable in
      // all browsers except IE
      disableSelection($headers); // disable all text selection in header (including input and textarea)

      if (options['enableTextSelectionOnCells']==null) {
        // disable text selection in grid cells except in input and textarea elements
        // (this is IE-specific, because selectstart event will only fire in IE)
        $viewport.queryAll(".ui").onSelectStart.listen((event){
            if( event.target is InputElement || event.target is TextAreaElement){
              return true;
            } else {
              return false;
            }
        });
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
      $viewport..onClick.listen(handleClick)
      ..onScroll.listen(handleScroll);

//      $viewport
//          .bind("click", handleClick)
//          .bind("scroll", handleScroll);
      $headerScroller..onContextMenu.listen(handleHeaderContextMenu)
      ..onClick.listen(handleHeaderClick);
      $headerScroller.onMouseEnter.matches('.slick-header-column').listen(handleHeaderMouseEnter);
      $headerScroller.onMouseLeave.matches('.slick-header-column').listen(handleHeaderMouseLeave);
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
      ..onClick.listen(handleClick)
      ..onDoubleClick.listen(handleDblClick)
      ..onContextMenu.listen(handleContextMenu)
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

    void setSelectionModel(model) {
      if (selectionModel) {
        selectionModel.onSelectedRangesChanged.unsubscribe(handleSelectedRangesChanged);
        if (selectionModel.destroy) {
          selectionModel.destroy();
        }
      }

      selectionModel = model;
      if (selectionModel) {
        selectionModel.init(this);
        selectionModel.onSelectedRangesChanged.subscribe(handleSelectedRangesChanged);
      }
    }


    getSelectionModel() {
      return selectionModel;
    }

    Element getCanvasNode() {
      return $canvas;
    }

    Map<String,int> measureScrollbar() {
      var $c = new Element.html("<div style='position:absolute; top:-10000px; left:-10000px; width:100px; height:100px; overflow:scroll;'></div>"
          ,treeSanitizer : _treeSanitizer);

      query('body').append($c);
      CssStyleDeclaration style=$c.getComputedStyle();
      Map dim = {
        'width': int.parse(style.width.replaceAll('px','')) -  $c.clientWidth, // $c[0].clientWidth,
        'height': int.parse(style.height.replaceAll('px','')) - $c.clientHeight
      };
      $c.remove();
      return dim;
    }




    String defaultFormatter(int row,int  cell,String value,[ columnDef, dataContext]) {
      if (value == null) {
        return "";
      } else {
        return value.replaceAll(r'&', '&amp;').replaceAll(r'<', '&lt;').replaceAll(r'>', '&gt;');
//        return (value + "").(r'&/g',"&amp;").replace(r'</g',"&lt;").replace(/>/g,"&gt;");
      }
    }


    int getHeadersWidth() {
      int headersWidth = 0;
      for (int i = 0, ii = columns.length; i < ii; i++) {
        var width = columns[i]['width'];
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
        rowWidth += columns[i]['width'];
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
      Element div = new Element.html("<div style='display:none' />",treeSanitizer: _treeSanitizer);

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
          if (!$boundAncestors) {
            $boundAncestors = $viewport;
          } else {
            $boundAncestors = $boundAncestors.append($canvas);  //TODO
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

      Map columnDef = columns[idx];

      Element $header = $headers.children[idx];
      if ($header !=null) {
        if (title != null) {
          columns[idx]['name'] = title;
        }
        if (toolTip != null) {
          columns[idx]['toolTip'] = toolTip;
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
        Map<String,dynamic> m = columns[i];

        Element header = new Element.html("<div class='ui-state-default slick-header-column' />");

        header.append(new Element.html("<span class='slick-column-name'>" + m['name'] + "</span>"));
        header.style.width = m['width'] - headerColumnWidthDiff;
        header.attributes.addAll({
          'id': uid + m['id'],
          'title': m['toolTip'],

        });
        header.dataset.addAll({'column':m});
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

        if (options['enableColumnReorder'] !=null || m['sortable'] != null) {
          header.onMouseEnter.listen(onMouseEnter);
          header.onMouseLeave.listen(onMouseLeave);
//            .on('mouseenter', onMouseEnter)
//            .on('mouseleave', onMouseLeave);
        }

        if (m['sortable']) {
          header.classes.add("slick-header-sortable");
          header.append(new Element.html("<span class='slick-sort-indicator' />"));
        }

        trigger(onHeaderCellRendered, {
          "node": header,
          "column": m
        });

        if (options['showHeaderRow']!=null) {
          Element headerRowCell = new Element.html("<div class='ui-state-default slick-headerrow-column l" + i.toString() + " r" + i.toString() + "'></div>");
          headerRowCell.dataset.addAll({'column':m});
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

      el = new Element.html("<div class='ui-state-default slick-header-column' style='visibility:hidden'>-</div>",treeSanitizer: _treeSanitizer );
      $headers.append(el);
      headerColumnWidthDiff = headerColumnHeightDiff = 0;
      if (el.style.boxSizing != "border-box"  ) {
          headerColumnWidthDiff += int.parse(el.style.borderLeftWidth.replaceAll('px',''),onError:(src)=>0);
          headerColumnWidthDiff += int.parse(el.style.borderRightWidth.replaceAll('px',''),onError:(src)=>0);
          headerColumnWidthDiff += int.parse(el.style.paddingLeft.replaceAll('px',''),onError:(src)=>0);
          headerColumnWidthDiff += int.parse(el.style.paddingRight.replaceAll('px',''),onError:(src)=>0);

          headerColumnHeightDiff += int.parse(el.style.borderTopWidth.replaceAll('px',''),onError:(src)=>0);
          headerColumnHeightDiff += int.parse(el.style.borderBottomWidth.replaceAll('px',''),onError:(src)=>0);
          headerColumnHeightDiff += int.parse(el.style.paddingTop.replaceAll('px',''),onError:(src)=>0);
          headerColumnHeightDiff += int.parse(el.style.paddingBottom.replaceAll('px',''),onError:(src)=>0);
      }
      el.remove();

      var r = new Element.html("<div class='slick-row' />",treeSanitizer: _treeSanitizer );
      $canvas.append(r); //appendTo($canvas);

      el = new Element.html("<div class='slick-cell' id='' style='visibility:hidden'>-</div>",treeSanitizer: _treeSanitizer);
      r.append(el);

      cellWidthDiff = cellHeightDiff = 0;
      if (el.style.boxSizing != "border-box") {
        cellWidthDiff += int.parse(el.style.borderLeftWidth.replaceAll('px',''),onError:(src)=>0);
        cellWidthDiff += int.parse(el.style.borderRightWidth.replaceAll('px',''),onError:(src)=>0);
        cellWidthDiff += int.parse(el.style.paddingLeft.replaceAll('px',''),onError:(src)=>0);
        cellWidthDiff += int.parse(el.style.paddingRight.replaceAll('px',''),onError:(src)=>0);

        cellHeightDiff += int.parse(el.style.borderTopWidth.replaceAll('px',''),onError:(src)=>0);
        cellHeightDiff += int.parse(el.style.borderBottomWidth.replaceAll('px',''),onError:(src)=>0);
        cellHeightDiff += int.parse(el.style.paddingTop.replaceAll('px',''),onError:(src)=>0);
        cellHeightDiff += int.parse(el.style.paddingBottom.replaceAll('px',''),onError:(src)=>0);
      }
      r.remove();

      absoluteColumnMinWidth = math.max(headerColumnWidthDiff, cellWidthDiff);
    }


    /////////////////////////////////////// general
    trigger(core.Event evt, Map<String,dynamic> args, [core.EventData e]) {
      if (e ==null) e =  new core.EventData();
      return evt.notify({'grid': this}, e, this);
    }
    void validateAndEnforceOptions() {
      if (options['autoHeight'] !=null) {
        options['leaveSpaceForNewRows'] = false;
      }
    }

    void updateColumnCaches() {
      // Pre-calculate cell boundaries.
      columnPosLeft = [];
      columnPosRight = [];
      int x = 0;
      for (int i = 0, ii = columns.length; i < ii; i++) {
        columnPosLeft[i] = x;
        columnPosRight[i] = x + columns[i]['width'];
        x += columns[i]['width'];
      }
    }
    setColumns(columnDefinitions) {
      columns = columnDefinitions;

      columnsById = {};
      for (var i = 0; i < columns.length; i++) {
        var m = columns[i] = $.extend({}, columnDefaults, columns[i]);
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

      $viewport.style.overflowY =  options['autoHeight'] !=null ? "hidden" : "auto";
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
      for (var row in rowsCache) {
        removeRowFromCache(row);
      }
    }

    void removeRowFromCache(row) {
      var cacheEntry = rowsCache[row];
      if (!cacheEntry) {
        return;
      }
      $canvas.removeChild(cacheEntry.rowNode);
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
        if (rowsCache[rows[i]]) {
          removeRowFromCache(rows[i]);
        }
      }
    }
    void invalidateRow(row) {
      invalidateRows([row]);
    }

    void updateCell(row, cell) {
      var cellNode = getCellNode(row, cell);
      if (!cellNode) {
        return;
      }

      var m = columns[cell], d = getDataItem(row);
      if (currentEditor && activeRow == row && activeCell == cell) {
        currentEditor.loadValue(d);
      } else {
        cellNode.innerHTML = d ? getFormatter(row, m)(row, cell, getDataItemValueForColumn(d, m), m, d) : "";
        invalidatePostProcessingResults(row);
      }
    }

    void updateRow(row) {
      var cacheEntry = rowsCache[row];
      if (!cacheEntry) {
        return;
      }

      ensureCellNodesInRowsCache(row);

      var d = getDataItem(row);

      for (var columnIdx in cacheEntry.cellNodesByColumnIdx) {
        if (!cacheEntry.cellNodesByColumnIdx.hasOwnProperty(columnIdx)) {
          continue;
        }

        columnIdx = columnIdx | 0;
        var m = columns[columnIdx],
            node = cacheEntry.cellNodesByColumnIdx[columnIdx];

        if (row == activeRow && columnIdx == activeCell && currentEditor) {
          currentEditor.loadValue(d);
        } else if (d) {
          node.innerHTML = getFormatter(row, m)(row, columnIdx, getDataItemValueForColumn(d, m), m, d);
        } else {
          node.innerHTML = "";
        }
      }

      invalidatePostProcessingResults(row);
    }




    int getViewportHeight() {
      CssStyleDeclaration csd = container.getComputedStyle();
      int height=int.parse(csd.height.replaceAll('px', ''));
      int paddingTop = int.parse(csd.paddingTop.replaceAll('px', ''));
      int paddingBottom = int.parse(csd.paddingBottom.replaceAll('px', ''));
      int headerScrollerHeight = int.parse($headerScroller.getComputedStyle().height.replaceAll('px', ''));
      int vboxDelta =  getVBoxDelta($headerScroller) ;
      int topPanelHeight = options['showTopPanel'] != null ?  options['topPanelHeight'] + getVBoxDelta($topPanelScroller) : 0;
      int headerRowHeight= options['showHeaderRow'] !=null ?  options['headerRowHeight'] + getVBoxDelta($headerRowScroller) : 0;
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
    // IEditor implementation for the editor lock

    commitCurrentEdit() {
      var item = getDataItem(activeRow);
      var column = columns[activeCell];

      if (currentEditor) {
        if (currentEditor.isValueChanged()) {
          var validationResults = currentEditor.validate();

          if (validationResults.valid) {
            if (activeRow < getDataLength()) {
              var editCommand = {
                row: activeRow,
                cell: activeCell,
                editor: currentEditor,
                serializedValue: currentEditor.serializeValue(),
                prevSerializedValue: serializedEditorValue,
                execute:  () {
                  this.editor.applyValue(item, this.serializedValue);
                  updateRow(this.row);
                },
                undo:  () {
                  this.editor.applyValue(item, this.prevSerializedValue);
                  updateRow(this.row);
                }
              };

              if (options.editCommandHandler) {
                makeActiveCellNormal();
                options.editCommandHandler(item, column, editCommand);
              } else {
                editCommand.execute();
                makeActiveCellNormal();
              }

              trigger(self.onCellChange, {
                'row': activeRow,
                'cell': activeCell,
                'item': item
              });
            } else {
              var newItem = {};
              currentEditor.applyValue(newItem, currentEditor.serializeValue());
              makeActiveCellNormal();
              trigger(self.onAddNewRow, {item: newItem, column: column});
            }

            // check whether the lock has been re-acquired by event handlers
            return !getEditorLock().isActive();
          } else {
            // Re-add the CSS class to trigger transitions, if any.
            $(activeCellNode).removeClass("invalid");
            $(activeCellNode).width();  // force layout
            $(activeCellNode).addClass("invalid");

            trigger(self.onValidationError, {
              editor: currentEditor,
              cellNode: activeCellNode,
              validationResults: validationResults,
              row: activeRow,
              cell: activeCell,
              column: column
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
      return getDataLength() + (options['enableAddRow'] !=null ? 1 : 0);
    }
    List getData() {
      return data;
    }

    getDataItem(i) {
        return data[i];
    }

    getTopPanel() {
      return $topPanel;
    }


}




