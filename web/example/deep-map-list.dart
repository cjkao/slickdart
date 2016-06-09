import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;

void main() {
  var g=init();
  g.init();
//  g.invalidate();
//    g.render();
}

grid.SlickGrid init(){
  Element el =querySelector('#grid');
  List<grid.Column> column = [
     new grid.Column.fromMap ({            'name': "id",                 'field': "title", 'sortable': true }),
     new grid.Column.fromMap ({'width':120,'name': "PercentComplete2",   'field': "percentComplete", 'sortable': true }),
     new grid.Column.fromMap ({            'name': "Start",             'field': "start", 'sortable': true }),
     new grid.Column.fromMap ({                                          'field': "finish"}),
     new grid.Column.fromMap ({            'name': "TitleA",            'field': "title", 'sortable': true }),
     new grid.Column.fromMap ({'width':120,'name': "Complete",          'field': "percentComplete", 'sortable': true }),
     new grid.Column.fromMap ({            'name': "Start A",             'field': "start", 'sortable': true }),
     new grid.Column.fromMap ({            'name': "Finish A",            'field': "finish"}),
     new grid.Column.fromMap ({            'name': "Finish B",            'field': "finish"}),
     new grid.Column.fromMap ({            'name': "Title C",          'field': "title", 'sortable': true }),
  ];
  List data=[];
  for (var i = 0; i < 500; i++) {
    data.add( {
      'title':  i+1,
      'duration': new math.Random().nextInt(100).toString(),
      'percentComplete': new math.Random().nextInt(10) * 100,
      'start': {'a':"01/01/200$i", 'b':'ccc'},
      'finish': "01/05/2009",
      'finish1': "01/05/2009 $i",
      'finish2': "01/05/20$i",
      'finish3': "01/05/201$i",
      'finish4': "01/05/202$i",
      'effortDriven': (i % 5 == 0)
    });
  }
  grid.GridOptions opt = new grid.GridOptions()
                              ..explicitInitialization= false
                              ..multiColumnSort= false
                              ..enableColumnReorder = true
                              ..dataItemColumnValueExtractor=mapExtract;
  grid.SlickGrid sg= new grid.SlickGrid.fromOpt(el,data,column,opt);
  return sg;
}
mapExtract(Map data, grid.Column col){
  if(col.field=='start') return data['start']['a'];
  return data[col.field];
}
