import 'dart:html';
//import 'dart:math' as math;
import 'package:slickdart/slick_custom.dart';
import 'package:slickdart/slick.dart';
//import 'package:slickdart/parser.dart';
main() {
  registerElem();
  HttpRequest.getString('gss1983_Code.csv').then((data) {
    CsvAdapter csv = new CsvAdapter(data);
    var cols = getColDefs(csv.columns);
    cols[1]..width=20..name='id';
    csv.columns[0]..width=14..name='id';
    JGrid gw0 = document.querySelector("$GRID_TAG.first");
    gw0.attributes['download']="f.csv";
    gw0.init(new MetaList(csv.data.sublist(1, 20),getMeta), cols);
    gw0.grid.setSelectionModel(new RowSelectionModel({
      'selectActiveRow': false
    }));
    gw0.grid.onSelectedRowsChanged.subscribe((EventData e, Map args) {
      querySelector('.right-pane')
          ..children.clear()
          ..appendText((args['rows'] as List).join(' '));
    });
    
    JGrid gw1 = document.querySelector("$GRID_TAG.second");
    gw1.init(csv.data, csv.columns);
    var opts={ 'multiColumnSort': true  };
    (document.querySelector("$GRID_TAG.third") as JGrid)..init(csv.data,  csv.columns,option:opts );
    (document.querySelector("$GRID_TAG.forth") as JGrid)..init(csv.data, csv.columns, option:{'frozenRow':1});

  });
//load other grid fron internet
//

}
/**
 * enable column sort
 */
List<Column> getColDefs(List<Column> cols) {
  List<Column> newCols = cols.map((col) => new Column.fromColumn(col)..sortable=true).toList();
  CheckboxSelectColumn checkboxCol = new CheckboxSelectColumn({
    'cssClass': "slick-cell-checkboxsel"
  });

  newCols.insert(0, checkboxCol.getColumnDefinition());
  return newCols;
}
LinkFormatter(row, cell, value, columnDef, dataContext) {
  return value != null ? "<a  href='#'>z</a>" : "";
}

Map getMeta(int row){
//          Map item=sg.data[row];
//          bool exist=item.values.any((_)=> searchStr.length>0 && _ is String && _.contains(searchStr) );
          if(row %2==1){
            return {
                      "cssClasses": "highlight"
                   };
          }else return {};
        }

