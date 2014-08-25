library slick.column;

import 'dart:html';
import 'slick_grid.dart';
import 'slick_core.dart' as core;

/**
 * Virtual column that add to first column, including header
 */
class CheckboxSelectColumn extends Column with IPlugin{
  Map _options;
  Map _defaults = {
                   'columnId': "_checkbox_selector",
                   'cssClass': null,
                   'toolTip': "Select/Deselect All",
                   'width': 30
  };
  SlickGrid _grid;
  var _handler = new core.EventHandler();
  Map<int,bool> _selectedRowsLookup = {};
  init(SlickGrid grid){
    _grid = grid;
    _handler.subscribe(_grid.onSelectedRowsChanged, handleSelectedRowsChanged)
      .subscribe(_grid.onClick, handleClick)
      .subscribe(_grid.onHeaderClick, handleHeaderClick)
      .subscribe(_grid.onKeyDown, handleKeyDown);
  }
  CheckboxSelectColumn(options) {
    _options = new Map.from(_defaults) ;
    _options.addAll(options);

  }

  destroy() {
    _handler.unsubscribeAll();
  }

  handleSelectedRowsChanged(core.EventData e, Map args) {
    List selectedRows = _grid.getSelectedRows();
    var lookup = {}, row, i;
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

    if (selectedRows.length>0 && selectedRows.length == _grid.getDataLength()) {
      _grid.updateColumnHeader(_options['columnId'], "<input type='checkbox' checked='checked'>", _options['toolTip']);
    } else {
      _grid.updateColumnHeader(_options['columnId'], "<input type='checkbox'>", _options['toolTip']);
    }
  }

   handleKeyDown(e, Map args) {
    if (e.which == 32) {
      if (_grid.columns[args['cell']].id == _options['columnId']) {
        // if editing, try to commit
        if (!_grid.getEditorLock().isActive() || _grid.getEditorLock().commitCurrentEdit()) {
          toggleRowSelection(args['row']);
        }
        e.preventDefault();
        e.stopImmediatePropagation();
      }
    }
  }
    /**
     * args: {row: 3, cell: 4, grid: SlickGrid}
     */
   handleClick(var e, Map args) {

     core.EventData evt;
     if(e is core.EventData){
       evt=e;
     }else{
       evt=new core.EventData.fromDom(e);
     }
     print('handle from:' + this.runtimeType.toString() +' ' + evt.target.toString());
//     var target= e.target ;
    // clicking on a row select checkbox
    if (_grid.columns[args['cell']].id == _options['columnId'] && evt.target  is CheckboxInputElement ) { //Checkbox
      // if editing, try to commit
      if (_grid.getEditorLock().isActive() && !_grid.getEditorLock().commitCurrentEdit()) {
        evt.preventDefault();
        evt.stopImmediatePropagation();
        return;
      }

      toggleRowSelection(args['row']);
      evt.stopPropagation();
      evt.stopImmediatePropagation();
    }
  }
//TODO fixme
   toggleRowSelection(int row) {
     List list=_grid.getSelectedRows();
    if (_selectedRowsLookup.containsKey(row)) {
      list.remove(row);
    } else {
      list.add(row);
    }
    _grid.setSelectedRows(list);
  }
  /**
   * change all row to selected state
   * args: {column: Column, grid: slickgrid}
   */
   handleHeaderClick(core.EventData evt, Map args) {
     MouseEvent e=evt.domEvent;
    if ( (args['column'] as Column).id == _options['columnId'] && e.target is CheckboxInputElement) {
      // if editing, try to commit
      if (_grid.getEditorLock().isActive() && !_grid.getEditorLock().commitCurrentEdit()) {
        e.preventDefault();
        e.stopImmediatePropagation();
        return;
      }

      if (e.target is CheckboxInputElement && (e.target as CheckboxInputElement).checked) {
        List rows = [];
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
  }

   getColumnDefinition() {
    return new Column.fromMap({
      'id': _options['columnId'],
      'name': "<input type='checkbox'>",
      'toolTip': _options['toolTip'],
      'field': "sel",
      'width': _options['width'],
      'resizable': false,
      'sortable': false,
      'cssClass': _options['cssClass'],
      'formatter': checkboxSelectionFormatter
    });
  }

   checkboxSelectionFormatter(row, cell, value, columnDef, dataContext) {
    if (dataContext!=null) {
      return _selectedRowsLookup.containsKey(row)
          ? "<input type='checkbox' checked='checked'>"
          : "<input type='checkbox'>";
    }
    return null;
  }




}