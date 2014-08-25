import 'dart:html';
import 'package:slickdart/slick_grid.dart' as grid;
import 'dart:math' as math;
import 'package:slickdart/plugin/autotooltip.dart';
void main() {
  var g=init();
  g.init();
 // print (g.$headerScroller.querySelectorAll('.slick-header-column').length);
}

grid.SlickGrid init(){
  Element el =querySelector('#myGrid');
  List column = [
     new grid.Column.fromMap ({'id': "title", 'name': "Title1", 'field': "title", 'sortable': true }),
     new grid.Column.fromMap ({'id': "duration", 'name': "percentComplete2", 'field': "percentComplete", 'sortable': true }),
     new grid.Column.fromMap ({'id': "%", 'name': "start3", 'field': "duration", 'sortable': true }),
     new grid.Column.fromMap ({'id': "start", 'name': "4finish", 'field': "finish"}),
     new grid.Column.fromMap ({'id': "title2", 'name': "5Title1", 'field': "title", 'sortable': true }),
     new grid.Column.fromMap ({'id': "duration2",'width':120, 'name': "6pppppppplete", 'field': "percentComplete", 'sortable': true }),
     new grid.Column.fromMap ({'id': "%2", 'name': "7start", 'field': "start", 'sortable': true }),
     new grid.Column.fromMap ({'id': "start2", 'name': "8finish", 'field': "finish"}),
     new grid.Column.fromMap ({'id': "start2", 'name': "9finish", 'field': "finish"}),
     new grid.Column.fromMap ({'id': "title2", 'name': "10 Title1", 'field': "title", 'sortable': true }),
     new grid.Column.fromMap ({'id': "duration2",'width':120, 'name': "11 percentComplete", 'field': "percentComplete", 'sortable': true }),
     new grid.Column.fromMap ({'id': "%2", 'name': "12 start", 'field': "start", 'sortable': true }),
     new grid.Column.fromMap ({'id': "start2", 'name': "13 finish", 'field': "finish"}),
     new grid.Column.fromMap ({'id': "title2", 'name': "14 Title1", 'field': "title", 'sortable': true }),
     new grid.Column.fromMap ({'id': "duration2",'width':120, 'name': "15 percentComplete", 'field': "percentComplete", 'sortable': true }),
     new grid.Column.fromMap ({'id': "%2", 'name': "16 start", 'field': "start", 'sortable': true }),
     new grid.Column.fromMap ({'id': "start2", 'name': "17 finish", 'field': "finish1"}),
     new grid.Column.fromMap ({'id': "start2", 'name': "18 finish", 'field': "finish2"}),
     new grid.Column.fromMap ({'id': "start2", 'name': "19 finish", 'field': "finish3"}),
     new grid.Column.fromMap ({'id': "start2", 'name': "20 finish", 'field': "finish4"})
  ];
  List data=[];
  for (var i = 0; i < 300; i++) {
    data.add( {
      'title':  'aa nnn aaa' + new math.Random().nextInt(100).toString(),
      'duration': new math.Random().nextInt(100).toString(),
      'percentComplete': new math.Random().nextInt(10) * 100,
      'start': "01/01/2009",
      'finish': "01/05/2009",
      'finish1': "01/05/2009 $i",
      'finish2': "01/05/20$i",
      'finish3': "01/05/201$i",
      'finish4': "01/05/202$i",
      'effortDriven': (i % 5 == 0)
    });
  }
  Map opt = {'explicitInitialization': false,
             'multiColumnSort': false,
             'topPanelHeight': 25,
             'frozenColumn': 0,
                 'frozenRow': 1,
  };
  grid.SlickGrid sg= new grid.SlickGrid(el,data,column,opt);
  sg.registerPlugin(new AutoTooltips());
  sg.onSort.subscribe( (e, args) {
    grid.Column col = args['sortCol'];
    data.sort( (dataRow1, dataRow2) {
        var field = col.field;
        var sign = args['sortAsc'] ? 1 : -1;
        dynamic value1 = dataRow1[field], value2 = dataRow2[field];
        var result = (value1 == value2 ? 0 : (value1.compareTo(value2)>0 ? 1 : -1)) * sign;
        if (result != 0) {
          return result;
        }
      return 0;
    });
    sg.invalidate();
    sg.render();
  });
  return sg;
}
