library slick.editor;
import 'dart:html';
import 'slick.dart';

abstract class Editor{
  EditorParm _ep;
  Element $input;
  EditorParm get editorParm => _ep;
  void set editorParm (EditorParm m) {
    _ep = m;

  }
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
  SlickGrid grid;
  Map<String,dynamic> gridPosition;
    Map<String,dynamic> position;
    Column columnDef;
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
  set editorParm (EditorParm m) {
      super.editorParm=m;
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
    TextEditor([_ep]) :super(_ep);

    String getValue() {
      return $input.value;
    }
    /**
     * item: a row of data
     */
    void loadValue(item) {
      super.loadValue(item);
      $input.value ='$defaultValue';
      $input.defaultValue = '$defaultValue';
      $input.select();
    }

    String serializeValue() => $input.value;
    bool isValueChanged() {
      return (!($input.value == "" && defaultValue == null)) && ($input.value != defaultValue);
    }
  }
/**
 * source data type: bool
 */
class CheckboxEditor extends InputEditor {

 // set editorParm (m) => _ep = new EditorParm(m);
  CheckboxEditor([_ep]) :super(_ep){
    $input = new InputElement(type: 'checkbox');
    $input.classes.add('editor-checkbox');
    _ep.activeCellNode.append($input);
    $input  //..attributes['value'] = 'true'
           ..attributes['hidefocus'] = 'true';
    $input.focus();
  }

  loadValue(item) {
    super.loadValue(item);
    //$input.value ='$defaultValue';
    $input.defaultValue = '$defaultValue';
    if ( ( defaultValue is String && defaultValue.toLowerCase() == 'true') || (defaultValue is bool && defaultValue) ) {
      $input.attributes['checked']= 'checked';
    } else {
      $input.attributes.remove('checked');
    }
  }

  String serializeValue() {
    if($input.checked) return 'true';
    return'false';
  }
  void applyValue(item, state){
      item[_ep.columnDef.field] = state == 'true' ? true : false;
  }

  isValueChanged() {
    return $input.checked.toString() != $input.defaultValue.toLowerCase();
//    return (!($input.value == "" && defaultValue == null)) && ($input.value != defaultValue);
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
      return {
        'valid': true,
        'msg': null
      };
    }
  void destroy()=>   $input.remove();
  void focus()=>  $input.focus();
  set editorParm (EditorParm m) {
    super.editorParm=m;
    $input = new SelectElement();
    _opts.forEach((key,dispVal)=>  $input.children.add(new OptionElement()..value='$key'..text=dispVal));
    editorParm.activeCellNode.append($input);
    $input.classes.add('editor-select');
    $input..attributes['hidefocus'] = 'true';
    $input.focus();
  }

  /**
   * opt: { option_value: option_display_name,....}
   */
  SelectListEditor([this._opts]);

  loadValue(item) {
    super.loadValue(item);
    OptionElement ope;
      if(_opts.keys.first is int){
        ope=$input.children.firstWhere((_)=> int.parse(_.value)== item[editorParm.columnDef.field]);
      }else{
        ope=$input.children.firstWhere((_)=> _.value == item[editorParm.columnDef.field]);
      }
      ope.selected=true;
  }
  String serializeValue() {
    SelectElement se=$input as SelectElement;
    return '${se.options[se.selectedIndex].value}';
  }
  void applyValue(item, state){
    if(_opts.keys.first is int){
      item[editorParm.columnDef.field] = int.parse(state);
    }else{
      super.applyValue(item, state);
    }
  }

  isValueChanged() {
    SelectElement se = $input as SelectElement;
    return defaultValue != se.options[se.selectedIndex].value;
  }

}



