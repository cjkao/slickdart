import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;

String searchStr = '';
List<Map<String, dynamic>> srcData = [];
void main() {
  grid.SlickGrid sg = makeGrid();
  sg.init();
  document.querySelector('#search').onInput.listen((Event ke) {
    searchStr = (ke.currentTarget as InputElement).value;
    sg.invalidate();
    sg.render();
  });
  document.querySelector('#filter').onClick.listen((Event ke) {
    List newList = srcData.where((Map z) {
      if (z.values.any((_) => _ is String && _.contains(searchStr))) return true;
      return false;
    }).toList();
    if (newList.isNotEmpty) {
      print('list len: ${newList.length}');
      sg.data
        ..clear()
        ..addAll(newList);
      sg.resetDynHeight();
      sg.invalidate();
      sg.render();
    } else {
      //show no data
    }
  });

  // print (g.$headerScroller.querySelectorAll('.slick-header-column').length);
}

AlertFormatter(int row, int cell, int value, grid.Column columnDef, Map dataRow) {
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
    return value > 5 ? '<span class="label label-success">Success</span>' : '<span class="label label-default">Default</span>';
  }
}

grid.SlickGrid makeGrid() {
  Element el = querySelector('#grid');
  List<grid.Column> column = grid.ColumnList.fromMap([
    {'field': "title", 'sortable': true, 'width': 20},
    {'field': "percentComplete", 'width': 120, 'formatter': AlertFormatter},
    {'field': "book", 'sortable': true, 'editor': 'TextEditor'},
    {'field': "finish"},
    {'field': "effortDriven", 'sortable': true},
    {'field': "duration", 'sortable': true},
    {'field': "start", 'sortable': true}
  ]);

  for (var i = 0; i < 1500; i++) {
    srcData.add({
      'title': i + 1,
      'duration': 'd ${i * 100}',
      'percentComplete': math.Random().nextInt(10),
      'start': "01/01/20${i}",
      'finish': "01/05/2009",
      'finish1': "01/05/2009 $i",
      'book': "$i${math.Random().nextInt(5)}",
      'effortDriven': (i % 5 == 0)
    });
    if (i % 2 == 0) {
      srcData[i]['_height'] = 50 + math.Random().nextInt(100);
    } else {}
  }
  Map opt = {'explicitInitialization': false, 'multiColumnSort': false, 'dynamicHeight': true, 'frozenColumn': 0};
  grid.SlickGrid sg;
  List tdata = []..addAll(srcData);
  Map<String, String> getMeta(int row) {
    Map item = sg.data[row];
    bool exist = item.values.any((_) => searchStr.isNotEmpty && _ is String && _.contains(searchStr));
    if (exist) {
      return {"cssClasses": "highlight"};
    } else if (row % 2 == 5) {
      return {
//          "columns": {
//            "duration": {
//              "colspan": 3
//            }
//          }
      };
    } else {
      return {
//          "columns": {
//            0: {  "colspan": "*"    }
//          },
        "cssClasses": "not-edit"
      };
    }
  }

  sg = grid.SlickGrid(el, grid.MetaList(tdata, getMeta), column, opt);
  sg.onSort.subscribe(grid.basicSorter);

  return sg;
}
