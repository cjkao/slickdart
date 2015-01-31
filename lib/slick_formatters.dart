part of slick;

PercentCompleteFormatter(row, cell, value, columnDef, dataContext) {
  if (value == null || value == "") {
    return "-";
  } else if (value < 50) {
    return "<span style='color:red;font-weight:bold;'>" + value + "%</span>";
  } else {
    return "<span style='color:green'>" + value + "%</span>";
  }
}

PercentCompleteBarFormatter(row, cell, value, columnDef, dataContext) {
  if (value == null || value == "") {
    return "";
  }

  var color;

  if (value < 30) {
    color = "red";
  } else if (value < 70) {
    color = "silver";
  } else {
    color = "green";
  }

  return "<span class='percent-complete-bar' style='background:" + color + ";width:" + value.toString() + "%'></span>";
}

YesNoFormatter(row, cell, value, columnDef, dataContext) {
  return value ? "Yes" : "No";
}

CheckmarkFormatter(row, cell, value, columnDef, dataContext) {
  return (value!=null && value) ? "<img src='packages/slickdart/images/tick.png'>" : "";
}
//CheckboxFormatter(row, cell, value, columnDef, dataContext) {
//  return value ? "<input checked type='checkbox' disabled>" : "<input type='checkbox' disabled>";
//}