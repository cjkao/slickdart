//library example.shadow;
//
//import 'dart:html';
//import 'package:polymer/polymer.dart';
//
//main(){
//
//
//
//
//}
//
//
////// The todo-element.
//@CustomTag('todo-app')
//class TodoElement extends PolymerElement {
//
//  @observable int remainingCount;
//
//  TodoElement.created() : super.created() {
//    // Need to check if the items list gets added to or has something removed.
//    items.changes.listen((records) {
//      remainingCount = _remainingCount;
//    });
//    new ListPathObserver(items, 'done')
//        ..changes.listen((_) {
//          remainingCount = _remainingCount;
//        });
//  }
//
//  int get _remainingCount => items.where((i) => !i.done).length;
//
//  // Apply the styles.
//  bool get applyAuthorStyles => true;
//
//  void addTodo(KeyboardEvent e, var detail, Node target) {
//    KeyEvent event = new KeyEvent.wrap(e);
//    if (event.keyCode == KeyCode.ENTER) {
//      InputElement newTodo = target as InputElement;
//      Item item = new Item(text: newTodo.value, done: false);
//      items.add(item);
//      newTodo.value = '';
//    }
//  }
//
//  void cancelTodo(KeyboardEvent e, var detail, Node target) {
//    KeyEvent event = new KeyEvent.wrap(e);
//    if (event.keyCode == KeyCode.ESC) {
//      (target as InputElement).value = '';
//    }
//  }
//
//  // Mark all items as done.
//  void markAllDone(Event e, var detail, Node target) {
//    items.forEach((item) => item.done = true);
//  }
//
//  // Archive completed items.
//  void archiveDone(Event e, var detail, Node target) {
//    items.removeWhere((item) => item.done);
//  }
//
//  void todoChanged(Event e, var detail, Node target) {
//    remainingCount = _remainingCount;
//  }
//}