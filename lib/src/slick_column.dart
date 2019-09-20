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

Logger _log = Logger('slick.column');

///
/// formatter interface
///
// typedef String TFormatter(int row, int cell, dynamic value, Column columnDef, Map dataContext);
typedef TFormatter = String Function(int row, int cell, dynamic value, Column columnDef, Map dataContext);

///
///create columns from list of map object
///
class ColumnList extends ListBase<Column> {
  ColumnList();

  ///
  ///must attribute: 'field'
  ///
  factory ColumnList.fromMap(List<Map<String, dynamic>> mList) {
    ColumnList cols = ColumnList();
    mList.forEach((k) {
      if (!k.containsKey('id')) {
        k['id'] = k['field'];
      }
      if (!k.containsKey('name')) {
        k['name'] = k['field'];
      }
      cols.add(Column.fromMap(k));
    });
    return cols;
  }
  List innerList = List();
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

///
/// Column configuration
///
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
    _src.addAll(_columnDefaults);
    _src["id"] = NO_ID + math.Random().nextInt(10000000).toString();
  }
  Map<String, dynamic> _src = {};
  Function get asyncPostRender => _src['asyncPostRender'];
  bool get defaultSortAsc => _src['defaultSortAsc'];
  Editor get editor => _src['editor'];
  bool get focusable => _src['focusable'];

  ///
  /// Warning!!, it throw exception after serialize and deserialization with JSON
  /// return type could be [String] or [TFormatter]
  ///
  TFormatter get formatter => _src['formatter'] is String ? gridOption?.formatterFactory[this.id] : _src['formatter'];

  // () {
  //   var tmp = _src['formatter'];
  //   if (tmp is String) {
  //     return gridOption?.formatterFactory[this.id];
  //   }
  //   return tmp;
  // }

  String get headerCssClass => _src['headerCssClass'];
  String get cssClass => _src['cssClass'];
  int get previousWidth => _src['previousWidth'];
  //visible
  bool get visible => _src['visible'];

  String get toolTip => _src['toolTip'];

  /// unique id for differeicent from same field name
  /// for pick up Column element
  ///
  String get id => _src['id']; // "range"
  int get minWidth => _src['minWidth']; //: 30
  ///
  /// [name] could be string or element
  ///
  get name => _src['name']; //: "Range"
  bool get rerenderOnResize => _src['rerenderOnResize'];
  bool get resizable => _src['resizable'];
  bool get selectable => _src['selectable'];
  bool get sortable => _src['sortable'];
  int get width => _src['width'];
  int get maxWidth => _src['maxWidth'];
  String get field => _src['field'];
  get validator => _src['validator'];
  //for header menu plugin
  Map get header {
    _src['header'] ??= {};
    return _src['header'];
  }

  bool get cannotTriggerInsert => _src['cannotTriggerInsert'];
  set asyncPostRender(item) => _src['asyncPostRender'] = item;
  set toolTip(item) {
    _src['toolTip'] = item;
  }

  set cannotTriggerInsert(item) {
    _src['cannotTriggerInsert'] = item;
  }

  set defaultSortAsc(item) {
    _src['defaultSortAsc'] = item;
  }

  set editor(Editor item) {
    _src['editor'] = item;
  }

  set focusable(bool item) {
    _src['focusable'] = item;
  }

  ///  Give TFormatter only if in Grid initialize
  ///  [item] is String or [TFormatter]
  ///  give String and then assing in GridOption is better
  set formatter(dynamic item) {
    _src['formatter'] = item;
  }

  set headerCssClass(String item) {
    _src['headerCssClass'] = item;
  }

  set cssClass(String item) {
    _src['cssClass'] = item;
  }

  set id(String item) {
    _src['id'] = item;
  } // "range"

  set previousWidth(int item) {
    _src['previousWidth'] = item;
  } // "range"

  set minWidth(int item) {
    _src['minWidth'] = item;
  } //: 30

  set name(var item) {
    _src['name'] = item;
  } //: "Range"

  set rerenderOnResize(bool item) {
    _src['rerenderOnResize'] = item;
  }

  set resizable(bool item) {
    _src['resizable'] = item;
  }

  set selectable(bool item) {
    _src['selectable'] = item;
  }

  set sortable(bool item) {
    _src['sortable'] = item;
  }

  set width(int item) {
    _src['width'] = item;
  }

  set maxWidth(int item) {
    _src['maxWidth'] = item;
  }

  set field(String item) {
    _src['field'] = item;
    if (_src["id"] == null || _src["id"].toString().startsWith(NO_ID)) {
      _src["id"] = '${_src['field']}-${math.Random().nextInt(1000000)}';
    }
    if (_src["name"] == null) _src["name"] = _src["field"];
  }

  set header(Map _) {
    _src['header'] = _;
  }

  set visible(bool item) {
    _src['visible'] = item;
  }

  ///
  ///  [field] is attribute name in map object, must exist for formatter to lookup in [GridOption]
  ///  [name] is display name on column header
  ///
  factory Column.fromMap(Map<String, dynamic> src) {
    Column c = Column();
    if (src['id'] == null) {
      src['id'] = '${src['field']}-${math.Random().nextInt(100000)}';
    }
    if (src['name'] == null) {
      src['name'] = '${src['field']}';
    }
    c._src..addAll(src);
    if (src["width"] == null) {
      c.useSysDefaultWidth = true;
    }
    return c;
  }

  factory Column.fromJSON(String src) {
    Map<String, dynamic> m = json.decode(src) as Map<String, dynamic>;
    return Column.fromMap(m); //c._src..addAll(src) ;
  }

  factory Column.fromColumn(Column old) {
    Column c = Column();
    c._src..addAll(old._src);
    return c;
  }

  dynamic operator [](String crit) {
    return _src[crit];
  }

  Column merge(Column newCol) {
    this._src.addAll(newCol._src);
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
    return _src.toString();
  }

  Map toJson() {
    return _src;
  }
}

///
///  Virtual column that add to first column, including header as checkbox column
///
class CheckboxSelectColumn extends Column with IPlugin {
  TFormatter checkboxSelectionFormatter() => (int row, int cell, value, Column columnDef, dataContext) {
        if (dataContext != null) {
          return _selectedRowsLookup.containsKey(row) ? "<input type='checkbox' checked='checked'>" : "<input type='checkbox'>";
        }
        return "";
      };
  Map _options;
  Map<String, dynamic> _defaults = {
    'columnId': "_checkbox_selector",
    'cssClass': null,
    'toolTip': "Select/Deselect All",
    'width': 30,
    'name': Element.html('<input type="checkbox"></input>', treeSanitizer: util.nullTreeSanitizer)
  };
  SlickGrid _grid;
  var _handler = core.EventHandler();

  Map<int, bool> _selectedRowsLookup = {};

  ///
  /// change for shadow dom element initialize
  ///
//  dynamic operator[](String crit){
//     if(crit=='name'){
//       var el=  InputElement();
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
    _options = Map.from(_defaults);
    _options.addAll(options);
  }

  destroy() {
    _handler.unsubscribeAll();
  }

  core.EvtCallback get handleSelectedRowsChanged => (core.EventData e, dynamic args) {
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

        if (selectedRows.isNotEmpty && selectedRows.length == _grid.getDataLength()) {
          _grid.updateColumnHeader(
              _options['columnId'], Element.html("<input type='checkbox' checked='checked'>"), _options['toolTip']);
        } else {
          _grid.updateColumnHeader(_options['columnId'], Element.html("<input type='checkbox'>"), _options['toolTip']);
        }
      };

  core.EvtCallback get handleKeyDown => (core.EventData e, Map args) {
        KeyboardEvent evt = e.domEvent;
        if (evt.which == 32) {
          if (_grid.columns[args['cell']].id == _options['columnId']) {
            // if editing, try to commit
            if (!_grid.getEditorLock().isActive() || _grid.getEditorLock().commitCurrentEdit()) {
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
        //   evt =  core.EventData.fromDom(e);
        // }

        _log.finest('handle from:' + this.runtimeType.toString() + ' ' + evt.target.toString());
//     var target= e.target ;
        // clicking on a row select checkbox
        if (_grid.columns[args['cell']].id == _options['columnId'] && evt.target is CheckboxInputElement) {
          //Checkbox
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
      };

  ///
  /// consider mutiple and single selection case
  ///
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

  ///
  /// change all row to selected state
  /// args: {column: Column, grid: slickgrid}
  ///
  core.EvtCallback get handleHeaderClick => (core.EventData evt, Map args) {
        MouseEvent e = evt.domEvent;

        if (_grid.gridOptions.multiSelect == false) {
          e.preventDefault();
          return;
        }

        if ((args['column'] as Column).id == _options['columnId'] && e.target is CheckboxInputElement) {
          // if editing, try to commit
          if (_grid.getEditorLock().isActive() && !_grid.getEditorLock().commitCurrentEdit()) {
            e.preventDefault();
            e.stopImmediatePropagation();
            return;
          }

          if (e.target is CheckboxInputElement && (e.target as CheckboxInputElement).checked) {
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
    InputElement elem = InputElement();
    elem.type = 'checkbox';
    this._src.addAll({
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
    //return  Column.fromMap();
  }
}
