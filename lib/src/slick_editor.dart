library slick.editor;

import 'slick_core.dart' as core;

import 'dart:html';
//import 'slick.dart';
import 'slick_grid.dart' show SlickGrid;
import 'slick_column.dart' show Column;

abstract class Editor {
  EditorParm _ep;
  Element $input;
  EditorParm get editorParm => _ep;
  set editorParm(EditorParm m) {
    _ep = m;
  }

  /// initial value from row
  var defaultValue;

  ///
  /// copy [item] to [defaultValue] when begin edit cell
  ///
  void loadValue(item) {
    defaultValue = item[_ep.columnDef.field] != null ? item[_ep.columnDef.field] : "";
  }

  ///
  /// return value from current editor to UI
  ///
  String serializeValue();

  ///
  /// write value([state]) back to target row([item]) object
  ///
  void applyValue(item, state) {
    item[_ep.columnDef.field] = state;
  }

  bool isValueChanged();

  /// check user input valid or not
  /// it not valid, set invalid class to target cell
  Map validate();
  bool show() {
    this.$input.style.visibility = 'visible';
    return true;
  }

  bool hide() {
    this.$input.style.visibility = 'hidden';
    return true;
  }

  void destroy();
  void focus();
}

///
///  * when user click cell and active editor mode
///  [EditorParm] will pass to [Editor] instance
///  * Can be customize editor, see web/example/polymer/[PercentElement]
///
class EditorParm {
  /// current cell element
  Element activeCellNode;
  SlickGrid grid;
  Map<String, dynamic> gridPosition;

  /// cell position, see [SlickGrid.absBox]
  Map<String, dynamic> position;
  Column columnDef;

  /// call [commitChanges] to commit change  see [SlickGrid.commitEditAndSetFocus]
  Function commitChanges;

  /// [cancelChange] revoke change, see [SlickGrid.cancelEditAndSetFocus]
  Function cancelChanges;

  EditorParm(Map<String, dynamic> ep) {
    activeCellNode = ep['activeCellNode'];
    grid = ep['grid'];
    gridPosition = ep['gridPosition'] as Map<String, dynamic>;
    position = ep['position'] as Map<String, dynamic>;
    columnDef = ep['columnDef'];
    commitChanges = ep['commitChanges'];
    cancelChanges = ep['cancelChanges'];
  }
}

///
/// InputElement based editor
/// add 'onActiveCellBlue' event, can be subscribe for auto commit
abstract class InputEditor extends Editor {
  InputElement _input = InputElement();
  InputEditor([_]) {
    $input = _input;
    _ep = _;
    _input
      ..onBlur.listen((Event _) {
        //  print(_input.classes.contains('keyup'));
        if (_ep.grid.gridOptions.autoCommitOnBlur && !_input.classes.contains('keyup')) {
          var ed = core.EventData.fromDom(_);
          _ep.grid.trigger(_ep.grid.onActiveCellBlur, {'old': defaultValue, 'new': _input.value}, ed);
        }
        _input.classes.remove('keyup');
      })
      ..onKeyUp.listen((_) {
        _input.classes.remove('keyup');
      })
      ..onKeyDown.listen((_) {
        _input.classes.add('keyup');
      });
  }
  Map validate() {
    if (_ep.columnDef.validator != null) {
      var validationResults = _ep.columnDef.validator(($input as InputElement).value);
      if (!validationResults.valid) {
        return validationResults;
      }
    }

    return {'valid': true, 'msg': null};
  }

  void destroy() {
    $input.remove();
    //$input.detached();
  }

  void focus() {
    $input.focus();
  }
}

class TextEditor extends InputEditor {
  set editorParm(EditorParm m) {
    super.editorParm = m;
    $input = _input..type = 'text'; // =  InputElement(type: 'text');
    _input.classes.add('editor-text');
    _ep.activeCellNode.append($input);
    _input
      ..onKeyDown.listen((KeyboardEvent e) {
        //cancel navigation when no selection
        if ((e.keyCode == KeyCode.LEFT || e.keyCode == KeyCode.RIGHT) && _input.selectionEnd == _input.selectionStart) {
          e.stopImmediatePropagation();
        }
      })
      ..focus()
      ..select();
  }

  TextEditor([_ep]) : super(_ep);

  String getValue() {
    return ($input as InputElement).value;
  }

  ///
  ///   item: a row of data
  ///
  void loadValue(item) {
    super.loadValue(item);
    _input
      ..value = '$defaultValue'
      ..defaultValue = '$defaultValue'
      ..select();
  }

  String serializeValue() => _input.value;
  bool isValueChanged() {
    return (!(_input.value == "" && defaultValue == null)) && (_input.value != defaultValue);
  }
}

///
/// Editor that only accept integer value
///
class IntEditor extends InputEditor {
  set editorParm(EditorParm m) {
    super.editorParm = m;
    $input = _input..type = 'number'; // =  InputElement(type: 'number');
    _input
      ..pattern = '[-+]?[0-9]*'
      ..classes.add('editor-text');
    _ep.activeCellNode.append($input);
    ($input as InputElement)
      ..onKeyDown.matches(".nav").listen((KeyboardEvent e) {
        if (e.keyCode == KeyCode.LEFT || e.keyCode == KeyCode.RIGHT) {
          e.stopImmediatePropagation();
        }
      })
      ..focus()
      ..select();
  }

  IntEditor([_ep]) : super(_ep);

  String getValue() {
    return _input.value;
  }

  ///
  ///  item: a row of data
  ///
  void loadValue(item) {
    super.loadValue(item);
    _input.value = '$defaultValue';
    _input.defaultValue = '$defaultValue';
    _input.select();
  }

  void applyValue(item, state) {
    item[_ep.columnDef.field] = int.tryParse(state) ?? item[_ep.columnDef.field];
  }

  String serializeValue() => _input.value;
  bool isValueChanged() {
    return (!(_input.value == "" && defaultValue == null)) && (_input.value != defaultValue);
  }
}

class DoubleEditor extends IntEditor {
  void applyValue(item, state) {
    item[_ep.columnDef.field] = num.tryParse(state) ?? item[_ep.columnDef.field];
  }

  DoubleEditor([_ep]) : super(_ep);
  set editorParm(EditorParm m) {
    super.editorParm = m;
    _input..pattern = r'^\d{0,2}(\.\d{0,2}){0,1}$';
  }
}

///  can be instinate by String of class name or using explict  keyword
///  source data type: bool
///
class CheckboxEditor extends InputEditor {
  // set editorParm (m) => _ep =  EditorParm(m);
  CheckboxEditor([_ep]) : super(_ep) {
    $input = _input..type = 'checkbox'; // =  InputElement(type: 'checkbox');
    $input.classes.add('editor-checkbox');
    _ep?.activeCellNode?.append($input);
    $input //..attributes['value'] = 'true'
      ..attributes['hidefocus'] = 'true';
    $input.focus();
  }
  @override
  set editorParm(EditorParm m) {
    super.editorParm = m;
    editorParm.activeCellNode.append($input);
    $input..attributes['hidefocus'] = 'true';
    $input.focus();
  }

  loadValue(item) {
    super.loadValue(item);
    //$input.value ='$defaultValue';
    _input.defaultValue = '$defaultValue';
    if ((defaultValue is String && defaultValue.toLowerCase() == 'true') || (defaultValue is bool && defaultValue)) {
      $input.attributes['checked'] = 'checked';
      ($input as CheckboxInputElement).checked = true;
    } else {
      ($input as CheckboxInputElement).checked = false;
      $input.attributes.remove('checked');
    }
  }

  String serializeValue() {
    if (_input.checked) return 'true';
    return 'false';
  }

  void applyValue(item, state) {
    item[_ep.columnDef.field] = state == 'true' ? true : false;
  }

  isValueChanged() {
    return _input.checked.toString() != _input.defaultValue.toLowerCase();
  }
}

///
/// default select option
/// data type: accept int and string type from src data
/// display name: always string
///
class SelectListEditor extends Editor {
  Map _opts;

  Map validate() {
    return {'valid': true, 'msg': null};
  }

  void destroy() => $input.remove();
  void focus() => $input.focus();
  set editorParm(EditorParm m) {
    super.editorParm = m;
    $input = SelectElement();
    _opts.forEach((key, dispVal) => $input.children.add(OptionElement()
      ..value = '$key'
      ..text = dispVal));
    editorParm.activeCellNode.append($input);
    $input.classes.add('editor-select');
    $input..attributes['hidefocus'] = 'true';
    $input.focus();
  }

  ///
  /// [opt]: { option_value: option_display_name,....}
  ///
  SelectListEditor([this._opts]);

  loadValue(item) {
    super.loadValue(item);
    OptionElement ope;
    if (_opts.keys.first is int) {
      ope = $input.children.firstWhere((_) => int.parse((_ as OptionElement).value) == item[editorParm.columnDef.field]);
    } else {
      ope = $input.children.firstWhere((_) => (_ as OptionElement).value == item[editorParm.columnDef.field]);
    }
    ope.selected = true;
  }

  String serializeValue() {
    SelectElement se = $input as SelectElement;
    return '${se.options[se.selectedIndex].value}';
  }

  void applyValue(item, state) {
    if (_opts.keys.first is int) {
      item[editorParm.columnDef.field] = int.parse(state);
    } else {
      super.applyValue(item, state);
    }
  }

  isValueChanged() {
    SelectElement se = $input as SelectElement;
    return defaultValue != se.options[se.selectedIndex].value;
  }
}
