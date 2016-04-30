library slick.selection;
import 'dart:html';
import 'slick_core.dart' as core;
import 'slick_grid.dart';
//import 'dart:collection';
import 'dart:math' as math;
import 'package:logging/logging.dart';
import 'slick_column.dart' show CheckboxSelectColumn;
Logger _log = new Logger('cj.grid.select');


void clearTextSelections() {
  window.getSelection().removeAllRanges();
  var activeElement = document.activeElement;
  if (activeElement is TextAreaElement) {
    activeElement.setSelectionRange(0, 0);
  } else if (activeElement is InputElement) {
    activeElement.setSelectionRange(0, 0);
  }
}

class CellRangeDecorator{
  Element _elem;
  Map options;
  SlickGrid _grid;
  Map _defaults = {
                   'selectionCssClass': 'slick-range-decorator',
                   'selectionCss': {
                     "zIndex": "9999",
                     "border": "2px dashed red"
                   }
  };
  CellRangeDecorator(SlickGrid sg){
    _grid=sg;
    options = new Map.from(_defaults);
    options.addAll(sg.options);
  }
  Element show(core.Range range) {
    if (_elem!=null) {
      _elem = new DivElement();
      _elem.style.zIndex= options['selectionCss']['zIndex'];
      _elem.style.zIndex= options['selectionCss']['border'];
      _elem.classes.add(options['selectionCssClass']);
      _grid.getCanvasNode().children.add(_elem);
    }
      Map from = _grid.getCellNodeBox(range.fromRow, range.fromCell);
      var to = _grid.getCellNodeBox(range.toRow, range.toCell);
      _elem.style..top=  from['top'] - 1
                 ..left =from['left'] - 1
                 ..height=  to['bottom'] - from['top'] - 2
                 ..width= to['right'] - from['left'] - 2;
      return _elem;
    }

  hide() {
    if (_elem!=null) {
      _elem.remove();
      _elem = null;
    }
  }
}


class CellRangeSelector extends IPlugin{
  core.Event onBeforeCellRangeSelected = new core.Event();
  core.Event onCellRangeSelected = new core.Event();
  CellRangeSelector(options){

  }
  Map options;
  SlickGrid _grid;
  Element $activeCanvas;
  bool _dragging;
  var _decorator;
//  v/ar _self = this;
  var _handler = new core.EventHandler();

  // Frozen row & column variables
   int _rowOffset;
   int _columnOffset;
   bool _isRightCanvas;
   bool _isBottomCanvas;


  var _defaults = {
                   'selectionCss': {
                     "border": "2px dashed blue"
                   }
  };

  init(SlickGrid grid) {
    options = new Map.from(_defaults);
    options.addAll(grid.options);
    _decorator = new CellRangeDecorator(grid);
    _grid = grid;

   // _canvas = _grid.getCanvasNode();
    _handler
      ..subscribe(_grid.onDragInit, handleDragInit)
      ..subscribe(_grid.onDragStart, handleDragStart)
      ..subscribe(_grid.onDrag, handleDrag)
      ..subscribe(_grid.onDragEnd, handleDragEnd);
    }

    destroy() {
      _handler.unsubscribeAll();
    }
    handleDragInit(e, dd) {
      $activeCanvas = _grid.getActiveCanvasNode( e );

       //var c = $activeCanvas.offset();

       _rowOffset = 0;
       _columnOffset = 0;
       _isBottomCanvas = $activeCanvas.classes.contains( 'grid-canvas-bottom' );

       if ( _grid.gridOptions.frozenRow > -1 && _isBottomCanvas ) {
           _rowOffset = ( _grid.gridOptions.frozenBottom )
               ? $activeCanvas.contentEdge.height
               : _grid.$canvas.firstWhere((e)=> e.classes.contains('grid-canvas-top')).contentEdge.height;
       }

       _isRightCanvas = $activeCanvas.classes.contains( 'grid-canvas-right' );

       if ( _grid.gridOptions.frozenColumn > -1 && _isRightCanvas ) {
           _columnOffset =
               _grid.$canvas.firstWhere((e)=> e.classes.contains('grid-canvas-left')).contentEdge.width;
//               $('.grid-canvas-left').width();
       }
      // prevent the grid from cancelling drag'n'drop by default
      e.stopImmediatePropagation();
    }
    handleDragStart(e, dd) {
      Map cell = _grid.getCellFromEvent(e);
      if (onBeforeCellRangeSelected.notify(cell) != false) {
        if (_grid.canCellBeSelected(cell['row'], cell['cell'])) {
          _dragging = true;
          e.stopImmediatePropagation();
        }
      }
      if (!_dragging) {
        return null;
      }

      _grid.setFocus(); //no _grid.focus, may from drag plugin

//      var start = _grid.getCellFromPoint(
//          dd.startX - _canvas.offset.left,
//          dd.startY - _canvas.offset.top);

      dd.range = {'start': cell, 'end': {}};

      return _decorator.show(new core.Range(cell['row'], cell['cell']));
    }

    handleDrag(e, dd) {
      if (!_dragging) {
        return;
      }
      e.stopImmediatePropagation();

      var end = _grid.getCellFromPoint(
          e.pageX - $activeCanvas.offset.left,
          e.pageY - $activeCanvas.offset.top);

      if (!_grid.canCellBeSelected(end['row'], end['cell'])) {
        return;
      }

      dd.range.end = end;
      _decorator.show(new core.Range(dd.range.start.row, dd.range.start.cell, end['row'], end['cell']));
    }
    handleDragEnd(e, dd) {
      if (!_dragging) {
        return;
      }

      _dragging = false;
      e.stopImmediatePropagation();

      _decorator.hide();
      onCellRangeSelected.notify({
        'range': new core.Range(
            dd.range.start.row,
            dd.range.start.cell,
            dd.range.end.row,
            dd.range.end.cell
        )
      });
    }

}
abstract class SelectionModel{
  init(SlickGrid grid);
  destroy();
  void setSelectedRanges(List<core.Range> ranges);
  List<core.Range> getSelectedRanges();
  core.Event onSelectedRangesChanged = new core.Event();
}
/**
 * Cell selection
 */
class CellSelectionModel extends SelectionModel{
     CellSelectionModel([Map options= const {}]){
       _options = new Map.from(options);
       _options['selectActiveCell']=true;
     }
    SlickGrid _grid;
    Element _canvas;
    List<core.Range> _ranges = [];
    var _selector = new CellRangeSelector({
      "selectionCss": {
        "border": "2px solid black"
      }
    });
    var _options;
    var _defaults = {  'selectActiveCell': true };


    init(SlickGrid grid) {

      _grid = grid;
      _canvas = _grid.getActiveCanvasNode();
      _grid.onActiveCellChanged.subscribe(_handleActiveCellChange);
      _grid.onKeyDown.subscribe(_handleKeyDown);
      grid.registerPlugin(_selector);
      _selector.onCellRangeSelected.subscribe(_handleCellRangeSelected);
      _selector.onBeforeCellRangeSelected.subscribe(_handleBeforeCellRangeSelected);
    }

    destroy() {
      _grid.onActiveCellChanged.unsubscribe(_handleActiveCellChange);
      _grid.onKeyDown.unsubscribe(_handleKeyDown);
      _selector.onCellRangeSelected.unsubscribe(_handleCellRangeSelected);
      _selector.onBeforeCellRangeSelected.unsubscribe(_handleBeforeCellRangeSelected);
      _grid.unregisterPlugin(_selector);
    }

    List<core.Range> _removeInvalidRanges(List<core.Range> ranges) {
      List<core.Range> result = [];

      for (var i = 0; i < ranges.length; i++) {
        core.Range r = ranges[i];
        if (_grid.canCellBeSelected(r.fromRow, r.fromCell) && _grid.canCellBeSelected(r.toRow, r.toCell)) {
          result.add(r);
        }
      }

      return result;
    }

    void setSelectedRanges(List<core.Range> ranges) {
      _ranges = _removeInvalidRanges(ranges);
      onSelectedRangesChanged.notify(_ranges);
    }

    List<core.Range> getSelectedRanges() {
      return _ranges;
    }

    _handleBeforeCellRangeSelected(core.EventData e, args) {
      if (_grid.getEditorLock().isActive()) {
        e.stopPropagation();
        return false;
      }
    }

    _handleCellRangeSelected(core.EventData e, args) {
      setSelectedRanges(args.range);
    }
  /**
   * args: object
        cell: 0
        grid: SlickGrid
       row: 6
   */
    _handleActiveCellChange(core.EventData e, Map<String,dynamic>args) {
      if (_options['selectActiveCell'] && args['row'] != null && args['cell'] != null) {
         setSelectedRanges([new core.Range(args['row'], args['cell'])]);
      }
    }

    _handleKeyDown(core.EventData evtData,[args]) {
      KeyboardEvent e = evtData.domEvent;
      /***
       * byte codes
       * 37 left
       * 38 up
       * 39 right
       * 40 down
       */
      List<core.Range> ranges;
      core.Range last;
      Map<String,int> active = _grid.getActiveCell();

      if ( active !=null && e.shiftKey && !e.ctrlKey && !e.altKey &&
          (e.which == 37 || e.which == 39 || e.which == 38 || e.which == 40) ) {

        ranges = getSelectedRanges();
        if (ranges.length==0)
         ranges.add(new core.Range(active['row'], active['cell']));

        // keyboard can work with last range only
        last = ranges.removeLast();

        // can't handle selection out of active cell
        if (!last.contains(active['row'], active['cell']))
          last = new core.Range(active['row'], active['cell']);

        var dRow = last.toRow - last.fromRow,
            dCell = last.toCell - last.fromCell,
            // walking direction
            dirRow = active['row'] == last.fromRow ? 1 : -1,
            dirCell = active['cell'] == last.fromCell ? 1 : -1;

        if (e.which == 37) {
          dCell -= dirCell;
        } else if (e.which == 39) {
          dCell += dirCell ;
        } else if (e.which == 38) {
          dRow -= dirRow;
        } else if (e.which == 40) {
          dRow += dirRow;
        }

        // define new selection range
        var new_last = new core.Range(active['row'], active['cell'], active['row'] + dirRow*dRow, active['cell'] + dirCell*dCell);
        if (_removeInvalidRanges([new_last]).length>0) {
          ranges.add(new_last);
          int viewRow = dirRow > 0 ? new_last.toRow : new_last.fromRow;
          int viewCell = dirCell > 0 ? new_last.toCell : new_last.fromCell;
         _grid.scrollRowIntoView(viewRow,false);
         _grid.scrollCellIntoView(viewRow, viewCell,false);
        }
        else
          ranges.add(last);

        setSelectedRanges(ranges);

        e.preventDefault();
        e.stopPropagation();
      }
    }
   }



class RowSelectionModel extends SelectionModel{
  SlickGrid _grid;
  var _ranges = <core.Range>[];
  var _handler = new core.EventHandler();
  bool _inHandler = false;
  Map _options;
  Map _defaults = {
                   'selectActiveRow': true
  };
  RowSelectionModel(Map options){
    _options = new Map.from(_defaults);
    _options.addAll(options);
  }
  init(grid) {

    _grid = grid;
    _handler.subscribe(_grid.onActiveCellChanged,   handleActiveCellChange);
    _handler.subscribe(_grid.onKeyDown, handleKeyDown);
    _handler.subscribe(_grid.onClick,   handleClick);
  }

  destroy() {
    _handler.unsubscribeAll();
  }

//  wrapHandler(Function handler) {
//    return () {
//        if (!_inHandler) {
//          _inHandler = true;
//          handler.apply(this, arguments);
//          _inHandler = false;
//        }
//    };
//  }



  List<int> rangesToRows(ranges) {
    var rows = <int>[];
    for (int i = 0; i < ranges.length; i++) {
      for (int j = ranges[i].fromRow; j <= ranges[i].toRow; j++) {
        rows.add(j);
      }
    }
    return rows;
  }

  List<core.Range> rowsToRanges(rows) {
    var ranges = <core.Range>[];
    int lastCell = _grid.columns.length - 1;
    for (int i = 0; i < rows.length; i++) {
      ranges.add(new core.Range(rows[i], 0, rows[i], lastCell));
    }
    return ranges;
  }

  List<int> getRowsRange(int from,int to) {
    int i;
    var rows = <int>[];
    for (i = from; i <= to; i++) {
      rows.add(i);
    }
    for (i = to; i < from; i++) {
      rows.add(i);
    }
    return rows;
  }

  List getSelectedRows() {
    return rangesToRows(_ranges);
  }

  void setSelectedRows(rows) {
    setSelectedRanges(rowsToRanges(rows));
  }

  void setSelectedRanges(ranges) {
    _ranges = ranges;
    onSelectedRangesChanged.notify(_ranges);
  }

  getSelectedRanges() {
    return _ranges;
  }

  handleActiveCellChange(e, Map<String,dynamic>  data) {
    if (_options['selectActiveRow'] && data['row'] != null) {
      setSelectedRanges([new core.Range(data['row'], 0, data['row'], _grid.columns.length - 1)]);
    }
  }
  //handleKeyDown(KeyboardEvent e,[Map<String,dynamic> args]) {
  handleKeyDown(core.EventData ed,[Map<String,dynamic> args]) {
    KeyboardEvent e=ed.domEvent;
    Map<String,int> activeRow = _grid.getActiveCell();
    if (activeRow!=null && e.shiftKey && !e.ctrlKey && !e.altKey && !e.metaKey && (e.which == 38 || e.which == 40)) {
      var selectedRows = getSelectedRows();
      selectedRows.sort((x, y) {
        return x - y;
      });

      if (selectedRows.length==0) {
        selectedRows = [activeRow['row']];
      }

      var top = selectedRows[0];
      var bottom = selectedRows[selectedRows.length - 1];
      var active;

      if (e.which == 40) {
        active = activeRow['row'] < bottom || top == bottom ? ++bottom : ++top;
      } else {
        active = activeRow['row'] < bottom ? --bottom : --top;
      }

      if (active >= 0 && active < _grid.getDataLength()) {
        _grid.scrollRowIntoView(active);
        _ranges = rowsToRanges(getRowsRange(top, bottom));
        setSelectedRanges(_ranges);
      }

      e.preventDefault();
      e.stopPropagation();
    }
  }
  /**
   * args: {row: 0, cell: 0, grid: Instance of 'SlickGrid'}
   */
  bool handleClick(var e,[Map<String,dynamic>  args]) {
    core.EventData evt=null;
    if (e is MouseEvent) {
      evt = new core.EventData.fromDom(e);
    }else{
      evt=e;
    }
    _log.finest('handle from:' + this.runtimeType.toString() +' ' + evt.target.toString());
    MouseEvent domEvt=evt.domEvent;

    Map<String,int> cell = _grid.getCellFromEvent(evt);
    if (cell==null || !_grid.canCellBeActive(cell['row'], cell['cell'])) {
      return false;
    }

    List selection = rangesToRows(_ranges);
    int  idx=selection.indexOf(cell['row']);

    if (!domEvt.ctrlKey && !domEvt.shiftKey && !domEvt.metaKey) {
      return false;
    }
    else if (_grid.gridOptions.multiSelect) {
      if (idx == -1 && (domEvt.ctrlKey || domEvt.metaKey)) {
        selection.add(cell['row']);
        _grid.setActiveCell(cell['row'], cell['cell']);
      } else if (idx != -1 && (domEvt.ctrlKey || domEvt.metaKey)) {
        selection.retainWhere((item)=> item != cell['row']);
//        selection = $.grep(selection, (o, i) {
//          return (o != cell['row']);
//        });
        _grid.setActiveCell(cell['row'], cell['cell']);
      } else if (selection.length>0 && domEvt.shiftKey) {
        int last = selection.last;
        int from = math.min(cell['row'], last);
        int to = math.max(cell['row'], last);
        selection = [];
        for (int i = from; i <= to; i++) {
          if (i != last) {
            selection.add(i);
          }
        }
        selection.add(last);
        _grid.setActiveCell(cell['row'], cell['cell']);
      }
      evt.stopImmediatePropagation();
    }

    _ranges = rowsToRanges(selection);
    setSelectedRanges(_ranges);
    if(!(_grid.columns[args['cell']] is CheckboxSelectColumn)){

      evt.stopImmediatePropagation();
    }

    return true;
  }


}
