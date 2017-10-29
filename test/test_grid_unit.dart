 //import 'package:unittest/unittest.dart';
import 'package:slickdart/slick.dart' as grid;
import 'dart:html';
import 'dart:math' as math;
import 'dart:async';
import 'package:test/test.dart';
grid.SlickGrid init(){
  Element el =querySelector('#grid');
  List<grid.Column> column = [
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
    //g.measureScrollbar();
  });

  test('disableSelection', (){
    var g=init();
    g.disableSelection([querySelector('#grid2')]);
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


  test('apply function',(){
    foo(a,[b]) => print(a+b);
    Function.apply(foo,[1,2]);

    foo2({a ,b}) => print(a+b);
    Map<Symbol,dynamic> m={};
    m[const Symbol('a')] = 6;
    m[const Symbol('b')] = 61;
    Function.apply(foo2, [], m);

    foo3({a ,b}) => print(a+b);
    Map m3={};
    m3['a'] = 6;
    m3['b'] = 61;
    Map<Symbol,dynamic> m3p ={};
    m3.forEach((k,v)=> m3p[new Symbol(k)]=v);
    Function.apply(foo3, [], m3p);
  });

  test('multi class match',(){
    Element e=new DivElement();
    e.classes.add('a');
    e.classes.add('c');

    e.classes.add('b');
    expect(e.classes.contains('a'),true);
  });

  test ('stream', (){
    var data = [1,2,3,4,5];
    var future = new Future(() {
      return 1;
    });
    var stream = new Stream.fromFuture(future);
    stream.listen((value) => print("stream.listen: $value"));


  });

  });
}
