import 'dart:html';
import 'dart:math' as math;
import 'package:slickdart/slick_custom.dart';
import 'package:slickdart/slick.dart';
main(){
  registerElem();

  List _data = [];
   for (var i = 0; i < 500; i++) {
     _data.add({
       'dtitle': new math.Random().nextInt(100).toString(),
       'duration': new math.Random().nextInt(100).toString(),
       'pc2': new math.Random().nextInt(10) * 100,
       'pc': (new math.Random().nextInt(10) * 100).toString(),
       'start': "01/01/2009",
       'finish': (new math.Random().nextInt(10) + 10).toString() + "/05/2013",
       'effortDriven': (i % 5 == 0)
     });
   }
   GridWrap gw0 = document.querySelector("$GRID_TAG.second");
   gw0.init(_data.sublist(1,100),getColDefs());
   GridWrap gw = document.querySelector("$GRID_TAG.first");
   gw.init(_data,getColDefs());

   (document.querySelector("$GRID_TAG.third") as GridWrap)..init(_data,getColDefs());
   (document.querySelector("$GRID_TAG.forth") as GridWrap)..init(_data,getColDefs()..removeAt(0));

   gw0.grid.setSelectionModel(new RowSelectionModel({
         'selectActiveRow': false
     }));
   gw0.grid.onSelectedRowsChanged.subscribe((EventData e, Map args) {
       querySelector('.right-pane')
           ..children.clear()
           ..appendText((args['rows'] as List).join(' '));
     });
}

List<Column> getColDefs(){
  List column =[new Column.fromMap({
        'id': "title",
        'name': "Title1",
        'field': "dtitle",
        'sortable': true,
        'editor': 'TextEditor'
      }), new Column.fromMap({
        'width': 120,
        'id': "duration",
        'name': "duration",
        'field': "duration",
        'sortable': true
      }), new Column.fromMap({
        'id': "%",
        'name': "percent",
        'field': "pc2",
        'sortable': true
      }), new Column.fromMap({
        'id': "start",
        'name': "finish",
        'field': "finish"
      }), new Column.fromMap({
        'id': "%_2",
        'name': "PC2",
        'field': "pc",
        'editor': 'TextEditor'
      }), new Column.fromMap({
        'id': "effort",
        'name': "effort",
        'field': "effortDriven",
        'width': 300
      })];
  CheckboxSelectColumn checkboxCol = new CheckboxSelectColumn({
      'cssClass': "slick-cell-checkboxsel"
    });

  column.insert(0, checkboxCol.getColumnDefinition());
  return column;
}