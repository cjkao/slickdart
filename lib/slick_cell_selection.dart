library slick.selection.cell;

import 'dart:html';
import 'slick_core.dart' as core;
import 'slick_grid.dart';
import 'package:logging/logging.dart';
import 'slick_column.dart' show CheckboxSelectColumn;
import 'dart:async';
import 'slick_selectionmodel.dart' show SelectionModel;
Logger _log = new Logger('cj.row.select');
Element _activeCanvas;

///
///  look and feel over active selection range
///
///
class CellRangeDecorator {
  Element _elem;
  Map options;
  SlickGrid _grid;
  Map _defaults = {
    'selectionCssClass': 'slick-range-decorator',
    'selectionCss': {"zIndex": "9999", "border": "1px solid blue"}
  };
  CellRangeDecorator(SlickGrid sg) {
    _grid = sg;
    options = new Map.from(_defaults);
    options.addAll(sg.options);
  }
  Element show(core.Range range) {
    if (_elem != null && !_activeCanvas.children.contains(_elem)) _activeCanvas.children.add(_elem);
    if (_elem == null) {
      _elem = new DivElement();
      _elem.style.zIndex = options['selectionCss']['zIndex'];
      _elem.style.border = options['selectionCss']['border'];
      _elem.style.backgroundColor = 'rgba(160,195,255,0.1)';
      _elem.classes.add(options['selectionCssClass']);
      _activeCanvas.children.add(_elem);
      _elem.style.position = 'absolute';
    }
    Map from = _grid.getCellNodeBox(range.fromRow, range.fromCell);
    var to = _grid.getCellNodeBox(range.toRow, range.toCell);
    _elem.style
      ..pointerEvents = 'none'
      ..top = "${from['top'] - 1}px"
      ..left = "${from['left'] - 1}px"
      ..height = "${to['bottom'] - from['top']}px"
      ..width = "${to['right'] - from['left']-1}px";
    return _elem;
  }

  hide() {
    if (_elem != null) {
      _elem.remove();
      _elem = null;
    }
  }
}
///
/// handle mouse event from canvas to compute range
/// new range will be dispatched to onCellRangeSelected
///
class CellRangeSelector extends IPlugin {
  core.Event onBeforeCellRangeSelected = new core.Event();
  core.Event onCellRangeSelected = new core.Event();
  CellRangeSelector(options) {}
  Map options;
  SlickGrid _grid;
//  Element $activeCanvas;
  //bool _dragging;
  CellRangeDecorator _decorator;
  core.Range range = new core.Range(0, 0);
  core.Range newRange = new core.Range(0, 0);
//  v/ar _self = this;
  var _handler = new core.EventHandler();

  var _defaults = {
    'selectionCss': {"border": "2px dashed blue"}
  };

  init(SlickGrid grid) {
    options = new Map.from(_defaults);
    options.addAll(grid.options);
    _decorator = new CellRangeDecorator(grid);
    _grid = grid;
    _handler..subscribe(_grid.onMouseDown, handleDownOnCanvas);
  }

  StreamSubscription<MouseEvent> moveSubscribe;
  StreamSubscription<MouseEvent> upSubscribe;
  //dd callback
  handleDownOnCanvas(core.EventData ed, [Map<String, int> parm]) {
    moveSubscribe?.cancel();
    upSubscribe?.cancel();
    moveSubscribe = null;
    upSubscribe = null;
    Event event = ed.domEvent;
    _activeCanvas = _grid.getActiveCanvasNode(event);
    _log.finest('dragging $parm');
    moveSubscribe = _activeCanvas.onMouseMove.listen((e) {
      Map<String, int> to = _grid.getCellFromEvent(new core.EventData.fromDom(e));
      if (to == null) return;
      int nrow = to['row'];
      int ncell = to['cell'];
      if (nrow < range.fromRow) {
        newRange.fromRow = nrow;
        newRange.toRow = range.fromRow;
      } else {
        newRange.fromRow = range.fromRow;
        newRange.toRow = nrow;
      }
      if (ncell < range.fromCell) {
        newRange.fromCell = ncell;
        newRange.toCell = range.fromCell;
      } else {
        newRange.fromCell = range.fromCell;
        newRange.toCell = ncell;
      }
      _decorator.show(newRange);
    });
    upSubscribe = _activeCanvas.onMouseUp.listen((e) {
      _log.finest('up $e');
      moveSubscribe.pause();
      onCellRangeSelected.notify({'range': newRange});
    });
    if (parm.containsKey('row')) {
      range
        ..fromRow = parm['row']
        ..fromCell = parm['cell']
        ..toRow = parm['row']
        ..toCell = parm['cell'];
    } else {
      //should not have untarget event
      assert(false);
    }
    _decorator.show(range);
  }

  destroy() {
    _handler.unsubscribeAll();
  }

//  handleDrag(e, dd) {
//    if (!_dragging) {
//      return;
//    }
//    e.stopImmediatePropagation();
//
//    var end = _grid.getCellFromPoint(e.pageX - $activeCanvas.offset.left, e.pageY - $activeCanvas.offset.top);
//
//    if (!_grid.canCellBeSelected(end['row'], end['cell'])) {
//      return;
//    }
//
//    dd.range.end = end;
//    _decorator.show(new core.Range(dd.range.start.row, dd.range.start.cell, end['row'], end['cell']));
//  }
//
//  handleDragEnd(e, dd) {
//    if (!_dragging) {
//      return;
//    }
//
//    _dragging = false;
//    e.stopImmediatePropagation();
//
//    _decorator.hide();
//    onCellRangeSelected.notify(
//        {'range': new core.Range(dd.range.start.row, dd.range.start.cell, dd.range.end.row, dd.range.end.cell)});
//  }
}

//
// Cell selection
//
class CellSelectionModel extends SelectionModel {
  CellSelectionModel([Map options = const {}]) {
    _options = new Map.from(options);
    _options['selectActiveCell'] = true;
  }
  SlickGrid _grid;
  DivElement _canvas;
  List<core.Range> _ranges = [];
  var _selector = new CellRangeSelector({
    "selectionCss": {"border": "2px solid black"}
  });
  var _options;
  var _defaults = {'selectActiveCell': true};

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
    setSelectedRanges([args['range']]);
  }

  /**
   * args: object
        cell: 0
        grid: SlickGrid
       row: 6
   */
  _handleActiveCellChange(core.EventData e, Map<String, dynamic> args) {
    if (_options['selectActiveCell'] && args['row'] != null && args['cell'] != null) {
      setSelectedRanges([new core.Range(args['row'], args['cell'])]);
    }
  }

  _handleKeyDown(core.EventData evtData, [args]) {
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
    Map<String, int> active = _grid.getActiveCell();

    if (active != null &&
        e.shiftKey &&
        !e.ctrlKey &&
        !e.altKey &&
        (e.which == 37 || e.which == 39 || e.which == 38 || e.which == 40)) {
      ranges = getSelectedRanges();
      if (ranges.length == 0) ranges.add(new core.Range(active['row'], active['cell']));

      // keyboard can work with last range only
      last = ranges.removeLast();

      // can't handle selection out of active cell
      if (!last.contains(active['row'], active['cell'])) last = new core.Range(active['row'], active['cell']);

      var dRow = last.toRow - last.fromRow,
          dCell = last.toCell - last.fromCell,
          // walking direction
          dirRow = active['row'] == last.fromRow ? 1 : -1,
          dirCell = active['cell'] == last.fromCell ? 1 : -1;

      if (e.which == 37) {
        dCell -= dirCell;
      } else if (e.which == 39) {
        dCell += dirCell;
      } else if (e.which == 38) {
        dRow -= dirRow;
      } else if (e.which == 40) {
        dRow += dirRow;
      }

      // define new selection range
      var new_last = new core.Range(
          active['row'], active['cell'], active['row'] + dirRow * dRow, active['cell'] + dirCell * dCell);
      if (_removeInvalidRanges([new_last]).length > 0) {
        ranges.add(new_last);
        int viewRow = dirRow > 0 ? new_last.toRow : new_last.fromRow;
        int viewCell = dirCell > 0 ? new_last.toCell : new_last.fromCell;
        _grid.scrollRowIntoView(viewRow, false);
        _grid.scrollCellIntoView(viewRow, viewCell, false);
      } else
        ranges.add(last);

      setSelectedRanges(ranges);

      e.preventDefault();
      e.stopPropagation();
    }
  }
}
