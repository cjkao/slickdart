import "package:angular/angular.dart";
// import "package:http/http.dart" as http;
import "dart:async";
import "dart:convert";
import "../model/model.dart";
import 'package:http/browser_client.dart';
import 'package:slickdart/slick.dart';

@Injectable()
class MyService {
  var client = BrowserClient();
  Future<Map> getJson() async {
    var resp = await client.get("data.json");
    return json.decode(resp.body);
  }

  Future<List<Hero>> getHeroes() async {
    var data = await getJson();
    var heroes = (data["heros"] as List).map((_) {
      return Hero(_["name"], _["power"], _["mana"]);
    }).toList();
    return heroes;
  }

  Future<CsvAdapter> getGridData() async {
    var resp = await client.get("gss1983_Code-small.csv");
    var csv = CsvAdapter(resp.body);
    return csv;
  }

  Hero selectedHero;
}
