import 'dart:html';
//import 'dart:math' as math;
import 'package:slickdart/slick_custom.dart';
import 'package:slickdart/slick.dart';
//import 'package:slickdart/parser.dart';


import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:angular_ui/angular_ui.dart';

main() async{
  document.querySelector('body').onClick.listen((event){
    var x = event.client.x;
       var y = event.client.y;
       var coords = "X coords: $x ,Y coords: $y";
       document.getElementById("demo").innerHtml= coords;
  });
  registerElem();
  applicationFactory()
    .addModule(new AngularUIModule()) // The angular-ui module
    .addModule(new MainModule()) // Your own module
    .run();
  

}
/**
 * enable column sort
 */
List<Column> getColDefs(List<Column> cols) {
  List<Column> newCols = cols.map((col) => new Column.fromColumn(col)..sortable=true).toList();
  CheckboxSelectColumn checkboxCol = new CheckboxSelectColumn({
    'cssClass': "slick-cell-checkboxsel"
  });

  newCols.insert(0, checkboxCol.getColumnDefinition());
  return newCols;
}
LinkFormatter(row, cell, value, columnDef, dataContext) {
  return value != null ? "<a  href='#'>z</a>" : "";
}

Map getMeta(int row){
          if(row %2==1){
            return {
                      "cssClasses": "highlight"
                   };
          }else return {};
}



class MainModule extends Module {
  MainModule() {
    install(new AngularUIModule());
    bind(ModalDemoEmbeddedTemplate);
  }
}


/**
 * Modal controller with template.
 */
@Component(
  selector: 'modal-demo-embedded-tmpl', 
  useShadowDom: false,
  templateUrl: '../../popup_template.html',
  exportExpressions: const ["tmp", "ok"]
)
class ModalDemoEmbeddedTemplate implements ScopeAware {
  List<String> items = ["1111", "2222", "3333", "4444"];
  String selected;
  String tmp;
  
  Modal modal;
  ModalInstance modalInstance;
  Scope scope;
  
  String template = """
<div class="modal-header">
  <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
  <h4 class="modal-title">I'm a modal!</h4>
</div>
<div class="modal-body">
  
  <cj-grid class='first' download='f.csv'></cj-grid>

</div>
<div class="modal-footer">
  <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
  <button type="button" class="btn btn-primary" ng-click="ok(tmp)">OK</button>
</div>
""";
  
ModalDemoEmbeddedTemplate(this.modal);
  
  ModalInstance getModalInstance() {
    return modal.open(new ModalOptions(template:template), scope);
  }
  
   open() {
    modalInstance = getModalInstance();
    
    modalInstance.opened.then((v) async{
        print('Opened');
       
        var data=await HttpRequest.getString('../gss1983_Code.csv');
            CsvAdapter csv = new CsvAdapter(data);
            var cols = getColDefs(csv.columns);
            cols[1]..width=20..name='id';
            csv.columns[0]..width=14..name='id';
            JGrid gw0 = document.querySelector("$GRID_TAG.first");
            gw0.init(new MetaList(csv.data.sublist(1, 20),getMeta), cols);

            gw0.grid.setSelectionModel(new RowSelectionModel({
              'selectActiveRow': false
            }));
            gw0.grid.onSelectedRowsChanged.subscribe((EventData e, Map args) {
              querySelector('.right-pane')
                  ..children.clear()
                  ..appendText((args['rows'] as List).join(' '));
            });
        
//        
        
        
        
        
        
        
        
        
        
        
        
      }, onError: (e) {
        print('Open error is $e');
      });
    
    // Override close to add you own functionality 
    modalInstance.close = (result) { 
      selected = result;
      print('Closed with selection $selected');
      modal.hide();
    };
    // Override dismiss to add you own functionality 
    modalInstance.dismiss = (String reason) { 
      print('Dismissed with $reason');
      modal.hide();
   };
  }
  
  void ok(sel) {
    modalInstance.close(sel);
  }
}

