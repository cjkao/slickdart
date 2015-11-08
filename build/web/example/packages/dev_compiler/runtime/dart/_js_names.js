var _js_names;
(function(exports) {
  'use strict';
  // Function preserveNames: () → dynamic
  function preserveNames() {
  }
  dart.defineLazyProperties(exports, {
    get mangledNames() {
      return computeMangledNames(_foreign_helper.JS_EMBEDDED_GLOBAL('=Object', _js_embedded_names.MANGLED_NAMES), false);
    },
    get reflectiveNames() {
      return computeReflectiveNames(exports.mangledNames);
    },
    get mangledGlobalNames() {
      return computeMangledNames(_foreign_helper.JS_EMBEDDED_GLOBAL('=Object', _js_embedded_names.MANGLED_GLOBAL_NAMES), true);
    },
    get reflectiveGlobalNames() {
      return computeReflectiveNames(exports.mangledGlobalNames);
    }
  });
  // Function computeMangledNames: (dynamic, bool) → Map<String, String>
  function computeMangledNames(jsMangledNames, isGlobal) {
    preserveNames();
    let keys = extractKeys(jsMangledNames);
    let result = dart.map();
    let getterPrefix = _foreign_helper.JS_GET_NAME('GETTER_PREFIX');
    let getterPrefixLength = getterPrefix.length;
    let setterPrefix = _foreign_helper.JS_GET_NAME('SETTER_PREFIX');
    for (let key of dart.as(keys, core.Iterable$(core.String))) {
      let value = jsMangledNames[key];
      result.set(key, value);
      if (!dart.notNull(isGlobal)) {
        if (key.startsWith(getterPrefix)) {
          result.set(`${setterPrefix}${key.substring(getterPrefixLength)}`, `${value}=`);
        }
      }
    }
    return result;
  }
  // Function computeReflectiveNames: (Map<String, String>) → Map
  function computeReflectiveNames(map) {
    preserveNames();
    let result = dart.map();
    map.forEach((mangledName, reflectiveName) => {
      result.set(reflectiveName, mangledName);
    });
    return result;
  }
  // Function extractKeys: (dynamic) → List<dynamic>
  function extractKeys(victim) {
    let result = function(victim, hasOwnProperty) {
      var result = [];
      for (var key in victim) {
        if (hasOwnProperty.call(victim, key))
          result.push(key);
      }
      return result;
    }(victim, Object.prototype.hasOwnProperty);
    return new _interceptors.JSArray.markFixed(result);
  }
  // Function unmangleGlobalNameIfPreservedAnyways: (String) → String
  function unmangleGlobalNameIfPreservedAnyways(name) {
    let names = _foreign_helper.JS_EMBEDDED_GLOBAL('=Object', _js_embedded_names.MANGLED_GLOBAL_NAMES);
    return dart.as(_js_helper.JsCache.fetch(names, name), core.String);
  }
  // Function unmangleAllIdentifiersIfPreservedAnyways: (String) → String
  function unmangleAllIdentifiersIfPreservedAnyways(str) {
    return str.replace(/[^<,> ]+/g, function(m) {
      return _foreign_helper.JS_EMBEDDED_GLOBAL('', _js_embedded_names.MANGLED_GLOBAL_NAMES)[m] || m;
    });
  }
  // Exports:
  exports.preserveNames = preserveNames;
  exports.computeMangledNames = computeMangledNames;
  exports.computeReflectiveNames = computeReflectiveNames;
  exports.extractKeys = extractKeys;
  exports.unmangleGlobalNameIfPreservedAnyways = unmangleGlobalNameIfPreservedAnyways;
  exports.unmangleAllIdentifiersIfPreservedAnyways = unmangleAllIdentifiersIfPreservedAnyways;
})(_js_names || (_js_names = {}));
