// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

var dart, _js_helper;
(function (dart) {
  'use strict';

  let defineProperty = Object.defineProperty;
  let getOwnPropertyDescriptor = Object.getOwnPropertyDescriptor;
  let getOwnPropertyNames = Object.getOwnPropertyNames;

  // Adapted from Angular.js
  let FN_ARGS = /^function\s*[^\(]*\(\s*([^\)]*)\)/m;
  let FN_ARG_SPLIT = /,/;
  let FN_ARG = /^\s*(_?)(\S+?)\1\s*$/;
  let STRIP_COMMENTS = /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/mg;

  function formalParameterList(fn) {
    let fnText,argDecl;
    let args=[];
    fnText = fn.toString().replace(STRIP_COMMENTS, '');
    argDecl = fnText.match(FN_ARGS);

    let r = argDecl[1].split(FN_ARG_SPLIT);
    for(let a in r) {
      let arg = r[a];
      arg.replace(FN_ARG, function(all, underscore, name){
        args.push(name);
      });
    }
    return args;
  }

  function dload(obj, field) {
    if (!(field in obj)) {
      throw new core.NoSuchMethodError(obj, field);
    }
    return obj[field];
  }
  dart.dload = dload;

  // TODO(jmesserly): this should call noSuchMethod, not throw.
  function throwNoSuchMethod(obj, name, args, opt_func) {
    if (obj === void 0) obj = opt_func;
    throw new core.NoSuchMethodError(obj, name, args);
  }

  function checkAndCall(f, obj, args, name) {
    if (!(f instanceof Function)) {
      // Grab the `call` method if it's not a function.
      if (f !== null) f = f.call;
      if (!(f instanceof Function)) {
        throwNoSuchMethod(obj, method, args);
      }
    }
    // TODO(jmesserly): enable this when we can fix => and methods.
    /*
    let formals = formalParameterList(f);
    // TODO(vsm): Type check args!  We need to encode sufficient type info on f.
    if (formals.length < args.length) {
      throwNoSuchMethod(obj, name, args, f);
    } else if (formals.length > args.length) {
      for (let i = args.length; i < formals.length; ++i) {
        if (formals[i].indexOf("opt$") != 0) {
          throwNoSuchMethod(obj, name, args, f);
        }
      }
    }
    */
    return f.apply(obj, args);
  }

  function dcall(f/*, ...args*/) {
    let args = Array.prototype.slice.call(arguments, 1);
    return checkAndCall(f, void 0, args, 'call');
  }
  dart.dcall = dcall;

  function dsend(obj, method/*, ...args*/) {
    let args = Array.prototype.slice.call(arguments, 2);
    return checkAndCall(obj[method], obj, args, method);
  }
  dart.dsend = dsend;

  function dindex(obj, index) {
    return checkAndCall(obj.get, obj, [index], '[]');
  }
  dart.dindex = dindex;

  function dsetindex(obj, index, value) {
    return checkAndCall(obj.set, obj, [index, value], '[]=');
  }
  dart.dsetindex = dsetindex;

  function cast(obj, type) {
    // TODO(vsm): handle non-nullable types
    if (obj == null) return obj;
    let actual = getRuntimeType(obj);
    if (isSubtype(actual, type)) return obj;
    throw new _js_helper.CastErrorImplementation(actual, type);
  }
  dart.as = cast;

  /**
   * Returns the runtime type of obj. This is the same as `obj.runtimeType`
   * but will not call an overridden getter.
   *
   * Currently this will return null for non-Dart objects.
   */
  function getRuntimeType(obj) {
    switch (typeof obj) {
      case "undefined":
        return core.Null;
      case "number":
        return Math.floor(obj) == obj ? core.int : core.double;
      case "boolean":
        return core.bool;
      case "string":
        return core.String;
      case "symbol":
        return Symbol;
    }
    // Undefined is handled above. For historical reasons,
    // typeof null == "object" in JS.
    if (obj === null) return core.Null;
    // TODO(vsm): Should we treat Dart and JS objects differently here?
    // E.g., we can check if obj instanceof core.Object to differentiate.
    var result = obj[dart.runtimeType];
    if (result) return result;
    result = obj.constructor;
    if (result == Function) {
      return getFunctionType(obj);
    }
    return result;
  }
  dart.getRuntimeType = getRuntimeType;

  function instanceOf(obj, type) {
    return isSubtype(getRuntimeType(obj), type);
  }
  dart.is = instanceOf;

  /**
   * Computes the canonical type.
   * This maps JS types onto their corresponding Dart Type.
   */
  // TODO(jmesserly): lots more needs to be done here.
  function canonicalType(t) {
    if (t === Object) return core.Object;
    if (t === Function) return core.Function;
    if (t === Array) return core.List;

    // We shouldn't normally get here with these types, unless something strange
    // happens like subclassing Number in JS and passing it to Dart.
    if (t === String) return core.String;
    if (t === Number) return core.double;
    if (t === Boolean) return core.bool;
    return t;
  }

  let subtypeMap = new Map();
  function isSubtype(t1, t2) {
    // See if we already know the answer
    // TODO(jmesserly): general purpose memoize function?
    let map = subtypeMap.get(t1);
    let result;
    if (map) {
      result = map.get(t2);
      if (result !== void 0) return result;
    } else {
      subtypeMap.set(t1, map = new Map());
    }
    map.set(t2, result = isSubtype_(t1, t2));
    return result;
  }
  dart.isSubtype = isSubtype;

  function _isBottom(type, dynamicIsBottom) {
    return (type == dart.dynamic && dynamicIsBottom) || type == dart.bottom;
  }

  function _isTop(type, dynamicIsBottom) {
    return type == core.Object || (type == dart.dynamic && !dynamicIsBottom);
  }

  function isSubtype_(t1, t2, opt_dynamicIsBottom) {
    let dynamicIsBottom =
      opt_dynamicIsBottom === void 0 ? false : opt_dynamicIsBottom;

    t1 = canonicalType(t1);
    t2 = canonicalType(t2);
    if (t1 == t2) return true;

    // In Dart, dynamic is effectively both top and bottom.
    // Here, we treat dynamic as one or the other depending on context,
    // but not both.

    // Trivially true.
    if (_isTop(t2, dynamicIsBottom) || _isBottom(t1, dynamicIsBottom)) {
      return true;
    }

    // Trivially false.
    if (_isTop(t1, dynamicIsBottom) || _isBottom(t2, dynamicIsBottom)) {
      return false;
    }

    // "Traditional" name-based subtype check.
    if (isClassSubType(t1, t2)) {
      return true;
    }

    // Function subtyping.
    // TODO(vsm): Handle Objects with call methods.  Those are functions
    // even if they do not *nominally* subtype core.Function.
    if (isFunctionType(t1) &&
        isFunctionType(t2)) {
      return isFunctionSubType(t1, t2);
    }
    return false;
  }

  function safeGetOwnProperty(obj, name) {
    var desc = getOwnPropertyDescriptor(obj, name);
    if (desc) return desc.value;
  }

  function isClassSubType(t1, t2) {
    // We support Dart's covariant generics with the caveat that we do not
    // substitute bottom for dynamic in subtyping rules.
    // I.e., given T1, ..., Tn where at least one Ti != dynamic we disallow:
    // - S !<: S<T1, ..., Tn>
    // - S<dynamic, ..., dynamic> !<: S<T1, ..., Tn>
    t1 = canonicalType(t1);
    assert(t2 == canonicalType(t2));
    if (t1 == t2) return true;

    if (t1 == core.Object) return false;

    // If t1 is a JS Object, we may not hit core.Object.
    if (t1 == null) return t2 == core.Object || t2 == dart.dynamic;

    // Check if t1 and t2 have the same raw type.  If so, check covariance on
    // type parameters.
    let raw1 = safeGetOwnProperty(t1, dart.originalDeclaration);
    let raw2 = safeGetOwnProperty(t2, dart.originalDeclaration);
    if (raw1 != null && raw1 == raw2) {
      let typeArguments1 = safeGetOwnProperty(t1, dart.typeArguments);
      let typeArguments2 = safeGetOwnProperty(t2, dart.typeArguments);
      let length = typeArguments1.length;
      if (typeArguments2.length == 0) {
        // t2 is the raw form of t1
        return true;
      } else if (length == 0) {
        // t1 is raw, but t2 is not
        return false;
      }
      assert(length == typeArguments2.length);
      for (let i = 0; i < length; ++i) {
        if (!isSubtype(typeArguments1[i], typeArguments2[i])) {
          return false;
        }
      }
      return true;
    }

    // Check superclass.
    if (isClassSubType(t1.__proto__, t2)) return true;

    // Check mixins.
    let mixins = safeGetOwnProperty(t1, dart.mixins);
    if (mixins) {
      for (let m1 of mixins) {
        // TODO(jmesserly): remove the != null check once we can load core libs.
        if (m1 != null && isClassSubType(m1, t2)) return true;
      }
    }

    // Check interfaces.
    let getInterfaces = safeGetOwnProperty(t1, dart.implements);
    if (getInterfaces) {
      for (let i1 of getInterfaces()) {
        // TODO(jmesserly): remove the != null check once we can load core libs.
        if (i1 != null && isClassSubType(i1, t2)) return true;
      }
    }

    return false;
  }

  // TODO(jmesserly): this isn't currently used, but it could be if we want
  // `obj is NonGroundType<T,S>` to be rejected at runtime instead of compile
  // time.
  function isGroundType(type) {
    // TODO(vsm): Cache this if we start using it at runtime.

    if (type instanceof AbstractFunctionType) {
      if (!_isTop(type.returnType, false)) return false;
      for (var i = 0; i < type.args.length; ++i) {
        if (!_isBottom(type.args[i], true)) return false;
      }
      for (var i = 0; i < type.optionals.length; ++i) {
        if (!_isBottom(type.optionals[i], true)) return false;
      }
      var names = Object.getOwnPropertyNames(type.named);
      for (var i = 0; i < names.length; ++i) {
        if (!_isBottom(type.named[names[i]], true)) return false;
      }
      return true;
    }

    let typeArgs = safeGetOwnProperty(type, dart.typeArguments);
    if (!typeArgs) return true;
    for (let t of typeArgs) {
      if (t != core.Object && t != dart.dynamic) return false;
    }
    return true;
  }
  dart.isGroundType = isGroundType;

  function arity(f) {
    // TODO(jmesserly): need to parse optional params.
    // In ES6, length is the number of required arguments.
    return { min: f.length, max: f.length };
  }
  dart.arity = arity;

  function equals(x, y) {
    if (x == null || y == null) return x == y;
    let eq = x['=='];
    return eq ? eq.call(x, y) : x == y;
  }
  dart.equals = equals;

  /** Checks that `x` is not null or undefined. */
  function notNull(x) {
    if (x == null) throw 'expected not-null value';
    return x;
  }
  dart.notNull = notNull;

  function _typeName(type) {
    var name = type.name;
    if (!name) throw 'Unexpected type: ' + type;
    return name;
  }

  class AbstractFunctionType {
    constructor() {
      this._stringValue = null;
    }

    get name() {
      if (this._stringValue) return this._stringValue;

      var buffer = '(';
      for (var i = 0; i < this.args.length; ++i) {
        if (i > 0) {
          buffer += ', ';
        }
        buffer += _typeName(this.args[i]);
      }
      if (this.optionals.length > 0) {
        if (this.args.length > 0) buffer += ', ';
        buffer += '[';
        for (var i = 0; i < this.optionals.length; ++i) {
          if (i > 0) {
            buffer += ', ';
          }
          buffer += _typeName(this.optionals[i]);
        }
        buffer += ']';
      } else if (this.named.length > 0) {
        if (this.args.length > 0) buffer += ', ';
        buffer += '{';
        let names = Object.getOwnPropertyNames(this.named).sort();
        for (var i = 0; i < names.length; ++i) {
          if (i > 0) {
            buffer += ', ';
          }
          buffer += names[i] + ': ' + _typeName(this.named[names[i]]);
        }
        buffer += '}';
      }

      buffer += ') -> ' + _typeName(this.returnType);
      this._stringValue = buffer;
      return buffer;
    }
  }

  class FunctionType extends AbstractFunctionType {
    constructor(returnType, args, optionals, named) {
      super();
      this.returnType = returnType;
      this.args = args;
      this.optionals = optionals;
      this.named = named;
    }
  }

  function functionType(returnType, args, extra) {
    // TODO(vsm): Cache / memomize?
    var optionals;
    var named;
    if (extra === void 0) {
      optionals = [];
      named = {};
    } else if (extra instanceof Array) {
      optionals = extra;
      named = {};
    } else {
      optionals = [];
      named = extra;
    }
    return new FunctionType(returnType, args, optionals, named);
  }
  dart.functionType = functionType;

  class Typedef extends AbstractFunctionType {
    constructor(name, closure) {
      super();
      this._name = name;
      this._closure = closure;
      this._functionType = null;
    }

    get name() {
      return this._name;
    }

    get functionType() {
      if (!this._functionType) {
        this._functionType = this._closure();
      }
      return this._functionType;
    }

    get returnType() {
      return this.functionType.returnType;
    }

    get args() {
      return this.functionType.args;
    }

    get optionals() {
      return this.functionType.optionals;
    }

    get named() {
      return this.functionType.named;
    }
  }

  function typedef(name, closure) {
    return new Typedef(name, closure);
  }
  dart.typedef = typedef;

  function isFunctionType(type) {
    return isClassSubType(type, core.Function) || type instanceof AbstractFunctionType;
  }

  function getFunctionType(obj) {
    // TODO(vsm): Encode this properly on the function for Dart-generated code.
    var args = Array.apply(null, new Array(obj.length)).map(function(){return core.Object});
    return functionType(dart.bottom, args);
  }

  function isFunctionSubType(ft1, ft2) {
    if (ft2 == core.Function) {
      return true;
    }

    let ret1 = ft1.returnType;
    let ret2 = ft2.returnType;

    if (!isSubtype_(ret1, ret2)) {
      // Covariant return types
      // Note, void (which can only appear as a return type) is effectively
      // treated as dynamic.  If the base return type is void, we allow any
      // subtype return type.
      // E.g., we allow:
      //   () -> int <: () -> void
      if (ret2 != dart.void) {
        return false;
      }
    }

    let args1 = ft1.args;
    let args2 = ft2.args;

    if (args1.length > args2.length) {
      return false;
    }

    for (var i = 0; i < args1.length; ++i) {
      if (!isSubtype_(args2[i], args1[i], true)) {
        return false;
      }
    }

    let optionals1 = ft1.optionals;
    let optionals2 = ft2.optionals;

    if (args1.length + optionals1.length < args2.length + optionals2.length) {
      return false;
    }

    var j = 0;
    for (var i = args1.length; i < args2.length; ++i, ++j) {
      if (!isSubtype_(args2[i], optionals1[j], true)) {
        return false;
      }
    }

    for (var i = 0; i < optionals2.length; ++i, ++j) {
      if (!isSubtype_(optionals2[i], optionals1[j], true)) {
        return false;
      }
    }

    let named1 = ft1.named;
    let named2 = ft2.named;

    let names = Object.getOwnPropertyNames(named2);
    for (var i = 0; i < names.length; ++i) {
      let name = names[i];
      let n1 = named1[name]
      let n2 = named2[name];
      if (n1 === void 0) {
        return false;
      }
      if (!isSubtype_(n2, n1, true)) {
        return false;
      }
    }

    return true;
  }

  /**
   * Defines a lazy property.
   * After initial get or set, it will replace itself with a value property.
   */
  // TODO(jmesserly): is this the best implementation for JS engines?
  // TODO(jmesserly): reusing descriptor objects has been shown to improve
  // performance in other projects (e.g. webcomponents.js ShadowDOM polyfill).
  function defineLazyProperty(to, name, desc) {
    let init = desc.get;
    let writable = !!desc.set;
    function lazySetter(value) {
      defineProperty(to, name, { value: value, writable: writable });
    }
    function lazyGetter() {
      // Clear the init function to detect circular initialization.
      let f = init;
      if (f === null) throw 'circular initialization for field ' + name;
      init = null;

      // Compute and store the value.
      let value = f();
      lazySetter(value);
      return value;
    }
    desc.get = lazyGetter;
    desc.configurable = true;
    if (writable) desc.set = lazySetter;
    defineProperty(to, name, desc);
  }

  function defineLazy(to, from) {
    let names = getOwnPropertyNames(from);
    for (let i = 0; i < names.length; i++) {
      let name = names[i];
      defineLazyProperty(to, name, getOwnPropertyDescriptor(from, name));
    }
  }
  // TODO(jmesserly): these are identical, but this makes it easier to grep for.
  dart.defineLazyClass = defineLazy;
  dart.defineLazyProperties = defineLazy;
  dart.defineLazyClassGeneric = defineLazyProperty;

  /**
   * Copy properties from source to destination object.
   * This operation is commonly called `mixin` in JS.
   */
  function copyProperties(to, from) {
    let names = getOwnPropertyNames(from);
    for (let i = 0; i < names.length; i++) {
      let name = names[i];
      defineProperty(to, name, getOwnPropertyDescriptor(from, name));
    }
    return to;
  }
  dart.copyProperties = copyProperties;


  /** The Symbol for storing type arguments on a specialized generic type. */
  dart.mixins = Symbol('mixins');
  dart.implements = Symbol('implements');

  /**
   * Returns a new type that mixes members from base and all mixins.
   *
   * Each mixin applies in sequence, with further to the right ones overriding
   * previous entries.
   *
   * For each mixin, we only take its own properties, not anything from its
   * superclass (prototype).
   */
  function mixin(base/*, ...mixins*/) {
    // Create an initializer for the mixin, so when derived constructor calls
    // super, we can correctly initialize base and mixins.
    let mixins = Array.prototype.slice.call(arguments, 1);

    // Create a class that will hold all of the mixin methods.
    class Mixin extends base {
      // Initializer method: run mixin initializers, then the base.
      [base.name](/*...args*/) {
        // Run mixin initializers. They cannot have arguments.
        // Run them backwards so most-derived mixin is initialized first.
        for (let i = mixins.length - 1; i >= 0; i--) {
          let mixin = mixins[i];
          let init = mixin.prototype[mixin.name];
          if (init) init.call(this);
        }
        // Run base initializer.
        let init = base.prototype[base.name];
        if (init) init.apply(this, arguments);
      }
    }
    // Copy each mixin's methods, with later ones overwriting earlier entries.
    for (let m of mixins) {
      copyProperties(Mixin.prototype, m.prototype);
    }
    // Save mixins for reflection
    Mixin[dart.mixins] = mixins;
    return Mixin;
  }
  dart.mixin = mixin;

  /**
   * Creates a dart:collection LinkedHashMap.
   *
   * For a map with string keys an object literal can be used, for example
   * `map({'hi': 1, 'there': 2})`.
   *
   * Otherwise an array should be used, for example `map([1, 2, 3, 4])` will
   * create a map with keys [1, 3] and values [2, 4]. Each key-value pair
   * should be adjacent entries in the array.
   *
   * For a map with no keys the function can be called with no arguments, for
   * example `map()`.
   */
  // TODO(jmesserly): this could be faster
  function map(values) {
    let map = new collection.LinkedHashMap();
    if (Array.isArray(values)) {
      for (let i = 0, end = values.length - 1; i < end; i += 2) {
        let key = values[i];
        let value = values[i + 1];
        map.set(key, value);
      }
    } else if (typeof values === 'object') {
      for (let key of Object.getOwnPropertyNames(values)) {
        map.set(key, values[key]);
      }
    }
    return map;
  }
  dart.map = map;

  function assert(condition) {
    // TODO(jmesserly): throw assertion error.
    if (!condition) throw 'assertion failed';
  }
  dart.assert = assert;

  function throw_(obj) { throw obj; }
  dart.throw_ = throw_;

  /**
   * Given a class and an initializer method name, creates a constructor
   * function with the same name. For example `new SomeClass.name(args)`.
   */
  function defineNamedConstructor(clazz, name) {
    let proto = clazz.prototype;
    let initMethod = proto[name];
    let ctor = function() { return initMethod.apply(this, arguments); }
    ctor.prototype = proto;
    clazz[name] = ctor;
  }
  dart.defineNamedConstructor = defineNamedConstructor;

  function stackTrace(exception) {
    throw new core.UnimplementedError();
  }
  dart.stackTrace = stackTrace;

  /** The Symbol for storing type arguments on a specialized generic type. */
  dart.typeArguments = Symbol('typeArguments');
  dart.originalDeclaration = Symbol('originalDeclaration');

  /** Memoize a generic type constructor function. */
  function generic(typeConstructor) {
    let length = typeConstructor.length;
    if (length < 1) throw Error('must have at least one generic type argument');

    let resultMap = new Map();
    function makeGenericType(/*...arguments*/) {
      if (arguments.length != length && arguments.length != 0) {
        throw Error('requires ' + length + ' or 0 type arguments');
      }
      let args = Array.prototype.slice.call(arguments);
      while (args.length < length) args.push(dart.dynamic);

      let value = resultMap;
      for (let i = 0; i < length; i++) {
        let arg = args[i];
        if (arg == null) {
          throw Error('type arguments should not be null: ' + typeConstructor);
        }
        let map = value;
        value = map.get(arg);
        if (value === void 0) {
          if (i + 1 == length) {
            value = typeConstructor.apply(null, args);
            // Save the type constructor and arguments for reflection.
            if (value) {
              value[dart.typeArguments] = args;
              value[dart.originalDeclaration] = makeGenericType;
            }
          } else {
            value = new Map();
          }
          map.set(arg, value);
        }
      }
      return value;
    }
    return makeGenericType;
  }
  dart.generic = generic;

  // TODO(jmesserly): right now this is a sentinel. It should be a type object
  // of some sort, assuming we keep around `dynamic` at runtime.
  dart.dynamic = { toString() { return 'dynamic'; } };
  dart.void = { toString() { return 'void'; } };
  dart.bottom = { toString() { return 'bottom'; } };

  // TODO(vsm): How should we encode the runtime type?
  dart.runtimeType = Symbol('runtimeType');

  dart.JsSymbol = Symbol;

  // TODO(jmesserly): hack to bootstrap the SDK
  _js_helper = _js_helper || {};
  _js_helper.checkNum = notNull;

})(dart || (dart = {}));
