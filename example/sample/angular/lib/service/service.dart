import "package:angular/angular.dart";
// import "package:http/http.dart" as http;
import "dart:async";
import "dart:convert";
import "../model/model.dart";
import 'package:http/browser_client.dart';

@Injectable()
class MyService {
  Future<Map> getJson() async {
    var client = new BrowserClient();
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

  Hero selectedHero;
}
