
- [slickdart](#slickdart)
- [Parameter Description](#parameter-description)
- [Example](#example)
- [Known Constraint](#known-constraint)
- [GridOptions](#gridoptions)
- [Formatter](#formatter)
- [Dynamic Row Height](#dynamic-row-height)
- [Customer Element (need polyfill for IE)](#customer-element-need-polyfill-for-ie)
- [MetaData](#metadata)
- [Filtered View](#filtered-view)
- [Header Row](#header-row)
- [Dropdown Menu on Header Column](#dropdown-menu-on-header-column)
- [Copy or Download Grid (only available in custom element: cj-grid)](#copy-or-download-grid-only-available-in-custom-element-cj-grid)
- [Collapsing use case](#collapsing-use-case)
- [Cell Selection](#cell-selection)
- [Programming select rows](#programming-select-rows)
- [Cell Editor](#cell-editor)
- [Simulate Row Split](#simulate-row-split)
- [TODO](#todo)

slickdart
=========
slick grid clone, for mobile,desktop devices

** Sort performance is not fast as javascript version

Parameter Description
=======================
* When enable 'selectActiveRow' on row selection model and with CheckboxSelectColumn in first row
  click on first column out side of check box will uncheck other rows if multiple row selected


Example
=========================
* [Live Sample](https://cjkao.github.io/slickdart)
* examples in web/example folder

Known Constraint
========================
* using keyboard navigation on non-editable cell and goes out of viewport will not
  immediate update screen until it on editable area
* Let forzen column editable cause display unsync in un-frozen area   



GridOptions
===============================
Grid Options have it's own class instead of Map object,
Can be ignore on construction
```dart
var opt = new GridOptions()
		        ..explicitInitialization= false
		        ..multiColumnSort= false;
var grid = new SlickGrid.fromOpt(el,data,[],opt);
```
Formatter
====================
Formatter adopt TFormatter function interface.
```dart
typedef TFormatter = String Function(
    int row, int cell, dynamic value, Column columnDef, Map dataContext);
```
Specify formatter in inital columns will auto collect formatter to
GridOption's [FormatterFactory],
if dynamic swap column, and need special formatter Function,
using  GridOption's [FormatterFactory],


Dynamic Row Height
===============================
limitation: visible row:
when calculate numVisibleRows, when we apply dynamic row height, minimal dynamic row height must >= single row hight
Current design
  - put '_height' on row object to specify pixel height  
  - add {'dynamicHeight': true} option to turn on it  
  - on sorting or change data, using resetDynHeight() to re-calculate height

Customer Element (need polyfill for IE)
==============================
Initial support customer element, see example: custom-elem.dart

Compatible with angular 1/2 dart
  - must specify height of cj-grid
  - accept customize option
```dart
import 'slick_custom.dart'
registerElem();
```      
```html
<cj-grid>
	<style>
	.special-style-here {..}
	</style>
</cj-grid>
```


MetaData
=============================
1. support row css styles, see example: metadata.dart, add dynamic height recalculate
1. support col span and row span, see example: cell-span.1.dart

Filtered View
========================================
Use FilteredList.class in slick_util.dart to wrap data
Example: ColumnFilter.dart


Header Row
========================================
Not to mix with checkbox select column
Example: headerRow.dart

Dropdown Menu on Header Column
=======================================
No shadow dom
Example: gdoc-header.dart

```dart
  //add menu
  column.header = {'menu': {
          'items': [
            {
              'iconImage': "../images/sort-asc.gif",
              'title': "Sort Ascending",
              'command': "sort-asc"
            }]
  }};
  HeaderMenu headerMenuPlugin=new HeaderMenu({});
  headerMenuPlugin.onBeforeMenuShow.subscribe((e, args) {
    List<MenuItem> menuList = args['menu'];
  });
  headerMenuPlugin.onCommand.subscribe((e, args) {
      if(args['command']=='hide'){
        if(columnList.remove(args['column'])){
          tmpCol.add(args['column']);
        };
        args['grid'].setColumns(columnList);
      }
  });
  grid.registerPlugin(headerMenuPlugin);
```
```html
<link rel="stylesheet" href="packages/slickdart/css/plugins-common.css" type="text/css" />
<link rel="stylesheet" href="packages/slickdart/css/plugins-gdoc-style.css" type="text/css" />
<link rel="stylesheet" href="packages/slickdart/css/slick.headermenu.css" type="text/css" />
```

Copy or Download Grid (only available in custom element: cj-grid)
==========================================
Right click on grid that show download or copy option,
Example: angular/popup.dart, custom-elem.dart

Follow steps:
1. include zero-clipboard script
2. add "download" attribute to grid tag
```javascript
    <script src="packages/slickdart/plugin/copy/ZeroClipboard.min.js"></script>
```
```html
  <cj-grid download='f.csv'></cj-grid>
```



Collapsing use case
=============================================
Example: Bs3_tree.dart


Cell Selection
================================================
Support one selection area only, can not cross frozen area
```dart
    grid.SlickGrid sg = new grid.SlickGrid.fromOpt(el, data, column, opt);
    var cellSelectModel = new CellSelectionModel();
    cellSelectModel.onSelectedRangesChanged.subscribe((var e, args) {
      cellSelectModel.getSelectedRanges().forEach(print);
    });
    sg.setSelectionModel(cellSelectModel);
```

Programming select rows
===============================================
```dart
grid.setSelectedRows([rowIndex1,rowIndex2...etc]);
grid.invalidate();
```

Cell Editor
==============================================
Cell editor need to extend  `Editor` class, refer to slick_editor.dart file
* Commit Edit cell
```dart
getEditorLock().commitCurrentEdit()
// or
commitCurrentEdit();
// or
commitEditAndSetFocus();
cancelEditAndSetFocus();

```

* Enable text selection
```dart
new GridOptions()..enableTextSelectionOnCells=true;
```

* Editor Flow
  1. click cell -> trigger `loadValue()`, `serialize()` value (for value change event)
  2. cell defocused, `isValueChanged()` -> false -> make cell back to normal. if `isValueChanged()==true`, call `validate()` 
     1. if `validate()==false`, add `invalid` class to cell
     2. if `validate()=true`, generate Edit Command object and call `serialize()`, if GridOption provide editCommandHandler, call handler, else call `applyValue()` to update data row


* Dropdown list Editor
Drop down list editor within cell using standard input-select element, 
see SelectListEditor. Constructor accept a map with format as {value: display_name,...}

sample code:
```dart
  //enable editable in GridOption
  new grid.GridOptions()..editable = true
  //set editor for column
  new Column()
      ..field = "City"
      // NY is value, "New York" is display name on the Select Option
      ..editor = new SelectListEditor({"NY": "New York", "TPE": "Taipei"})
      ..formatter =(int row, int cell, value, Column columnDef, Map dataContext)
                 { return value=="NY" ? "NEW YORK" : "TAIPEI";}
}
```

* Checkbox Editor
A check box to reneder true/false value

Sample code:
```dart
   new grid.Column.fromMap(
        {'field': "...", 'editor': new CheckboxEditor(),  'formatter': CheckmarkFormatter}),
```



Simulate Row Split
=================================
* Add new css class with column padding left and right to zero, add `cssClass` in `Column` definition

```css
.nopad{
      padding-left: 0px;
      padding-right: 0px;
}
```
```dart
new grid.Column.fromMap(
    {'field': "title",  'formatter': SplitFormatter})
  ..cssClass = 'nopad';
```

* For each row, add `_height` to specify row height
* Add customize formatter for target column

```dart
SplitFormatter(int row, int cell, int value, grid.Column columnDef, Map dataRow) {
  if (dataRow['_height'] != null && dataRow['_height'] > 90) {  
    return '''
        <div class="h40">
          bbbbbbb $value
          <span>$cell<span class='important'> $row
        </div>
        <hr/>
        <div>
          aaa
        </div>
        ''';
  } else {
    return value;
  }
}
```
Add style to upper row
```css
.h40 {
    height: 40px;
    display: block;
    background: yellow;
    word-wrap: break-word;
    white-space: normal;
}
```

TODO
========================
- [ ] keyboard navigation when focus on uneditable cell
- [ ] adjust row height via mouse

