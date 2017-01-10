import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;
import 'package:slickdart/slick_editor.dart';
import 'package:slickdart/slick_selectionmodel.dart';

//import 'package:bootjack_datepicker/bootjack_datepicker.dart';
//import 'package:datepicker/components/date_input.dart';
//import 'package:polymer/polymer.dart';
void main() {
  grid.SlickGrid g = prepareGrid();
  g.init();
}

grid.SlickGrid prepareGrid() {
  Element el = querySelector('#grid');
  List<grid.Column> column = [
    new grid.Column.fromMap({'name': 'string', 'field': "str", 'sortable': true, 'editor': 'TextEditor'}),
    new grid.Column.fromMap({'field': "int", 'sortable': true, 'editor': 'IntEditor'}),
    new grid.Column.fromMap({'field': "double", 'sortable': true, 'editor': 'DoubleEditor'}),
    new grid.Column.fromMap({
      'name': 'checkbox-str',
      'field': "checkbox2",
      'width': 140,
      'editor': 'CheckboxEditor',
      'formatter': grid.CheckmarkFormatter
    }),
    new grid.Column.fromMap({'name': 'date editor', 'field': "StartDate", 'width': 140, 'editor': new DateEditor()}),
    new grid.Column.fromMap({
      'id': 'checkbox1',
      'field': "checkbox",
      'width': 140,
      'editor': new CheckboxEditor(),
      'formatter': grid.CheckmarkFormatter
    }),
    new grid.Column.fromMap({
      'id': "%",
      'name': "percent",
      'field': "pc",
      'sortable': true,
      'editor': new PercentCompleteEditor(),
      'formatter': grid.PercentCompleteBarFormatter
    }),
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
      'str': rand.nextInt(100).toString(),
      'double': rand.nextInt(100) + 0.1,
      'int': rand.nextInt(10) * 100,
      'pc': rand.nextInt(100),
      'bool': rand.nextBool() ? true : false,
      'checkbox2': rand.nextBool() ? true : false,
      'intlist': rand.nextInt(2),
      'City': "NY",
      'StartDate': '200${i%9}-01-31'
    });
  }
  grid.GridOptions opt = new grid.GridOptions()
    ..forceFitColumns = false
    ..editable = true
    ..enableColumnReorder = true
    ..multiColumnSort = true
    ..enableColumnReorder = true
    ..autoCommitOnBlur = true;
  grid.SlickGrid sg = new grid.SlickGrid.fromOpt(el, data, column, opt);

  sg.setSelectionModel(new RowSelectionModel(sg.options));

  sg.onBeforeEditCell.subscribe((e, args) {
    //swap editor here
    print(args['column']);
  });
  sg.onActiveCellBlur.subscribe((e, args) {
    print(args['old']);
    print(args['new']);
    sg.commitCurrentEdit();
  });
  sg.onSort.subscribe(grid.basicSorter);

  /// 'editor': currentEditor,
  ///        'cellNode': activeCellNode,
  ///        'validationResults': validationResults,
  ///        'row': activeRow,
  ///        'cell': activeCell,
  ///        'column': column
  sg.onValidationError.subscribe((e, dynamic stat) {
    querySelector('.err').text = stat['validationResults']['msg'];
  });
  return sg;
}

///
/// default select option
/// data type: accept int and string type from src data
/// display name: always string
///
class DateEditor extends InputEditor {
  // Map _opts;

  Map validate() {
    var date = ($input as DateInputElement).valueAsDate;
    return {'valid': date.isAfter(new DateTime(2012, 01, 08)), 'msg': 'not valid date'};
  }

  //void destroy() => $input.remove();
  //void focus() => $input.focus();
  set editorParm(EditorParm m) {
    super.editorParm = m;
    ($input as InputElement).type = 'date';
    m.activeCellNode.append($input);
    $input..attributes['hidefocus'] = 'true';
    $input.focus();
  }

  /**
   * opt: { option_value: option_display_name,....}
   */
  DateEditor();

  loadValue(item) {
    super.loadValue(item);
    var dateStr = (item[this.editorParm.columnDef.field] as String).replaceAll('/', '-');
    ($input as DateInputElement)
      ..value = dateStr
      ..min = '2012-01-08';
//      ..max = '2012-01-20';
  }

  String serializeValue() {
    print(($input as DateInputElement).value);
    //return '2013/09/16';
    return ($input as DateInputElement).valueAsDate?.toIso8601String()?.split("T")?.first;
  }

  void applyValue(item, state) {
    if (state != null) super.applyValue(item, state);
  }

  bool isValueChanged() {
    var value = ($input as DateInputElement).value;
    return value != '' && this.defaultValue != value;
  }
}

///percent editor
///
class PercentCompleteEditor extends Editor {
  Element $picker;
  TextInputElement _$input;
  set editorParm(EditorParm m) {
    super.editorParm = m;
    //$input = new DateInputElement(); //
    $input = new TextInputElement(); //$("<INPUT type=text class='editor-percentcomplete' />");
    _$input = $input;
    $input.style.width = '${editorParm.activeCellNode.getBoundingClientRect().width-35}px';
    editorParm.activeCellNode.append($input);
    $picker = new DivElement()
      ..classes.add('editor-percentcomplete-picker'); // $("<div class='' />").appendTo(args.container);

    editorParm.activeCellNode.append($picker);
    $input..attributes['hidefocus'] = 'true';
    $input.focus();
  }

  init() {
    /**
     $input.appendTo(args.container);


     $picker.append("<div class='editor-percentcomplete-helper'><div class='editor-percentcomplete-wrapper'><div class='editor-percentcomplete-slider' /><div class='editor-percentcomplete-buttons' /></div></div>");

     $picker.find(".editor-percentcomplete-buttons").append("<button val=0>Not started</button><br/><button val=50>In Progress</button><br/><button val=100>Complete</button>");

     $input.focus().select();

     $picker.find(".editor-percentcomplete-slider").slider({
       orientation: "vertical",
       range: "min",
       value: defaultValue,
       slide: function (event, ui) {
         $input.val(ui.value)
       }
     });

     $picker.find(".editor-percentcomplete-buttons button").bind("click", function (e) {
       $input.val($(this).attr("val"));
       $picker.find(".editor-percentcomplete-slider").slider("value", $(this).attr("val"));
     });
     **/
  }

  destroy() {
    _$input.remove();
    //$picker.remove();
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
    if (state != null) super.applyValue(item, int.parse(state));
  }

  isValueChanged() {
    return _$input.value != defaultValue;
  }

  validate() {
    bool valid = false;
    if (int.parse(_$input.value, onError: (_) => -1) > 0) {
      valid = true;
    }
    if (!valid) {
      return {'valid': false, 'msg': " '${_$input.value}' is not valid, Please enter positive number"};
    }

    return {'valid': true, 'msg': null};
  }
}
