import 'dart:html';
import 'package:slickdart/slick.dart' as grid;

import 'dart:math' as math;

void main() {
  List<grid.Column> columns = [
       new grid.Column.fromMap ({            'name': "id",                 'field': "title", 'sortable': true }),
       new grid.Column.fromMap ({            'name': "start3",             'field': "start", 'sortable': true }),
       new grid.Column.fromMap ({                                          'field': "finish"}),
       new grid.Column.fromMap ({            'name': "5Title1",            'field': "title", 'sortable': true }),
       new grid.Column.fromMap ({            'name': "7start",             'field': "start", 'sortable': true }),
       new grid.Column.fromMap ({            'name': "8finish",            'field': "finish"}),
       new grid.Column.fromMap ({            'name': "9finish",            'field': "finish"}),
       new grid.Column.fromMap ({            'name': "10 Title1",          'field': "title", 'sortable': true }),
       new grid.Column.fromMap ({            'name': "18 finish",          'field': "finish2"}),
       new grid.Column.fromMap ({            'name': "19 finish",          'field': "finish3"}),
       new grid.Column.fromMap ({            'name': "20 finish",          'field': "finish4"})
    ];
  var g=initShrink();
  g.init();
  columns.forEach((grid.Column _){
    _.minWidth=30;
    _.maxWidth=200;
  });
  g.setColumns(columns);
  g.invalidate();

  var gGrow=initGrow();
  gGrow.init();
  gGrow.invalidate();



}

grid.SlickGrid initShrink(){
  Element el =querySelector('#grid');

  List data=[];
  for (var i = 0; i < 500; i++) {
    data.add( {
      'title':  i+1,
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
  var opt = new grid.GridOptions()
                ..explicitInitialization= false
                ..multiColumnSort= false..forceFitColumns=true;
  grid.SlickGrid sg= new grid.SlickGrid.fromOpt(el,data,[],opt);
  return sg;
}



grid.SlickGrid initGrow(){
  Element el =querySelector('#grid-grow');

  List data=[];
  for (var i = 0; i < 500; i++) {
    data.add( {
      'title':  i+1,
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
  var opt = new grid.GridOptions()
                ..explicitInitialization= false
                ..enableColumnReorder = true
                ..multiColumnSort= false..forceFitColumns=true;
  List<grid.Column> columns = [
         new grid.Column.fromMap ({            'name': "NoResize1",                 'field': "title", 'resizable': false }),
         new grid.Column.fromMap ({            'name': "start3",             'field': "start", 'sortable': true }),
         new grid.Column.fromMap ({                                          'field': "finish"}),
         new grid.Column.fromMap ({            'name': "NoResize1",            'field': "title", 'resizable': false }),
         new grid.Column.fromMap ({            'name': "NoResize1",             'field': "start", 'resizable': false }),
         new grid.Column.fromMap ({            'name': "8finish",            'field': "finish"}),
         new grid.Column.fromMap ({            'name': "9finish",            'field': "finish"}),
         new grid.Column.fromMap ({            'name': "10 Title1",          'field': "title", 'sortable': true }),
         new grid.Column.fromMap ({            'name': "18 finish",          'field': "finish2"}),
         new grid.Column.fromMap ({            'name': "19 finish",          'field': "finish3"}),
         new grid.Column.fromMap ({            'name': "20 finish",          'field': "finish4"})
      ];
  grid.SlickGrid sg= new grid.SlickGrid.fromOpt(el,data,columns,opt);
  return sg;
}
