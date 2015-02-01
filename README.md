slickdart
=========

slick grid clone, for mobile,desktop devices

** Sort performance is not expected in javascript version

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
- [ ] ease of use, (Map adapter, auto column declare, width calculation and sorting)
- [ ] column reorder
- [ ] adjust row height via mouse
- [x] efficent dynamic row height on frozen column
  - sort column should re-calcule height
  - how about insert row or delete row?
- [x] low performance on horzontal scrolling, fixed by extend buffer to 4block
- [x] Frozen column, also editable
- [x] Resize column
- [x] auto tooltip

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
<cj-grid></cj-grid>
```
  
  
MetaData
=============================
Only support row css styles, see example: metadata.dart, add dynamic height recalculate

Filter View
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