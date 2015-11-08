// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Feature test for harmony support, alert if not present.
(function () {
  try {
    var f = new Function(
      '"use strict";'+
      'class C {' +
        'constructor(x) { this.x = x; };' +
        // TODO(jmesserly): arrow functions on V8 don't have lexical this yet.
        // https://code.google.com/p/v8/issues/detail?id=2700
        '["foo"]() { var self = this; return x => self.x + x; };' +
      '};' +
      'return new C(42).foo()(100);');
    if (f() == 142) return; // supported!
  } catch (e) {
  }

  var message = 'This script needs EcmaScript 6 features ' +
      'like `class` and `=>`. Please run in a browser with support, ' +
      'for example: chrome --js-flags="--harmony-arrow-functions' +
      ' --harmony-classes --harmony-computed-property-names"';
  console.error(message);
  alert(message);

})();
