import 'dart:html';
import 'package:slickdart/slick_custom.dart';
import 'package:slickdart/slick.dart';

//import 'package:slickdart/parser.dart';
Map<String,String> getMeta(int row) {
  var rdata = csv.data[row];
  if (rdata['gss_code'] == filterStr) {
    return {"cssClasses": "highlight"};
  } else return {}; // {"cssClasses":'highlight'};
}

main() {
  registerElem();
  HttpRequest.getString('gss1983_Code-small.csv').then((data) {
    csv = new CsvAdapter(data);
    var cols = getColDefs(csv.columns);
    cols[1]
      ..width = 20
      ..name = 'id';
    csv.columns[0]
      ..width = 14
      ..name = 'id';
    gw0 = document.querySelector("$GRID_TAG.second");
    gw0.init(new MetaList(csv.data, getMeta), cols);
    gw0.grid.setSelectionModel(new RowSelectionModel({}));
  });
  querySelector('.inputgs').onChange.listen((Event _) {
    filterStr = (_.target as InputElement).value;
    gw0.grid.invalidate();
  });

  querySelector('.empty.btn').onClick.listen((_) {
    gw0.grid.setSelectedRows([]);
    gw0.grid.resetActiveCell();
    _.preventDefault();
    _.stopPropagation();
  });
}

JGrid gw0;
CsvAdapter csv;
String filterStr;

List<Column> getColDefs(List<Column> cols) {
  List<Column> newCols = cols.map((col) => new Column.fromColumn(col)..sortable = true).toList();
  CheckboxSelectColumn checkboxCol = new CheckboxSelectColumn({'cssClass': "slick-cell-checkboxsel"});
  newCols.insert(0, checkboxCol.getColumnDefinition());
  return newCols;
}
