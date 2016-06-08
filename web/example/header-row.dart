import 'dart:html';
import 'package:slickdart/slick.dart' as cj;
import 'dart:math' as math;
import 'package:slickdart/plugin/autotooltip.dart';
void main() {
  cj.SlickGrid  grid=init();
  grid.init();
  querySelector('#reset').onClick.listen((e){
    cj.FilteredList _data=new cj.FilteredList();
    for (var i = 0; i < 50000; i++) {
      _data.add( {
        'dtitle':  new math.Random().nextInt(100).toString(),
         'duration': new math.Random().nextInt(100),
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
//    grid.render();
  });
}

cj.SlickGrid init(){
  Element el =querySelector('#grid');
  List<cj.Column> column = [

                 new cj.Column.fromMap ({'id': "title", 'name': "Title1", 'field': "dtitle", 'sortable': true }),
                 new cj.Column.fromMap ({'width':120,'id': "duration", 'name': "duration", 'field': "duration", 'sortable': true ,'editor': 'TextEditor'}),
                 new cj.Column.fromMap ({'id': "%", 'name': "(nubmer)", 'field': "pc2", 'sortable': true,'editor': 'TextEditor' }),
                 new cj.Column.fromMap ({'id': "start", 'name': "finish", 'field': "finish"}),
                 new cj.Column.fromMap ({'id': "%_2", 'name': "(number)", 'field': "pc", 'editor':'TextEditor'}),
                 new cj.Column.fromMap ({'id': "effort", 'name': "(bool)", 'field': "effortDriven", 'width':300})
                 ];
  //cj.CheckboxSelectColumn checkboxCol=new cj.CheckboxSelectColumn({   'cssClass': "slick-cell-checkboxsel" });
 // column.insert(0,checkboxCol.getColumnDefinition());
  cj.FilteredList data=new cj.FilteredList();
  for (var i = 0; i < 5; i++) {
    data.add( {
      'dtitle':  new math.Random().nextInt(100).toString(),
      'duration': new math.Random().nextInt(100),
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
             'frozenColumn':1,
             'showHeaderRow': true,
             'headerRowHeight': 25
  };
  cj.SlickGrid sg= new cj.SlickGrid(el,data,column,opt);
  sg.setSelectionModel(new cj.RowSelectionModel({'selectActiveRow': false}));
  sg.registerPlugin(new AutoTooltips());

//  sg.onSelectedRowsChanged.subscribe((cj.EventData e,Map args){
//          querySelector('.right-pane')..children.clear()..appendText((args['rows'] as List).join(' '));
//  });


  sg.onHeaderRowCellRendered.subscribe((cj.EventData e,Map args) {
      Element headerEl=  args['node'];
      headerEl.children.clear();
      cj.Column col  = args['column'];
      if(col.id =='_checkbox_selector') return;
      InputElement inputEl= new InputElement();
      inputEl.dataset['columnId'] = col.field;
      headerEl.append(inputEl);

      inputEl.onKeyUp.listen( (KeyboardEvent ke){
              data.setKeyword(col.field,inputEl.value);
              sg.invalidate();
        });

    });




  sg.onSort.subscribe( (e, args) {
    var cols = args['sortCols'];
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
  });
  return sg;
}
