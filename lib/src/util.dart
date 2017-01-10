library slick.sort.util;

import 'package:slickdart/slick.dart';

///
/// args :   key: multiColumnSort: bool,sortCols: List of cols,  grid: instance of Grid
void basicSorter(EventData e, Map args) {
  SlickGrid sg = args['grid'];
  var data = sg.data;
  var sRows = sg.getSelectedRows().map((id) => data[id]).toList();
  var cols = args['sortCols'];
  data.sort((dataRow1, dataRow2) {
    for (var i = 0, l = cols.length; i < l; i++) {
      var field = cols[i]['sortCol']['field'];
      var sign = cols[i]['sortAsc'] ? 1 : -1;
      dynamic value1 = dataRow1[field], value2 = dataRow2[field];
      if (field == 'dtitle') {
        return value1 == value2 ? 0 : (int.parse(value1) > int.parse(value2) ? 1 : -1) * sign;
      }
      var result = (value1 == value2 ? 0 : (value1.compareTo(value2) > 0 ? 1 : -1)) * sign;
      if (result != 0) {
        return result;
      }
    }
    return 0;
  });
  var sRowIdx = sRows.map((item) => data.indexOf(item));
  sg.setSelectedRows(sRowIdx.toList());
  sg.invalidate();
  sg.render();
}
