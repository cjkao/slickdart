import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;

void main() {
  var g = init();
  g.init();
  // print (g.$headerScroller.querySelectorAll('.slick-header-column').length);
}

String AlertFormatter(int row, int cell, dynamic value, grid.Column columnDef, Map dataRow) {
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
    if (value > 5) {
      return '<span class="label label-success">Success</span>';
    } else {
      return '<span class="label label-default">Default</span>';
    }
  }
}

String SplitFormatter(int row, int cell, dynamic value, grid.Column columnDef, Map dataRow) {
  if (dataRow['_height'] != null && dataRow['_height'] > 90) {
    return '''
        <div class="h40">
          bbbbbbb $value
          <span>$cell<span class='important'> $row
        </div>
        <hr/>
        <div>
          aaa
        </div>
        ''';
  } else {
    return "$value";
  }
}

grid.SlickGrid init() {
  Element el = querySelector('#grid');
  List<grid.Column> column = [
    grid.Column.fromMap({'id': "title", 'name': "id", 'field': "title", 'sortable': true, 'width': 20}),
    grid.Column.fromMap({'id': "duration", 'width': 120, 'name': "Alert", 'field': "percentComplete", 'formatter': AlertFormatter}),
    grid.Column.fromMap({'id': "%", 'name': "start3", 'field': "start", 'sortable': true}),
    grid.Column.fromMap({'id': "start", 'name': "4finish", 'field': "finish"}),
    grid.Column.fromMap({'id': "title2", 'name': "5Title1", 'field': "title", 'sortable': true, 'formatter': SplitFormatter})
      ..cssClass = 'nopad',
    grid.Column.fromMap(
        {'id': "duration2", 'width': 120, 'name': "Row Split ", 'field': "percentComplete", 'formatter': SplitFormatter})
      ..cssClass = 'nopad',
    grid.Column.fromMap({'id': "%2", 'name': "7start", 'field': "start", 'sortable': true}),
    grid.Column.fromMap({'id': "start2", 'name': "8finish", 'field': "finish"}),
    grid.Column.fromMap({'id': "start2", 'name': "9finish", 'field': "finish"}),
    grid.Column.fromMap({'id': "title2", 'name': "10 Title1", 'field': "title", 'sortable': true}),
    grid.Column.fromMap(
        {'id': "duration2", 'width': 120, 'name': "11 percentComplete", 'field': "percentComplete", 'sortable': true}),
    grid.Column.fromMap({'id': "%2", 'name': "12 start", 'field': "start", 'sortable': true}),
    grid.Column.fromMap({'id': "start2", 'name': "13 finish", 'field': "finish"}),
    grid.Column.fromMap({'id': "title2", 'name': "14 Title1", 'field': "title", 'sortable': true}),
    grid.Column.fromMap(
        {'id': "duration2", 'width': 120, 'name': "15 percentComplete", 'field': "percentComplete", 'sortable': true}),
    grid.Column.fromMap({'id': "%2", 'name': "16 start", 'field': "start", 'sortable': true})
  ];
  List data = [];
  for (var i = 0; i < 105000; i++) {
    data.add({
      'title': i + 1,
      'duration': 'd ${i * 100}',
      'percentComplete': math.Random().nextInt(10),
      'start': "01/01/20${i}",
      'finish': "01/05/2009",
      'finish1': "01/05/2009 $i",
      'finish2': "01/05/20$i",
      'finish3': "01/05/201$i",
      'finish4': "01/05/202$i",
      'effortDriven': (i % 5 == 0)
    });
    if (i % 2 == 0) {
      data[i]['_height'] = 50 + math.Random().nextInt(100);
    } else {}
  }
  grid.GridOptions opts = grid.GridOptions()
    ..explicitInitialization = false
    ..multiColumnSort = false
    ..dynamicHeight = true;

  grid.SlickGrid sg = grid.SlickGrid.fromOpt(el, data, column, opts);
  sg.onSort.subscribe(grid.basicSorter);

  return sg;
}
