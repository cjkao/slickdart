import 'dart:html';
import 'dart:math' as math;
import 'package:slickdart/slick_custom.dart';
import 'package:slickdart/slick.dart';
import 'package:slickdart/parser.dart';
main() {
  registerElem();
  HttpRequest.getString('gss1983_Code.csv').then((data) {
    CsvAdapter csv = new CsvAdapter(data);
    var cols = getColDefs(csv.columns);
    cols[1]..width=20..name='id';
    csv.columns[0]..width=14..name='id';
    JGrid gw0 = document.querySelector("$GRID_TAG.second");
    gw0.init(csv.data.sublist(1, 2000), cols);
    JGrid gw1 = document.querySelector("$GRID_TAG.first");
    gw1.init(csv.data, csv.columns);

    (document.querySelector("$GRID_TAG.third") as JGrid)..init(csv.data,  csv.columns);
    (document.querySelector("$GRID_TAG.forth") as JGrid)..init(csv.data, csv.columns);

    gw0.grid.setSelectionModel(new RowSelectionModel({
      'selectActiveRow': false
    }));
    gw0.grid.onSelectedRowsChanged.subscribe((EventData e, Map args) {
      querySelector('.right-pane')
          ..children.clear()
          ..appendText((args['rows'] as List).join(' '));
    });
  });
//load other grid fron internet
//

}
List<Column> getColDefs(List<Column> cols) {
//  var cols= new ColumnList.fromMap(
//      [ { 'field': "dtitle",    'name': "Title1",       'sortable': true                          },
//        { 'field': "duration",  'sortable': true,'width': 80, 'formatter': LinkFormatter          },
//        { 'field': "pc2",       'editor': 'TextEditor', 'sortable': true                          },
//        { 'field': "finish"                                                                       },
//        { 'field': "Querter",   'editor': new SelectListEditor({1:'1',2:'2',3:'3',4:'4'})         },
//        { 'field': "Querter2",  'editor': new SelectListEditor({'1':'1','2':'2','3':'3','4':'4'}) },
//        { 'field': "YesNo",     'editor': 'CheckboxEditor',    'formatter': CheckmarkFormatter    },
//        { 'field': "pc",        'editor': 'TextEditor',   'id': "%_2"                             },
//        { 'field': "effortDriven",  'width': 300  }
//      ]);
  List<Column> newCols = cols.map((col) => new Column.fromColumn(col)).toList();
  CheckboxSelectColumn checkboxCol = new CheckboxSelectColumn({
    'cssClass': "slick-cell-checkboxsel"
  });

  newCols.insert(0, checkboxCol.getColumnDefinition());
  return newCols;
}
LinkFormatter(row, cell, value, columnDef, dataContext) {
  return value != null ? "<a  href='#'>z</a>" : "";
}
