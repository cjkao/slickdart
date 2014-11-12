import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;
import 'package:slickdart/plugin/autotooltip.dart';
void main() {
  var g=init();
  g.init();
}

grid.SlickGrid init(){
  Element el =querySelector('#myGrid');
  List column = new grid.ColumnList.fromMap([
     {'field': "seq",      'name': "Seq",  'sortable': true , 'width':50},
     {'field': "percentComplete", 'sortable': true },
     {'field': "duration", 'name': "start3", 'sortable': true },
     {'field': "finish",   'name': "4finish"},
     {'field': "title", 'sortable': true },
     {'field': "percentComplete", 'width':120,  'sortable': true },
     {'field': "start",     'name': "7start", 'sortable': true },
     {'field': "finish"},
     {'field': "finish",    'name': "9finish"},
     {'field': "title",     'name': "10 Title1",  'sortable': true },
     {'field': "percentComplete",'width':120, 'name': "11 percentComplete",  'sortable': true },
     {'field': "start",     'name': "12 start", 'sortable': true },
     {'field': "finish",    'name': "13 finish"},
     {'field': "title",     'name': "14 Title1", 'sortable': true },
     {'field': "percentComplete", 'width':120, 'name': "15 percentComplete",  'sortable': true },
     {'field': "start",     'name': "16 start",  'sortable': true },
     {'field': "finish1",   'name': "17 finish"},
     {'field': "finish2",   'name': "18 finish" },
     {'field': "finish3",   'name': "19 finish"},
     {'field': "finish4",   'name': "20 finish" }
  ]);
  List data=[];
  for (var i = 0; i < 300; i++) {
    data.add( {
      'seq':  i,
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
