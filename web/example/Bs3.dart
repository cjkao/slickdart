import 'dart:html';
import 'package:slickdart/slick.dart' as cj;
import 'dart:math' as math;
import 'package:slickdart/plugin/autotooltip.dart';
void main() {
  cj.SlickGrid  grid=prepareGrid();
  grid.init();
  querySelector('#reset').onClick.listen((e){
    grid.data=makeData(50000);
    grid.invalidate();
  });
}

List makeData(int len){
  List _data=[];
  for (var i = 0; i < len; i++) {
        _data.add( {
          'title':  new math.Random().nextInt(100).toString(),
           'duration': new math.Random().nextInt(100),
           'percent': '${i%100}%' ,
           'pc': (new math.Random().nextInt(10) * 100).toString(),
           'start': "01/01/2009",
           'finish': (new math.Random().nextInt(10)+10).toString() + "/05/2013",
           'effortDriven': (i % 5 == 0)
        });
      }
  return _data;
}

cj.SlickGrid prepareGrid(){
  Element el =querySelector('#grid');
  List column = [
                 new cj.Column.fromMap ({'field': "title",        'name': "FIXED",  'sortable': true }),
                 new cj.Column.fromMap ({'field': "duration",     'name': "A",'width':120, 'sortable': true ,'editor': 'IntEditor'}),
                 new cj.Column.fromMap ({'field': "percent",      'name': 'B', 'sortable': true,'editor': 'TextEditor' }),
                 new cj.Column.fromMap ({'field': "finish",       'name': "C" }),
                 new cj.Column.fromMap ({'field': "pc",           'name': "D",  'editor':'TextEditor'}),
                 new cj.Column.fromMap ({'field': "effortDriven", 'name': "E",  'width':200})
                 ];
  cj.CheckboxSelectColumn checkboxCol=new cj.CheckboxSelectColumn({   'cssClass': "slick-cell-checkboxsel" });
  column.insert(0,checkboxCol.getColumnDefinition());
  var opt = new cj.GridOptions()..explicitInitialization=false
                                ..multiColumnSort=true
                                ..editable=true
                                ..autoEdit=true
                                ..frozenColumn = 1
                                ..enableColumnReorder=true;
  
  cj.SlickGrid sg= new cj.SlickGrid.fromOpt(el,makeData(500),column,opt);
  sg.setSelectionModel(new cj.RowSelectionModel({'selectActiveRow': false}));
  sg.registerPlugin(checkboxCol);
  sg.registerPlugin(new AutoTooltips());

  //sg.setSelectionModel(new CellSelectionModel(sg.options));
  //args: {rows:[...], grid: SlickGrid }
  sg.onSelectedRowsChanged.subscribe((cj.EventData e,Map args){
          querySelector('.right-pane')..children.clear()..appendText((args['rows'] as List).join(' '));
  });

  sg.onSort.subscribe( (e, args) {
    var cols = args['sortCols'];
//{sortCol: {name: Title1, resizable: true, sortable: true, minWidth: 30, rerenderOnResize: false, headerCssClass: null, defaultSortAsc: true, focusable: true, selectable: true, cannotTriggerInsert: false, width: 80, id: title, field: title}, sortAsc: true}
    sg.getData().sort( (dataRow1, dataRow2) {
      for (var i = 0, l = cols.length; i < l; i++) {
        var field = cols[i]['sortCol']['field'];
        var sign = cols[i]['sortAsc'] ? 1 : -1;
        dynamic value1 = dataRow1[field], value2 = dataRow2[field];
        if(field=='dtitle') {
          return value1 == value2 ? 0 : (int.parse(value1) > int.parse(value2) ? 1: -1)* sign;
        }
        var result = (value1 == value2 ? 0 : (value1.compareTo(value2)>0 ? 1 : -1)) * sign;
        if (result != 0) {
          return result;
        }
      }
      return 0;
    });
    sg.invalidate();
  });
  return sg;
}
