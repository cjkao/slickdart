//to read csv and mapping to map object
import 'dart:html';
import 'dart:async';
import 'package:slickdart/slick.dart' as cj;
import 'dart:math' as math;
import 'package:slickdart/plugin/autotooltip.dart';
import 'dart:async';
//import 'package:csv/csv.dart';
//import 'package:csvparser/csvparser.dart';
main(){
  HttpRequest.getString( 'gss1983_Code-small.csv').then((data){

    //var decoder = new CsvToListConverter(fieldDelimiter:',',parseNumbers:false);
    var colNames= ["A","B","C"];
    var arr=data.split("\r").map((_){
      var cols=_.split(',');
      return {
        colNames[0]: cols[0]
      };

    });



    //each arr item to s
    //var list = decoder.convert(data);
    print('ok');
  //  CsvParser cp = new CsvParser(data, seperator:",", quotemark:"\"");
   // cp.getLineAsList();
  });
}