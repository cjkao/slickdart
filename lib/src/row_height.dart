library row_height;

//import 'slick_core.dart';
///
/// left can be node
/// 1. add a row or del a row should reflect to tree
/// 2. construct a tree from rows
/// 3. lookup a row position
/// 4. given a position, reply a starting row
///           n
///         n      n
///       n   n    n  n
///      l l l l  l l l l
///   a horzontal link list on leaf that reduce cost to search target row by pos
///
class Node {
  Node left, right;
  int height; //total height of this leaf
  int numRow; //total row in this leaf
  int startRow; //start row index of rows

//  int defaultHeight=0; //0px
  ///
  /// @param defaultHeight default height in px
  ///
  Node() {
    //this.rows=rows;
  }
  //construct node index
  //
  Node _createTree(Node node, List rows, [Root root, int beginIdx = 0]) {
    if (root == null) root = node;
    //recursive dividen rows and construct it
    if (rows.length > Root.THRESHOLD * 2) {
      int half = rows.length ~/ 2;
      node.left = _createTree(Node(), rows.sublist(0, half), root, beginIdx);
      node.right = _createTree(Node(), rows.sublist(half), root, beginIdx + half);
      node.numRow = rows.length;
      node.height = node.left.height + node.right.height;
      node.startRow = beginIdx;
      return node;
    } else {
      //root may cover all
      Node leaf = Leaf();
      //int defHeight=0;
      if (node == root) {
        leaf = root;
      } else {
        (leaf as Leaf).root = root;
      }
      leaf.numRow = rows.length;
      leaf.numRow = rows.length;
      leaf.height = rows.fold(0, (prev, elem) => prev + (elem['_height'] as int ?? root.defaultHeight));
      leaf.startRow = beginIdx;
      return leaf;
    }
  }

  _isLeaf() => left == null && right == null;

  bool _inScope(int rowId) {
    if (rowId >= startRow && rowId <= startRow + numRow) {
      return true;
    }
    return false;
  }
  //using guess method
  //from root traverse down to block
//  bool _inPosScope(int pos){
//    if(this)
//    }

  ///
  /// get y position relative first row,
  /// first row height=0
  /// @param rowId target rowId,zero based
  /// @param beginHeight start height of each block
  /// @return compuatd y axis relative to 0
  ///
  int _getPositionHelper(int rowId, [int beginHeight = 0]) {
    if (!this._isLeaf()) {
      if (this.left != null && this.left._inScope(rowId)) return this.left._getPositionHelper(rowId, beginHeight);
      if (this.right != null && this.right._inScope(rowId)) {
        return this.right._getPositionHelper(rowId, this.left.height + beginHeight);
      }
    } else {
      //leaf
      //begin hight + each item length in block to target rowid
      int targetHeight = beginHeight;
      //int nextRowId=rowId+1;
      List arr = (this as Leaf).root.rows;
      for (int i = startRow; i < rowId; i++) {
        targetHeight += (arr[i]['_height'] != null ? arr[i]['_height'] : (this as Leaf).root.defaultHeight);
      }
      return targetHeight;
    }
    //traverse down to each node from most left node and sum up to each right node
    //if have child, go to child, if have left ,
    return -1;
  }

  //add cache here
  int getPosition(int rowId, [int beginHeight = 0]) {
    Root r = this as Root;

    if (r.cache.containsKey(rowId)) {
      return r.cache[rowId];
    }
    if (r.cache.containsKey(rowId - 1)) {
      int curPos = r.cache[rowId - 1] + (r.rows[rowId - 1]['_height'] != null ? r.rows[rowId - 1]['_height'] : r.defaultHeight);
      r.cache[rowId] = curPos;
      return r.cache[rowId];
    }

    if (rowId >= (this as Root).rows.length) return -1;

    int npos = _getPositionHelper(rowId, 0);
    r.cache[rowId] = npos;
    return npos;
  }

  ///
  /// get rowId from position
  /// @param position current y postion relative to first row
  ///
  int getRowId(int position) {
    Node start = this;
    int beginHeight = 0;
    while (!start._isLeaf()) {
      if (start.left != null && position < beginHeight + start.left.height) {
        start = start.left;
        continue;
      }
      beginHeight += start.left.height;
      if (start.right != null) {
        start = start.right;
      }
    }
    Leaf curPos = start as Leaf;
    List arr = curPos.root.rows;
    for (int i = 0; i < start.numRow; ++i) {
      int len = arr[start.startRow + i]['_height'] != null ? arr[start.startRow + i]['_height'] : curPos.root.defaultHeight;
      if (beginHeight <= position && beginHeight + len > position) {
        return start.startRow + i;
      } else {
        beginHeight += len;
      }
    }
    return start.startRow + start.numRow; //last row
  }
}

///
/// a leaf is start or
///
class Leaf extends Node {
  Root root;
}

class Root extends Leaf {
  List rows;
  int defaultHeight;
  //TOOD fixme, restrict cache size
  //row id to position, use LFU
  // {rowid, {pos, accCnt}}
  Map<int, int> cache = {};

  static final int THRESHOLD = 100;
  Root(this.rows, [this.defaultHeight]) {
    this.root = this;
    this._createTree(this, rows);
  }
}
