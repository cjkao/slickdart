library slick.cust.el;

import 'slick_grid.dart';
import "slick_column.dart";
import "slick_core.dart";
import 'dart:html';
import 'dart:async';
import 'dart:js';
import 'package:logging/logging.dart';
import "slick_selectionmodel.dart";

//import 'package:initialize/initialize.dart';
//import 'plugin/header_menu.dart';
Logger _log = Logger('slick.cust');
const GRID_TAG = 'cj-grid';
StyleElement _styleElement;

//publish [GRID_TAG] as custom element
//@initMethod
registerElem() {
  _setupBlockElement(); //for safari
}
//download can be disable from here
//StreamSubscription contextSubscription;

_setupBlockElement() {
  if (_styleElement == null) {
    // document.registerElement(GRID_TAG, JGrid);
    _styleElement = StyleElement();
    document.head.append(_styleElement);
    CssStyleSheet sheet = _styleElement.sheet;
    // window.customElements.define("cj-grid", JGrid);
    final rule = '$GRID_TAG { display:block; }'; //force element to have column width from css
    sheet.insertRule(rule, 0);
    _addContext();
  }
}

_addContext() {
  if (document.head.querySelector('script.grid-download') == null) {
    ScriptElement se = ScriptElement();
    se.classes.add('grid-download');
    se.type = 'text/javascript';
    se.text = '''
    function setClipboard(data, elem, hideMenu) {
        var client =  Clipboard(elem, {
            text: function(trigger) {
                return data;
            }
        });
        client.on('success', function(e) {
            hideMenu();
            client.destroy();
        });
        client.on('error', function(e) {
            client.destroy();
        });
    }
''';
    document.head.children.add(se);
  }
}

///
/// shadow root does not work well in firefox!
/// consider shadowroot an optional approach
///
class JGrid {
  ShadowRoot shadowRoot;
  get attributes => he.attributes;
  HtmlElement he;
  // List _tmpCols=[];
  SlickGrid grid;
  Element rmenu;
  JGrid([this.he]) {
    this.shadowRoot = he.attachShadow({"mode": 'open'});
//    this.shadowRoot=he.createShadowRoot();//.shadowRoot;
    this.shadowRoot //= this.createShadowRoot()
      ..innerHtml = """
<style>
 .slick-header.ui-state-default,.slick-headerrow.ui-state-default{width:100%;overflow:hidden;border-left:0}
 .slick-header-columns,.slick-headerrow-columns{position:relative;white-space:nowrap;cursor:default;overflow:hidden}
 .slick-header-column.ui-state-default{position:relative;display:inline-block;overflow:hidden;-o-text-overflow:ellipsis;text-overflow:ellipsis;height:16px;line-height:16px;margin:0;padding:4px;border-right:1px solid silver;border-left:0;border-top:0;border-bottom:0;float:left}
 .slick-headerrow-column.ui-state-default{padding:4px}.slick-header-column-sorted{font-style:italic}.slick-header-column{box-shadow:inset 0 -1px 0 0 grey}
 .slick-sort-indicator{display:inline-block;width:8px;height:5px;margin-left:4px;margin-top:6px;float:left}
 .slick-sort-indicator-desc{background:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAgAAAAFCAYAAAB4ka1VAAAAMklEQVQI12NgIAJwAfEnIP6Phu8DMQtMEQ8Qf4NK/APid0DMhm4STBFWSRhgB2JmZAEAPLwLz6hj83EAAAAASUVORK5CYII=)}.slick-sort-indicator-asc{background:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAgAAAAFCAYAAAB4ka1VAAAAMElEQVQI12NgQAXsQMzMgAPwAPE3IH4HxGy4JP8D8T90RVxA/AkqiYzvAzELAyEAAEDLC89q7ZR0AAAAAElFTkSuQmCC)}.slick-resizable-handle{position:absolute;font-size:.1px;display:block;cursor:col-resize;width:4px;right:0;top:0;height:100%}
 .slick-resizable-handle-hover{background-color:#ccc}
 .slick-sortable-placeholder{background:silver}.grid-canvas{position:relative;outline:0;overflow:hidden}
 .slick-row.ui-state-active,.slick-row.ui-widget-content{position:absolute;border:0;width:100%}
 .slick-cell,.slick-headerrow-column{position:absolute;border:1px solid transparent;border-right:1px dotted silver;border-bottom-color:silver;overflow:hidden;-o-text-overflow:ellipsis;text-overflow:ellipsis;vertical-align:middle;z-index:1;padding:1px 2px 2px 1px;margin:0;white-space:nowrap;cursor:default}
 .slick-group-toggle{display:inline-block}.slick-cell.highlighted{background:#87cefa;background:rgba(0,0,255,.2);-webkit-transition:all .5s;-moz-transition:all .5s;-o-transition:all .5s;transition:all .5s}
 .slick-cell.flashing{border:1px solid red!important}.slick-cell.editable{z-index:11;overflow:visible;background:#fff;border-color:#000;border-style:solid}.slick-cell:focus{outline:0}
 .slick-reorder-proxy{display:inline-block;background:#00f;opacity:.15;filter:alpha(opacity=15);cursor:move}
 .slick-reorder-guide{display:inline-block;height:2px;background:#00f;opacity:.7;filter:alpha(opacity=70)}
 .slick-selection{z-index:10;position:absolute;border:2px dashed #000}
 .slick-pane{position:absolute;outline:0;overflow:hidden;width:100%}.slick-pane-header{display:block;z-index:10}
 .slick-header,.slick-headerrow,.slick-top-panel-scroller{overflow:hidden;position:relative}
 .slick-top-panel{width:10000px}
 .slick-cell,.slick-cell:after,.slick-header-column,.slick-row{box-sizing:content-box}[hidden]{display:none}
 .slick-pane-left{box-shadow:1px 0 0 0 grey;z-index:5}
 .slick-pane.slick-pane-top.slick-pane-right{z-index:1}
 .slick-header-column.over-right{border-right:2px solid red}
 .slick-header-column.over-left{border-left:2px solid red}
 .slick-header-column{background-color:#ededed;border-right:1px solid silver}.slick-header-column-active,.slick-header-column:hover{background:-webkit-gradient(linear,left bottom,left top,color-stop(0,#BDF),color-stop(1,#eee));background:-ms-linear-gradient(bottom,#eee,#fff);background:-moz-linear-gradient(center bottom,#eee 0,#fff 100%);background:-o-linear-gradient(#fff,#eee);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#eeeeee', GradientType=0)}.slick-headerrow{background:#fafafa}.slick-headerrow-column{background:#fafafa;border-bottom:0;height:100%}
 .slick-row{position:absolute;background:#fff;border:0;line-height:20px}.slick-row.selected{z-index:10;background:#DFE8F6}.slick-cell{padding-left:4px;padding-right:4px}.slick-group{border-bottom:2px solid silver}.slick-group-toggle{width:9px;height:9px;margin-right:5px}.slick-group-toggle.expanded{background:url(packages/slickdart/images/collapse.gif) center center no-repeat}.slick-group-toggle.collapsed{background:url(packages/slickdart/images/expand.gif) center center no-repeat}.slick-group-totals{color:gray;background:#fff}.slick-cell.selected{background-color:beige}.slick-cell.active{border-color:gray;border-style:solid}.slick-sortable-placeholder{background:silver!important}.slick-row.odd{background:#fafafa}
 .slick-row.ui-state-active{background:#F5F7D7}.slick-row.loading{opacity:.5;filter:alpha(opacity=50)}.slick-cell.invalid{border-color:red;-moz-animation-duration:.2s;-webkit-animation-duration:.2s;-moz-animation-name:slickgrid-invalid-hilite;-webkit-animation-name:slickgrid-invalid-hilite}@-moz-keyframes slickgrid-invalid-hilite{from{box-shadow:0 0 6px red}to{box-shadow:none}}@-webkit-keyframes slickgrid-invalid-hilite{from{box-shadow:0 0 6px red}to{box-shadow:none}}
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
   position:absolute;
}
#rmenu{
   position: fixed;
}
.show {
    z-index:1000;

    width:100px;
    background-color:#F0F0F0;
    border: 1px solid gray;
    padding: 2px;
    display: block;
    margin: 0;
    list-style-type: none;
    list-style: none;
}
.show ul{padding-left:5px; margin:2px;}
.hide {
    display: none;
}

.show li{ list-style: none;
    cursor:pointer;
 }
.show li { border: 0 !important; text-decoration: none; }

.show li a{
   color:black;
   text-decoration:none;
}
.overlay{
   position:relative;
   height:0;
   widht:0;
}
</style>

  <div class='overlay'>
    <div class="hide" id="rmenu">
        <ul>
            <li class='li-download'><a class='download'>Download</a></li>
            <li class='li-copy'>Copy</li>
        </ul>
     </div>
     <div class='calendar'></div>
  </div>
  <div id='grid'>
  </div>
  <content></content>
""";
  }

  ///
  /// build grid object, defer init till shadow dom constructed
  ///
  void init(List data, List<Column> colDefs, {Map option}) {
    Element elGrid = shadowRoot.querySelector('#grid');
    assert(elGrid != null);
    grid = _prepareGrid(elGrid, colDefs, opt: option);
    grid.init();
    grid.data.clear();
    grid.data = data;
    _log.finest("height in shadow: ${elGrid.getBoundingClientRect().height}");
    int maxTry = 1800;
    int tryCnt = 0;
    Timer.periodic(Duration(milliseconds: 500), (Timer t) {
      //look for better solution
      double h = elGrid.getBoundingClientRect().height;
      _log.finest('after: $h');
      tryCnt++;
      if (h > 1) {
        t.cancel();
        grid.finishInitialization();
      }
      if (tryCnt > maxTry) {
        _log.severe("no element height within shadowdom");
        t.cancel();
      }
    });
    grid.onSort.subscribe(_defaultSort);
    _setupContextMenu();
    //prepare listener for context menu
    _extractDistributeNodeStyle();
  }

  ///
  /// List based data
  ///
  void setData(List data) {
    if (data != grid.data) {
      grid.data.clear();
    }
    grid.data = data;
    grid.invalidate();
  }

  ///
  /// apply style with style string
  /// example string:  .slick-pane-top .slick-row {   background-color: #a9F9FF;    }
  ///
  void setStyle(String s) {
    CssStyleSheet styleSheet = shadowRoot.styleSheets[0];
    styleSheet.insertRule(s, 0);
  }

  ///
  /// move style tag from external to shadowdom
  ///
  _extractDistributeNodeStyle() {
    var els = (this.he.querySelector("style") as StyleElement);
    if (els != null) shadowRoot.append(els);
  }

  void attached() {
    _log.finer('attached');
    _log.finest(shadowRoot.host.clientWidth);
  }

  void detached() {
    if (grid != null) grid.unSubscribe();
  }

  // factory JGrid(text) =>  Element.tag(GRID_TAG);

  SlickGrid _prepareGrid(Element el, List<Column> colDefs, {Map opt}) {
    //Element el =querySelector('#grid');
    var column = colDefs;

    List data = [];
    if (opt == null) {
      opt = {'multiColumnSort': true, 'editable': true, 'autoEdit': true, 'frozenColumn': 1};
    }
    opt['explicitInitialization'] = true;
    SlickGrid sg = SlickGrid(el, data, column, opt);

    column.forEach((item) {
      if (item is IPlugin) {
        sg.registerPlugin(item as IPlugin);
        sg.setSelectionModel(RowSelectionModel({'selectActiveRow': false}));
      }
    });
    return sg;
  }

  //StreamSubscription _downloadSubscription;
  //context menu to export as csv
//  Timer _rightClickTimer;
  _setupContextMenu() {
    String downloadName = he.getAttribute('download');
    if (downloadName == null) return;

    Element elGrid = shadowRoot.querySelector('#grid');

    elGrid.onClick.listen((_) => rmenu.classes
      ..clear()
      ..add('hide'));
    //inject javascript

    rmenu = this.shadowRoot.querySelector("#rmenu");
    rmenu.querySelector('.li-copy').onMouseOver.listen((_) {
      rmenu.querySelectorAll('li').style.backgroundColor = '';
      rmenu.querySelector('.li-copy').style.backgroundColor = 'lightgray';
    });
    rmenu.querySelector('.li-download').onMouseOver.listen((_) {
      rmenu.querySelectorAll('li').style.backgroundColor = '';
      rmenu.querySelector('.li-download').style.backgroundColor = 'lightgray';
    });
    shadowRoot.host.onContextMenu.listen(_cjContextMenu);
    //  if(this.getAttribute('download')!=null){
    var downloadLink = rmenu.querySelector('a.download');
    downloadLink.onClick.listen((_) {
      List<Column> cols = List.from(grid.columns);
      cols.removeWhere((col) => col is CheckboxSelectColumn);
      String data = cols.map((col) => '"${col.name}"').join(',') + "\r\n";
      data += grid.data.map((_) {
        return cols.map((col) => '"${_[col.field]}"').join(",");
      }).join("\r\n");
      downloadLink.setAttribute('href', 'data:text/csv;base64,' + window.btoa(data));
      downloadLink.setAttribute('download', downloadName);
      rmenu.classes
        ..clear()
        ..add('hide');
    });
  }

  _cjContextMenu(MouseEvent e) {
    rmenu.classes
      ..clear()
      ..add("show");
    var bound = he.getBoundingClientRect();
    rmenu.style.position = 'absolute';
    rmenu.style.top = '${e.client.y - bound.top}px';
    rmenu.style.left = '${e.client.x - bound.left}px';

//     rmenu.style.position='fixed';
//     rmenu.style.top =  '${e.client.y}px';
//     rmenu.style.left = '${e.client.x}px';
//     rmenu.style.top =  '${e.client.y - this.getBoundingClientRect().top }px';
//     rmenu.style.left = '${e.client.x - hostBox.left}px';

    var copyLink = rmenu.querySelector('.li-copy');
    List<Column> cols = List.from(grid.columns);
    cols.removeWhere((col) => col is CheckboxSelectColumn);
    String data = cols.map((col) => '"${col.name}"').join(',') + "\r\n";
    data += grid.data.map((_) {
      return cols.map((col) => '"${_[col.field]}"').join(",");
    }).join("\r\n");

    context.callMethod('setClipboard', [
      data,
      copyLink,
      () => rmenu.classes
        ..clear()
        ..add('hide')
    ]);
    rmenu.onMouseLeave.listen((_) => rmenu.classes
      ..clear()
      ..add('hide'));
    e.stopPropagation();
    e.preventDefault();
    //write menu box.
    //open data uri
  }

  ///
  /// args:  sortCols, grid : slickgrid
  ///
  _defaultSort(EventData e, Map args) {
    var cols = args['sortCols'];
    SlickGrid sgrid = args['grid'] as SlickGrid;
    sgrid.data.sort((dataRow1, dataRow2) {
      for (var i = 0, l = cols.length; i < l; i++) {
        var field = cols[i]['sortCol']['field'];
        var sign = cols[i]['sortAsc'] ? 1 : -1;
        dynamic value1 = dataRow1[field], value2 = dataRow2[field];
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
