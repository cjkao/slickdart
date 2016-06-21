library slick.formatter;

import 'slick_column.dart';

//typedef String formatFn(int row, int cell, dynamic value, Column columnDef, Map dataContext);
PercentCompleteFormatter(int row, int cell, value, Column columnDef, Map dataContext) {
  if (value == null || value == "") {
    return "-";
  } else if (value < 50) {
    return "<span style='color:red;font-weight:bold;'>" + value + "%</span>";
  } else {
    return "<span style='color:green'>" + value + "%</span>";
  }
}

PercentCompleteBarFormatter(int row, int cell, value, Column columnDef, Map dataContext) {
  if (value == null || value == "") {
    return "";
  }

  String color;

  if (value < 30) {
    color = "red";
  } else if (value < 70) {
    color = "silver";
  } else {
    color = "green";
  }

  return "<span class='percent-complete-bar' style='background:$color;width:$value%'></span>";
}

YesNoFormatter(int row, int cell, value, Column columnDef, Map dataContext) {
  return value ? "Yes" : "No";
}

CheckmarkFormatter(int row, int cell, value, Column columnDef, Map dataContext) {
  return (value != null && value) ? "<span style='color:green;font-size:16px;font-weight:bold;'>\u2713</span>" : "";
}
//CheckboxFormatter(row, cell, value, columnDef, dataContext) {
//  return value ? "<input checked type='checkbox' disabled>" : "<input type='checkbox' disabled>";
//}
