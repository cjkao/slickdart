//to read csv and mapping to map object
import 'dart:html';
import 'dart:async';
import 'package:slickdart/slick.dart' as cj;
import 'dart:math' as math;
import 'package:slickdart/plugin/autotooltip.dart';
import 'dart:async';
main(){
  HttpRequest.getString( 'gss1983_Code.csv').then((_){
    print('ok');

  });
}