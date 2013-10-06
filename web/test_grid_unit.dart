 import 'package:unittest/unittest.dart';
import 'slick.grid.dart' as grid;
import 'dart:html';
import 'dart:math' as math;
grid.SlickGrid init(){
  Element el =query('#grid');
  List column = [
                 {'id': "title", 'name': "Title1", 'field': "title"},
                 {'id': "duration", 'name': "percentComplete", 'field': "percentComplete"},
                 {'id': "%", 'name': "start", 'field': "start"},
                 {'id': "start", 'name': "finish", 'field': "finish"}
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
  Map opt = {'explicitInitialization': true};
  return new grid.SlickGrid(el,data,column,opt);

}
void main() {
  test('QuickSort', () {
        }
  );
  test('measureScrollBar',(){
    var g=init();
    g.measureScrollbar();
  });

  test('disableSelection', (){
    var g=init();
    g.disableSelection(query('#grid2'));
  });

  test('createColumnHeader',(){
    var g=init();
    g.init();
  });

}