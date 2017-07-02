import 'dart:html';
import 'package:slickdart/slick_custom.dart';
import 'package:slickdart/slick.dart';
import 'package:slickdart/slick_cell_selection.dart' as cellMode;
import 'dart:math';

Map<int, Map<String, String>> hash = {};
Map<String, String> getMeta(int row) {
  var rdata = csv.data[row];

  if (rdata['gss_code'] == filterStr) {
    //build column style hash
    hash[row] = {'UNITID': 'bold', 'school_id': 'bold'};

    return {"cssClasses": "highlight"};
  } else
    return {}; // {"cssClasses":'highlight'};
}

main() {
  registerElem();
  List<Column> cols;
  HttpRequest.getString('gss1983_Code-small.csv').then((data) {
    csv = new CsvAdapter(data);
    cols = getColDefs(csv.columns);
    cols[1]
      ..width = 20
      ..name = 'id';
    csv.columns[0]
      ..width = 14
      ..name = 'id';
    Map opt = {
      'multiColumnSort': true,
      'editable': false,
    };
    gw0 = document.querySelector("$GRID_TAG.second");
    gw0.init(new MetaList(csv.data, getMeta), [], option: opt);

    gw0.grid.onSort.subscribe((EventData e, dynamic parm) {
      hash.clear();
      gw0.grid.invalidate();
    });
  });
  querySelector('.btn').onClick.listen((_) {
    int rndColCnt = new Random().nextInt(cols.length);
    cols.shuffle();

    gw0.grid
      ..setColumns(cols.sublist(0, rndColCnt))
      ..invalidate();
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
