library slick.editor;

import 'dart:html';
//import 'slick.dart';
import 'slick_grid.dart' show SlickGrid;
import 'slick_column.dart' show Column;
abstract class Editor {
  EditorParm _ep;
  Element $input;
  EditorParm get editorParm => _ep;
  void set editorParm(EditorParm m) {
    _ep = m;
  }

  var defaultValue;

//  String getValue();
//  void setValue(String  value);
  void loadValue(item) {
    defaultValue = item[_ep.columnDef.field] != null ? item[_ep.columnDef.field] : "";
  }

  /**
   * return value from current editor to UI
   */
  String serializeValue();
  ///
  /// write value([state]) back to target row([item]) object 
  ///
  void applyValue(item, state) {
    item[_ep.columnDef.field] = state;
  }

  bool isValueChanged();

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

class EditorParm {
  Element activeCellNode;
  SlickGrid grid;
  Map<String, dynamic> gridPosition;
  Map<String, dynamic> position;
  Column columnDef;
  Function commitChanges;
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
abstract class InputEditor extends Editor {
  InputElement _input;
  InputEditor([_ep]) {
    super._ep = _ep;
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
  }

  void focus() {
    $input.focus();
  }
}

class TextEditor extends InputEditor {
  set editorParm(EditorParm m) {
    super.editorParm = m;
    $input = _input = new InputElement(type: 'text');
    _input.classes.add('editor-text');
    _ep.activeCellNode.append($input);
    _input
      ..onKeyDown.matches(".nav").listen((KeyboardEvent e) {
        if (e.keyCode == KeyCode.LEFT || e.keyCode == KeyCode.RIGHT) {
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

  /**
     * item: a row of data
     */
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

class IntEditor extends InputEditor {
  set editorParm(EditorParm m) {
    super.editorParm = m;
    $input = _input = new InputElement(type: 'number');
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

  /**
     * item: a row of data
     */
  void loadValue(item) {
    super.loadValue(item);
    _input.value = '$defaultValue';
    _input.defaultValue = '$defaultValue';
    _input.select();
  }

  void applyValue(item, state) {
    item[_ep.columnDef.field] = int.parse(state, onError: (_) => item[_ep.columnDef.field]);
  }

  String serializeValue() => _input.value;
  bool isValueChanged() {
    return (!(_input.value == "" && defaultValue == null)) && (_input.value != defaultValue);
  }
}

class DoubleEditor extends IntEditor {
  void applyValue(item, state) {
    item[_ep.columnDef.field] = num.parse(state, (_) => item[_ep.columnDef.field]);
  }

  DoubleEditor([_ep]) : super(_ep);
  set editorParm(EditorParm m) {
    super.editorParm = m;
    _input..pattern = r'^\d{0,2}(\.\d{0,2}){0,1}$';
  }
}

/**
 * source data type: bool
 */
class CheckboxEditor extends InputEditor {
  // set editorParm (m) => _ep = new EditorParm(m);
  CheckboxEditor([_ep]) : super(_ep) {
    $input = _input = new InputElement(type: 'checkbox');
    $input.classes.add('editor-checkbox');
    _ep.activeCellNode.append($input);
    $input //..attributes['value'] = 'true'
      ..attributes['hidefocus'] = 'true';
    $input.focus();
  }

  loadValue(item) {
    super.loadValue(item);
    //$input.value ='$defaultValue';
    _input.defaultValue = '$defaultValue';
    if ((defaultValue is String && defaultValue.toLowerCase() == 'true') || (defaultValue is bool && defaultValue)) {
      $input.attributes['checked'] = 'checked';
    } else {
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

/**
 * default select option
 * data type: accept int and string type from src data
 * display name: always string
 */
class SelectListEditor extends Editor {
  Map _opts;

  Map validate() {
    return {'valid': true, 'msg': null};
  }

  void destroy() => $input.remove();
  void focus() => $input.focus();
  set editorParm(EditorParm m) {
    super.editorParm = m;
    $input = new SelectElement();
    _opts.forEach((key, dispVal) => $input.children.add(new OptionElement()
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
      ope =
          $input.children.firstWhere((_) => int.parse((_ as OptionElement).value) == item[editorParm.columnDef.field]);
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
