import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;
import 'package:slickdart/slick_selectionmodel.dart';
import 'package:slickdart/slick_column.dart';
void main() {
  grid.SlickGrid  g=init();
  g.init();
  querySelector
  ('#reset').onClick.listen((e){
    List _data=[];
    for (var i = 0; i < 50000; i++) {
      _data.add( {
        'idi':  i,
        'title':  new math.Random().nextInt(1000).toString(),
        'duration': new math.Random().nextInt(1000).toString(),
        'pc': i
      });
    }
    g.data.clear();
    g.data.addAll(_data);
    g.invalidate();
    g.render();

  });
}

grid.SlickGrid init(){
  Element el =querySelector('#grid');
  List column = new ColumnList.fromMap([
                 {'width':130, 'field': "idi", 'sortable': true,'editor': 'TextEditor' },
                 {'width':120, 'field': "duration", 'sortable': true },
                 {'field': "pc", 'sortable': true },
                 {'width':400,  'field': "finish"}
                 ]);
  CheckboxSelectColumn checkboxCol=new CheckboxSelectColumn({   'cssClass': "slick-cell-checkboxsel" });
  column.insert(0,checkboxCol.getColumnDefinition());
  List data=[];
  for (var i = 0; i < 50; i++) {
    data.add( {
      'title':  new math.Random().nextInt(100).toString(),
      'duration': new math.Random().nextInt(100).toString(),
      'pc': new math.Random().nextInt(10) * 100,
      'idi':i+1,
      'finish': (new math.Random().nextInt(10)+10).toString() + "/05/2013",
    });
  }
//  Map opt = {'explicitInitialization': false,
//             'multiColumnSort': false,
//             'editable': true,
//             'autoEdit': false,
//             'frozenColumn': 1
//  };
  var opt = new grid.GridOptions()
                  ..explicitInitialization= false
                  ..multiColumnSort= false
                  ..multiSelect=false
                  ..autoEdit=false
                  ..frozenColumn=1;
  grid.SlickGrid sg= new grid.SlickGrid.fromOpt(el,data,column,opt);
  RowSelectionModel rsm=new RowSelectionModel({'selectActiveRow':true});
  sg.onSelectedRowsChanged.subscribe((var e, args){
    rsm.getSelectedRows().forEach(print);
  });
  sg.setSelectionModel(rsm);
  sg.registerPlugin(checkboxCol);
  //sg.setSelectionModel(new CellSelectionModel(sg.options));


  sg.onSort.subscribe( (e, args) {
    var sRows= sg.getSelectedRows().map((id)=> data[id]).toList();
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
    var sRowIdx=sRows.map((item)=> data.indexOf(item));
    sg.setSelectedRows(sRowIdx.toList());
    sg.invalidate();
    sg.render();
  });
  return sg;
}
