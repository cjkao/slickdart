import 'dart:html';
import 'dart:math' as math;
import 'package:slickdart/slick_custom.dart';
import 'package:slickdart/slick.dart';
main(){
  registerElem();

  List _data = [];
   for (var i = 0; i < 500; i++) {
     _data.add({
       'dtitle': new math.Random().nextInt(100).toString(),
       'duration': new math.Random().nextInt(100).toString(),
       'pc2': new math.Random().nextInt(10) * 100,
       'pc': (new math.Random().nextInt(10) * 100).toString(),
       'YesNo': new math.Random().nextInt(10)>5 ? true: false,
       'Three': new math.Random().nextInt(10)>5 ? 11: 12,
       'finish': (new math.Random().nextInt(10) + 10).toString() + "/05/2013",
       'effortDriven': (i % 5 == 0)
     });
   }
   GridWrap gw0 = document.querySelector("$GRID_TAG.second");
   gw0.init(_data.sublist(1,100),getColDefs());
   GridWrap gw = document.querySelector("$GRID_TAG.first");
   gw.init(_data,getColDefs());

   (document.querySelector("$GRID_TAG.third") as GridWrap)..init(_data,getColDefs());
   (document.querySelector("$GRID_TAG.forth") as GridWrap)..init(_data,getColDefs()..removeAt(0));

   gw0.grid.setSelectionModel(new RowSelectionModel({
         'selectActiveRow': false
     }));
   gw0.grid.onSelectedRowsChanged.subscribe((EventData e, Map args) {
       querySelector('.right-pane')
           ..children.clear()
           ..appendText((args['rows'] as List).join(' '));
     });
}

List<Column> getColDefs(){
  var cols= new ColumnList.fromMap([{
        'name': "Title1",
        'field': "dtitle",
        'sortable': true,

      },{
        'width': 80,
        'field': "duration",
        'sortable': true,
        'editor': 'TextEditor'
      },{
        'field': "pc2",
        'sortable': true,
        'editor': 'TextEditor'
      },{
        'field': "finish"
      },{
        'field': "Three",

        'editor': new SelectListEditor()

      },{
        'field': "YesNo",
        'editor': 'CheckboxEditor',
        'formatter': CheckmarkFormatter
      },{
        'id': "%_2",
        'field': "pc",
        'editor': 'TextEditor'

      },{
        'field': "effortDriven",
        'width': 300
      }]);
  CheckboxSelectColumn checkboxCol = new CheckboxSelectColumn({
      'cssClass': "slick-cell-checkboxsel"
    });

  cols.insert(0, checkboxCol.getColumnDefinition());
  return cols;
}
//
class SelectListEditor extends Editor {
  List keys= [12,14,15,16];
  var defaultValue;
  Map validate() {
//      if (ep.columnDef.validator !=null) {
//        var validationResults = ep.columnDef.validator($input.value);
//        if (!validationResults.valid) {
//          return validationResults;
//        }
//      }

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
  set editorParm (Map m) => super.ep = new EditorParm(m);
  SelectListEditor([_ep]) :super(){
    this.ep = _ep;
    $input = new SelectElement();
    keys.forEach((_){
      var option = new OptionElement();
      option.value = '$_';
      option.text= '$_';
      $input.append(option);

    });
    $input.classes.add('editor-select');
    _ep.activeCellNode.append($input);
    $input..attributes['hidefocus'] = 'true';
    $input.focus();
  }

  loadValue(item) {
    super.loadValue(item);
    defaultValue=item;
    OptionElement ope=$input.children.firstWhere((_)=> _.value==item);
    ope.selected=true;
  }

  String serializeValue() {
    int selectIdx=($input as SelectElement).selectedIndex;
    return keys[selectIdx];
  }
  void applyValue(item, state){
      item[ep.columnDef.field] = state;
  }

  isValueChanged() {
    int selectIdx=($input as SelectElement).selectedIndex;
//    return keys[selectIdx];
    return defaultValue != keys[selectIdx];
  }

}