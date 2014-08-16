library slick.util;
import 'dart:html';
/** TODO add scope
 * find element's cloest parent of target css selector rule
 * ancestorClzName : query condition
 *
 */
Element findClosestAncestor(Element element, String cssSelector,[String scope]) {
  if (element == null ) return null;
  do {
    if (element.matches(cssSelector)) return element;
    element = element.parent;
  } while(element != null );
  return null;
}