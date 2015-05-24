library slick.dnd;
import 'slick_grid.dart';
import 'slick_column.dart';
import 'slick_util.dart';
import 'package:logging/logging.dart';
import 'dart:html';
Logger _log = new Logger('slick.dnd');
class DragAndDrop{
  Element rootEl;
  Element _dragSourceEl;
  Element _enter; //latest entered elem
  Point _start_p;
  SlickGrid _grid;
  DragAndDrop(this._grid,this.rootEl){

  }
  install(){
    List<Element> cols = rootEl.querySelectorAll('.slick-header-column');
    for (Element col in cols) {
      col.draggable=true;
      col.onDragStart.listen(_onDragStart);
      col.onDragEnd.listen(_onDragEnd);
      col.onDragEnter.listen(_onDragEnter);
      col.onDragOver.listen(_onDragOver);
      col.onDragLeave.listen(_onDragLeave);
      col.onDrop.listen(_onDrop);
      col.onDrag.listen(_onDrag);
    }
  }
void _onDrag(MouseEvent event){
//  print(event.client.y);
  //event.client.y=56;
 // (event.target as Element)=40;
 // print((event.target as Element)..getBoundingClientRect().top);
 //print( (event.target as Element).offsetTo(rootEl).y );
}
void _onDragStart(MouseEvent event) {
    DivElement headerElem=findClosestAncestor(event.target,'div.slick-header-column');
    
    if(! (event.target is Element)) {
      event.preventDefault();
      return;
    }
    
    if((event.target as Element).classes.contains('slick-resizable-handle')){
      return;
    }
    _log.finest('drag start');
    Element dragTarget = event.target;
    _start_p=event.client;
  //  dragTarget.classes.add('moving');
  //  Element ghost=dragTarget.clone(true);
  //  document.body.append(ghost);
  //  ghost.style.backgroundColor='red';
    _dragSourceEl = dragTarget;
    event.dataTransfer.effectAllowed = 'move';
    //event.dataTransfer.setDragImage(ghost, 0, 0);
    event.dataTransfer.setData("source_id", headerElem.dataset['id']);
   // event.dataTransfer.setData('text/html', dragTarget.innerHtml);
  }

  void _onDragEnd(MouseEvent event) {
    if(_dragSourceEl==null) return;
    if(_enter!=null){
      _enter.classes.remove('over-right');
      _enter.classes.remove('over-left');
      
    }
    _dragSourceEl=null;
  //  Element dragTarget = event.target;
  //  dragTarget.classes.remove('moving');
 //   var cols = rootEl.querySelectorAll('.slick-header-column');
//    for (var col in cols) {
//      col.classes.remove('over');
//    }
  }

  void _onDragEnter(MouseEvent event) {
    if(_dragSourceEl==null) return;
    if(! (event.target is Element) || !(event.target as Element).classes.contains('slick-header-column')) {
      event.preventDefault();
      return;
    }
    if((event.target as Element).classes.contains('slick-resizable-handle')){
         return;
    }
    
    _log.finest("eneter ${event.target}, srcEL: ${_dragSourceEl}");
    
//    Element dropTarget = event.target;
//    dropTarget.classes.add('over');
    DivElement headerElem=findClosestAncestor(event.target,'div.slick-header-column');
    if(_dragSourceEl == headerElem) return; //not to self
    if(headerElem!=_enter && _enter!=null){
      _enter.classes.remove('over-right');
      _enter.classes.remove('over-left');
    }
    _enter=headerElem;
    if(_start_p.x- event.client.x>0){
      headerElem.classes.add('over-left');
    }else{
      headerElem.classes.add('over-right');
    }
  }

  void _onDragOver(MouseEvent event) {
    if(_dragSourceEl==null) return;
    // This is necessary to allow us to drop.
    event.preventDefault();
    event.dataTransfer.dropEffect = 'move';
    //event.target.
   // Element elem = event.target;
   // print(event.target);
    //
    //event.dataTransfer.setData("col", )
  }

  void _onDragLeave(MouseEvent event) {
    if(_dragSourceEl==null) return;
    Element dropTarget = event.target;
    if(!(event.target is Element) || !(event.target as Element).classes.contains('slick-header-column')) {
      event.preventDefault();
      return;
    }
    if(_enter == event.target) return;
    _log.finest("leave ${event.target}");
    dropTarget.classes.remove('over-right');
    dropTarget.classes.remove('over-left');
  }

  void _onDrop(MouseEvent event) {
    if(_dragSourceEl==null) return;
    // Stop the browser from redirecting.
//    event.stopPropagation();
    
    event.preventDefault();
    if(event.dataTransfer.items.length==0) return;
    // Don't do anything if dropping onto the same column we're dragging.
//    Element dropTarget = event.target; 
    DivElement headerElem=findClosestAncestor(event.target,'div.slick-header-column');
  //  DivElement srcHeaderElem = headerElem.parent.querySelector('#${_grid.uid}'+ event.dataTransfer.getData('source_id'));
    if (event.dataTransfer.getData('source_id') != headerElem.dataset['id']) {
          if (!_grid.getEditorLock().commitCurrentEdit()) {//reject drop when have active editor
            return;
          }
          _log.finest('trigger resort column');
          
         List cols= _grid.getColumns();
         Column srcCol=cols[ _grid.columnsById[event.dataTransfer.getData('source_id')] ];
         Column destCol =cols[  _grid.columnsById[headerElem.dataset['id']] ];
         int srcIdx= cols.indexOf(srcCol);
         int destIdx= cols.indexOf(destCol);
         if(srcIdx<destIdx){ //move to rigtht
           cols.removeAt(srcIdx);
           cols.insert(destIdx, srcCol);
//           headerElem.parent.children.insert(destIdx-1, srcHeaderElem);
         }else{
           cols.removeAt(srcIdx);
           cols.insert(destIdx, srcCol);
         }
         _grid.columns =cols;
         _grid.updateColumnIndex();
         _grid.createColumnHeaders();
         _grid.applyColumnHeaderWidths();
         //_grid.setupColumnResize();
         _grid.applyColumnWidths();
         _grid.invalidateAllRows();
         _grid.resizeCanvas();
         _grid.trigger(_grid.onColumnsReordered, {});
//          e.stopPropagation();
//          setupColumnResize();
    }
  }

}