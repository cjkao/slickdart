import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;

void main() {
  var g=init();
  g.init();
 // print (g.$headerScroller.querySelectorAll('.slick-header-column').length);
}
Map getMeta(int row){
    if (row % 2 == 1) {
        return {
//          "columns": {
//            "duration": {
//              "colspan": 3
//            }
//          }
        };
      } else {
        return {
//          "columns": {
//            0: {  "colspan": "*"    }
//          },
          "cssClasses": "not-edit"
        };
      }
  }
AlertFormatter(int row,int cell,int value,grid.Column columnDef,Map dataRow) {
  if(dataRow['_height']!=null && dataRow['_height']>70){
    return '''
        <p style=' white-space: normal;'>CSS word-wrapping in div</p>       
        <div class="btn-group btn-group-xs">
         <button type="button" class="btn btn-default">Left</button>
        <button type="button" class="btn btn-default">Middle</button>
        </div>
        <div>
          <span class="label label-warning">Check:${value}</span>
        </div>
        ''';
  }else{
    if(value>5){
      return '<span class="label label-success">Success</span>';

    }else{

      return '<span class="label label-default">Default</span>';
    }
  }
}

grid.SlickGrid init(){
  Element el =querySelector('#grid');
  List column = new grid.ColumnList.fromMap([
     {'field': "title", 'sortable': true, 'width':20 },
     {'field': "percentComplete",'width':120,  'formatter': AlertFormatter },
     {'field': "book", 'sortable': true },
     {'field': "finish"},
     {'field': "effortDriven", 'sortable': true },
     {'field': "duration", 'sortable': true },
     {'field': "start", 'sortable': true }]);
  List data=[];
  for (var i = 0; i < 1500; i++) {
    data.add( {
      'title':  i+1,
      'duration': 'd ${i*100}',
      'percentComplete': new math.Random().nextInt(10) ,
      'start': "01/01/20${i}",
      'finish': "01/05/2009",
      'finish1': "01/05/2009 $i",
      'book': "01/05/20$i",
      'effortDriven': (i % 5 == 0)
    });
    if(i%2==0){
      data[i]['_height']=50 + new math.Random().nextInt(100);
    }else{
    }
  }
  Map opt = {'explicitInitialization': false,
             'multiColumnSort': false,
             'dynamicHeight': true,
             'frozenColumn': 0,
//                             'frozenRow':0,
  };



  grid.SlickGrid sg= new grid.SlickGrid(el,new grid.MetaList(data,getMeta),column,opt);
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
