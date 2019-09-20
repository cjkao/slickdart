library slick.plugin;

import 'dart:html';
import '../slick_grid.dart';
import '../slick_util.dart';
import '../slick_core.dart' as core;
//import '../slick_core.dart' as core;

///
///   AutoTooltips plugin to show/hide tooltips when columns are too narrow to fit content.
///   @constructor
///   @param {boolean} [options.enableForCells=true]        - Enable tooltip for grid cells
///   @param {boolean} [options.enableForHeaderCells=false] - Enable tooltip for header cells
///   @param {number}  [options.maxToolTipLength=null]      - The maximum length for a tooltip
///
class AutoTooltips extends IPlugin {
  SlickGrid _grid;
  Map _defaults = {"enableForCells": true, "enableForHeaderCells": true, "maxToolTipLength": null};
  Map _options;

  ///
  ///   Initialize plugin.
  ///
  init(grid) {
    // options = $.extend(true, {}, _defaults, options);
    _options = Map.from(_defaults);
    _options.addAll(grid.options);
    _grid = grid;
    if (_options['enableForCells']) _grid.onMouseEnter.subscribe(handleMouseEnter);
    if (_options['enableForHeaderCells']) _grid.onHeaderMouseEnter.subscribe(handleHeaderMouseEnter);
  }

  ///
  ///  Destroy plugin.
  ///
  destroy() {
    if (_options['enableForCells']) _grid.onMouseEnter.unsubscribe(handleMouseEnter);
    if (_options['enableForHeaderCells']) _grid.onHeaderMouseEnter.unsubscribe(handleHeaderMouseEnter);
  }

  ///
  ///   Handle mouse entering grid cell to add/remove tooltip.
  ///   @param {jQuery.Event} e - The event
  ///   @param arg: {grid: Instance of 'SlickGrid'}
  ///
  handleMouseEnter(core.EventData e, [Map arg]) {
    Map<String, int> cell = _grid.getCellFromEvent(e);
    if (cell != null) {
      Element $node = _grid.getCellNode(cell['row'], cell['cell']);
      String text;
      if ($node.paddingEdge.width < $node.scrollWidth) {
        text = $node.text;
        if (_options['maxToolTipLength'] != null && text.length > _options['maxToolTipLength']) {
          text = text.substring(0, _options['maxToolTipLength'] - 3) + "...";
        }
      } else {
        text = "";
      }
      $node.attributes["title"] = text;
    }
  }

  ///
  ///   Handle mouse entering header cell to add/remove tooltip.
  ///   @param {jQuery.Event} e     - The event
  ///   @param {object} args.column - The column definition
  ///
  handleHeaderMouseEnter(core.EventData e, Map args) {
    var column = args['column'], $node = findClosestAncestor(e.target, ".slick-header-column");
    if (column['toolTip'] == null) {
      //when tool tip is not defined
      $node.attributes["title"] = $node.paddingEdge.width < $node.scrollWidth ? column.name : "";
    }
  }
}
