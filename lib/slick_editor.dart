library slick.editor;
import 'dart:html';
import 'slick.dart' as grid;

abstract class Editor{
  EditorParm _ep;
  Element $input;

  set editorParm (Map m) => _ep = new EditorParm(m);

  var defaultValue;

//  String getValue();
//  void setValue(String  value);
  void loadValue(item){
    defaultValue = item[_ep.columnDef.field]!=null ?  item[_ep.columnDef.field] :   "";
  }
  /**
   * return value from current editor
   */
  String serializeValue();
  /**
   * update value to target attribute of row object
   */
  void applyValue(item, state){
    item[_ep.columnDef.field] = state;
  }
  bool isValueChanged();

  Map validate();
  bool show(){
    this.$input.style.visibility='visible';
    return true;
  }
  bool hide(){
    this.$input.style.visibility='hidden';
    return true;
  }
  void destroy();
  void focus();
}

class EditorParm{
  Element activeCellNode;
  grid.SlickGrid grid;
  Map<String,dynamic> gridPosition;
    Map<String,dynamic> position;
    grid.Column columnDef;
    Function commitChanges;
    Function cancelChanges;

  EditorParm(Map<String,dynamic> ep){
    activeCellNode = ep['activeCellNode'];
    grid = ep['grid'];
    gridPosition = ep['gridPosition'];
    position = ep['position'];
    columnDef = ep['columnDef'];
    commitChanges = ep['commitChanges'];
    cancelChanges = ep['cancelChanges'];
  }
}

abstract class InputEditor extends Editor{
  InputEditor([_ep]){
    super._ep=_ep;
  }
  InputElement $input;
  Map validate() {
    if (_ep.columnDef.validator !=null) {
      var validationResults = _ep.columnDef.validator($input.value);
      if (!validationResults.valid) {
        return validationResults;
      }
    }

    return {
      'valid': true,
      'msg': null
    };
  }
  void destroy(){
    $input.remove();
  }
  void focus(){
    $input.focus();
  }
}

class TextEditor extends InputEditor{
    TextEditor([_ep]) :super(_ep){
      if(_ep!=null){
        $input = new InputElement(type:'text');
        $input.classes.add('editor-text');
        _ep.activeCellNode.append($input);
        $input..onKeyDown.matches(".nav").
        listen((KeyboardEvent e){
          if(e.keyCode == KeyCode.LEFT || e.keyCode == KeyCode.RIGHT){
            e.stopImmediatePropagation();
          }
        })
        ..focus()
        ..select();
      }
    }

    void destroy  () {
      $input.remove();
    }

    void focus() {
      $input.focus();
    }

    String getValue() {
      return $input.value;
    }
//
//    void setValue(String val) {
//      $input.value=val;
//    }
    /**
     * item: a row of data
     */
    void loadValue(item) {
      super.loadValue(item);
      $input.value =defaultValue;
      $input.defaultValue = defaultValue;
      $input.select();
    }

    String serializeValue() {
      return $input.value;
    }

    void applyValue(item, state) {
      item[_ep.columnDef.field] = state;
    }

    bool isValueChanged() {
      return (!($input.value == "" && defaultValue == null)) && ($input.value != defaultValue);
    }



  }

class CheckboxEditor extends InputEditor {

  set editorParm (Map m) => _ep = new EditorParm(m);
  CheckboxEditor([_ep]) :super(_ep){
    $input = new InputElement(type: 'checkbox');
    $input.classes.add('editor-checkbox');
    _ep.activeCellNode.append($input);
    $input..attributes['value'] = 'true'
           ..attributes['hidefocus'] = 'true';
    $input.focus();
  }

  loadValue(item) {
    super.loadValue(item);
    $input.value =defaultValue;
    $input.defaultValue = defaultValue;

//    if (defaultValue) {
//      $input.attributes['checked']= 'true';
//    } else {
//      $input.attributes['checked']= 'false';
//    }
  }

  String serializeValue() {
    return $input.attributes['checked'];
  }


  isValueChanged() {
    return (!($input.value == "" && defaultValue == null)) && ($input.value != defaultValue);
  }

}
