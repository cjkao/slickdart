library slick.cust.el;
import 'slick.dart';
import 'dart:html';
import 'dart:async';
import 'package:logging/logging.dart';
//import 'package:initialize/initialize.dart';
//import 'plugin/header_menu.dart';
Logger _log = new Logger('slick.cust');
const GRID_TAG = 'cj-grid';
StyleElement _styleElement;

//publish [GRID_TAG] as custom element
//@initMethod
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
//import cause crash in chrome 42,43
    shadowRoot.innerHtml = """
<style>
 .slick-header.ui-state-default,.slick-headerrow.ui-state-default{width:100%;overflow:hidden;border-left:0}.slick-header-columns,.slick-headerrow-columns{position:relative;white-space:nowrap;cursor:default;overflow:hidden}.slick-header-column.ui-state-default{position:relative;display:inline-block;overflow:hidden;-o-text-overflow:ellipsis;text-overflow:ellipsis;height:16px;line-height:16px;margin:0;padding:4px;border-right:1px solid silver;border-left:0;border-top:0;border-bottom:0;float:left}.slick-headerrow-column.ui-state-default{padding:4px}.slick-header-column-sorted{font-style:italic}.slick-header-column{box-shadow:inset 0 -1px 0 0 grey}.slick-sort-indicator{display:inline-block;width:8px;height:5px;margin-left:4px;margin-top:6px;float:left}.slick-sort-indicator-desc{background:url(images/sort-desc.gif)}.slick-sort-indicator-asc{background:url(images/sort-asc.gif)}.slick-resizable-handle{position:absolute;font-size:.1px;display:block;cursor:col-resize;width:4px;right:0;top:0;height:100%}.slick-resizable-handle-hover{background-color:#ccc}.slick-sortable-placeholder{background:silver}.grid-canvas{position:relative;outline:0;overflow:hidden}.slick-row.ui-state-active,.slick-row.ui-widget-content{position:absolute;border:0;width:100%}.slick-cell,.slick-headerrow-column{position:absolute;border:1px solid transparent;border-right:1px dotted silver;border-bottom-color:silver;overflow:hidden;-o-text-overflow:ellipsis;text-overflow:ellipsis;vertical-align:middle;z-index:1;padding:1px 2px 2px 1px;margin:0;white-space:nowrap;cursor:default}.slick-group-toggle{display:inline-block}.slick-cell.highlighted{background:#87cefa;background:rgba(0,0,255,.2);-webkit-transition:all .5s;-moz-transition:all .5s;-o-transition:all .5s;transition:all .5s}.slick-cell.flashing{border:1px solid red!important}.slick-cell.editable{z-index:11;overflow:visible;background:#fff;border-color:#000;border-style:solid}.slick-cell:focus{outline:0}.slick-reorder-proxy{display:inline-block;background:#00f;opacity:.15;filter:alpha(opacity=15);cursor:move}.slick-reorder-guide{display:inline-block;height:2px;background:#00f;opacity:.7;filter:alpha(opacity=70)}.slick-selection{z-index:10;position:absolute;border:2px dashed #000}.slick-pane{position:absolute;outline:0;overflow:hidden;width:100%}.slick-pane-header{display:block;z-index:10}.slick-header,.slick-headerrow,.slick-top-panel-scroller{overflow:hidden;position:relative}.slick-top-panel{width:10000px}.slick-cell,.slick-cell:after,.slick-header-column,.slick-row{box-sizing:content-box}[hidden]{display:none}.slick-pane-left{box-shadow:1px 0 0 0 grey;z-index:5}.slick-pane.slick-pane-top.slick-pane-right{z-index:1}.slick-header-column.over-right{border-right:2px solid red}.slick-header-column.over-left{border-left:2px solid red}
 .slick-header-column{background-color:#ededed;border-right:1px solid silver}.slick-header-column-active,.slick-header-column:hover{background:-webkit-gradient(linear,left bottom,left top,color-stop(0,#BDF),color-stop(1,#eee));background:-ms-linear-gradient(bottom,#eee,#fff);background:-moz-linear-gradient(center bottom,#eee 0,#fff 100%);background:-o-linear-gradient(#fff,#eee);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#eeeeee', GradientType=0)}.slick-headerrow{background:#fafafa}.slick-headerrow-column{background:#fafafa;border-bottom:0;height:100%}.slick-row{position:absolute;background:#fff;border:0;line-height:20px}.slick-row.selected{z-index:10;background:#DFE8F6}.slick-cell{padding-left:4px;padding-right:4px}.slick-group{border-bottom:2px solid silver}.slick-group-toggle{width:9px;height:9px;margin-right:5px}.slick-group-toggle.expanded{background:url(images/collapse.gif) center center no-repeat}.slick-group-toggle.collapsed{background:url(images/expand.gif) center center no-repeat}.slick-group-totals{color:gray;background:#fff}.slick-cell.selected{background-color:beige}.slick-cell.active{border-color:gray;border-style:solid}.slick-sortable-placeholder{background:silver!important}.slick-row.odd{background:#fafafa}.slick-row.ui-state-active{background:#F5F7D7}.slick-row.loading{opacity:.5;filter:alpha(opacity=50)}.slick-cell.invalid{border-color:red;-moz-animation-duration:.2s;-webkit-animation-duration:.2s;-moz-animation-name:slickgrid-invalid-hilite;-webkit-animation-name:slickgrid-invalid-hilite}@-moz-keyframes slickgrid-invalid-hilite{from{box-shadow:0 0 6px red}to{box-shadow:none}}@-webkit-keyframes slickgrid-invalid-hilite{from{box-shadow:0 0 6px red}to{box-shadow:none}} 
:host {
        display: block;
      }
#grid{
   height: 100%;
   width: 100%;
   background: white;
   display: block;
   min-height:100px;
   border : 1px solid gray;
}
</style>
<div id='grid'></div>""";
  }
  void init(List data, List<Column> colDefs, {Map option}) {
   
    assert(shadowRoot.lastChild!=null);
    grid = _prepareGrid(shadowRoot.lastChild, colDefs, opt:option);
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
    grid.invalidate();

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
