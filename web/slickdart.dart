import 'dart:html';
import 'slick.grid.dart' as grid;
import 'dart:html';
import 'dart:math' as math;

void main() {
  var g=init();
  g.init();
  print (g.$headerScroller.queryAll('.slick-header-column').length);
}

grid.SlickGrid init(){
  Element el =query('#grid');
  List column = [
                 new grid.Column.fromMap ({'id': "title", 'name': "Title1", 'field': "title", 'sortable': true }),
                 new grid.Column.fromMap ({'id': "duration", 'name': "percentComplete", 'field': "percentComplete"}),
                 new grid.Column.fromMap ({'id': "%", 'name': "start", 'field': "start"}),
                 new grid.Column.fromMap ({'id': "start", 'name': "finish", 'field': "finish"})
                 ];
  List data=[];
  for (var i = 0; i < 500; i++) {
    data.add( {
      'title':  new math.Random().nextInt(100).toString(),
      'duration': "5 days",
      'percentComplete': new math.Random().nextInt(10) * 100,
      'start': "01/01/2009",
      'finish': "01/05/2009",
      'effortDriven': (i % 5 == 0)
    });
  }
  Map opt = {'explicitInitialization': false};
  grid.SlickGrid sg= new grid.SlickGrid(el,data,column,opt);
  sg.onSort.subscribe( (e, args) {
    var cols = args['sortCols'];
//{sortCol: {name: Title1, resizable: true, sortable: true, minWidth: 30, rerenderOnResize: false, headerCssClass: null, defaultSortAsc: true, focusable: true, selectable: true, cannotTriggerInsert: false, width: 80, id: title, field: title}, sortAsc: true}
    data.sort( (dataRow1, dataRow2) {
      for (var i = 0, l = cols.length; i < l; i++) {
        var field = cols[i]['sortCol']['field'];
        var sign = cols[i]['sortAsc'] ? 1 : -1;
        String value1 = dataRow1[field], value2 = dataRow2[field];
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
