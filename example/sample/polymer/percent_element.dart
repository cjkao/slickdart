@HtmlImport('percent_element.html')
library percent.editor;

import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;
import 'dart:async';
import 'dart:html' show Element, MouseEvent;
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/paper_listbox.dart';
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_material.dart';
import 'package:polymer_elements/paper_card.dart';
import 'package:polymer_elements/roboto.dart';

///
///  Floating Card
///
///
@PolymerRegister('percent-element')
class PercentElement extends PolymerElement {
  @property
  String get value => $['menu'].selectedItem;
  PercentElement.created() : super.created();
  @property
  bool hidView = false;

  factory PercentElement() => new Element.tag('percent-element') as PercentElement;
  @reflectable
  void toggleView([_, __]) {
    set('hidView', !this.hidView);
  }

  @property
  String curValue = '';

  /// move Card close to picker
  void place(int top, int left) {
    ($['box'] as Element).style.top = '${top-40}px';
    ($['box'] as Element).style.left = '${left}px';
  }

  ///append value to head
  void headValue(String value) {
    set('curValue', value);
    $['menu'].selected = '-1';
  }

  ///emit percent change to cell
  @Listen('menu.iron-select')
  handleSelect(event, [_]) {
    print('select $_');
    this.hidden = true;
    this.fire('percent-change', detail: event.detail.values.first.attributes['value']);
  }

  /// hide menu when leave menu
  @Listen('box.mouseout')
  hideOnMouseOut(CustomEventWrapper event, [_]) {
    MouseEvent me = event.original as MouseEvent;
    PaperCard pc = $['box'];
    var bound = pc.getBoundingClientRect();
    if (bound.left < me.client.x && bound.right > me.client.x && bound.top < me.client.y && bound.bottom > me.client.y)
      return;
    this.hidden = true;
  }
}

///percent editor
///
class PercentCompleteEditor extends grid.Editor {
  Element $picker;
  TextInputElement _$input;
  PercentElement floatMenu = null;
  StreamSubscription floatMenuSelectStream;

  ///
  /// add picker on enter cell
  ///
  /// hover on icon and set value from PercentElement
  ///
  @override
  set editorParm(grid.EditorParm m) {
    super.editorParm = m;
    //$input = new DateInputElement(); //
    $input = new TextInputElement(); //$("<INPUT type=text class='editor-percentcomplete' />");
    _$input = $input;
    $input.style.width = '${editorParm.activeCellNode.getBoundingClientRect().width-35}px';
    editorParm.activeCellNode.append($input);

    /// picker
    $picker = new Element.tag('iron-icon');
    $picker.attributes['icon'] = 'editor:format-list-numbered';
    $picker.classes.add('cell');
    $picker.onMouseEnter.listen((_) {
      const id = '_percent';

      if (floatMenu == null) {
        floatMenu = new Element.tag('percent-element');
        floatMenu.id = id;

        querySelector('body').append(floatMenu);
      } else {
        floatMenu = document.querySelector('#${id}');
      }

      floatMenuSelectStream?.cancel();
      floatMenuSelectStream = floatMenu.on['percent-change'].listen((_) {
        var val = new CustomEventWrapper(_).detail;
        
        _$input.value = val;
      });

      ///move menu to cell
      //var pos = editorParm.position;
      //floatMenu.place(pos['top'], pos['left']);
      var pos = $picker.getBoundingClientRect();
      floatMenu.headValue(_$input.value);
      floatMenu.place(pos.top, pos.left);
      floatMenu.hidden = false;
    });

    editorParm.activeCellNode.append($picker);
    $input..attributes['hidefocus'] = 'true';
    $input.focus();
  }

  init() {}

  destroy() {
    _$input.remove();
    $picker.remove();
    floatMenu?.hidden = true;
  }

  focus() {
    $input.focus();
  }

  loadValue(item) {
    _$input.value = item[this.editorParm.columnDef.field];
    defaultValue = item[this.editorParm.columnDef.field];
    _$input.select();
  }

  serializeValue() {
    return _$input.value ?? '$defaultValue';
  }

  @override
  applyValue(item, state) {
    if (state != null) super.applyValue(item, num.parse(state, (_) => defaultValue));
  }

  isValueChanged() {
    return _$input.value != defaultValue;
  }

  validate() {
    if (num.parse(_$input.value, (_) => defaultValue) < 0) {
      return {'valid': false, 'msg': "Please enter a valid positive number"};
    }

    return {'valid': true, 'msg': null};
  }
}
