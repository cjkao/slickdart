part of slick;
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

  List<Map> get data => _data;
  List<Column> get columns => _cols;
  /**
   * widthBase: padding space
   * charWidth: width of each char in pixel
   * csv csv string, including column name at first line
   */
  CsvAdapter(String csv,[this.charWidth=8, this.widthBase=10]) {
    List _strs = csv.split('\r');
    if (_strs.length > 1) {
      _strs[0].split(',').forEach((item) =>    _log.finest(item));
      var list =
          _strs[0].split(',').map((String item) => {
        'field': item.replaceAll('"', ''),
        'width': widthBase + item.length * charWidth,
        'id': item,
        'name': item
      }).toList();
      _cols=new ColumnList.fromMap(list);
    }

    //estimate width from next 10 lines
    _strs.sublist(1, _strs.length > 10 ? 10 : _strs.length).forEach((line) => _updateMaxLen(line.split(",")));
    _data=makeData(_strs);
  }

  /**
   * replace max len of column
   */
  _updateMaxLen(List<String> fields) {
    for (int i = 0, len = fields.length; i < len; i++) {
      int newWidth = fields[i].length * charWidth + widthBase;
      if (_cols[i]['width'] < newWidth) {
        _cols[i].width = newWidth;
      }
    }
  }
  /**
   *  ignore first line
   *  @return list of lines to map
   * [{row1},{row2}...]
   */
  makeData(List strs){
    return strs.sublist(1).map((line) => _toDataMap(line.split(','))).toList();
  }
  Map _toDataMap(List<String> fields){
    Map m={};
    for(int i=0,len=_cols.length; i<len;i++){
      m[_cols[i].field] = fields[i];
    }
    return m;
  }

}

//class MapAdapter{
//
//}