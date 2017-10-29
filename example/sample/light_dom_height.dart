import 'dart:html';
import 'package:slickdart/slick.dart' ;
import 'dart:math' as math;

void main() {
  SlickGrid g = init();
  g.init();
}

SlickGrid init() {
  Element el = querySelector('#grid');
  List<Column> column = [
    new Column.fromMap({'field': "dtitle", 'sortable': true, 'editor': 'TextEditor'}),
    new Column.fromMap({'width': 120, 'field': "duration", 'sortable': true}),
    new Column.fromMap({'field': "StartDate", 'width': 140, 'editor': new DateEditor()}),
    new Column.fromMap({'id': "%", 'name': "percent", 'field': "pc", 'sortable': true}),
    new Column.fromMap({
      'name': 'List Editor',
      'field': "City",
      'width': 100,
      'editor': new SelectListEditor({"NY": "New York", "TPE": "Taipei"})
    }),
  ];
  List data = [];
  for (var i = 0; i < 50; i++) {
    data.add({
      'dtitle': new math.Random().nextInt(100).toString(),
      'duration': new math.Random().nextInt(100),
      'pc': new math.Random().nextInt(10) * 100,
      'City': "NY",
      'StartDate': '2012/01/31'
    });
  }
  GridOptions opt = new GridOptions()
    ..forceFitColumns = false
    ..editable = true
    ..enableColumnReorder = true
    ..multiColumnSort = true
    ..enableColumnReorder = true;
  SlickGrid sg = new SlickGrid.fromOpt(el, data, column, opt);

  sg.setSelectionModel(new RowSelectionModel(sg.options));

  sg.onBeforeEditCell.subscribe((e, args) {
    print(args['column']);
  });
  sg.onSort.subscribe(basicSorter);

  return sg;
}

/**
 * default select option
 * data type: accept int and string type from src data
 * display name: always string
 */
class DateEditor extends Editor {
  // Map _opts;

  Map validate() {
    return {'valid': true, 'msg': null};
  }

  void destroy() => $input.remove();
  void focus() => $input.focus();
  set editorParm(EditorParm m) {
    super.editorParm = m;
    $input = new DateInputElement(); //
    editorParm.activeCellNode.append($input);
    $input..attributes['hidefocus'] = 'true';
    $input.focus();
  }

  /**
   * opt: { option_value: option_display_name,....}
   */
  DateEditor();

  loadValue(item) {
    super.loadValue(item);
    $input.attributes['value'] = (item[this.editorParm.columnDef.field] as String).replaceAll('/', '-');
  }

  String serializeValue() {
    return '2013/09/16';
  }

  void applyValue(item, state) {}

  isValueChanged() {
    return true;
  }
}
