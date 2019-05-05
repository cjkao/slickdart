library slick.column.checkbox;

import "slick_column.dart";
import 'dart:html';
//import 'slick.dart';
import 'slick_grid.dart';
import 'slick_core.dart' as core;
import 'package:logging/logging.dart';

Logger _log = new Logger('slick.column.v2');

///
///  Virtual column that add to first column, including header as checkbox column
///
class CheckboxSelectColumnV2 extends Column with IPlugin {
  TFormatter checkboxSelectionFormatter() =>
      (int row, int cell, value, Column columnDef, dataContext) {
        if (dataContext != null) {
          return _selectedRowsLookup.containsKey(row)
              ? """ <label class="cb"><input type="checkbox" checked="checked"><span class="checkmark"></span></label> """
              : """ <label class="cb"><input type="checkbox" ><span class="checkmark"></span></label>""";
        }
        return "";
      };
  // Map<String, dynamic> src = {};
  Map _options;
  Map<String, Object> _defaults = {
    'columnId': "_checkbox_selector",
    'cssClass': null,
    'toolTip': "Select/Deselect All",
    'width': 30,
    'name': LabelElement()
      ..classes.add("cb")
      ..children.add(InputElement()..type = "checkbox")
      ..children.add(SpanElement()
        ..classes.add("checkmark")) //'<input type="checkbox"></input>',
  };
  SlickGrid _grid;
  var _handler = new core.EventHandler();

  Map<int, bool> _selectedRowsLookup = {};
  /**
   * change for shadow dom element initialize
   */
  init(SlickGrid grid) {
    _grid = grid;
    _handler
        .subscribe(_grid.onSelectedRowsChanged, handleSelectedRowsChanged)
        .subscribe(_grid.onClick, handleClick)
        .subscribe(_grid.onHeaderClick, handleHeaderClick)
        .subscribe(_grid.onKeyDown, handleKeyDown);
  }

  CheckboxSelectColumnV2(Map options) {
    _options = new Map.from(_defaults);
    _options.addAll(options);
  }

  destroy() {
    _handler.unsubscribeAll();
  }

  core.EvtCallback get handleSelectedRowsChanged =>
      (core.EventData e, dynamic args) {
        List<int> selectedRows = _grid.getSelectedRows();
        Map<int, bool> lookup = {};
        int row, i;
        for (i = 0; i < selectedRows.length; i++) {
          row = selectedRows[i];
          lookup[row] = true;
          if (lookup[row] != _selectedRowsLookup[row]) {
            _grid.invalidateRow(row);
            _selectedRowsLookup.remove(row);
          }
        }
        for (i in _selectedRowsLookup.keys) {
          _grid.invalidateRow(i);
        }
        _selectedRowsLookup = lookup;
        _grid.render();

        if (selectedRows.isNotEmpty &&
            selectedRows.length == _grid.getDataLength()) {
          _grid.updateColumnHeader(
              _options['columnId'],
              LabelElement()
                ..classes.add("cb")
                ..children.addAll([
                  InputElement(type: "checkbox")..checked = true,
                  SpanElement()..classes.add("checkmark")
                ]),
              _options['toolTip'],
              true);
        } else {
          _grid.updateColumnHeader(
              _options['columnId'],
              LabelElement()
                ..classes.add("cb")
                ..children.addAll([
                  InputElement(type: "checkbox"),
                  SpanElement()..classes.add("checkmark")
                ]),
              _options['toolTip'],
              true);
        }
      };

  core.EvtCallback get handleKeyDown => (core.EventData e, Map args) {
        KeyboardEvent evt = e.domEvent;
        if (evt.which == 32) {
          if (_grid.columns[args['cell']].id == _options['columnId']) {
            // if editing, try to commit
            if (!_grid.getEditorLock().isActive() ||
                _grid.getEditorLock().commitCurrentEdit()) {
              toggleRowSelection(args['row']);
            }
            e.preventDefault();
            e.stopImmediatePropagation();
          }
        }
      };

  //
  //   * args: {row: 3, cell: 4, grid: SlickGrid}
  //
  core.EvtCallback get handleClick => (core.EventData evt, Map args) {
        // core.EventData evt;
        // if (e is core.EventData) {
        //   evt = e;
        // }
        // else {
        //   evt = new core.EventData.fromDom(e);
        // }

        _log.finest('handle from:' +
            this.runtimeType.toString() +
            ' ' +
            evt.target.toString());
        if (_grid.columns[args['cell']].id == _options['columnId'] &&
            evt.target is CheckboxInputElement) {
          //Checkbox
          // if editing, try to commit
          if (_grid.getEditorLock().isActive() &&
              !_grid.getEditorLock().commitCurrentEdit()) {
            evt.preventDefault();
            evt.stopImmediatePropagation();
            return;
          }

          toggleRowSelection(args['row']);
          evt.stopPropagation();
          evt.stopImmediatePropagation();
        }
      };

  /**
   * consider mutiple and single selection case
   */
  toggleRowSelection(int row) {
    List<int> list = _grid.getSelectedRows();
    if (_grid.gridOptions.multiSelect == false) {
      if (_grid.getSelectedRows().contains(row)) {
        list.remove(row);
      } else {
        list
          ..clear()
          ..add(row);
      }
    } else {
      if (_selectedRowsLookup.containsKey(row)) {
        list.remove(row);
      } else {
        list.add(row);
      }
    }
    _grid.setSelectedRows(list);
  }

  /**
   * change all row to selected state
   * args: {column: Column, grid: slickgrid}
   */
  core.EvtCallback get handleHeaderClick => (core.EventData evt, Map args) {
        MouseEvent e = evt.domEvent;

        if (_grid.gridOptions.multiSelect == false) {
          e.preventDefault();
          return;
        }

        if ((args['column'] as Column).id == _options['columnId'] &&
            e.target is CheckboxInputElement) {
          // if editing, try to commit
          if (_grid.getEditorLock().isActive() &&
              !_grid.getEditorLock().commitCurrentEdit()) {
            e.preventDefault();
            e.stopImmediatePropagation();
            return;
          }

          if (e.target is CheckboxInputElement &&
              (e.target as CheckboxInputElement).checked) {
            List<int> rows = [];
            for (var i = 0; i < _grid.getDataLength(); i++) {
              rows.add(i);
            }
            _grid.setSelectedRows(rows);
          } else {
            _grid.setSelectedRows([]);
          }
          e.stopPropagation();
          e.stopImmediatePropagation();
        }
      };

  CheckboxSelectColumnV2 getColumnDefinition() {
    InputElement elem = new InputElement();
    elem.type = 'checkbox';

    this.src.addAll({
      'id': _options['columnId'],
      'name': _defaults["name"], // elem, //"<input type='checkbox'>",
      'toolTip': _options['toolTip'],
      'field': "sel",
      'width': _options['width'],
      'resizable': false,
      'sortable': false,
      'cssClass': _options['cssClass'],
      'formatter': checkboxSelectionFormatter()
    });
    return this;
  }
}
