@HtmlImport('percent_element.html')
library my_element;

import 'dart:html' show Element;
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:polymer/polymer.dart';
import 'package:polymer_elements/paper_listbox.dart';
import 'package:polymer_elements/paper_dropdown_menu.dart';
import 'package:polymer_elements/paper_item.dart';
import 'package:polymer_elements/paper_material.dart';

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

//  @reflectable
  void place(int top, int left) {
    ($['box'] as Element).style.top = '${top}px';
    ($['box'] as Element).style.left = '${left}px';
  }

  @Listen('menu.iron-select')
  handleSelect(event, [_]) {
    print('select $_');
    this.hidden = true;
    this.fire('percent-change',detail:  event.detail.values.first.attributes['value']);
  }

  @Listen('menu.mouseout')
  hideOnMouseOut(CustomEventWrapper event, [_]) {
    if(event.target is PaperListbox){
      this.hidden=true;
      return;
    }
    //  PaperItem
    if (this.contains(event.target)) return;
    this.hidden = true;
  }
}
