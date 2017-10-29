import 'package:test/test.dart';
import 'package:slickdart/row_height.dart';
main() {
 test('An empty test', () {
   List list=[];
   int total=501;
   for(int i=0;i<total;i++){
     list.add({'_height':10,'a':i});
   }
   Node n = new Root(list);
//   n.createTree(n, list);
   int pos=n.getPosition(5);
   expect(pos,50);

   pos=n.getPosition(50);
   expect(pos,500);

   for(int i=0;i<total;i++){
     pos=n.getPosition(i);
     expect(pos,i*10);
     if(i%10000==0)
     print(pos);
   }

   // a test with expectations and matchers
 });


 test('increasing height', () {
    List list=[];
    int total=500;
    for(int i=0;i<total;i++){
      list.add({'_height':i,'a':i});
    }
    Node n = new Root(list);
//    n.createTree(n, list);
    int pos=n.getPosition(5);
    expect(pos,10);

    int currentHeight=0;
    for(int i=0;i<total;i++){
      pos=n.getPosition(i);
      expect(pos,currentHeight);
      currentHeight+=i;
      if(i%100==0)
        print(pos);
    }

    // a test with expectations and matchers
  });

 test('random sparce height', () {
     List list=[];
     int total=5000;
     for(int i=0;i<total;i++){
       list.add({'a':i});
     }
     list[0]['_height']=30;
     list[11]['_height']=30;
     Root n = new Root(list,20);
//     n.createTree(n, list);
     int pos=n.getPosition(5);
     expect(pos,110);
     pos=n.getPosition(12);
     expect(pos,260);


     // a test with expectations and matchers
   });
 test('position to row id', () {
     List list=[];
     int total=5000;
     for(int i=0;i<total;i++){
       list.add({'a':i});
     }
     Root n = new Root(list,20);
//     n.createTree(n, list);
     int pos=n.getPosition(5);
     int rowid=n.getRowId(119);
     expect(pos,100);
     expect(rowid,5);
     for(int i=100;i<120;i++){
       int rowid=n.getRowId(i);
       expect(rowid,5);
     }
   });

 test('position to row id 2', () {
      List list=[];
      int total=5000;
      for(int i=0;i<total;i++){
        list.add({'a':i});
      }
     list[0]['_height']=30;
     list[11]['_height']=30;
      Root n = new Root(list,20);
//      n.createTree(n, list);
      int pos=n.getPosition(5);
      int rowid=n.getRowId(230);
      expect(pos,110);
      expect(rowid,11);
      expect(n.getRowId(231),11);
    });


}