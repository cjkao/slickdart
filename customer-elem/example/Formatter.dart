import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;

void main() {
  grid.SlickGrid  g=init();
  g.init();
//  print (g.$headerScroller.querySelectorAll('.slick-header-column').length);
  querySelector('#reset').onClick.listen((e){
    List _data=[];
    for (var i = 0; i < 50000; i++) {
      _data.add( {
        'dtitle':  new math.Random().nextInt(1000).toString(),
        'duration': new math.Random().nextInt(1000).toString(),
        'pc': new math.Random().nextInt(100),
        'effortDriven': (i % 5 == 0)
      });
    }
    g.data.clear();
    g.data.addAll(_data);
    g.invalidate();
    g.render();

    //print(g.data);
  });
//  querySelector('#reset').onClick.listen((e){
//    print(g.data);
//  });
}

grid.SlickGrid init(){
  Element el =querySelector('#grid');
  List column = [
                 new grid.Column.fromMap ({'id': "title", 'name': "Title1", 'field': "dtitle", 'sortable': true,'editor': 'TextEditor' }),
                 new grid.Column.fromMap ({'width':120,'id': "duration", 'name': "duration", 'field': "duration", 'sortable': true }),
                 new grid.Column.fromMap ({'id': "%", 'name': "percentComplete", 'field': "pc", 'sortable': true, 'formatter': grid.PercentCompleteBarFormatter }),
                 new grid.Column.fromMap ({'id': "effort-driven", 'name': "Effort Driven", 'sortable': false, 'width': 80, 'minWidth': 20, 'maxWidth': 80,
                   'cssClass': "cell-effort-driven", 'field': "effortDriven", 'formatter': grid.CheckmarkFormatter})

                // new grid.Column.fromMap ({'id': "start", 'name': "finish", 'field': "finish"})
                 ];
  List data=[];
  for (var i = 0; i < 5; i++) {
    data.add( {
      'dtitle':  new math.Random().nextInt(100).toString(),
      'duration': new math.Random().nextInt(100).toString(),
      'pc': new math.Random().nextInt(100),
//      'start': "01/01/2009",
//      'finish': (new math.Random().nextInt(10)+10).toString() + "/05/2013",
      'effortDriven': (i % 5 == 0)
    });
  }
  Map opt = {'explicitInitialization': false,
             'multiColumnSort': true,
             'editable': true,
  };
  grid.SlickGrid sg= new grid.SlickGrid(el,data,column,opt);

  sg.setSelectionModel(new grid.CellSelectionModel(sg.options));


  sg.onSort.subscribe( (e, args) {
    var cols = args['sortCols'];
//{sortCol: {name: Title1, resizable: true, sortable: true, minWidth: 30, rerenderOnResize: false, headerCssClass: null, defaultSortAsc: true, focusable: true, selectable: true, cannotTriggerInsert: false, width: 80, id: title, field: title}, sortAsc: true}
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
