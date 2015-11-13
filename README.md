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
* col-span (not tested) 
* using keyboard navigation on non-editable cell and goes out of viewport will not
  immediate update screen until it on editable area
* Let forzen column editable cause display unsync in un-frozen area   


TODO
========================
- [ ] header column menu within shadowdom
- [ ] checkbox focus need revalidate 
- [X] ease of use, (Map adapter, auto column declare, width calculation and sorting)
- [ ] column reorder
- [ ] adjust row height via mouse
- [x] efficent dynamic row height on frozen column
  - sort column should re-calcule height
  - how about insert row or delete row?
- [x] low performance on horzontal scrolling, fixed by extend buffer to 4block
- [x] Frozen column, also editable
- [x] Resize column
- [x] auto tooltip



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


Dynamic Row Height
===============================
limitation: visible row:
when calculate numVisibleRows, when we apply dynamic row height, minimal dynamic row height must >= single row hight
Current design
  - put '_height' on row object to specify pixel height  
  - add {'dynamicHeight': true} option to turn on it  
  - on sorting or change data, using resetDynHeight() to re-calculate height

Mobile Device
==============================
- Lumia 925  => fast scrolling on vertical and horizontal 
- HTC One (M7) Chrome => fast scrolling on both vertical and horizontal
- HTC One (M7) Firefox => smooth but slower than chrome
- HTC One (M7) Content Shell => fast
- IPAD2 => fast
- Black Berry => fast

Customer Element
==============================
Initial support customer element, see example: custom-elem.dart

Compitable with angular.dart
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
Only support row css styles, see example: metadata.dart, add dynamic height recalculate

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