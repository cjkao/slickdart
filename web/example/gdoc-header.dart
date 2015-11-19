import 'dart:html';
import 'package:slickdart/slick.dart' as cj;
import 'dart:math' as math;
import 'package:slickdart/plugin/autotooltip.dart';
import 'package:slickdart/plugin/header_menu.dart';
import 'package:slickdart/slick_editor.dart';
import 'package:logging/logging.dart' as log;
List columnList;
List tmpCol=[];
void main() {
  log.Logger.root.level=log.Level.FINEST;
  log.Logger.root.onRecord.listen((record) { print(record); });
  cj.SlickGrid  grid=setup();
  grid.init();
  grid.setOptions({});
  //log.hierarchicalLoggingEnabled=true;
  //print(g.$canvas.getBoundingClientRect());
  querySelector('#hideCol').onClick.listen((e){
    if(columnList.length==1) return;
    tmpCol.add(columnList.removeLast());
    grid.setColumns(columnList);
  });
  
  querySelector('#addCol').onClick.listen((e){
      columnList.addAll(tmpCol);
      tmpCol.clear();
       grid.setColumns(columnList);
  });
  
}

cj.SlickGrid setup(){
  Element el =querySelector('#grid');
  columnList = [
                 new cj.Column.fromMap ({ 'name': "Title1", 'field': "dtitle", 'sortable': true , 'minWidth':70, 'maxWidth':100}),
                 new cj.Column.fromMap ({'width':120,       'field': "duration", 'sortable': true ,'editor': new NumberEditor() ,'minWidth':80, 'maxWidth':200}),
                 new cj.Column.fromMap ({ 'name': "percent",'field': "pc2", 'sortable': true,'editor': new NumberEditor() ,'minWidth':90, 'maxWidth':200}),
                 new cj.Column.fromMap ({ 'name': "finish", 'field': "finish", 'minWidth':100, 'maxWidth':200}),
                 new cj.Column.fromMap ({ 'name': "String field",    'field': "pc", 'editor':'TextEditor', 'minWidth':110, 'maxWidth':200}),
                 new cj.Column.fromMap ({ 'name': "effort", 'field': "effortDriven", 'width':150, 'minWidth':120, 'maxWidth':200})
                 ];
  
  
  //append column menu
  for (var i = 0; i < columnList.length; i++) {
     columnList[i].header = {'menu': {
          'items': [
            {
              'iconImage': "../images/sort-asc.gif",
              'title': "Sort Ascending",
              'command': "sort-asc"
            },
            {
              'iconImage': "../images/sort-desc.gif",
              'title': "Sort Descending",
              'command': "sort-desc"
            },
            {
              'title': "Hide Column",
              'command': "hide",
            },
            {
              'iconCssClass': "icon-help",
              'title': "Help",
              'disabled': true,
              'command': "help",
              'tooltip': "No Help"
            }
          ]
        }
     };
      
  }
  
  
  cj.CheckboxSelectColumn checkboxCol=new cj.CheckboxSelectColumn({   'cssClass': "slick-cell-checkboxsel" });
  columnList.insert(0,checkboxCol.getColumnDefinition());
  List data=[];
  for (var i = 0; i < 50000; i++) {
    data.add( {
      'dtitle':  'Str' + new math.Random().nextInt(100).toString(),
      'duration': new math.Random().nextInt(100),
      'pc2': new math.Random().nextInt(10) * 100,
      'pc': (new math.Random().nextInt(10) * 100).toString(),
      'start': "01/01/2009",
      'finish': (new math.Random().nextInt(10)+10).toString() + "/05/2013",
      'effortDriven': (i % 5 == 0)
    });
  }
  cj.GridOptions opt=new cj.GridOptions(); 
  opt..explicitInitialization=false
     ..multiColumnSort=true
     ..editable=true
     ..autoEdit=true
     ..frozenColumn=1
     ..enableCellNavigation = true
     ..enableColumnReorder = true
     ..leaveSpaceForNewRows =true
     ..forceSyncScrolling =true
     ..headerRowHeight=50
     ..topPanelHeight=50
     //..syncColumnCellResize=true
     ;
//  Map opt = {'explicitInitialization': false,
//             'multiColumnSort': true,
//             'editable': true,
//             'autoEdit': true,
//             'frozenColumn':1,
//             'enableCellNavigation': true,
//             'enableColumnReorder': false
//             
//         //    'forceFitColumns':true
//  };
  cj.SlickGrid sg= new cj.SlickGrid.fromOpt(el,data,columnList,opt);
  sg.setSelectionModel(new cj.RowSelectionModel({'selectActiveRow': false}));
  
  sg.registerPlugin(checkboxCol);
  sg.registerPlugin(new AutoTooltips());

  HeaderMenu headerMenuPlugin=new HeaderMenu({});
  /**
   * args: grid, column , columnMenu
   */
  headerMenuPlugin.onBeforeMenuShow.subscribe((e, args) {
   // return false;
    List<MenuItem> menuList = args['menu'];
    menuList.add(
        new MenuItem.forMap(title:'item1', command:'alert'));
    });
  headerMenuPlugin.onCommand.subscribe((e, args) {
      if(args['command']=='hide'){
        if(columnList.remove(args['column'])){
          tmpCol.add(args['column']);
        };
        args['grid'].setColumns(columnList);
      }
  });
  sg.registerPlugin(headerMenuPlugin);
  
  
  
  
  
  
  
  
  
  sg.onSelectedRowsChanged.subscribe((cj.EventData e,Map args){
        //  querySelector('.right-pane')..children.clear()..appendText((args['rows'] as List).join(' '));
  });

  sg.onSort.subscribe( (e, args) {
    var cols = args['sortCols'];
//{sortCol: {name: Title1, resizable: true, sortable: true, minWidth: 30, rerenderOnResize: false, headerCssClass: null, defaultSortAsc: true, focusable: true, selectable: true, cannotTriggerInsert: false, width: 80, id: title, field: title}, sortAsc: true}
    data.sort( (dataRow1, dataRow2) {
      for (var i = 0, l = cols.length; i < l; i++) {
        var field = cols[i]['sortCol']['field'];
        var sign = cols[i]['sortAsc'] ? 1 : -1;
        dynamic value1 = dataRow1[field], value2 = dataRow2[field];
        
        var result = (value1 == value2 ? 0 : (value1.compareTo(value2)>0 ? 1 : -1)) * sign;
        if (result != 0) {
          return result;
        }
      }
      return 0;
    });
    sg.invalidate();
  });
  return sg;
}

class NumberEditor extends TextEditor{
  NumberEditor([_ep]) :super(_ep);
  
  void applyValue(item, state){
    try{
      int val=int.parse(state);
      super.applyValue(item,val);
    }catch(e){
      
    }
    
  }
}

