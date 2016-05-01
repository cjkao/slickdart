library slick.selection;

import 'dart:html';
import 'slick_core.dart' as core;
import 'slick_grid.dart';
import 'dart:math' as math;
import 'package:logging/logging.dart';
import 'slick_column.dart' show CheckboxSelectColumn;
import 'dart:async';

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

abstract class SelectionModel {
  init(SlickGrid grid);
  destroy();
  void setSelectedRanges(List<core.Range> ranges);
  List<core.Range> getSelectedRanges();
  core.Event onSelectedRangesChanged = new core.Event();
}

class RowSelectionModel extends SelectionModel {
  SlickGrid _grid;
  var _ranges = <core.Range>[];
  var _handler = new core.EventHandler();
  bool _inHandler = false;
  Map _options;
  Map _defaults = {'selectActiveRow': true};
  RowSelectionModel(Map options) {
    _options = new Map.from(_defaults);
    _options.addAll(options);
  }
  init(grid) {
    _grid = grid;
    _handler.subscribe(_grid.onActiveCellChanged, handleActiveCellChange);
    _handler.subscribe(_grid.onKeyDown, handleKeyDown);
    _handler.subscribe(_grid.onClick, handleClick);
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

  List<int> getRowsRange(int from, int to) {
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

  handleActiveCellChange(core.EventData e, Map<String, dynamic> data) {
    if (_options['selectActiveRow'] && data['row'] != null) {
      setSelectedRanges([new core.Range(data['row'], 0, data['row'], _grid.columns.length - 1)]);
    }
  }

  //handleKeyDown(KeyboardEvent e,[Map<String,dynamic> args]) {
  handleKeyDown(core.EventData ed, [Map<String, dynamic> args]) {
    KeyboardEvent e = ed.domEvent;
    Map<String, int> activeRow = _grid.getActiveCell();
    if (activeRow != null && e.shiftKey && !e.ctrlKey && !e.altKey && !e.metaKey && (e.which == 38 || e.which == 40)) {
      var selectedRows = getSelectedRows();
      selectedRows.sort((x, y) {
        return x - y;
      });

      if (selectedRows.length == 0) {
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
  bool handleClick(core.EventData evt, [Map<String, dynamic> args]) {
//    core.EventData evt = null;
    //if (e is MouseEvent) {
    //  evt = new core.EventData.fromDom(e);
    //}else{
    //  evt=e;
    //}
    _log.finest('handle from:' + this.runtimeType.toString() + ' ' + evt.target.toString());
    MouseEvent domEvt = evt.domEvent;

    Map<String, int> cell = _grid.getCellFromEvent(evt);
    if (cell == null || !_grid.canCellBeActive(cell['row'], cell['cell'])) {
      return false;
    }

    List selection = rangesToRows(_ranges);
    int idx = selection.indexOf(cell['row']);

    if (!domEvt.ctrlKey && !domEvt.shiftKey && !domEvt.metaKey) {
      return false;
    } else if (_grid.gridOptions.multiSelect) {
      if (idx == -1 && (domEvt.ctrlKey || domEvt.metaKey)) {
        selection.add(cell['row']);
        _grid.setActiveCell(cell['row'], cell['cell']);
      } else if (idx != -1 && (domEvt.ctrlKey || domEvt.metaKey)) {
        selection.retainWhere((item) => item != cell['row']);
//        selection = $.grep(selection, (o, i) {
//          return (o != cell['row']);
//        });
        _grid.setActiveCell(cell['row'], cell['cell']);
      } else if (selection.length > 0 && domEvt.shiftKey) {
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
    if (!(_grid.columns[args['cell']] is CheckboxSelectColumn)) {
      evt.stopImmediatePropagation();
    }

    return true;
  }
}
