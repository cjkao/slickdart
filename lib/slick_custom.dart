library slick.cust.el;
import 'slick.dart';
import 'dart:html';
import 'dart:async';
import 'package:logging/logging.dart';
//import 'plugin/header_menu.dart';
Logger _log = new Logger('slick.cust');
const GRID_TAG = 'cj-grid';
StyleElement _styleElement;
registerElem() {
  document.registerElement(GRID_TAG, JGrid);
  _setupBlockElement(); //for safari
}
_setupBlockElement() {
  if (_styleElement == null) {
    _styleElement = new StyleElement();
    document.head.append(_styleElement);
    CssStyleSheet sheet = _styleElement.sheet;
    final rule = '$GRID_TAG { display:block; }';  //force element to have column width from css
    sheet.insertRule(rule, 0);
  }
}

/**
 * shadow root does not work well in firefox!
 * consider shadowroot an optional approach
 */
class JGrid extends HtmlElement {
  ShadowRoot shadowRoot;
 // List _tmpCols=[];
  SlickGrid grid;
  JGrid.created() : super.created() {
    shadowRoot = this.createShadowRoot();
    shadowRoot.innerHtml = """
<style>
 @import "packages/slickdart/slick.grid.css";
</style>
<style>
@import "packages/slickdart/slick_default_theme.css"; 
</style>

<!-- 
<style>
@import "packages/slickdart/css/plugins-common.css"; 
</style>
<style>
@import "packages/slickdart/css/plugins-gdoc-style.css"; 
</style>
<style>
@import "packages/slickdart/css/slick.headermenu.css"; 
</style>

-->
<style>
:host {
        display: block;
      }
#grid{
   height: 100%;
   width: 100%;
   background: white;
   display: block;
   min-height:100px;
}


</style>
<div id='grid'></div>""";
  }
  void init(List data, List<Column> colDefs, {Map option}) {
    assert(shadowRoot.lastChild!=null);
    
//    
//    for (var i = 0; i < colDefs.length; i++) {
//        colDefs[i].header = {'menu': {
//              'items': [
//                {
//                  'title': "Hide Column",
//                  'command': "hide",
//                }
//              ]
//            }
//         };
//          
//      }
//    
    
    
    
    grid = _prepareGrid(shadowRoot.lastChild, colDefs, opt:option);
    
    
    
    
//    HeaderMenu headerMenuPlugin=new HeaderMenu({});
//      /**
//       * args: grid, column , columnMenu
//       */
//      headerMenuPlugin.onBeforeMenuShow.subscribe((e, args) {
//       // return false;
//        List<MenuItem> menuList = args['menu'];
//        menuList.add(
//            new MenuItem.forMap(title:'item1', command:'alert'));
//        });
//        headerMenuPlugin.onCommand.subscribe((e, args) {
//            if(args['command']=='hide'){
//              if(colDefs.remove(args['column'])){
//                _tmpCols.add(args['column']);
//              };
//              args['grid'].setColumns(colDefs);
//            }
//        });
//        grid.registerPlugin(headerMenuPlugin);
    
    
    grid.init();
   grid.data.clear();
   grid.data=data;
   _log.finest("height in shadow: ${ (shadowRoot.lastChild as Element).getBoundingClientRect().height}");
   int maxTry=100;
   int tryCnt=0;
   new Timer.periodic(new Duration(milliseconds: 100), (Timer t){  //look for better solution
     double h= (shadowRoot.lastChild as Element).getBoundingClientRect().height;
     _log.finest('after: $h');
     tryCnt++;
     if(h>0 ){
       grid.finishInitialization();
       t.cancel();
     }
     if(tryCnt>maxTry){
       _log.severe("no element height within shadowdom");
       t.cancel();
     }
   });
    grid.onSort.subscribe(_defaultSort);
  }
  /**
   * List based data,
   */
  void setData(List data){
    if(data!=grid.data){
      grid.data.clear();
    }
    grid.data=data;
    //grid.data.addAll(data);
    grid.invalidate();
    //grid.render();

  }
  void attached() {
    _log.finer('attached');
    _log.finest(shadowRoot.host.clientWidth);
    shadowRoot.host.onContextMenu.listen(_cjContextMenu);
    //   Timer t=new Timer(new Duration(milliseconds:10),()=> grid.finishInitialization());
  }
  void detached() {
    if(grid!=null) grid.unSubscribe();
  }
  factory JGrid(text) => new Element.tag(GRID_TAG);


  SlickGrid _prepareGrid(Element el, List<Column> colDefs, {Map opt}) {
    //Element el =querySelector('#grid');
    List column = colDefs;


    List data = [];
    if (opt == null) {
      opt = {
        'multiColumnSort': true,
        'editable': true,
        'autoEdit': true,
        'frozenColumn': 1
      };
    }
    opt['explicitInitialization']=true;
    SlickGrid sg = new SlickGrid(el, data, column, opt);

    column.forEach((item) {
      if (item is IPlugin) {
        sg.registerPlugin(item);
        sg.setSelectionModel(new RowSelectionModel({
          'selectActiveRow': false
        }));
      }
    });



    return sg;
  }
  //context menu to export as csv
  _cjContextMenu (MouseEvent e){
      //window.alert('hi');
      e.stopPropagation();
      e.preventDefault();
      //write menu box
      //open data uri
  }
  /**
   * args:  sortCols, grid : slickgrid
   */
  _defaultSort(e, Map args) {
        var cols = args['sortCols'];
        SlickGrid sgrid=args['grid'] as SlickGrid;
        sgrid.data.sort((dataRow1, dataRow2) {
          for (var i = 0,
              l = cols.length; i < l; i++) {
            var field = cols[i]['sortCol']['field'];
            var sign = cols[i]['sortAsc'] ? 1 : -1;
            dynamic value1 = dataRow1[field],
                value2 = dataRow2[field];
            var result = (value1 == value2 ? 0 : (value1.compareTo(value2) > 0 ? 1 : -1)) * sign;
            if (result != 0) {
              return result;
            }
          }
          return 0;
        });
        sgrid.invalidate();
        //sgrid.render();
      }

}
