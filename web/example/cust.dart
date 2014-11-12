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
       'YesNo': new math.Random().nextInt(10)>5 ? true: false,
       'Querter': new math.Random().nextInt(3)+1,
       'Querter2': '${new math.Random().nextInt(3)+1}',
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
List getData(){
  List _data = [];
     for (var i = 0; i < 500; i++) {
       _data.add({
         'dtitle': new math.Random().nextInt(100).toString(),
         'duration': new math.Random().nextInt(100).toString(),
         'pc2': new math.Random().nextInt(10) * 100,
         'pc': (new math.Random().nextInt(10) * 100).toString(),
         'YesNo': new math.Random().nextInt(10)>5 ? true: false,
         'Querter': new math.Random().nextInt(3)+1,
         'Querter2': '${new math.Random().nextInt(3)+1}',
         'finish': (new math.Random().nextInt(10) + 10).toString() + "/05/2013",
         'effortDriven': (i % 5 == 0)
       });
     }
     return _data;
}
List<Column> getColDefs(){
  var cols= new ColumnList.fromMap(
      [ { 'field': "dtitle",    'name': "Title1",       'sortable': true                          },
        { 'field': "duration",  'sortable': true,'width': 80, 'formatter': LinkFormatter          },
        { 'field': "pc2",       'editor': 'TextEditor', 'sortable': true                          },
        { 'field': "finish"                                                                       },
        { 'field': "Querter",   'editor': new SelectListEditor({1:'1',2:'2',3:'3',4:'4'})         },
        { 'field': "Querter2",  'editor': new SelectListEditor({'1':'1','2':'2','3':'3','4':'4'}) },
        { 'field': "YesNo",     'editor': 'CheckboxEditor',    'formatter': CheckmarkFormatter    },
        { 'field': "pc",        'editor': 'TextEditor',   'id': "%_2"                             },
        { 'field': "effortDriven",  'width': 300  }
      ]);
  CheckboxSelectColumn checkboxCol = new CheckboxSelectColumn({
      'cssClass': "slick-cell-checkboxsel"
    });

  cols.insert(0, checkboxCol.getColumnDefinition());
  return cols;
}
LinkFormatter(row, cell, value, columnDef, dataContext) {
  return value!=null ? "<a  href='#'>z</a>" : "";
}
