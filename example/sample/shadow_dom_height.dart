import 'dart:html';
import 'package:slickdart/slick_custom.dart';
import 'package:slickdart/slick.dart';

var data;

main() async {
  registerElem();
  var data = await HttpRequest.getString('gss1983_Code.csv');
  CsvAdapter csv = CsvAdapter(data);
  var cols = getColDefs(csv.columns);
  cols[1]
    ..width = 20
    ..name = 'id';
  csv.columns[0]
    ..width = 14
    ..name = 'id';
  JGrid gw0 = JGrid(document.querySelector("$GRID_TAG"));

//  gw0.setStyle(""".slick-pane-top .slick-row {   background-color: #a9F9FF;    }""");
//  gw0.setStyle(""".slick-pane-top .slick-row {   color: #11FF11;    }""");
  var opts = {'showHeaderRow': true, 'headerRowHeight': 25, 'frozenRow': 1};
  gw0.init(MetaList(csv.data.sublist(1, 200), getMeta), cols, option: opts);

  gw0.grid.setSelectionModel(RowSelectionModel({'selectActiveRow': false}));
  _setHeaderRow(gw0);
}

///
/// enable column sort
///
List<Column> getColDefs(List<Column> cols) {
  List<Column> newCols = cols.map((col) => Column.fromColumn(col)..sortable = true).toList();
  CheckboxSelectColumn checkboxCol = CheckboxSelectColumn({'cssClass': "slick-cell-checkboxsel"});

  newCols.insert(0, checkboxCol.getColumnDefinition());
  return newCols;
}

LinkFormatter(row, cell, value, columnDef, dataContext) {
  return value != null ? "<a  href='#'>z</a>" : "";
}

Map<String, String> getMeta(int row) {
  if (row % 2 == 1) {
    return {"cssClasses": "highlight"};
  } else {
    return {};
  }
}

_setHeaderRow(JGrid jgrid) {
  jgrid.grid.onHeaderRowCellRendered.subscribe((EventData e, Map args) {
    Element headerEl = args['node'];
    headerEl.children.clear();
    Column col = args['column'];
    if (col.id == '_checkbox_selector') return;
    InputElement inputEl = InputElement();
    inputEl.dataset['columnId'] = col.field;
    inputEl.style.width = '90%';
    headerEl.append(inputEl);

    inputEl.onKeyUp.listen((KeyboardEvent ke) {
      // data.setKeyword(col.field,inputEl.value);
//              sg.invalidate();
    });
  });
}
