 import 'package:unittest/unittest.dart';
import 'slick.grid.dart' as grid;
import 'dart:html';
import 'dart:math' as math;
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
void main() {
  test('QuickSort', () {
    expect(  {}[1] , null);
        }
  );
  test('measureScrollBar',(){
     grid.SlickGrid g=init();
    g.measureScrollbar();
  });

  test('disableSelection', (){
    var g=init();
    g.disableSelection(query('#grid2'));
  });


  test('stylesheet',(){
    List<CssStyleSheet> sheets = document.styleSheets;
    List<CssStyleRule> styles=sheets.first.cssRules;
    expect (styles.first.selectorText,'.thumbnail');
  });
  test('regex',(){
//    assert('.l12345'.contains('.l123'));
    RegExp r= new RegExp("\.l\\d+");
    bool result ='a.l123456'.contains(r"\.l\\d+");
    var m=r"\.l\\d+".matchAsPrefix('.l12345');
    expect (m,null);
  });

  test('init',(){
    grid.SlickGrid sg = init();
    sg.init();
  });

  test('regex',(){
    var x = {'1': 'a'};
    for(var z in x.keys){
      print(z);
    }
  test('selection',(){
    var g=init();
    g.clearTextSelection();

  });

  test('multi class match',(){
    Element e=new DivElement();
    e.classes.add('a');
    e.classes.add('c');

    e.classes.add('b');
    expect(e.classes.contains('a'),true);
  });

  });
}