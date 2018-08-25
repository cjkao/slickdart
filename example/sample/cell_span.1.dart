import 'dart:html';
import 'dart:math' as math;
import "package:slickdart/slick.dart";
import 'package:logging/logging.dart';
final int TOP_ROW=2;
Map<int, Map<String, int>> headerStructure={
   0:{'a1': 4,"a5":3,'b1':5, "duration":1,"duration!":3},
   1:{'a1': 2, 'a3':2},
   2:{'a3':2, "b3":3},
   4:{'a3':2, "b3":3, 'a3!':2},
   8:{'a4':2, 'a4!':3},
};
Map<int, Map<String, String>> headerCss={
   0:{'a1': "c1", "a5":"a5", "duration":"merged"},
   4:{'a3':"merged"},
   8:{'a4':"merged"},
};

Map<String,Map<String,dynamic>> getMeta(int row) {
    if(headerStructure.containsKey(row))
      return {MetaList.COLUMN:headerStructure[row], MetaList.COLUMN_CSS:headerCss[row]?? {}};
  return {};
}

SlickGrid g = buildGrid();
void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  g.init();
  querySelector('#reset').onClick.listen((e) {
  List _data = genData(10000);
    var metaList = new MetaList(_data, getMeta);
    g.data = metaList;
    g.invalidate();
    g.render();
  });
  querySelector('#commit').onClick.listen((e){
     g.getEditorLock().commitCurrentEdit();
  });

}

SlickGrid buildGrid() {
  Element el = querySelector('#grid');
  List<Column> column = new ColumnList.fromMap([
    {'width': 130, 'field': "idi", 'name': 'ID', 'sortable': true, 'editor': 'TextEditor'},
    {'width': 120, 'field': "duration", 'sortable': true, 'editor': 'TextEditor'},
    {'field': "pc", 'sortable': true},
    {'width': 100, 'field': "Long_Text"},
    {'width': 100, 'field': "a1", "formatter":CenterFormatter},
    {'width': 100, 'field': "a2"},
    {'width': 100, 'field': "a3"},
    {'width': 100, 'field': "a4"},
    {'width': 100, 'field': "a5"},
    {'width': 100, 'field': "a6"},
    {'width': 100, 'field': "a7"},
    {'width': 100, 'field': "a8"},
    {'width': 100, 'field': "a9"},
    {'width': 100, 'field': "a10"},
    {'width': 100, 'field': "b1"},
    {'width': 100, 'field': "b2"},
    {'width': 100, 'field': "b3"},
    {'width': 100, 'field': "b4"},
    {'width': 100, 'field': "b5"},
    {'width': 100, 'field': "b6"},
    {'width': 100, 'field': "b7"},
    {'width': 100, 'field': "b8"},
    {'width': 100, 'field': "b9"},
    {'width': 100, 'field': "b10"},
     {'width': 100, 'field': "c1"},
    {'width': 100, 'field': "c2"},
    {'width': 100, 'field': "c3"},
    {'width': 100, 'field': "c4"},
    {'width': 100, 'field': "c5"},
    {'width': 100, 'field': "c6"},
    {'width': 100, 'field': "c7"},
    {'width': 100, 'field': "c8"},
    {'width': 100, 'field': "c9"},
    {'width': 100, 'field': "c10"},
 
  ]);
  //CheckboxSelectColumn checkboxCol=new CheckboxSelectColumn({   'cssClass': "slick-cell-checkboxsel" });
  //column.insert(0,checkboxCol.getColumnDefinition());
  List data = genData(500);
  
  var metaList = new MetaList(data, getMeta);
  var opt = new GridOptions()
    ..explicitInitialization = false
    ..multiColumnSort = false
    ..multiSelect = false
    ..editable = true
    ..autoEdit = false
    ..enableColumnReorder = true
   ..frozenColumn = 0..frozenRow=TOP_ROW+1..rowHeight=20;
  SlickGrid sg = new SlickGrid.fromOpt(el, metaList, column, opt);
  var cellSelectModel = new CellSelectionModel();
  cellSelectModel.onSelectedRangesChanged.subscribe((var e, args) {
    cellSelectModel.getSelectedRanges().forEach(print);
    var ranges=cellSelectModel.getSelectedRanges();
    if(ranges.length==0)return;
    var range=ranges.first;
    int fromCell=range.fromCell;
    int len=range.toCell - fromCell+1;
    int fromRow=range.fromRow;
    int vLen=range.toRow - range.fromRow+1;
    if((len>1 || vLen>1) &&headerStructure.containsKey(fromRow)){
      if(!headerStructure[fromRow].containsKey(fromCell)){ //this is not init used index
        var field1=sg.getColumns()[fromCell].field;
          headerStructure[fromRow][field1]=len;
          if(vLen>1){
            headerStructure[fromRow][field1+"!"]=vLen;
          }
          headerCss[fromRow]??= {};
          headerCss[fromRow][field1]="merged";
          print(headerStructure);
          print(headerCss);
          sg.invalidate();
      }
    }
    
  });
  sg.setSelectionModel(cellSelectModel);
  
  return sg;
}
TFormatter get CenterFormatter=>(int row, int cell, dynamic value, Column columnDef, dataContext) {
  if(row<TOP_ROW)
    return '<span class="center">$value</span>';
  return "$value";
};
String veryLongString= """
'a1': i+10,
      'a2': i+40,
      'a3': i+30,
      'a4': i+20,
      'a5': i+50,
      'a6': i+50,
      'a7': i+50,
      'a8': i+30,
      'a9': i+20,
""";
List genData( int count){
   List data=[];
  for (var i = 0; i < count; i++) {
    data.add({
      'title': new math.Random().nextInt(100).toString(),
      'duration': new math.Random().nextInt(100).toString(),
      'pc': new math.Random().nextInt(10) * 100,
      'idi': i + 1,
      'Long_Text': (new math.Random().nextInt(10) + 10).toString() + veryLongString,
      'a1': i+10,
      'a2': i+40,
      'a3': i+30,
      'a4': i+20,
      'a5': i+50,
      'a6': i+50,
      'a7': i+50,
      'a8': i+30,
      'a9': i+20,
      'a10': i+51,
      'b1': i+10,
      'b2': i+40,
      'b3': i+30,
      'b4': i+20,
      'b5': i+50,
      'b6': i+50,
      'b7': i+50,
      'b8': i+30,
      'b9': i+20,
      'b10': i+51,
 
      'c1': i*10,
      'c2': i*40,
      'c3': i*30,
      'c4': i*20,
      'c5': i-50,
      'c6': i-50,
      'c7': i-50,
      'c8': i-30,
      'c9': i-20,
      'c10': i-51,
    });
  }
  return data;
}