import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;

void main() {
  var g=init();
  g.init();
}

grid.SlickGrid init(){
  Element el =querySelector('#grid');
  List column = [
     new grid.Column.fromMap ({            'name': "id",                 'field': "title", 'sortable': true }),
     new grid.Column.fromMap ({'width':120,'name': "percentComplete2",   'field': "percentComplete", 'sortable': true }),
     new grid.Column.fromMap ({            'name': "start3",             'field': "start", 'sortable': true }),
     new grid.Column.fromMap ({                                          'field': "finish"}),
     new grid.Column.fromMap ({            'name': "5Title1",            'field': "title", 'sortable': true }),
     new grid.Column.fromMap ({'width':120,'name': "6complete",          'field': "percentComplete", 'sortable': true }),
     new grid.Column.fromMap ({            'name': "7start",             'field': "start", 'sortable': true }),
     new grid.Column.fromMap ({            'name': "8finish",            'field': "finish"}),
     new grid.Column.fromMap ({            'name': "9finish",            'field': "finish"}),
     new grid.Column.fromMap ({            'name': "10 Title1",          'field': "title", 'sortable': true }),
  ];
  List data=[];
  for (var i = 0; i < 500; i++) {
    data.add( {
      'title':  i+1,
      'duration': new math.Random().nextInt(100).toString(),
      'percentComplete': new math.Random().nextInt(10) * 100,
      'start': {'a':"01/01/2009", 'b':'ccc'},
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
             'dataItemColumnValueExtractor':mapExtract
  };
  grid.SlickGrid sg= new grid.SlickGrid(el,data,column,opt);
  return sg;
}
mapExtract(Map data, grid.Column col){
    //col.extract(data);
}