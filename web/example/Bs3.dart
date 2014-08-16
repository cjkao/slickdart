import 'dart:html';
import 'package:slickdart/slick.dart' as cj;
import 'dart:math' as math;
import 'package:slickdart/slick_core.dart' as core;
void main() {
  cj.SlickGrid  grid=init();
  grid.init();
  //print(g.$canvas.getBoundingClientRect());
  querySelector('#reset').onClick.listen((e){
    List _data=[];
    for (var i = 0; i < 50000; i++) {
      _data.add( {
        'dtitle':  new math.Random().nextInt(100).toString(),
         'duration': new math.Random().nextInt(100).toString(),
         'pc2': new math.Random().nextInt(10) * 100,
         'pc': (new math.Random().nextInt(10) * 100).toString(),
         'start': "01/01/2009",
         'finish': (new math.Random().nextInt(10)+10).toString() + "/05/2013",
         'effortDriven': (i % 5 == 0)
      });
    }
    grid.data.clear();
    grid.data.addAll(_data);
    grid.invalidate();
    grid.render();

  });
}

cj.SlickGrid init(){
  Element el =querySelector('#grid');
  List column = [

                 new cj.Column.fromMap ({'id': "title", 'name': "Title1", 'field': "dtitle", 'sortable': true,'editor': 'TextEditor' }),
                 new cj.Column.fromMap ({'width':120,'id': "duration", 'name': "duration", 'field': "duration", 'sortable': true }),
                 new cj.Column.fromMap ({'id': "%", 'name': "percent", 'field': "pc2", 'sortable': true }),
                 new cj.Column.fromMap ({'id': "start", 'name': "finish", 'field': "finish"}),
                 new cj.Column.fromMap ({'id': "%_2", 'name': "PC2", 'field': "pc", 'editor':'TextEditor'}),
                 new cj.Column.fromMap ({'id': "effort", 'name': "effort", 'field': "effortDriven", 'width':300})
                 ];
  cj.CheckboxSelectColumn checkboxCol=new cj.CheckboxSelectColumn({   'cssClass': "slick-cell-checkboxsel" });
  column.insert(0,checkboxCol.getColumnDefinition());
  List data=[];
  for (var i = 0; i < 5; i++) {
    data.add( {
      'dtitle':  new math.Random().nextInt(100).toString(),
      'duration': new math.Random().nextInt(100).toString(),
      'pc2': new math.Random().nextInt(10) * 100,
      'pc': (new math.Random().nextInt(10) * 100).toString(),
      'start': "01/01/2009",
      'finish': (new math.Random().nextInt(10)+10).toString() + "/05/2013",
      'effortDriven': (i % 5 == 0)
    });
  }
  Map opt = {'explicitInitialization': false,
             'multiColumnSort': true,
             'editable': true,
             'autoEdit': true,
             'frozenColumn':1
  };
  cj.SlickGrid sg= new cj.SlickGrid(el,data,column,opt);
  sg.setSelectionModel(new cj.RowSelectionModel({'selectActiveRow': false}));
  sg.registerPlugin(checkboxCol);

  //sg.setSelectionModel(new CellSelectionModel(sg.options));
  //args: {rows:[...], grid: SlickGrid }
  sg.onSelectedRowsChanged.subscribe((cj.EventData e,Map args){
          querySelector('.right-pane')..children.clear()..appendText((args['rows'] as List).join(' '));
  });

  sg.onSort.subscribe( (e, args) {
    var cols = args['sortCols'];
//{sortCol: {name: Title1, resizable: true, sortable: true, minWidth: 30, rerenderOnResize: false, headerCssClass: null, defaultSortAsc: true, focusable: true, selectable: true, cannotTriggerInsert: false, width: 80, id: title, field: title}, sortAsc: true}
    data.sort( (dataRow1, dataRow2) {
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
    sg.render();
  });
  return sg;
}
