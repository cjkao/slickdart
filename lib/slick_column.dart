library slick.column;
import 'dart:collection';
import 'dart:html';
import 'dart:convert';
import 'slick.dart';
import 'slick_core.dart' as core;
class ColumnList  extends ListBase<Column>{
    ColumnList(){

    }
    /**
     * must attribute: 'field'
     */
    factory ColumnList.fromMap(List<Map> mList){
      ColumnList cols=new ColumnList();
      mList.forEach((Map k){
        if(!k.containsKey('id')){
          k['id']= k['field'];
        }
        if(!k.containsKey('name')){
          k['name']= k['field'];
        }
        cols.add(new Column.fromMap(k));
      });
      return cols;
    }
    List innerList = new List();
    int get length => innerList.length;

    void set length(int length) {
      innerList.length = length;
    }
    void operator[]=(int index, Column value) {
      innerList[index] = value;
    }
    Column operator [](int index) => innerList[index];

    // Though not strictly necessary, for performance reasons
    // you should implement add and addAll.

    void add(Column value) => innerList.add(value);

    void addAll(Iterable<Column> all) => innerList.addAll(all);
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
  //unique id for differeicent from same field name
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
     InputElement elem=new InputElement();
     elem.type='checkbox';
     this._src.addAll({
       'id': _options['columnId'],
       'name': elem, //"<input type='checkbox'>",
       'toolTip': _options['toolTip'],
       'field': "sel",
       'width': _options['width'],
       'resizable': false,
       'sortable': false,
       'cssClass': _options['cssClass'],
       'formatter': checkboxSelectionFormatter
     });
     return this;
    //return new Column.fromMap();
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