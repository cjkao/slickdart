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
                 new grid.Column.fromMap ({'id': "title", 'name': "Title1", 'field': "title"}),
                 new grid.Column.fromMap ({'id': "duration", 'name': "percentComplete", 'field': "percentComplete"}),
                 new grid.Column.fromMap ({'id': "%", 'name': "start", 'field': "start"}),
                 new grid.Column.fromMap ({'id': "start", 'name': "finish", 'field': "finish"})
                 ];
  List data=[];
  for (var i = 0; i < 500; i++) {
    data.add( {
      'title': "Task $i" ,
      'duration': "5 days",
      'percentComplete': new math.Random().nextInt(10) * 100,
      'start': "01/01/2009",
      'finish': "01/05/2009",
      'effortDriven': (i % 5 == 0)
    });
  }
  Map opt = {'explicitInitialization': false};
  return new grid.SlickGrid(el,data,column,opt);

}
