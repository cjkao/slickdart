#Version 0.1.3+5 (2015/09/29)
- parseInt fixed on style


#Version 0.1.3+4 (2015/09/07)
- polymer element embed grid (not slick custom element), and stylesheet fall into shadowdom


#Version 0.1.3+2 (2015/07/21)
- sort indicator in custom-elem, add cols attribute for sort event object on single column sort

#Version 0.1.3+1 (2015/06/21)
- reset data will clear selected row, see CheckBox.html

#Version 0.1.3
- Copy and Download, sample case: angular/popup.html, first grid of custom-elem.html

#Version 0.1.2+2 (2015/06/13)
- fix header_row, sample case: light-dom-height.html


#Version 0.1.2+1 (2015/06/04)
- hot fix for popup window(angular ui) to embed grid cause chrome 42,43 crash.
 

#Version 0.1.2 (2015/05/25)
- enable column reorder on non-frozen columns
- no reorder by default , set _optoins.enableColumnReorder = true to turn on it
- duplicated field may cause reorder fail 
- add simple integer editor

#Version 0.1.1+4
- adapt css change in dart 1.10
- a noticable perfomance degrade in Chrome 42.02311.90 when have large horzontal columns2
#Version 0.1.1+3
- fix RowSelectionModel + dynamic height + column filter
- can be test on ColumnFilter.dart

#Version 0.1.1+2
- fix RowSelectionModel + CheckboxSelectioncolumn with maximum single selected row
- can be test on CheckBox.dart

#Version 0.1.1+1
- fix forceFitColumn

#Version 0.1.1 
- move grid options to GridOptions (simplify grid preparation)
- quick way to add “visibility” to columns. (thx to Alex Lopez)
- add default border of grid in customer element type (may cause style broken change)

#Version 0.1.0+9 (2015/2/10)
- add add drop-down menus for header column (light dom only) , see example/gdoc-header.dart

#Version 0.1.0+9 (2015/2/1)
- add add drop-down menus for header column (light dom only) , see example/gdoc-header.dart

#Version 0.1.0+8 (2015/1/31)
- fix addColumn 

#Version 0.1.0+7 (2014/12/30)
- add column row sample, refer headerRow.dart 

#Version 0.1.0+6, (2014/12/24)
- delay shadow dom component render till element style is ready

#Version 0.1.0+5, (2014/12/10)
- add column css sample
##Bug Fixes
- fix numeric parsing


