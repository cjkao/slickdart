import 'dart:html';
import 'dart:math' as math;
import "package:slickdart/slick.dart";
import 'package:logging/logging.dart';
import 'dart:convert';
// import 'dart:async';

final int TOP_ROW = 2;

// Map<String, Map<String, dynamic>> getMeta(int row) {
Map<String, dynamic> getMeta(int row) {
  if (headerFormat["header"].containsKey('$row')) {
    return {
      MetaList.COLUMN: headerFormat["header"]['$row'],
      MetaList.COLUMN_CSS: headerFormat["headerCss"]['$row'] ?? {}
    };
  }
  return {};
}

SlickGrid g = buildGrid();
Map<String, Map<String, dynamic>> headerFormat = {};
main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  headerFormat = new Map<String, Map<String, dynamic>>.from(
      json.decode(await HttpRequest.getString('cell_span_head.json')));
  g.init();
  querySelector('#reset').onClick.listen((e) {
    List _data = genData(50000);
    var metaList = new MetaList(_data, getMeta);
    g.data = metaList;
    g.invalidate();
    g.render();
  });
  querySelector('#commit').onClick.listen((e) {
    g.getEditorLock().commitCurrentEdit();
  });
}

SlickGrid buildGrid() {
  Element el = querySelector('#grid');
  List<Column> columnList = new ColumnList.fromMap([
    {
      'width': 130,
      'field': "idi",
      'name': 'ID',
      'sortable': true,
      'editor': 'TextEditor'
    },
    {
      'width': 120,
      'field': "duration",
      'sortable': true,
      'editor': 'TextEditor'
    },
    {'field': "pc", 'sortable': true},
    {'width': 100, 'field': "Long_Text"},
    {'width': 100, 'field': "a1", "formatter": CenterFormatter},
    {'width': 100, 'field': "a2"},
    {'field': "a3"},
    {'field': "a4"},
    {'field': "a5"},
    {'field': "a6"},
    {'field': "a7"},
    {'field': "a8"},
    {'field': "a9"},
    {'field': "a10"},
    {'field': "b1"},
    {'field': "b2"},
    {'field': "b3"},
    {'field': "b4"},
    {'field': "b5"},
    {'field': "b6"},
    {'field': "b7"},
    {'field': "b8"},
    {'field': "b9"},
    {'field': "b10"},
    {'field': "c1"},
    {'field': "c2"},
    {'field': "c3"},
    {'field': "c4"},
    {'field': "c5"},
    {'field': "c6"},
    {'field': "c7"},
    {'field': "c8"},
    {'field': "c9"},
    {'field': "d10"},
    {'field': "d1"},
    {'field': "d2"},
    {'field': "d3"},
    {'field': "d4"},
    {'field': "d5"},
    {'field': "d6"},
    {'field': "d7"},
    {'field': "d8"},
    {'field': "d9"},
    {'field': "d10"},
  ]);
  //CheckboxSelectColumn checkboxCol=new CheckboxSelectColumn({   'cssClass': "slick-cell-checkboxsel" });
  //column.insert(0,checkboxCol.getColumnDefinition());
  List data = genData(500);

  var metaList = new MetaList(data, getMeta);
  var opt = new GridOptions()
    ..explicitInitialization = false
    ..multiColumnSort = false
    ..multiSelect = false
    ..editable = true
    ..autoEdit = false
    ..enableColumnReorder = true
    ..frozenColumn = 0
    ..frozenRow = TOP_ROW + 1
    ..showHeaderRow = true
    ..showTopPanel = true..defaultColumnWidth=40;

  SlickGrid sg = new SlickGrid.fromOpt(el, metaList, columnList, opt);
  var cellSelectModel = new CellSelectionModel();

  /// update merged block
  cellSelectModel.onSelectedRangesChanged.subscribe((var e, args) {
    cellSelectModel.getSelectedRanges().forEach(print);
    var ranges = cellSelectModel.getSelectedRanges();
    if (ranges.isEmpty) return;
    var range = ranges.first;
    var fromCell = '${range.fromCell}';
    int len = range.toCell - range.fromCell + 1;
    var fromRow = '${range.fromRow}';
    int vLen = range.toRow - range.fromRow + 1;
    if (len > 1 || vLen > 1) {
      headerFormat["header"][fromRow] ??= {};
      headerFormat["headerCss"][fromRow] ??= {};
      if (!headerFormat["header"][fromRow].containsKey(fromCell)) {
        //this is not init used index
        var field1 = sg.getColumns()[range.fromCell].field;
        headerFormat["header"][fromRow][field1] = len;
        if (vLen > 1) {
          headerFormat["header"][fromRow][field1 + "!"] = vLen;
        }
        headerFormat["headerCss"][fromRow][field1] = "merged";
        // print(json.encode(headerStructure));
        JsonEncoder encoder = new JsonEncoder.withIndent('  ');
        String ppty = encoder.convert(headerFormat);

        querySelector("code#head").text = ppty;
        print(ppty);
        sg.invalidate();
      }
    }
  });
  sg.setSelectionModel(cellSelectModel);

  return sg;
}

TFormatter get CenterFormatter =>
    (int row, int cell, dynamic value, Column columnDef, dataContext) {
      if (row < TOP_ROW) return '<span class="center">$value</span>';
      return "$value";
    };
String veryLongString = """
'a1': i+10,
      'a2': i+40,
      'a3': i+30,
      'a4': i+20,
      'a5': i+50,
      'a6': i+50,
      'a7': i+50,
      'a8': i+30,
      'a9': i+20,
""";
List genData(int count) {
  List data = [];
  for (var i = 0; i < count; i++) {
    data.add({
      'title': new math.Random().nextInt(100).toString(),
      'duration': new math.Random().nextInt(100).toString(),
      'pc': new math.Random().nextInt(10) * 100,
      'idi': i + 1,
      'Long_Text':
          (new math.Random().nextInt(10) + 10).toString() + veryLongString,
      'a1': i + 10,
      'a2': i + 40,
      'a3': i + 30,
      'a4': i % 20,
      'a5': i % 50,
      'a6': i % 50,
      'a7': i % 50,
      'a8': i % 30,
      'a9': i + 20,
      'a10': i + 51,
      'b1': i + 10,
      'b2': i + 40,
      'b3': i + 30,
      'b4': i + 20,
      'b5': i % 51,
      'b6': i % 51,
      'b7': i % 51,
      'b8': i % 31,
      'b9': i % 21,
      'b10': i + 51,
      'c1': i * 10,
      'c2': i * 40,
      'c3': i * 30,
      'c4': i * 20,
      'c5': i % 50,
      'c6': i % 50,
      'c7': i % 50,
      'c8': i % 30,
      'c9': i % 20,
      'c10': i % 51,
      'd1': i % 100,
      'd2': i % 400,
      'd3': i % 300,
      'd4': i % 200,
      'd5': i % 500,
      'd6': i % 500,
      'd7': i % 500,
      'd8': i % 300,
      'd9': i - 20,
      'd10': i - 51,
    });
  }
  return data;
}
