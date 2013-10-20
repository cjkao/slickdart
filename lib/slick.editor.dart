library slick.editor;
import 'dart:html';
import 'slick.grid.dart' as grid;

abstract class Editor{
  Element $input;
  var defaultValue;
//  var scope = this;
//  void init();
  void destroy();
  void focus();
  String getValue();
  void setValue(String  value);
  void loadValue(item);
  String serializeValue();
  void applyValue(item, state);
  bool isValueChanged();
  Map validate();
  void hide();
  void show();
  set editorParm(Map m);

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
//grid: self,
//gridPosition: absBox($container[0]),
//position: absBox(activeCellNode),
//container: activeCellNode,
//column: columnDef,
//item: item || {},
//commitChanges: commitEditAndSetFocus,
//cancelChanges: cancelEditAndSetFocus

class TextEditor extends Editor{
    InputElement $input;
    var defaultValue;
//    var scope = this;
    EditorParm _ep;

    set editorParm (Map m) => _ep = new EditorParm(m);
    TextEditor([this._ep]) {
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

    void setValue(String val) {
      $input.value=val;
    }
    /**
     * item: a row of data
     */
    void loadValue(item) {
      defaultValue = item[_ep.columnDef.field]!=null ?  item[_ep.columnDef.field] :   "";
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
    bool show(){
      this.$input.style.visibility='visible';
    }
    bool hide(){
      this.$input.style.visibility='hidden';
    }
  }