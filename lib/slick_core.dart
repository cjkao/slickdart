library slick.core;
import 'dart:html' as html;
//import 'dart:collection';
//import 'dart:convert';
//import 'dart:math' as math;
//import 'dart:mirrors';
EditorLock GlobalEditorLock = new EditorLock();

//parm:  List<core.Range>, Map
//e: KeyboardEvent, EventData
typedef handlerFunction(EventData e,dynamic parm);


/**
 * utility to get dom width / height
 */
class Dimension{
  static int getCalcWidth(html.Element elem){
    return (elem.getBoundingClientRect().width).floor();
  }
  static int getCalcHeight(html.Element elem){
    return (elem.getBoundingClientRect().height ).floor();
  }
}
/**
 * wrap browser event and append propogation status
 */
class EventData{
  html.Event domEvent;
  factory EventData.fromDom(html.Event e){
    EventData ed=new EventData();
    ed.domEvent=e;
    return ed;
  }
  EventData(){
  }
  get target => domEvent.target;

  preventDefault(){
    domEvent.preventDefault();
  }
  bool _isPropagationStopped = false;
  bool _isImmediatePropagationStopped = false;
  String toString(){
    return 'evd pg:' + (_isPropagationStopped ? 'T' : 'F' )+ ' imStp ' + ( _isImmediatePropagationStopped ? 'T' : 'F');
  }
  /***
   * Stops event from propagating up the DOM tree.
   * @method stopPropagation
   */
  stopPropagation(){
    this.domEvent.stopPropagation();
    _isPropagationStopped = true;
  }

  /***
   * Returns whether stopPropagation was called on this event object.
   * @method isPropagationStopped
   * @return {Boolean}
   */
  isPropagationStopped(){
    return _isPropagationStopped;
  }

  /***
   * Prevents the rest of the handlers from being executed.
   * @method stopImmediatePropagation
   */
  stopImmediatePropagation(){
    this.domEvent.stopImmediatePropagation();
    _isImmediatePropagationStopped = true;
  }

  /***
   * Returns whether stopImmediatePropagation was called on this event object.\
   * @method isImmediatePropagationStopped
   * @return {Boolean}
   */
  isImmediatePropagationStopped(){
    return _isImmediatePropagationStopped;
  }

}

/** TODO
 * consider refactor this to stream
 */
class Event {
  List<Function> handlers = [];
  //StreamController sc;
  /***
   * Adds an event handler to be called when the event is fired.
   * <p>Event handler will receive two arguments - an <code>EventData</code> and the <code>data</code>
   * object the event was fired with.<p>
   * @method subscribe
   * @param fn {Function} Event handler.
   */
  subscribe (handlerFunction fn) {
    handlers.add(fn);
  }

  /***
   * Removes an event handler added with <code>subscribe(fn)</code>.
   * @method unsubscribe
   * @param fn {Function} Event handler to be removed.
   */
  bool unsubscribe (Function fn) => handlers.remove(fn);

  /***
   * Fires an event notifying all subscribers.
   * @method notify
   * @param args {Object} Additional data object to be passed to all handlers.
   * @param e {EventData}
   *      Optional.
   *      An <code>EventData</code> object to be passed to all handlers.
   *      For DOM events, an existing W3C/jQuery event object can be passed in.
   * @param scope {Object}
   *      Optional.
   *      The scope ("this") within which the handler will be executed.
   *      If not specified, the scope will be set to the <code>Event</code> instance.
   */
  notify(args, [dynamic e, scope]) {
    e ??= new EventData();
   // scope = scope || this;
    var returnValue;
    for (int i = 0; i < handlers.length && !(e is EventData && (e.isPropagationStopped() || e.isImmediatePropagationStopped())); i++) {
      returnValue = Function.apply(handlers[i],[e,args]);
    }

    return returnValue;
  }
}

class EventHandler{
  List<Map<String,dynamic>> handlers = [];

  subscribe  (Event event, handlerFunction handler) {
    handlers.add({
      'event': event,
      'handler': handler
    });
    event.subscribe(handler);

    return this;  // allow chaining
  }

  EventHandler unsubscribe  (Event event,Function handler) {
    var i = handlers.length;
    while (i-- > 0) {
      if (handlers[i]['event'] == event &&
          handlers[i]['handler'] == handler) {
        handlers.removeAt(i);
        event.unsubscribe(handler);
        return this;
      }
    }

    return this;  // allow chaining
  }

  unsubscribeAll (){
    var i = handlers.length;
    while (i-- > 0) {
      handlers[i]['event'].unsubscribe(handlers[i]['handler']);
    }
    handlers = [];

    return this;  // allow chaining
  }
}



/***
 * A structure containing a range of cells.
 * @class Range
 * @constructor
 * @param fromRow {Integer} Starting row.
 * @param fromCell {Integer} Starting cell.
 * @param toRow {Integer} Optional. Ending row. Defaults to <code>fromRow</code>.
 * @param toCell {Integer} Optional. Ending cell. Defaults to <code>fromCell</code>.
 */
class Range{
  int fromRow,fromCell, toRow,toCell;
  Range(this.fromRow, this.fromCell,[ this.toRow, this.toCell]) {
    if (toRow == null && toCell == null) {
      toRow = fromRow;
      toCell = fromCell;
    }

    /***
     * @property fromRow
     * @type {Integer}
     */
//    fromRow = math.min(fromRow, toRow);
    if (fromRow > toRow) {
      var tmp =toRow;
      toRow=fromRow;
      fromRow=tmp;
    }
    /***
     * @property fromCell
     * @type {Integer}
     */
//    this.fromCell = math.min(fromCell, toCell);
    if (fromCell > toCell) {
      var tmp =toCell;
      toCell=fromCell;
      fromCell=tmp;
    }
    /***
     * @property toRow
     * @type {Integer}
     */
//    this.toRow = math.max(fromRow, toRow);

    /***
     * @property toCell
     * @type {Integer}
     */
//    this.toCell = math.max(fromCell, toCell);
  }


  /***
   * Returns whether a range represents a single row.
   * @method isSingleRow
   * @return {Boolean}
   */
  bool isSingleRow () {
    return this.fromRow == this.toRow;
  }

  /***
   * Returns whether a range represents a single cell.
   * @method isSingleCell
   * @return {Boolean}
   */
  bool isSingleCell() {
    return this.fromRow == this.toRow && this.fromCell == this.toCell;
  }

  /***
   * Returns whether a range contains a given cell.
   * @method contains
   * @param row {Integer}
   * @param cell {Integer}
   * @return {Boolean}
   */
  bool contains (int row, int cell) {
    return row >= this.fromRow && row <= this.toRow &&
        cell >= this.fromCell && cell <= this.toCell;
  }

  /***
   * Returns a readable representation of a range.
   * @method toString
   * @return {String}
   */
  String toString () {
    if (this.isSingleCell()) {
      return "( + $fromRow : $fromCell )";
    }
    else {
      return "( $fromRow : $fromCell - $toRow : $toCell )";
    }
  }
}


/***
 * A base class that all special / non-data rows (like Group and GroupTotals) derive from.
 * @class NonDataItem
 * @constructor
 */
class NonDataItem {
  bool _nonDataRow = true;
  bool get nonDataRow => _nonDataRow;
}


/***
 * Information about a group of rows.
 * @class Group
 * @extends Slick.NonDataItem
 * @constructor
 */
class Group extends NonDataItem {
 // bool __group = true;

  /**
   * Grouping level, starting with 0.
   * @property level
   * @type {Number}
   */
  int level = 0;

  /***
   * Number of rows in the group.
   * @property count
   * @type {Integer}
   */
  int count = 0;

  /***
   * Grouping value.
   * @property value
   * @type {Object}
   */
  Object value = null;

  /***
   * Formatted display value of the group.
   * @property title
   * @type {String}
   */
  String title = null;

  /***
   * Whether a group is collapsed.
   * @property collapsed
   * @type {Boolean}
   */
  bool collapsed = false;

  /***
   * GroupTotals, if any.
   * @property totals
   * @type {GroupTotals}
   */
  GroupTotals totals = null;

  /**
   * Rows that are part of the group.
   * @property rows
   * @type {Array}
   */
  List rows = [];

  /**
   * Sub-groups that are part of the group.
   * @property groups
   * @type {Array}
   */
  List groups = null;

  /**
   * A unique key used to identify the group.  This key can be used in calls to DataView
   * collapseGroup() or expandGroup().
   * @property groupingKey
   * @type {Object}
   */
  Object groupingKey = null;

  /***
   * Compares two Group instances.
   * @method equals
   * @return {Boolean}
   * @param group {Group} Group instance to compare to.
  operator==(Group group){
    return this.value == group.value &&
        this.count == group.count &&
        this.collapsed == group.collapsed &&
        this.title == group.title;
  }

   */
}




/***
 * Information about group totals.
 * An instance of GroupTotals will be created for each totals row and passed to the aggregators
 * so that they can store arbitrary data in it.  That data can later be accessed by group totals
 * formatters during the display.
 * @class GroupTotals
 * @extends Slick.NonDataItem
 * @constructor
 */
class GroupTotals extends NonDataItem{
//  bool __groupTotals = true;

  /***
   * Parent Group.
   * @param group
   * @type {Group}
   */
  Group group = null;
}


/***
 * A locking helper to track the active edit controller and ensure that only a single controller
 * can be active at a time.  This prevents a whole class of state and validation synchronization
 * issues.  An edit controller (such as SlickGrid) can query if an active edit is in progress
 * and attempt a commit or cancel before proceeding.
 * @class EditorLock
 * @constructor
 */
class EditorLock {
  var activeEditController = null;

  /***
   * Returns true if a specified edit controller is active (has the edit lock).
   * If the parameter is not specified, returns true if any edit controller is active.
   * @method isActive
   * @param editController {EditController}
   * @return {Boolean}
   */
  bool isActive([editController]) {
    return (editController!=null ? activeEditController == editController : activeEditController != null);
  }

  /***
   * Sets the specified edit controller as the active edit controller (acquire edit lock).
   * If another edit controller is already active, and exception will be thrown.
   * @method activate
   * @param editController {EditController} edit controller acquiring the lock
   */
  void activate(editController) {
    if (editController == activeEditController) { // already activated?
      return;
    }
    if (activeEditController != null) {
      throw "SlickGrid.EditorLock.activate: an editController is still active, can't activate another editController";
    }
    if (editController['commitCurrentEdit']==null) {
      throw "SlickGrid.EditorLock.activate: editController must implement .commitCurrentEdit()";
    }
    if (editController['cancelCurrentEdit']==null) {
      throw "SlickGrid.EditorLock.activate: editController must implement .cancelCurrentEdit()";
    }
    activeEditController = editController;
  }

  /***
   * Unsets the specified edit controller as the active edit controller (release edit lock).
   * If the specified edit controller is not the active one, an exception will be thrown.
   * @method deactivate
   * @param editController {EditController} edit controller releasing the lock
   */
  void deactivate (editController) {
    if (activeEditController != editController) {
      throw "SlickGrid.EditorLock.deactivate: specified editController is not the currently active one";
    }
    activeEditController = null;
  }

  /***
   * Attempts to commit the current edit by calling "commitCurrentEdit" method on the active edit
   * controller and returns whether the commit attempt was successful (commit may fail due to validation
   * errors, etc.).  Edit controller's "commitCurrentEdit" must return true if the commit has succeeded
   * and false otherwise.  If no edit controller is active, returns true.
   * @method commitCurrentEdit
   * @return {Boolean}
   */
  bool commitCurrentEdit () {
    return (activeEditController!=null ? activeEditController['commitCurrentEdit']() : true);
  }

  /***
   * Attempts to cancel the current edit by calling "cancelCurrentEdit" method on the active edit
   * controller and returns whether the edit was successfully cancelled.  If no edit controller is
   * active, returns true.
   * @method cancelCurrentEdit
   * @return {Boolean}
   */
  bool cancelCurrentEdit() {
    return (activeEditController!=null ? activeEditController['cancelCurrentEdit']() : true);
  }
}
