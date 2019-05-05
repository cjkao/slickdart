library slick.observer;
import "dart:html";
var observer = IntersectionObserver((changes,obs){
  for (var change in changes) {
    // ⚠️ Feature detection
    if ( change.isVisible == 'undefined') {
      // The browser doesn't support Intersection Observer v2, falling back to v1 behavior.
      change.isVisible = true;
    }
    if (change.isIntersecting && change.isVisible) {
      // visibleSince = change.time;
    } else {
      // visibleSince = 0;
    }
  }
}, {
  "threshold": [1.0],
  // 🆕 Track the actual visibility of the element
  "trackVisibility": true,
  // 🆕 Set a minimum delay between notifications
  "delay": 100
});