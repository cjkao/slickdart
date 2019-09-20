library slick.util;

import 'slick_util.dart';

// import 'dart:html';
// import 'dart:math';
// import 'dart:collection';
// import 'package:logging/logging.dart';
// import 'slick_core.dart' as core;
// import 'dart:convert';
// import 'slick_column.dart' show TFormatter, Column;
///fixme
///
class HeaderMergeMetaList<T> extends MetaList<T> {
  Map<int, Map<String, int>> headerStructure = {
    0: {'a1': 4, "a5": 3, 'b1': 5, "duration": 1, "duration!": 3},
    1: {'a1': 2, 'a3': 2},
    2: {'a3': 2, "b3": 3},
    4: {'a3': 2, "b3": 3, 'a3!': 2},
    8: {'duration': 1, 'duration!': 8, 'a4': 2, 'a4!': 3},
  };
  Map<int, Map<String, String>> headerCss = {
    0: {'a1': "c1", "a5": "a5", "duration": "merged"},
    4: {'a3': "merged"},
    8: {'duration': 'merged', 'a4': "merged"},
  };

  Map<String, Map<String, dynamic>> getMeta(int row) {
    if (headerStructure.containsKey(row)) {
      return {MetaList.COLUMN: headerStructure[row], MetaList.COLUMN_CSS: headerCss[row] ?? {}};
    }
    return {};
  }

  HeaderMergeMetaList(List<T> innerList) : super(innerList) {
    setMetaData(this.getMeta);
  }
  //override sort

}
