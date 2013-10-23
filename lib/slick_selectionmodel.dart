library slick.selection;
import 'dart:html';
import 'slick_core.dart' as core;
import 'slick_grid.dart';
import 'dart:collection';
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
    if (!_elem) {
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


class CellRangeSelector{
  core.Event onBeforeCellRangeSelected = new core.Event();
  core.Event onCellRangeSelected = new core.Event();
  CellRangeSelector(options){

  }
  Map options;
  SlickGrid _grid;
  Element _canvas;
  var _dragging;
  var _decorator;
//  v/ar _self = this;
  var _handler = new core.EventHandler();
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
    _canvas = _grid.getCanvasNode();
    _handler
    .subscribe(_grid.onDragInit, handleDragInit)
      .subscribe(_grid.onDragStart, handleDragStart)
        .subscribe(_grid.onDrag, handleDrag)
        .subscribe(_grid.onDragEnd, handleDragEnd);
    }

    destroy() {
      _handler.unsubscribeAll();
    }
    handleDragInit(e, dd) {
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
        return;
      }

      _grid.setFocus(); //no _grid.focus, may from drag plugin

      var start = _grid.getCellFromPoint(
          dd.startX - _canvas.offset.left,
          dd.startY - _canvas.offset.top);

      dd.range = {'start': start, 'end': {}};

      return _decorator.show(new core.Range(start['row'], start['cell']));
    }

    handleDrag(e, dd) {
      if (!_dragging) {
        return;
      }
      e.stopImmediatePropagation();

      var end = _grid.getCellFromPoint(
          e.pageX - _canvas.offset.left,
          e.pageY - _canvas.offset.top);

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
  void setSelectedRanges(List ranges);
  List getSelectedRanges();
}
class CellSelectionModel extends SelectionModel{
   core.Event onSelectedRangesChanged = new core.Event();

     CellSelectionModel(Map options){
       _options = new Map.from(options);
       _options['selectActiveCell']=true;

     }
    SlickGrid _grid;
    Element _canvas;
    List _ranges = [];
    var _selector = new CellRangeSelector({
      "selectionCss": {
        "border": "2px solid black"
      }
    });
    var _options;
    var _defaults = {  'selectActiveCell': true };


    init(SlickGrid grid) {

      _grid = grid;
      _canvas = _grid.getCanvasNode();
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

    List _removeInvalidRanges(List ranges) {
      var result = [];

      for (var i = 0; i < ranges.length; i++) {
        var r = ranges[i];
        if (_grid.canCellBeSelected(r.fromRow, r.fromCell) && _grid.canCellBeSelected(r.toRow, r.toCell)) {
          result.add(r);
        }
      }

      return result;
    }

    void setSelectedRanges(List ranges) {
      _ranges = _removeInvalidRanges(ranges);
      onSelectedRangesChanged.notify(_ranges);
    }

    List getSelectedRanges() {
      return _ranges;
    }

    _handleBeforeCellRangeSelected(e, args) {
      if (_grid.getEditorLock().isActive()) {
        e.stopPropagation();
        return false;
      }
    }

    _handleCellRangeSelected(e, args) {
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

    _handleKeyDown(KeyboardEvent e,[args]) {
      /***
       * byte codes
       * 37 left
       * 38 up
       * 39 right
       * 40 down
       */
      List ranges;
      var last;
      Map<String,int> active = _grid.getActiveCell();

      if ( active !=null && e.shiftKey && !e.ctrlKey && !e.altKey &&
          (e.which == 37 || e.which == 39 || e.which == 38 || e.which == 40) ) {

        ranges = getSelectedRanges();
        if (ranges.length>0)
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

