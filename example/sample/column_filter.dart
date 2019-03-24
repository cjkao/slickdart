import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;

String searchStr = '';
grid.FilteredList srcData = new grid.FilteredList();


String alertFormatter(int row, int cell, value, grid.Column columnDef, Map dataRow) {
  if (dataRow['_height'] != null && dataRow['_height'] > 70) {
    return '''
        <p style=' white-space: normal;'>CSS word-wrapping in div</p>
        <div class="btn-group btn-group-xs">
         <button type="button" class="btn btn-default">Left</button>
        <button type="button" class="btn btn-default">Middle</button>
        </div>
        <div>
          <span class="label label-warning">Check:${value}</span>
        </div>
        ''';
  } else {
    return value > 5
        ? '<span class="label label-success">Success</span>'
        : '<span class="label label-default">Default</span>';
  }
}

grid.SlickGrid makeGrid() {
  Element el = querySelector('#grid');
  List<grid.Column> column = new grid.ColumnList.fromMap([
    {'field': "title", 'sortable': true, 'width': 20},
    {'field': "percentComplete", 'width': 120, 'formatter': alertFormatter},
    {'field': "book", 'sortable': true, 'editor': 'TextEditor'},
    {'field': "finish"},
    {'field': "effortDriven", 'sortable': true},
    {'field': "duration", 'sortable': true},
    {'field': "start", 'sortable': true},
    {'field': "boolean", 'sortable': true}
  ]);

  for (var i = 0; i < 500; i++) {
    srcData.add({
      'title': i + 1,
      'duration': 'd ${i*100}',
      'percentComplete': new math.Random().nextInt(10),
      'start': "01/01/20${i} ${new String.fromCharCode(new math.Random().nextInt(4) + 65) }"
          "${new String.fromCharCode(new math.Random().nextInt(4) + 97) }",
      'finish': "01/05/21${i+1}",
      'book': "$i${new math.Random().nextInt(5)}",
      'effortDriven': (i % 5 == 0),
      'boolean': (i % 5 == 0)
    });
    if (i % 2 == 0) {
      srcData[i]['_height'] = 50 + new math.Random().nextInt(100);
    } else {}
  }

  var opt = new grid.GridOptions()
    ..explicitInitialization = false
    ..multiSelect = false
    ..multiColumnSort = false
    ..dynamicHeight = true
    ..frozenColumn = 0;
  grid.SlickGrid sg;
  Map<String, String> getMeta(int row) {
    Map item = sg.data[row];
    bool exist = item.values.any((_) => searchStr.isNotEmpty  && _ is String && _.contains(searchStr));
    if (exist) {
      return {"cssClasses": "highlight"};
    } else if (row % 2 == 5) {
      return {};
    } else {
      return {"cssClasses": "not-edit"};
    }
  }

  sg = new grid.SlickGrid.fromOpt(el, new grid.MetaList(srcData, getMeta), column, opt);

  grid.RowSelectionModel rsm = new grid.RowSelectionModel({'selectActiveRow': true});
  sg.onSelectedRowsChanged.subscribe((var e, args) {
    rsm.getSelectedRows().forEach(print);
  });
  sg.setSelectionModel(rsm);

  sg.onSort.subscribe(grid.basicSorter);

  return sg;
}



void main() {




  srcData.ignoreCase = true;
  grid.SlickGrid sg = makeGrid();
  sg.init();
  document.querySelector('#search').onInput.listen((Event ke) {
    searchStr = (ke.currentTarget as InputElement).value;
    sg.invalidate();
  });
  document.querySelector('#filter').onClick.listen((Event ke) {
    srcData.keyword = {'start': searchStr};
    sg.resetDynHeight();
    sg.invalidate();
  });
  document.querySelector('#header').onClick.listen((Event ke) {
    var style = querySelector('#style');
    if (style.text.length < 10) {
      style.appendText("""
    #grid .slick-header-column.ui-state-default {
      height: 0px;
      padding: 0px;
    }
    """);
    } else {
      style.text = "";
    }
    sg.resizeCanvas();
    sg.invalidate();
  });
}