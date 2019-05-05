library slick.column;

import 'dart:collection';
import 'dart:html';
import 'dart:convert';
//import 'slick.dart';
import 'dart:math' as math;
import 'slick_util.dart';
import 'slick_grid.dart';
import 'slick_editor.dart';
import 'slick_core.dart' as core;
import 'slick_util.dart' as util;
import 'package:logging/logging.dart';

Logger _log = new Logger('slick.column');

///
/// formatter interface
///
// typedef String TFormatter(int row, int cell, dynamic value, Column columnDef, Map dataContext);
typedef TFormatter = String Function(
    int row, int cell, dynamic value, Column columnDef, Map dataContext);

/**
 * create columns from list of map object
 */
class ColumnList extends ListBase<Column> {
  ColumnList();
  /**
   * must attribute: 'field'
   */
  factory ColumnList.fromMap(List<Map<String, dynamic>> mList) {
    ColumnList cols = new ColumnList();
    mList.forEach((k) {
      if (!k.containsKey('id')) {
        k['id'] = k['field'];
      }
      if (!k.containsKey('name')) {
        k['name'] = k['field'];
      }
      cols.add(new Column.fromMap(k));
    });
    return cols;
  }
  List innerList = new List();
  int get length => innerList.length;

  set length(int length) {
    innerList.length = length;
  }

  void operator []=(int index, Column value) {
    innerList[index] = value;
  }

  Column operator [](int index) => innerList[index];

  // Though not strictly necessary, for performance reasons
  // you should implement add and addAll.

  void add(Column value) => innerList.add(value);

  void addAll(Iterable<Column> all) => innerList.addAll(all);
}

/**
 * Column configuration
 */
class Column {
  ///link gridOption to store TFormatter or Editor
  ///
  GridOptions gridOption;
  bool useSysDefaultWidth = false;
  final String NO_ID = "noid_";

  ///
  /// GridOption for formatter access
  ///
  Column() {
    src.addAll(_columnDefaults);
    src["id"] = NO_ID + new math.Random().nextInt(10000000).toString();
  }
  Map<String, dynamic> src = {};
  Function get asyncPostRender => src['asyncPostRender'];
  bool get defaultSortAsc => src['defaultSortAsc'];
  Editor get editor => src['editor'];
  bool get focusable => src['focusable'];
  /**
   * Warning!!, it throw exception after serialize and deserialization with JSON
   * return type could be [String] or [TFormatter]
   */
  TFormatter get formatter => src['formatter'] is String
      ? gridOption?.formatterFactory[this.id]
      : src['formatter'];

  // () {
  //   var tmp = _src['formatter'];
  //   if (tmp is String) {
  //     return gridOption?.formatterFactory[this.id];
  //   }
  //   return tmp;
  // }

  String get headerCssClass => src['headerCssClass'];
  String get cssClass => src['cssClass'];
  int get previousWidth => src['previousWidth'];
  //visible
  bool get visible => src['visible'];

  String get toolTip => src['toolTip'];
  /** unique id for differeicent from same field name
   *  for pick up Column element
   */
  String get id => src['id']; // "range"
  int get minWidth => src['minWidth']; //: 30
  /**
   * [name] could be string or element
   */
  get name => src['name']; //: "Range"
  bool get rerenderOnResize => src['rerenderOnResize'];
  bool get resizable => src['resizable'];
  bool get selectable => src['selectable'];
  bool get sortable => src['sortable'];
  int get width => src['width'];
  int get maxWidth => src['maxWidth'];
  String get field => src['field'];
  get validator => src['validator'];
  //for header menu plugin
  Map get header {
    src['header'] ??= {};
    return src['header'];
  }

  bool get cannotTriggerInsert => src['cannotTriggerInsert'];
  set asyncPostRender(item) => src['asyncPostRender'] = item;
  set toolTip(item) {
    src['toolTip'] = item;
  }

  set cannotTriggerInsert(item) {
    src['cannotTriggerInsert'] = item;
  }

  set defaultSortAsc(item) {
    src['defaultSortAsc'] = item;
  }

  set editor(Editor item) {
    src['editor'] = item;
  }

  set focusable(bool item) {
    src['focusable'] = item;
  }

  ///  Give TFormatter only if in Grid initialize
  ///  [item] is String or [TFormatter]
  ///  give String and then assing in GridOption is better
  set formatter(dynamic item) {
    src['formatter'] = item;
  }

  set headerCssClass(String item) {
    src['headerCssClass'] = item;
  }

  set cssClass(String item) {
    src['cssClass'] = item;
  }

  set id(String item) {
    src['id'] = item;
  } // "range"

  set previousWidth(int item) {
    src['previousWidth'] = item;
  } // "range"

  set minWidth(int item) {
    src['minWidth'] = item;
  } //: 30

  set name(var item) {
    src['name'] = item;
  } //: "Range"

  set rerenderOnResize(bool item) {
    src['rerenderOnResize'] = item;
  }

  set resizable(bool item) {
    src['resizable'] = item;
  }

  set selectable(bool item) {
    src['selectable'] = item;
  }

  set sortable(bool item) {
    src['sortable'] = item;
  }

  set width(int item) {
    src['width'] = item;
  }

  set maxWidth(int item) {
    src['maxWidth'] = item;
  }

  set field(String item) {
    src['field'] = item;
    if (src["id"] == null || src["id"].toString().startsWith(NO_ID)) {
      src["id"] = '${src['field']}-${new math.Random().nextInt(1000000)}';
    }
    if (src["name"] == null) src["name"] = src["field"];
  }

  set header(Map _) {
    src['header'] = _;
  }

  set visible(bool item) {
    src['visible'] = item;
  }

  ///
  ///  [field] is attribute name in map object, must exist for formatter to lookup in [GridOption]
  ///  [name] is display name on column header
  ///
  factory Column.fromMap(Map<String, dynamic> src) {
    Column c = new Column();
    if (src['id'] == null) {
      src['id'] = '${src['field']}-${new math.Random().nextInt(100000)}';
    }
    if (src['name'] == null) {
      src['name'] = '${src['field']}';
    }
    c.src..addAll(src);
    if (src["width"] == null) {
      c.useSysDefaultWidth = true;
    }
    return c;
  }

  factory Column.fromJSON(String src) {
    Map<String, dynamic> m = json.decode(src) as Map<String, dynamic>;
    return new Column.fromMap(m); //c._src..addAll(src) ;
  }

  factory Column.fromColumn(Column old) {
    Column c = new Column();
    c.src..addAll(old.src);
    return c;
  }

  dynamic operator [](String crit) {
    return src[crit];
  }

  Column merge(Column newCol) {
    this.src.addAll(newCol.src);
    return this;
  }

  Map<String, dynamic> _columnDefaults = {
    'name': "",
    'resizable': true,
    'sortable': false,
    'minWidth': 30,
    'width': 80,
    'maxWidth': 1000000000000000000,
    'rerenderOnResize': false,
    'headerCssClass': null,
    'defaultSortAsc': true,
    'focusable': true,
    'selectable': true,
    'cannotTriggerInsert': false,
    'visible': true
  };
  String toString() {
    return src.toString();
  }

  Map toJson() {
    return src;
  }
}

///
///  Virtual column that add to first column, including header as checkbox column
///
class CheckboxSelectColumn extends Column with IPlugin {
  TFormatter checkboxSelectionFormatter() =>
      (int row, int cell, value, Column columnDef, dataContext) {
        if (dataContext != null) {
          return _selectedRowsLookup.containsKey(row)
              ? "<input type='checkbox' checked='checked'>"
              : "<input type='checkbox'>";
        }
        return "";
      };
  Map _options;
  Map<String, Object> _defaults = {
    'columnId': "_checkbox_selector",
    'cssClass': null,
    'toolTip': "Select/Deselect All",
    'width': 30,
    'name': InputElement()..type = "checkbox"
  };
  SlickGrid _grid;
  var _handler = new core.EventHandler();

  Map<int, bool> _selectedRowsLookup = {};
  /**
   * change for shadow dom element initialize
   */
//  dynamic operator[](String crit){
//     if(crit=='name'){
//       var el= new InputElement();
//           el.type='checkbox';
//           return el;
//     }
//     return _src[crit];
//  }

  init(SlickGrid grid) {
    _grid = grid;
    _handler
        .subscribe(_grid.onSelectedRowsChanged, handleSelectedRowsChanged)
        .subscribe(_grid.onClick, handleClick)
        .subscribe(_grid.onHeaderClick, handleHeaderClick)
        .subscribe(_grid.onKeyDown, handleKeyDown);
  }

  CheckboxSelectColumn(Map options) {
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
              new Element.html("<input type='checkbox' checked='checked'>"),
              _options['toolTip']);
        } else {
          _grid.updateColumnHeader(_options['columnId'],
              new Element.html("<input type='checkbox'>"), _options['toolTip']);
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
//     var target= e.target ;
        // clicking on a row select checkbox
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

  CheckboxSelectColumn getColumnDefinition() {
    InputElement elem = new InputElement();
    elem.type = 'checkbox';
    this.src.addAll({
      'id': _options['columnId'],
      'name': elem, //"<input type='checkbox'>",
      'toolTip': _options['toolTip'],
      'field': "sel",
      'width': _options['width'],
      'resizable': false,
      'sortable': false,
      'cssClass': _options['cssClass'],
      'formatter': checkboxSelectionFormatter()
    });
    return this;
    //return new Column.fromMap();
  }
}
