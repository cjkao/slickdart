import 'package:test/test.dart';
import 'dart:convert';
import 'package:slickdart/slick.dart';

//import 'package:slickdart/parser.dart';
import 'dart:async';
import 'dart:io';
main() {
// test('An empty test', () {
//   var timer = Timer.run(expectAsync(() {
//     File f= new File('gss.csv');
//     f.readAsString().then((strs){
//       CsvAdapter csv= new CsvAdapter(strs);
//       print (JSON.encode(csv.columns));
//       print (JSON.encode(csv.data));
//     });
//   }));
//
// });
 test('test that time has passed', () {
  //  var duration = const Duration(milliseconds: 200);
  //  var time = new DateTime.now();
   CsvAdapter csv;
   Timer.run(()=>expectAsync0(() {
     File f= new File('gss.csv');
     String fstr=f.readAsStringSync();
     print (fstr);
     csv= new CsvAdapter(fstr);
     print (json.encode(csv.columns));
     print (json.encode(csv.data));
     expect(csv.columns, 3);

   }));
 });



}
