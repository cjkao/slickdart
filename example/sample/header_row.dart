import 'dart:html';
import 'package:slickdart/slick.dart' as cj;
import 'dart:math' as math;
import 'package:slickdart/plugin.dart';
//import 'package:throttle_debounce/throttle_debounce.dart';

void main() {
  cj.SlickGrid grid = init();
  grid.init();
  querySelector('#reset').onClick.listen((e) {
    cj.FilteredList _data = cj.FilteredList();
    for (var i = 0; i < 50000; i++) {
      _data.add({
        'dtitle': math.Random().nextInt(100).toString(),
        'duration': math.Random().nextInt(100),
        'pc2': math.Random().nextInt(10) * 100,
        'pc': (math.Random().nextInt(10) * 100).toString(),
        'start': "01/01/2009",
        'finish': (math.Random().nextInt(10) + 10).toString() + "/05/2013",
        'effortDriven': (i % 5 == 0)
      });
    }
    grid.data.clear();
    grid.data.addAll(_data);
    grid.invalidate();
//    grid.render();
  });
}

cj.SlickGrid init() {
  Element el = querySelector('#grid');
  List<cj.Column> column = [
    cj.Column.fromMap({'id': "title", 'name': "Title1", 'field': "dtitle", 'sortable': true}),
    cj.Column.fromMap(
        {'width': 120, 'id': "duration", 'name': "duration", 'field': "duration", 'sortable': true, 'editor': 'TextEditor'}),
    cj.Column.fromMap({'id': "%", 'name': "int (nubmer)", 'field': "pc2", 'sortable': true, 'editor': 'TextEditor'}),
    cj.Column.fromMap({'id': "start", 'name': "finish", 'field': "finish"}),
    cj.Column.fromMap({'id': "%_2", 'name': "String (number)", 'field': "pc", 'editor': 'TextEditor'}),
    cj.Column.fromMap({'id': "effort", 'name': "(bool)", 'field': "effortDriven", 'width': 300})
  ];
  //cj.CheckboxSelectColumn checkboxCol= cj.CheckboxSelectColumn({   'cssClass': "slick-cell-checkboxsel" });
  // column.insert(0,checkboxCol.getColumnDefinition());
  cj.FilteredList data = cj.FilteredList();
  for (var i = 0; i < 55; i++) {
    data.add({
      'dtitle': math.Random().nextInt(100).toString(),
      'duration': math.Random().nextInt(100),
      'pc2': math.Random().nextInt(10) * 100,
      'pc': (math.Random().nextInt(10) * 100).toString(),
      'start': "01/01/2009",
      'finish': (math.Random().nextInt(10) + 10).toString() + "/05/2013",
      'effortDriven': (i % 5 == 0)
    });
  }
  Map opt = {
    'explicitInitialization': false,
    'multiColumnSort': true,
    'editable': true,
    'autoEdit': true,
    'frozenColumn': 1,
    'showHeaderRow': true,
    'headerRowHeight': 25
  };
  cj.SlickGrid sg = cj.SlickGrid(el, data, column, opt);
  sg.setSelectionModel(cj.RowSelectionModel({'selectActiveRow': false}));
  sg.registerPlugin(AutoTooltips());

//  sg.onSelectedRowsChanged.subscribe((cj.EventData e,Map args){
//          querySelector('.right-pane')..children.clear()..appendText((args['rows'] as List).join(' '));
//  });

  sg.onHeaderRowCellRendered.subscribe((cj.EventData e, Map args) {
    Element headerEl = args['node'];
    headerEl.children.clear();
    cj.Column col = args['column'];
    if (col.id == '_checkbox_selector') return;
    InputElement inputEl = InputElement();
    inputEl.dataset['columnId'] = col.field;
    headerEl.append(inputEl);
    // int counter = 0;
//    var callback =
//    var debounce =
//     Debouncer(const Duration(milliseconds: 300), (List args) {
//      if(col.field=="effortDriven"){
//          if( inputEl.value.toLowerCase() == "true")    data.addKeyword(col.field,  true);
//          else if (inputEl.value.toLowerCase() == "false")data.addKeyword(col.field,  false);
//          else data.addKeyword(col.field,  ""); //clear input filter
//      }else{
//
//        data.addKeyword(col.field, inputEl.value);
//      }
//      sg.invalidate();
//      counter++;
//      print("$counter ${inputEl.value}");
//    }, [], false);
//    inputEl.onKeyUp.listen((e) {
//      debounce.debounce();
//    });
  });
  sg.onSort.subscribe(cj.basicSorter);
  return sg;
}
