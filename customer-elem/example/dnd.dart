
import 'dart:html';

class Basics {
  Element _dragSourceEl;

  void start() {
    var cols = document.querySelectorAll('.slick-resizable-handle');
    for (var col in cols) {
      col.onDragStart.listen(_onDragStart);
      col.onDragEnd.listen(_onDragEnd);
      col.onDragEnter.listen(_onDragEnter);
      col.onDragOver.listen(_onDragOver);
      col.onDragLeave.listen(_onDragLeave);
      col.onDrop.listen(_onDrop);
    }
  }

  void _onDragStart(MouseEvent event) {
    Element dragTarget = event.target;
    print('drag start');
    dragTarget.classes.add('moving');
    _dragSourceEl = dragTarget;
    event.dataTransfer.effectAllowed = 'move';
    event.dataTransfer.setData('text/html', dragTarget.innerHtml);
  }

  void _onDragEnd(MouseEvent event) {
    Element dragTarget = event.target;
    dragTarget.classes.remove('moving');
    var cols = document.queryAll('.slick-resizable-handle');
    for (var col in cols) {
      col.classes.remove('over');
    }
  }

  void _onDragEnter(MouseEvent event) {
    Element dropTarget = event.target;
    dropTarget.classes.add('over');
  }

  void _onDragOver(MouseEvent event) {
    // This is necessary to allow us to drop.
    event.preventDefault();
    event.dataTransfer.dropEffect = 'move';
  }

  void _onDragLeave(MouseEvent event) {
    Element dropTarget = event.target;
    dropTarget.classes.remove('over');
  }

  void _onDrop(MouseEvent event) {
    // Stop the browser from redirecting.
    event.stopPropagation();

    // Don't do anything if dropping onto the same column we're dragging.
    Element dropTarget = event.target;
    if (_dragSourceEl != dropTarget) {
      // Set the source column's HTML to the HTML of the column we dropped on.
      _dragSourceEl.innerHtml = dropTarget.innerHtml;
      dropTarget.innerHtml = event.dataTransfer.getData('text/html');
    }
  }
}

void main() {
  var basics = new Basics();
  basics.start();
}