library slick.cust.el;
import 'slick.dart';
import 'dart:html';
import 'dart:async';
const GRID_TAG = 'cj-grid';
StyleElement _styleElement;
registerElem() {
  document.registerElement(GRID_TAG, JGrid);
  _setupBlockElement();
  // print(gw);
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
<style>
#grid{
   height: 100%;
   width: 100%;
   background: white;
   display: block;
}
</style>
<div id='grid'></div>""";
  }
  //Timer _timer;
  void init(List data, List<Column> colDefs) {
    grid = _prepareGrid(shadowRoot.lastChild, colDefs);
    grid.init();
    grid.data.clear();
    grid.data.addAll(data);
    //this still not fix issue
//    _timer=new Timer.periodic(new Duration(milliseconds:10), (e){
//      print(shadowRoot.host.clientWidth);
//      if(shadowRoot.host.clientWidth>0){
//        _timer.cancel();
        grid.finishInitialization();
//      }
//    });

//    //this is big trouble
//    Timer t = new Timer(new Duration(milliseconds: 150), () => );
  }
  void setData(List data){
    grid.data.clear();
    grid.data.addAll(data);
    grid.invalidate();
    grid.render();
  }
  void attached() {
    print('attached');
    print(shadowRoot.host.clientWidth);
    shadowRoot.host.onContextMenu.listen(_cjContextMenu);
    //   Timer t=new Timer(new Duration(milliseconds:10),()=> grid.finishInitialization());
  }
  void detached() {
    grid.unSubscribe();
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


    sg.onSort.subscribe((e, args) {
      var cols = args['sortCols'];
  //{sortCol: {name: Title1, resizable: true, sortable: true, minWidth: 30, rerenderOnResize: false, headerCssClass: null, defaultSortAsc: true, focusable: true, selectable: true, cannotTriggerInsert: false, width: 80, id: title, field: title}, sortAsc: true}
      data.sort((dataRow1, dataRow2) {
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
      sg.invalidate();
      sg.render();
    });
    return sg;
  }
  //context menu to export as csv
  _cjContextMenu (MouseEvent e){
      window.alert('hi');
      e.stopPropagation();
      e.preventDefault();
      //write menu box
      //open data uri
  }
}
