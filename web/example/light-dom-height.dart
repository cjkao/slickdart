import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;
import 'package:slickdart/slick_editor.dart';
import 'package:slickdart/slick_selectionmodel.dart';
void main() {
  grid.SlickGrid  g=init();
  g.init();
}

grid.SlickGrid init(){
  Element el =querySelector('#grid');
  List column = [
       new grid.Column.fromMap ({ 'field': "dtitle", 'sortable': true,'editor': 'TextEditor' }),
       new grid.Column.fromMap ({'width':120, 'field': "duration", 'sortable': true }),
       new grid.Column.fromMap ({'field': "StartDate", 'width':140,'editor': new DateEditor()}),
       new grid.Column.fromMap ({'id': "%", 'name': "percent", 'field': "pc", 'sortable': true }),
       new grid.Column.fromMap ({'name':'List Editor','field': "City",'width':100, 'editor': new SelectListEditor({"NY":"New York", "TPE":"Taipei"})}),
  ];
  List data=[];
  for (var i = 0; i < 50; i++) {
    data.add( {
      'dtitle':  new math.Random().nextInt(100).toString(),
      'duration': new math.Random().nextInt(100),
      'pc': new math.Random().nextInt(10) * 100,
      'City': "NY",
      'StartDate': '2012/01/31'
    });
  }
  grid.GridOptions opt=new grid.GridOptions()
      ..forceFitColumns=false
      ..editable=true
      ..enableColumnReorder = true
      ..multiColumnSort=true
      ..enableColumnReorder=true;
  grid.SlickGrid sg= new grid.SlickGrid.fromOpt(el,data,column,opt);

  sg.setSelectionModel(new CellSelectionModel(sg.options));

  sg.onBeforeEditCell.subscribe((e,args){
    print(args['column']);
  });
  sg.onSort.subscribe( (e, args) {
    sg.commitCurrentEdit();
    var cols = args['sortCols'];
    data.sort( (dataRow1, dataRow2) {
      for (var i = 0, l = cols.length; i < l; i++) {
        var field = cols[i]['sortCol']['field'];
        var sign = cols[i]['sortAsc'] ? 1 : -1;
        dynamic value1 = dataRow1[field], value2 = dataRow2[field];
        if(field=='dtitle') {
          return value1 == value2 ? 0 : (int.parse(value1) > int.parse(value2) ? 1: -1)* sign;
        }
        var result = (value1 == value2 ? 0 : (value1.compareTo(value2)>0 ? 1 : -1)) * sign;
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
      return {
        'valid': true,
        'msg': null
      };
    }
  void destroy()=>   $input.remove();
  void focus()=>  $input.focus();
  set editorParm (EditorParm m) {
    super.editorParm=m;
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
    $input.attributes['value']= (item[this.editorParm.columnDef.field] as String).replaceAll('/', '-');
  }
  String serializeValue() {
    return '2013/09/16';
  }
  void applyValue(item, state){
  }

  isValueChanged() {
    return true;
  }

}
