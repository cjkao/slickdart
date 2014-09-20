slickdart
=========

slick grid port, for mobile,desktop devices

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
   
TODO
========================

- [ ] efficent dynamic row height on frozen column
  - sort column should re-calcule height
  - how about insert row or delete row?
  [x] low performance on horzontal scrolling, fixed by extend buffer to 4block
- [x] Frozen column, also editable
- [x] Resize column
- [ ] Column reorder
- [x] auto tooltip
- [ ] adjust row height via mouse



Dynamic Row Height
===============================
limitation: visible row:
when calculate numVisibleRows, when we apply dynamic row height, minimal dynamic row height must >= single row hight
Current design: 
- put '_height' on row object to specify pixel height  
- add {'dynamicHeight': true} option to turn on it  

Mobile Device
==============================
- Lumia 925  => very fast scrolling on vertical and horizontal 
- HTC One (M7) Chrome => very fast scrolling on both vertical and horizontal
- HTC One (M7) Firefox => smooth but slower than chrome
- HTC One (M7) Content Shell => very fast
- IPAD2 => very fast
