import 'slick_column.dart';
import 'slick_util.dart';
/**
 *
 * convert csv to map,
 * first line is header
 * estimate width in next 10 lines
 */
class CsvAdapter {
//  Map m;
  int charWidth = 8;
  int widthBase = 10;
  List<Column> _cols;
  List<Map> _data;
  List strs;
  List<Map> get data => _data;
  List<Column> get columns => _cols;
  /**
   * widthBase: padding space
   * charWidth: width of each char in pixel
   * csv csv string, including column name at first line
   */
  CsvAdapter(String csv,[this.charWidth=8, this.widthBase=10]) {
    strs = csv.split('\r');
    if (strs.length > 1) {
      strs[0].split(',').forEach((item) =>    log.finest(item));
      var list =
          strs[0].split(',').map((String item) => {
        'field': item.replaceAll('"', ''),
        'width': widthBase + item.length * charWidth,
        'id': item,
        'name': item
      }).toList();
      _cols=new ColumnList.fromMap(list);
    }

    //estimate width from next 10 lines
    strs.sublist(1, strs.length > 10 ? 10 : strs.length).forEach((line) => updateMaxLen(line.split(",")));
    _data=makeData();
  }
  updateMaxLen(List<String> fields) {
    for (int i = 0, len = fields.length; i < len; i++) {
      int newWidth = fields[i].length * charWidth + widthBase;
      if (_cols[i]['width'] < newWidth) {
        _cols[i].width = newWidth;
      }
    }
  }
  /**
   * list of lines to map
   */
  makeData(){
    return strs.sublist(1).map((line) => toDataMap(line.split(','))).toList();
  }
  Map toDataMap(List<String> fields){
    Map m={};
    for(int i=0,len=_cols.length; i<len;i++){
      m[_cols[i].field] = fields[i];
    }
    return m;
  }

}