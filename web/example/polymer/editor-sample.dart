library grid.example.polymer;

import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;
import 'package:slickdart/slick_editor.dart';
import 'package:slickdart/slick_selectionmodel.dart';
import 'package:polymer/polymer.dart';
import 'percent_element.dart';
//import 'package:bootjack_datepicker/bootjack_datepicker.dart';
//import 'package:datepicker/components/date_input.dart';
//import 'package:polymer/polymer.dart';
import 'package:polymer_elements/iron_icon.dart';
import 'package:polymer_elements/editor_icons.dart';
import 'dart:async';

main() async {
  await initPolymer();
  grid.SlickGrid g = init();
  g.init();
}

grid.SlickGrid init() {
  Element el = querySelector('#grid');
  List<grid.Column> column = [
    new grid.Column.fromMap({'name': 'text editor', 'field': "dtitle", 'sortable': true, 'editor': 'TextEditor'}),
    new grid.Column.fromMap({'width': 80, 'field': "duration", 'sortable': true, 'editor': 'DoubleEditor'}),
    new grid.Column.fromMap({'name': 'date editor', 'field': "StartDate", 'width': 180, 'editor': new DateEditor()}),
    new grid.Column.fromMap({
      'id': 'checkbox1',
      'field': "checkbox",
      'width': 140,
      'editor': new CheckboxEditor(),
      'formatter': grid.CheckmarkFormatter
    }),
    new grid.Column.fromMap({
      'id': 'checkbox2',
      'name': 'checkbox-str',
      'field': "checkbox2",
      'width': 80,
      'editor': 'CheckboxEditor',
      'formatter': grid.CheckmarkFormatter
    }),
    new grid.Column.fromMap(
        {'id': "%", 'name': "percent", 'field': "pc", 'sortable': true, 'editor': new PercentCompleteEditor()}),
    new grid.Column.fromMap({
      'name': 'int List Editor',
      'field': "intlist",
      'width': 100,
      'editor': new SelectListEditor({0: "Label_0", 1: "Lable_1", 2: "Label_2"})
    }),
    new grid.Column.fromMap({
      'name': 'str List Editor',
      'field': "City",
      'width': 100,
      'editor': new SelectListEditor({"NY": "New York", "TPE": "Taipei"})
    }),
  ];
  List data = [];
  var rand = new math.Random();
  for (var i = 0; i < 50; i++) {
    data.add({
      'dtitle': rand.nextInt(100).toString(),
      'duration': rand.nextInt(100) + 0.1,
      'pc': rand.nextInt(10) * 100,
      'checkbox': rand.nextBool() ? true : false,
      'checkbox2': rand.nextBool() ? true : false,
      'intlist': rand.nextInt(2),
      'City': "NY",
      'StartDate': '2012/01/31'
    });
  }
  grid.GridOptions opt = new grid.GridOptions()
    ..forceFitColumns = false
    ..editable = true
    ..enableColumnReorder = true
    ..multiColumnSort = true
    ..enableColumnReorder = true;
  grid.SlickGrid sg = new grid.SlickGrid.fromOpt(el, data, column, opt);

  sg.setSelectionModel(new RowSelectionModel(sg.options));

  sg.onBeforeEditCell.subscribe((e, args) {
    //swap editor here
    print(args['column']);
  });
  sg.onSort.subscribe((e, args) {
    sg.commitCurrentEdit();
    var cols = args['sortCols'];
//{sortCol: {name: Title1, resizable: true, sortable: true, minWidth: 30, rerenderOnResize: false, headerCssClass: null, defaultSortAsc: true, focusable: true, selectable: true, cannotTriggerInsert: false, width: 80, id: title, field: title}, sortAsc: true}
    data.sort((dataRow1, dataRow2) {
      for (var i = 0, l = cols.length; i < l; i++) {
        var field = cols[i]['sortCol']['field'];
        var sign = cols[i]['sortAsc'] ? 1 : -1;
        dynamic value1 = dataRow1[field], value2 = dataRow2[field];
        if (field == 'dtitle') {
          return value1 == value2 ? 0 : (int.parse(value1) > int.parse(value2) ? 1 : -1) * sign;
        }
        var result = (value1 == value2 ? 0 : (value1.compareTo(value2) > 0 ? 1 : -1)) * sign;
        if (result != 0) {
          return result;
        }
      }
      return 0;
    });
    sg.invalidate();
    sg.render();
  });
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
    //return '2013/09/16';
    return ($input as DateInputElement).valueAsDate?.toIso8601String()?.split("T")?.first;
  }

  void applyValue(item, state) {
    if (state != null) super.applyValue(item, state);
  }

  isValueChanged() {
    return true;
  }
}

///percent editor
///
class PercentCompleteEditor extends Editor {
  Element $picker;
  TextInputElement _$input;
  PercentElement floatMenu = null;
  StreamSubscription floatMenuSelectStream;
  set editorParm(EditorParm m) {
    super.editorParm = m;
    //$input = new DateInputElement(); //
    $input = new TextInputElement(); //$("<INPUT type=text class='editor-percentcomplete' />");
    _$input = $input;
    $input.style.width = '${editorParm.activeCellNode.getBoundingClientRect().width-35}px';
    editorParm.activeCellNode.append($input);
    $picker = new Element.tag('iron-icon');
    $picker.attributes['icon'] = 'editor:format-list-numbered';
    $picker.classes.add('cell');

    $picker.onMouseEnter.listen((_) {
      const id = '_percent';

      if (floatMenu == null) {
        floatMenu = new Element.tag('percent-element');
        floatMenu.id = id;

        querySelector('body').append(floatMenu);
      } else {
        floatMenu = document.querySelector('#${id}');
        floatMenu.hidden = false;
      }

      floatMenuSelectStream?.cancel();
      floatMenuSelectStream = floatMenu.on['percent-change'].listen((_) {
        var val = new CustomEventWrapper(_).detail;
        print(val);
        _$input.value = val;
      });

      ///move menu to cell
      var pos = editorParm.position;
      floatMenu.place(pos['top'], pos['left']);
    });

    editorParm.activeCellNode.append($picker);
    $input..attributes['hidefocus'] = 'true';
    $input.focus();
  }

  init() {}

  destroy() {
    _$input.remove();
    $picker.remove();
    floatMenu?.hidden = true;
  }

  focus() {
    $input.focus();
  }

  loadValue(item) {
    _$input.value = item[this.editorParm.columnDef.field];

    _$input.select();
  }

  serializeValue() {
    return _$input.value;
  }

  applyValue(item, state) {
    if (state != null) super.applyValue(item, state);
  }

  isValueChanged() {
    return _$input.value != defaultValue;
  }

  validate() {
    if (_$input.value.length > 10) {
      return {'valid': false, 'msg': "Please enter a valid positive number"};
    }

    return {'valid': true, 'msg': null};
  }
}
