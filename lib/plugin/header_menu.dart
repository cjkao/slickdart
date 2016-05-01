library slick.plugin.headermenu;
import 'dart:html';
import '../slick_grid.dart';
import '../slick_column.dart';
import '../slick_util.dart';
import '../slick_core.dart' as core;
import 'dart:async';
import 'package:logging/logging.dart';
Logger _log = new Logger('log.headermenu');
typedef void MenuFun(MouseEvent e);
/***
   * A plugin to add drop-down menus to column headers.
   *
   * USAGE:
   * To specify a menu in a column header, extend the column definition like so:
   *
   *   var columns = [
   *     {
   *       id: 'myColumn',
   *       name: 'My column',
   *
   *       // This is the relevant part
   *       header: {
   *          menu: {
   *              items: [
   *                {
   *                  // menu item options
   *                },
   *                {
   *                  // menu item options
   *                }
   *              ]
   *          }
   *       }
   *     }
   *   ];
   *
   *
   * Available menu options:
   *    tooltip:      Menu button tooltip.
   *
   *
   * Available menu item options:
   *    title:        Menu item text.
   *    disabled:     Whether the item is disabled.
   *    tooltip:      Item tooltip.
   *    command:      A command identifier to be passed to the onCommand event handlers.
   *    iconCssClass: A CSS class to be added to the menu item icon.
   *    iconImage:    A url to the icon image.
   *
   *
   * The plugin exposes the following events:
   *    onBeforeMenuShow:   Fired before the menu is shown.  You can customize the menu or dismiss it by returning false.
   *        Event args:
   *            grid:     Reference to the grid.
   *            column:   Column class instance.
   *            menu:     MenuItem List.  Note that you can change the menu items here.
   *
   *    onCommand:    Fired on menu item click for buttons with 'command' specified.
   *        Event args:
   *            grid:     Reference to the grid.
   *            column:   Column definition.
   *            command:  Button command identified.
   *            button:   Button options.  Note that you can change the button options in your
   *                      event handler, and the column header will be automatically updated to
   *                      reflect them.  This is useful if you want to implement something like a
   *                      toggle button.
   *
   *
   * @param options {Object} Options:
   *    buttonCssClass:   an extra CSS class to add to the menu button
   *    buttonImage:      a url to the menu button image (default '../images/down.gif')
   */
class HeaderMenu  extends IPlugin{

    Map _opt;
    //Column _parent;
    HeaderMenu(this._opt){

    }
    /**
     * We can add or modify the menu here, or cancel it by returning false
     */
    core.Event onBeforeMenuShow = new core.Event();
    core.Event onCommand = new core.Event();
    void set buttonCssClass (_) => _opt['buttonCssClass'] = _;
    void set buttonImage    (_) => _opt['buttonImage']    = _;
    String get buttonCssClass => _opt['buttonCssClass'];
    String get buttonImage => _opt['buttonImage'];
    String get tooltip => _opt['tooltip'];

    SlickGrid _grid;
    core.EventHandler _handler = new core.EventHandler();
    Element _$menu;
    Element _$activeHeaderColumn;
    StreamSubscription _clickStream;

    init(grid) {
      _grid = grid;
      _handler
        .subscribe(_grid.onHeaderCellRendered, handleHeaderCellRendered)
        .subscribe(_grid.onBeforeHeaderCellDestroy, handleBeforeHeaderCellDestroy);

      // Force the grid to re-render the header now that the events are hooked up.
      _grid.setColumns(_grid.getColumns());

      // Hide the menu on outside click.
      _clickStream=document.body.onClick.listen(_handleBodyClick);
    }


    destroy() {
      _handler.unsubscribeAll();
      _clickStream.cancel();
//      $(document.body).unbind("mousedown", handleBodyMouseDown);
    }


    _handleBodyClick(MouseEvent e) {
      if (_$menu!=null && _$menu != e.target) { // && !$.contains($menu[0], e.target)
       // new Future.delayed(new Duration(milliseconds:50),(){
          _hideMenu();
          _log.finest('click');
        //});
      }
    }


    _hideMenu() {
      if (_$menu!=null) {
        _$menu.remove();
        _$menu = null;
        _$activeHeaderColumn.classes.remove("slick-header-column-active");
      }
    }
    /**
     * [e] Event
     * [args] : {"node": $header,
                 "column": Column}
     */
    handleHeaderCellRendered(core.EventData e,Map args) {
      //_parent = args['column'];
//      Map menu = {};
      Column column=args['column'];
      if(column.header['menu']==null) return;
      //HeaderMenu menu =column.header['menu'];
        var $el = new DivElement()
          ..classes.add("slick-header-menubutton");
        if (buttonCssClass!=null) {
          $el.classes.add(buttonCssClass);
        }
        if (buttonImage!=null) {
          $el.style.backgroundImage= "url(" + buttonImage + ")";
        }
        if (tooltip!=null) {
          $el.attributes["title"]= tooltip;
        }
        $el.onClick.listen(_showMenuFun(_showMenu,args['column']) );
        (args['node'] as Element).append($el);
    }


    handleBeforeHeaderCellDestroy(core.EventData e,[Map args]) {
      var column = args['column'];

      if (column.header['menu']!=null) {
        args['node'].find(".slick-header-menubutton").remove();
      }
    }

    MenuFun _showMenuFun(Function f, Column column)=>(e)=> f(column,e);

    _showMenu(Column column,MouseEvent e) {
     // var menu = $menuButton.data("menu");
     // var columnDef = $menuButton.data("column");
      if(column.header.length==0) return;
      // Let the user modify the menu or cancel altogether,
      // or provide alternative menu implementation.
      List<MenuItem> menuList = column.header['menu']['items'].map((_) => new MenuItem(_)).toList() as List<MenuItem>;
      if (onBeforeMenuShow.notify({
          "grid": _grid,
          "column": column,
          "menu": menuList
        }, e) == false) {
        return;
      }


      if (_$menu==null) {
        _$menu = new Element.html("<div class='slick-header-menu'></div>");
        _grid.container.children.add(_$menu);
      }
      _$menu.children.clear();


      // Construct the menu items.
      for (var i = 0; i < menuList.length; i++) {
        var item = menuList[i];

        var $li = new Element.html("<div class='slick-header-menuitem'></div>");
          //     ..dataset["command"]= item.command
         // ..onClick.listen( handleMenuItemClickFun(menuItemClick,column,item));
          _$menu.children.add($li);
          $li.onClick.listen(_handleMenuItemClickFun(_menuItemClick,column,item));

        if (item.disabled) {
          $li.classes.add("slick-header-menuitem-disabled");
        }

        if (item.tooltip!=null) {
          $li.attributes["title"]=item.tooltip;
        }

        var $icon = new Element.html("<div class='slick-header-menuicon'></div>");
        $li.children.add($icon);

        if (item.iconCssClass!=null) {
          $icon.classes.add(item.iconCssClass);
        }

        if (item.iconImage!=null) {
          $icon.style.backgroundImage= "url(" + item.iconImage + ")";
        }

        var span=new Element.html("<span class='slick-header-menucontent'></span>")..text=item.title;
        $li.children.add(span);
//          .text(item.title)
//          .appendTo($li);
      }


      // Position the menu.
      _$menu.style.top= '${ (e.target as Element).marginEdge.height}px';
      _$menu.style.left= '${(e.target as Element).marginEdge.left}px';
//        .offset({ top: $(this).offset().top + $(this).height(), left: $(this).offset().left });


      // Mark the header as active to keep the highlighting.
      _$activeHeaderColumn = findClosestAncestor(e.target,".slick-header-column");
      _$activeHeaderColumn.classes.add("slick-header-column-active");

      // Stop propagation so that it doesn't register as a header click event.
      e.preventDefault();
      e.stopPropagation();
    }

  MenuFun  _handleMenuItemClickFun(Function f,Column column,MenuItem item) => (MouseEvent e) => f(column,item,e);
    _menuItemClick(Column column,MenuItem item,MouseEvent e) {
      _log.finest('click:${column.name} ${item.command}');

      if (item.disabled) {
        return;
      }

      _hideMenu();

      if (item.command != null && item.command != '') {
        onCommand.notify({
            "grid": _grid,
            "column": column,
            "command": item.command,
            "item": item
          }, e);
      }

      // Stop propagation so that it doesn't register as a header click event.
      e.preventDefault();
      e.stopPropagation();
    }
//    clickTest(e){
//      print('menu item click: ${e.target}');
//    }
}
/**
 *  *    title:        Menu item text.
   *    disabled:     Whether the item is disabled.
   *    tooltip:      Item tooltip.
   *    command:      A command identifier to be passed to the onCommand event handlers.
   *    iconCssClass: A CSS class to be added to the menu item icon.
   *    iconImage:    A url to the icon imag
 */
class MenuItem{
  Map _opt={};
  MenuItem(this._opt){
    if(_opt['command']==null) _opt['command']='';
    if(_opt['title']==null) _opt['title']='';
    if(_opt['disabled']==null) _opt['disabled']=false;
  }
  factory MenuItem.forMap({String title, String command:'', bool disabled:false,
                            String iconCssClass,String iconImage, String tooltip }){
    return new MenuItem({
      'title': title, 'command': command, 'disabled':disabled,
      'iconCssClass': iconCssClass, 'iconImage':iconImage, 'tooltip':tooltip
    });
  }
  String get title =>        _opt['title'];
  bool get disabled =>     _opt['disabled'];
  String get command =>      _opt['command'];
  String get iconCssClass => _opt['iconCssClass'];
  String get iconImage =>    _opt['iconImage'];
  String get tooltip =>      _opt['tooltip'];

  void set title          (_) => _opt['title']          = _;
  void set command        (_) => _opt['command']        = _;
  void set iconCssClass   (_) => _opt['iconCssClass']   = _;
  void set iconImage      (_) => _opt['iconImage']      = _;
  void set tooltip        (_) => _opt['tooltip']        = _;
  set disabled       (bool _) => _opt['disabled']       = _;
}
