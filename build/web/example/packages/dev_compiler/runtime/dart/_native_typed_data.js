var _native_typed_data;
(function(exports) {
  'use strict';
  let _externalStorage = Symbol('_externalStorage');
  class NativeByteBuffer extends core.Object {
    NativeByteBuffer() {
      this.lengthInBytes = null;
    }
    get runtimeType() {
      return typed_data.ByteBuffer;
    }
    asUint8List(offsetInBytes, length) {
      if (offsetInBytes === void 0)
        offsetInBytes = 0;
      if (length === void 0)
        length = null;
      return new NativeUint8List.view(this, offsetInBytes, length);
    }
    asInt8List(offsetInBytes, length) {
      if (offsetInBytes === void 0)
        offsetInBytes = 0;
      if (length === void 0)
        length = null;
      return new NativeInt8List.view(this, offsetInBytes, length);
    }
    asUint8ClampedList(offsetInBytes, length) {
      if (offsetInBytes === void 0)
        offsetInBytes = 0;
      if (length === void 0)
        length = null;
      return new NativeUint8ClampedList.view(this, offsetInBytes, length);
    }
    asUint16List(offsetInBytes, length) {
      if (offsetInBytes === void 0)
        offsetInBytes = 0;
      if (length === void 0)
        length = null;
      return new NativeUint16List.view(this, offsetInBytes, length);
    }
    asInt16List(offsetInBytes, length) {
      if (offsetInBytes === void 0)
        offsetInBytes = 0;
      if (length === void 0)
        length = null;
      return new NativeInt16List.view(this, offsetInBytes, length);
    }
    asUint32List(offsetInBytes, length) {
      if (offsetInBytes === void 0)
        offsetInBytes = 0;
      if (length === void 0)
        length = null;
      return new NativeUint32List.view(this, offsetInBytes, length);
    }
    asInt32List(offsetInBytes, length) {
      if (offsetInBytes === void 0)
        offsetInBytes = 0;
      if (length === void 0)
        length = null;
      return new NativeInt32List.view(this, offsetInBytes, length);
    }
    asUint64List(offsetInBytes, length) {
      if (offsetInBytes === void 0)
        offsetInBytes = 0;
      if (length === void 0)
        length = null;
      throw new core.UnsupportedError("Uint64List not supported by dart2js.");
    }
    asInt64List(offsetInBytes, length) {
      if (offsetInBytes === void 0)
        offsetInBytes = 0;
      if (length === void 0)
        length = null;
      throw new core.UnsupportedError("Int64List not supported by dart2js.");
    }
    asInt32x4List(offsetInBytes, length) {
      if (offsetInBytes === void 0)
        offsetInBytes = 0;
      if (length === void 0)
        length = null;
      let storage = dart.as(this.asInt32List(offsetInBytes, length != null ? dart.notNull(length) * 4 : null), NativeInt32List);
      return new NativeInt32x4List[_externalStorage](storage);
    }
    asFloat32List(offsetInBytes, length) {
      if (offsetInBytes === void 0)
        offsetInBytes = 0;
      if (length === void 0)
        length = null;
      return new NativeFloat32List.view(this, offsetInBytes, length);
    }
    asFloat64List(offsetInBytes, length) {
      if (offsetInBytes === void 0)
        offsetInBytes = 0;
      if (length === void 0)
        length = null;
      return new NativeFloat64List.view(this, offsetInBytes, length);
    }
    asFloat32x4List(offsetInBytes, length) {
      if (offsetInBytes === void 0)
        offsetInBytes = 0;
      if (length === void 0)
        length = null;
      let storage = dart.as(this.asFloat32List(offsetInBytes, length != null ? dart.notNull(length) * 4 : null), NativeFloat32List);
      return new NativeFloat32x4List[_externalStorage](storage);
    }
    asFloat64x2List(offsetInBytes, length) {
      if (offsetInBytes === void 0)
        offsetInBytes = 0;
      if (length === void 0)
        length = null;
      let storage = dart.as(this.asFloat64List(offsetInBytes, length != null ? dart.notNull(length) * 2 : null), NativeFloat64List);
      return new NativeFloat64x2List[_externalStorage](storage);
    }
    asByteData(offsetInBytes, length) {
      if (offsetInBytes === void 0)
        offsetInBytes = 0;
      if (length === void 0)
        length = null;
      return new NativeByteData.view(this, offsetInBytes, length);
    }
  }
  NativeByteBuffer[dart.implements] = () => [typed_data.ByteBuffer];
  let _storage = Symbol('_storage');
  let _slowFromList = Symbol('_slowFromList');
  let _invalidIndex = Symbol('_invalidIndex');
  let _checkIndex = Symbol('_checkIndex');
  let _checkSublistArguments = Symbol('_checkSublistArguments');
  let _truncated = Symbol('_truncated');
  class NativeFloat32x4List extends dart.mixin(core.Object, collection.ListMixin$(typed_data.Float32x4), _internal.FixedLengthListMixin$(typed_data.Float32x4)) {
    NativeFloat32x4List(length) {
      this[_storage] = new NativeFloat32List(dart.notNull(length) * 4);
    }
    [_externalStorage](storage) {
      this[_storage] = storage;
    }
    [_slowFromList](list) {
      this[_storage] = new NativeFloat32List(dart.notNull(list[core.$length]) * 4);
      for (let i = 0; dart.notNull(i) < dart.notNull(list[core.$length]); i = dart.notNull(i) + 1) {
        let e = list[core.$get](i);
        this[_storage][core.$set](dart.notNull(i) * 4 + 0, e.x);
        this[_storage][core.$set](dart.notNull(i) * 4 + 1, e.y);
        this[_storage][core.$set](dart.notNull(i) * 4 + 2, e.z);
        this[_storage][core.$set](dart.notNull(i) * 4 + 3, e.w);
      }
    }
    get runtimeType() {
      return typed_data.Float32x4List;
    }
    fromList(list) {
      if (dart.is(list, NativeFloat32x4List)) {
        return new NativeFloat32x4List[_externalStorage](new NativeFloat32List.fromList(list[_storage]));
      } else {
        return new NativeFloat32x4List[_slowFromList](list);
      }
    }
    get buffer() {
      return this[_storage].buffer;
    }
    get lengthInBytes() {
      return this[_storage].lengthInBytes;
    }
    get offsetInBytes() {
      return this[_storage].offsetInBytes;
    }
    get elementSizeInBytes() {
      return typed_data.Float32x4List.BYTES_PER_ELEMENT;
    }
    [_invalidIndex](index, length) {
      if (dart.notNull(index) < 0 || dart.notNull(index) >= dart.notNull(length)) {
        if (length == this[core.$length]) {
          throw new core.RangeError.index(index, this);
        }
        throw new core.RangeError.range(index, 0, dart.notNull(length) - 1);
      } else {
        throw new core.ArgumentError(`Invalid list index ${index}`);
      }
    }
    [_checkIndex](index, length) {
      if (index >>> 0 != index || dart.notNull(index) >= dart.notNull(length)) {
        this[_invalidIndex](index, length);
      }
    }
    [_checkSublistArguments](start, end, length) {
      this[_checkIndex](start, dart.notNull(length) + 1);
      if (end == null)
        return length;
      this[_checkIndex](end, dart.notNull(length) + 1);
      if (dart.notNull(start) > dart.notNull(end))
        throw new core.RangeError.range(start, 0, end);
      return end;
    }
    get [core.$length]() {
      return (dart.notNull(this[_storage][core.$length]) / 4).truncate();
    }
    [core.$get](index) {
      this[_checkIndex](index, this[core.$length]);
      let _x = this[_storage][core.$get](dart.notNull(index) * 4 + 0);
      let _y = this[_storage][core.$get](dart.notNull(index) * 4 + 1);
      let _z = this[_storage][core.$get](dart.notNull(index) * 4 + 2);
      let _w = this[_storage][core.$get](dart.notNull(index) * 4 + 3);
      return new NativeFloat32x4[_truncated](_x, _y, _z, _w);
    }
    [core.$set](index, value) {
      this[_checkIndex](index, this[core.$length]);
      this[_storage][core.$set](dart.notNull(index) * 4 + 0, value.x);
      this[_storage][core.$set](dart.notNull(index) * 4 + 1, value.y);
      this[_storage][core.$set](dart.notNull(index) * 4 + 2, value.z);
      this[_storage][core.$set](dart.notNull(index) * 4 + 3, value.w);
    }
    [core.$sublist](start, end) {
      if (end === void 0)
        end = null;
      end = this[_checkSublistArguments](start, end, this[core.$length]);
      return new NativeFloat32x4List[_externalStorage](dart.as(this[_storage][core.$sublist](dart.notNull(start) * 4, dart.notNull(end) * 4), NativeFloat32List));
    }
  }
  NativeFloat32x4List[dart.implements] = () => [typed_data.Float32x4List];
  dart.defineNamedConstructor(NativeFloat32x4List, _externalStorage);
  dart.defineNamedConstructor(NativeFloat32x4List, _slowFromList);
  dart.defineNamedConstructor(NativeFloat32x4List, 'fromList');
  class NativeInt32x4List extends dart.mixin(core.Object, collection.ListMixin$(typed_data.Int32x4), _internal.FixedLengthListMixin$(typed_data.Int32x4)) {
    NativeInt32x4List(length) {
      this[_storage] = new NativeInt32List(dart.notNull(length) * 4);
    }
    [_externalStorage](storage) {
      this[_storage] = storage;
    }
    [_slowFromList](list) {
      this[_storage] = new NativeInt32List(dart.notNull(list[core.$length]) * 4);
      for (let i = 0; dart.notNull(i) < dart.notNull(list[core.$length]); i = dart.notNull(i) + 1) {
        let e = list[core.$get](i);
        this[_storage][core.$set](dart.notNull(i) * 4 + 0, e.x);
        this[_storage][core.$set](dart.notNull(i) * 4 + 1, e.y);
        this[_storage][core.$set](dart.notNull(i) * 4 + 2, e.z);
        this[_storage][core.$set](dart.notNull(i) * 4 + 3, e.w);
      }
    }
    get runtimeType() {
      return typed_data.Int32x4List;
    }
    fromList(list) {
      if (dart.is(list, NativeInt32x4List)) {
        return new NativeInt32x4List[_externalStorage](new NativeInt32List.fromList(list[_storage]));
      } else {
        return new NativeInt32x4List[_slowFromList](list);
      }
    }
    get buffer() {
      return this[_storage].buffer;
    }
    get lengthInBytes() {
      return this[_storage].lengthInBytes;
    }
    get offsetInBytes() {
      return this[_storage].offsetInBytes;
    }
    get elementSizeInBytes() {
      return typed_data.Int32x4List.BYTES_PER_ELEMENT;
    }
    [_invalidIndex](index, length) {
      if (dart.notNull(index) < 0 || dart.notNull(index) >= dart.notNull(length)) {
        if (length == this[core.$length]) {
          throw new core.RangeError.index(index, this);
        }
        throw new core.RangeError.range(index, 0, dart.notNull(length) - 1);
      } else {
        throw new core.ArgumentError(`Invalid list index ${index}`);
      }
    }
    [_checkIndex](index, length) {
      if (index >>> 0 != index || index >= length) {
        this[_invalidIndex](index, length);
      }
    }
    [_checkSublistArguments](start, end, length) {
      this[_checkIndex](start, dart.notNull(length) + 1);
      if (end == null)
        return length;
      this[_checkIndex](end, dart.notNull(length) + 1);
      if (dart.notNull(start) > dart.notNull(end))
        throw new core.RangeError.range(start, 0, end);
      return end;
    }
    get [core.$length]() {
      return (dart.notNull(this[_storage][core.$length]) / 4).truncate();
    }
    [core.$get](index) {
      this[_checkIndex](index, this[core.$length]);
      let _x = this[_storage][core.$get](dart.notNull(index) * 4 + 0);
      let _y = this[_storage][core.$get](dart.notNull(index) * 4 + 1);
      let _z = this[_storage][core.$get](dart.notNull(index) * 4 + 2);
      let _w = this[_storage][core.$get](dart.notNull(index) * 4 + 3);
      return new NativeInt32x4[_truncated](_x, _y, _z, _w);
    }
    [core.$set](index, value) {
      this[_checkIndex](index, this[core.$length]);
      this[_storage][core.$set](dart.notNull(index) * 4 + 0, value.x);
      this[_storage][core.$set](dart.notNull(index) * 4 + 1, value.y);
      this[_storage][core.$set](dart.notNull(index) * 4 + 2, value.z);
      this[_storage][core.$set](dart.notNull(index) * 4 + 3, value.w);
    }
    [core.$sublist](start, end) {
      if (end === void 0)
        end = null;
      end = this[_checkSublistArguments](start, end, this[core.$length]);
      return new NativeInt32x4List[_externalStorage](dart.as(this[_storage][core.$sublist](dart.notNull(start) * 4, dart.notNull(end) * 4), typed_data.Int32List));
    }
  }
  NativeInt32x4List[dart.implements] = () => [typed_data.Int32x4List];
  dart.defineNamedConstructor(NativeInt32x4List, _externalStorage);
  dart.defineNamedConstructor(NativeInt32x4List, _slowFromList);
  dart.defineNamedConstructor(NativeInt32x4List, 'fromList');
  class NativeFloat64x2List extends dart.mixin(core.Object, collection.ListMixin$(typed_data.Float64x2), _internal.FixedLengthListMixin$(typed_data.Float64x2)) {
    NativeFloat64x2List(length) {
      this[_storage] = new NativeFloat64List(dart.notNull(length) * 2);
    }
    [_externalStorage](storage) {
      this[_storage] = storage;
    }
    [_slowFromList](list) {
      this[_storage] = new NativeFloat64List(dart.notNull(list[core.$length]) * 2);
      for (let i = 0; dart.notNull(i) < dart.notNull(list[core.$length]); i = dart.notNull(i) + 1) {
        let e = list[core.$get](i);
        this[_storage][core.$set](dart.notNull(i) * 2 + 0, e.x);
        this[_storage][core.$set](dart.notNull(i) * 2 + 1, e.y);
      }
    }
    fromList(list) {
      if (dart.is(list, NativeFloat64x2List)) {
        return new NativeFloat64x2List[_externalStorage](new NativeFloat64List.fromList(list[_storage]));
      } else {
        return new NativeFloat64x2List[_slowFromList](list);
      }
    }
    get runtimeType() {
      return typed_data.Float64x2List;
    }
    get buffer() {
      return this[_storage].buffer;
    }
    get lengthInBytes() {
      return this[_storage].lengthInBytes;
    }
    get offsetInBytes() {
      return this[_storage].offsetInBytes;
    }
    get elementSizeInBytes() {
      return typed_data.Float64x2List.BYTES_PER_ELEMENT;
    }
    [_invalidIndex](index, length) {
      if (dart.notNull(index) < 0 || dart.notNull(index) >= dart.notNull(length)) {
        if (length == this[core.$length]) {
          throw new core.RangeError.index(index, this);
        }
        throw new core.RangeError.range(index, 0, dart.notNull(length) - 1);
      } else {
        throw new core.ArgumentError(`Invalid list index ${index}`);
      }
    }
    [_checkIndex](index, length) {
      if (index >>> 0 != index || dart.notNull(index) >= dart.notNull(length)) {
        this[_invalidIndex](index, length);
      }
    }
    [_checkSublistArguments](start, end, length) {
      this[_checkIndex](start, dart.notNull(length) + 1);
      if (end == null)
        return length;
      this[_checkIndex](end, dart.notNull(length) + 1);
      if (dart.notNull(start) > dart.notNull(end))
        throw new core.RangeError.range(start, 0, end);
      return end;
    }
    get [core.$length]() {
      return (dart.notNull(this[_storage][core.$length]) / 2).truncate();
    }
    [core.$get](index) {
      this[_checkIndex](index, this[core.$length]);
      let _x = this[_storage][core.$get](dart.notNull(index) * 2 + 0);
      let _y = this[_storage][core.$get](dart.notNull(index) * 2 + 1);
      return new typed_data.Float64x2(_x, _y);
    }
    [core.$set](index, value) {
      this[_checkIndex](index, this[core.$length]);
      this[_storage][core.$set](dart.notNull(index) * 2 + 0, value.x);
      this[_storage][core.$set](dart.notNull(index) * 2 + 1, value.y);
    }
    [core.$sublist](start, end) {
      if (end === void 0)
        end = null;
      end = this[_checkSublistArguments](start, end, this[core.$length]);
      return new NativeFloat64x2List[_externalStorage](dart.as(this[_storage][core.$sublist](dart.notNull(start) * 2, dart.notNull(end) * 2), NativeFloat64List));
    }
  }
  NativeFloat64x2List[dart.implements] = () => [typed_data.Float64x2List];
  dart.defineNamedConstructor(NativeFloat64x2List, _externalStorage);
  dart.defineNamedConstructor(NativeFloat64x2List, _slowFromList);
  dart.defineNamedConstructor(NativeFloat64x2List, 'fromList');
  class NativeTypedData extends core.Object {
    NativeTypedData() {
      this.buffer = null;
      this.lengthInBytes = null;
      this.offsetInBytes = null;
      this.elementSizeInBytes = null;
    }
    [_invalidIndex](index, length) {
      if (dart.notNull(index) < 0 || dart.notNull(index) >= dart.notNull(length)) {
        if (dart.is(this, core.List)) {
          let list = this;
          if (dart.equals(length, list.length)) {
            throw new core.RangeError.index(index, this);
          }
        }
        throw new core.RangeError.range(index, 0, dart.notNull(length) - 1);
      } else {
        throw new core.ArgumentError(`Invalid list index ${index}`);
      }
    }
    [_checkIndex](index, length) {
      if (index >>> 0 !== index || index >= dart.notNull(length)) {
        this[_invalidIndex](index, length);
      }
    }
    [_checkSublistArguments](start, end, length) {
      this[_checkIndex](start, dart.notNull(length) + 1);
      if (end == null)
        return length;
      this[_checkIndex](end, dart.notNull(length) + 1);
      if (dart.notNull(start) > dart.notNull(end))
        throw new core.RangeError.range(start, 0, end);
      return end;
    }
  }
  NativeTypedData[dart.implements] = () => [typed_data.TypedData];
  // Function _checkLength: (dynamic) → int
  function _checkLength(length) {
    if (!(typeof length == 'number'))
      throw new core.ArgumentError(`Invalid length ${length}`);
    return dart.as(length, core.int);
  }
  // Function _checkViewArguments: (dynamic, dynamic, dynamic) → void
  function _checkViewArguments(buffer, offsetInBytes, length) {
    if (!dart.is(buffer, NativeByteBuffer)) {
      throw new core.ArgumentError('Invalid view buffer');
    }
    if (!(typeof offsetInBytes == 'number')) {
      throw new core.ArgumentError(`Invalid view offsetInBytes ${offsetInBytes}`);
    }
    if (dart.notNull(length != null) && !(typeof length == 'number')) {
      throw new core.ArgumentError(`Invalid view length ${length}`);
    }
  }
  // Function _ensureNativeList: (List<dynamic>) → List
  function _ensureNativeList(list) {
    if (dart.is(list, _interceptors.JSIndexable))
      return list;
    let result = new core.List(list[core.$length]);
    for (let i = 0; dart.notNull(i) < dart.notNull(list[core.$length]); i = dart.notNull(i) + 1) {
      result[core.$set](i, list[core.$get](i));
    }
    return result;
  }
  let _create1 = Symbol('_create1');
  let _create2 = Symbol('_create2');
  let _create3 = Symbol('_create3');
  let _getFloat32 = Symbol('_getFloat32');
  let _getFloat64 = Symbol('_getFloat64');
  let _getInt16 = Symbol('_getInt16');
  let _getInt32 = Symbol('_getInt32');
  let _getUint16 = Symbol('_getUint16');
  let _getUint32 = Symbol('_getUint32');
  let _setFloat32 = Symbol('_setFloat32');
  let _setFloat64 = Symbol('_setFloat64');
  let _setInt16 = Symbol('_setInt16');
  let _setInt32 = Symbol('_setInt32');
  let _setUint16 = Symbol('_setUint16');
  let _setUint32 = Symbol('_setUint32');
  class NativeByteData extends NativeTypedData {
    NativeByteData(length) {
      return NativeByteData[_create1](_checkLength(length));
    }
    view(buffer, offsetInBytes, length) {
      _checkViewArguments(buffer, offsetInBytes, length);
      return length == null ? NativeByteData[_create2](buffer, offsetInBytes) : NativeByteData[_create3](buffer, offsetInBytes, length);
    }
    get runtimeType() {
      return typed_data.ByteData;
    }
    get elementSizeInBytes() {
      return 1;
    }
    getFloat32(byteOffset, endian) {
      if (endian === void 0)
        endian = typed_data.Endianness.BIG_ENDIAN;
      return this[_getFloat32](byteOffset, dart.equals(typed_data.Endianness.LITTLE_ENDIAN, endian));
    }
    getFloat64(byteOffset, endian) {
      if (endian === void 0)
        endian = typed_data.Endianness.BIG_ENDIAN;
      return this[_getFloat64](byteOffset, dart.equals(typed_data.Endianness.LITTLE_ENDIAN, endian));
    }
    getInt16(byteOffset, endian) {
      if (endian === void 0)
        endian = typed_data.Endianness.BIG_ENDIAN;
      return this[_getInt16](byteOffset, dart.equals(typed_data.Endianness.LITTLE_ENDIAN, endian));
    }
    getInt32(byteOffset, endian) {
      if (endian === void 0)
        endian = typed_data.Endianness.BIG_ENDIAN;
      return this[_getInt32](byteOffset, dart.equals(typed_data.Endianness.LITTLE_ENDIAN, endian));
    }
    getInt64(byteOffset, endian) {
      if (endian === void 0)
        endian = typed_data.Endianness.BIG_ENDIAN;
      throw new core.UnsupportedError('Int64 accessor not supported by dart2js.');
    }
    getUint16(byteOffset, endian) {
      if (endian === void 0)
        endian = typed_data.Endianness.BIG_ENDIAN;
      return this[_getUint16](byteOffset, dart.equals(typed_data.Endianness.LITTLE_ENDIAN, endian));
    }
    getUint32(byteOffset, endian) {
      if (endian === void 0)
        endian = typed_data.Endianness.BIG_ENDIAN;
      return this[_getUint32](byteOffset, dart.equals(typed_data.Endianness.LITTLE_ENDIAN, endian));
    }
    getUint64(byteOffset, endian) {
      if (endian === void 0)
        endian = typed_data.Endianness.BIG_ENDIAN;
      throw new core.UnsupportedError('Uint64 accessor not supported by dart2js.');
    }
    setFloat32(byteOffset, value, endian) {
      if (endian === void 0)
        endian = typed_data.Endianness.BIG_ENDIAN;
      return this[_setFloat32](byteOffset, value, dart.equals(typed_data.Endianness.LITTLE_ENDIAN, endian));
    }
    setFloat64(byteOffset, value, endian) {
      if (endian === void 0)
        endian = typed_data.Endianness.BIG_ENDIAN;
      return this[_setFloat64](byteOffset, value, dart.equals(typed_data.Endianness.LITTLE_ENDIAN, endian));
    }
    setInt16(byteOffset, value, endian) {
      if (endian === void 0)
        endian = typed_data.Endianness.BIG_ENDIAN;
      return this[_setInt16](byteOffset, value, dart.equals(typed_data.Endianness.LITTLE_ENDIAN, endian));
    }
    setInt32(byteOffset, value, endian) {
      if (endian === void 0)
        endian = typed_data.Endianness.BIG_ENDIAN;
      return this[_setInt32](byteOffset, value, dart.equals(typed_data.Endianness.LITTLE_ENDIAN, endian));
    }
    setInt64(byteOffset, value, endian) {
      if (endian === void 0)
        endian = typed_data.Endianness.BIG_ENDIAN;
      throw new core.UnsupportedError('Int64 accessor not supported by dart2js.');
    }
    setUint16(byteOffset, value, endian) {
      if (endian === void 0)
        endian = typed_data.Endianness.BIG_ENDIAN;
      return this[_setUint16](byteOffset, value, dart.equals(typed_data.Endianness.LITTLE_ENDIAN, endian));
    }
    setUint32(byteOffset, value, endian) {
      if (endian === void 0)
        endian = typed_data.Endianness.BIG_ENDIAN;
      return this[_setUint32](byteOffset, value, dart.equals(typed_data.Endianness.LITTLE_ENDIAN, endian));
    }
    setUint64(byteOffset, value, endian) {
      if (endian === void 0)
        endian = typed_data.Endianness.BIG_ENDIAN;
      throw new core.UnsupportedError('Uint64 accessor not supported by dart2js.');
    }
    static [_create1](arg) {
      return dart.as(new DataView(new ArrayBuffer(arg)), NativeByteData);
    }
    static [_create2](arg1, arg2) {
      return dart.as(new DataView(arg1, arg2), NativeByteData);
    }
    static [_create3](arg1, arg2, arg3) {
      return dart.as(new DataView(arg1, arg2, arg3), NativeByteData);
    }
  }
  NativeByteData[dart.implements] = () => [typed_data.ByteData];
  dart.defineNamedConstructor(NativeByteData, 'view');
  let _setRangeFast = Symbol('_setRangeFast');
  class NativeTypedArray extends NativeTypedData {
    get length() {
      return dart.as(this.length, core.int);
    }
    [_setRangeFast](start, end, source, skipCount) {
      let targetLength = this.length;
      this[_checkIndex](start, dart.notNull(targetLength) + 1);
      this[_checkIndex](end, dart.notNull(targetLength) + 1);
      if (dart.notNull(start) > dart.notNull(end))
        throw new core.RangeError.range(start, 0, end);
      let count = dart.notNull(end) - dart.notNull(start);
      if (dart.notNull(skipCount) < 0)
        throw new core.ArgumentError(skipCount);
      let sourceLength = source.length;
      if (dart.notNull(sourceLength) - dart.notNull(skipCount) < dart.notNull(count)) {
        throw new core.StateError('Not enough elements');
      }
      if (skipCount != 0 || sourceLength != count) {
        source = dart.as(source.subarray(skipCount, dart.notNull(skipCount) + dart.notNull(count)), NativeTypedArray);
      }
      this.set(source, start);
    }
  }
  NativeTypedArray[dart.implements] = () => [_js_helper.JavaScriptIndexingBehavior];
  class NativeTypedArrayOfDouble extends dart.mixin(NativeTypedArray, collection.ListMixin$(core.double), _internal.FixedLengthListMixin$(core.double)) {
    [core.$get](index) {
      this[_checkIndex](index, this[core.$length]);
      return this[index];
    }
    [core.$set](index, value) {
      this[_checkIndex](index, this[core.$length]);
      this[index] = value;
    }
    [core.$setRange](start, end, iterable, skipCount) {
      if (skipCount === void 0)
        skipCount = 0;
      if (dart.is(iterable, NativeTypedArrayOfDouble)) {
        this[_setRangeFast](start, end, iterable, skipCount);
        return;
      }
      super[core.$setRange](start, end, iterable, skipCount);
    }
  }
  class NativeTypedArrayOfInt extends dart.mixin(NativeTypedArray, collection.ListMixin$(core.int), _internal.FixedLengthListMixin$(core.int)) {
    [core.$set](index, value) {
      this[_checkIndex](index, this[core.$length]);
      this[index] = value;
    }
    [core.$setRange](start, end, iterable, skipCount) {
      if (skipCount === void 0)
        skipCount = 0;
      if (dart.is(iterable, NativeTypedArrayOfInt)) {
        this[_setRangeFast](start, end, iterable, skipCount);
        return;
      }
      super[core.$setRange](start, end, iterable, skipCount);
    }
  }
  NativeTypedArrayOfInt[dart.implements] = () => [core.List$(core.int)];
  class NativeFloat32List extends NativeTypedArrayOfDouble {
    NativeFloat32List(length) {
      return NativeFloat32List[_create1](_checkLength(length));
    }
    fromList(elements) {
      return NativeFloat32List[_create1](_ensureNativeList(elements));
    }
    view(buffer, offsetInBytes, length) {
      _checkViewArguments(buffer, offsetInBytes, length);
      return length == null ? NativeFloat32List[_create2](buffer, offsetInBytes) : NativeFloat32List[_create3](buffer, offsetInBytes, length);
    }
    get runtimeType() {
      return typed_data.Float32List;
    }
    [core.$sublist](start, end) {
      if (end === void 0)
        end = null;
      end = this[_checkSublistArguments](start, end, this[core.$length]);
      let source = this.subarray(start, end);
      return NativeFloat32List[_create1](source);
    }
    static [_create1](arg) {
      return dart.as(new Float32Array(arg), NativeFloat32List);
    }
    static [_create2](arg1, arg2) {
      return dart.as(new Float32Array(arg1, arg2), NativeFloat32List);
    }
    static [_create3](arg1, arg2, arg3) {
      return dart.as(new Float32Array(arg1, arg2, arg3), NativeFloat32List);
    }
  }
  NativeFloat32List[dart.implements] = () => [typed_data.Float32List];
  dart.defineNamedConstructor(NativeFloat32List, 'fromList');
  dart.defineNamedConstructor(NativeFloat32List, 'view');
  class NativeFloat64List extends NativeTypedArrayOfDouble {
    NativeFloat64List(length) {
      return NativeFloat64List[_create1](_checkLength(length));
    }
    fromList(elements) {
      return NativeFloat64List[_create1](_ensureNativeList(elements));
    }
    view(buffer, offsetInBytes, length) {
      _checkViewArguments(buffer, offsetInBytes, length);
      return length == null ? NativeFloat64List[_create2](buffer, offsetInBytes) : NativeFloat64List[_create3](buffer, offsetInBytes, length);
    }
    get runtimeType() {
      return typed_data.Float64List;
    }
    [core.$sublist](start, end) {
      if (end === void 0)
        end = null;
      end = this[_checkSublistArguments](start, end, this[core.$length]);
      let source = this.subarray(start, end);
      return NativeFloat64List[_create1](source);
    }
    static [_create1](arg) {
      return dart.as(new Float64Array(arg), NativeFloat64List);
    }
    static [_create2](arg1, arg2) {
      return dart.as(new Float64Array(arg1, arg2), NativeFloat64List);
    }
    static [_create3](arg1, arg2, arg3) {
      return dart.as(new Float64Array(arg1, arg2, arg3), NativeFloat64List);
    }
  }
  NativeFloat64List[dart.implements] = () => [typed_data.Float64List];
  dart.defineNamedConstructor(NativeFloat64List, 'fromList');
  dart.defineNamedConstructor(NativeFloat64List, 'view');
  class NativeInt16List extends NativeTypedArrayOfInt {
    NativeInt16List(length) {
      return NativeInt16List[_create1](_checkLength(length));
    }
    fromList(elements) {
      return NativeInt16List[_create1](_ensureNativeList(elements));
    }
    view(buffer, offsetInBytes, length) {
      _checkViewArguments(buffer, offsetInBytes, length);
      return length == null ? NativeInt16List[_create2](buffer, offsetInBytes) : NativeInt16List[_create3](buffer, offsetInBytes, length);
    }
    get runtimeType() {
      return typed_data.Int16List;
    }
    [core.$get](index) {
      this[_checkIndex](index, this[core.$length]);
      return this[index];
    }
    [core.$sublist](start, end) {
      if (end === void 0)
        end = null;
      end = this[_checkSublistArguments](start, end, this[core.$length]);
      let source = this.subarray(start, end);
      return NativeInt16List[_create1](source);
    }
    static [_create1](arg) {
      return dart.as(new Int16Array(arg), NativeInt16List);
    }
    static [_create2](arg1, arg2) {
      return dart.as(new Int16Array(arg1, arg2), NativeInt16List);
    }
    static [_create3](arg1, arg2, arg3) {
      return dart.as(new Int16Array(arg1, arg2, arg3), NativeInt16List);
    }
  }
  NativeInt16List[dart.implements] = () => [typed_data.Int16List];
  dart.defineNamedConstructor(NativeInt16List, 'fromList');
  dart.defineNamedConstructor(NativeInt16List, 'view');
  class NativeInt32List extends NativeTypedArrayOfInt {
    NativeInt32List(length) {
      return NativeInt32List[_create1](_checkLength(length));
    }
    fromList(elements) {
      return NativeInt32List[_create1](_ensureNativeList(elements));
    }
    view(buffer, offsetInBytes, length) {
      _checkViewArguments(buffer, offsetInBytes, length);
      return length == null ? NativeInt32List[_create2](buffer, offsetInBytes) : NativeInt32List[_create3](buffer, offsetInBytes, length);
    }
    get runtimeType() {
      return typed_data.Int32List;
    }
    [core.$get](index) {
      this[_checkIndex](index, this[core.$length]);
      return this[index];
    }
    [core.$sublist](start, end) {
      if (end === void 0)
        end = null;
      end = this[_checkSublistArguments](start, end, this[core.$length]);
      let source = this.subarray(start, end);
      return NativeInt32List[_create1](source);
    }
    static [_create1](arg) {
      return dart.as(new Int32Array(arg), NativeInt32List);
    }
    static [_create2](arg1, arg2) {
      return dart.as(new Int32Array(arg1, arg2), NativeInt32List);
    }
    static [_create3](arg1, arg2, arg3) {
      return dart.as(new Int32Array(arg1, arg2, arg3), NativeInt32List);
    }
  }
  NativeInt32List[dart.implements] = () => [typed_data.Int32List];
  dart.defineNamedConstructor(NativeInt32List, 'fromList');
  dart.defineNamedConstructor(NativeInt32List, 'view');
  class NativeInt8List extends NativeTypedArrayOfInt {
    NativeInt8List(length) {
      return NativeInt8List[_create1](_checkLength(length));
    }
    fromList(elements) {
      return NativeInt8List[_create1](_ensureNativeList(elements));
    }
    view(buffer, offsetInBytes, length) {
      _checkViewArguments(buffer, offsetInBytes, length);
      return dart.as(length == null ? NativeInt8List[_create2](buffer, offsetInBytes) : NativeInt8List[_create3](buffer, offsetInBytes, length), NativeInt8List);
    }
    get runtimeType() {
      return typed_data.Int8List;
    }
    [core.$get](index) {
      this[_checkIndex](index, this[core.$length]);
      return this[index];
    }
    [core.$sublist](start, end) {
      if (end === void 0)
        end = null;
      end = this[_checkSublistArguments](start, end, this[core.$length]);
      let source = this.subarray(start, end);
      return NativeInt8List[_create1](source);
    }
    static [_create1](arg) {
      return dart.as(new Int8Array(arg), NativeInt8List);
    }
    static [_create2](arg1, arg2) {
      return dart.as(new Int8Array(arg1, arg2), NativeInt8List);
    }
    static [_create3](arg1, arg2, arg3) {
      return dart.as(new Int8Array(arg1, arg2, arg3), typed_data.Int8List);
    }
  }
  NativeInt8List[dart.implements] = () => [typed_data.Int8List];
  dart.defineNamedConstructor(NativeInt8List, 'fromList');
  dart.defineNamedConstructor(NativeInt8List, 'view');
  class NativeUint16List extends NativeTypedArrayOfInt {
    NativeUint16List(length) {
      return NativeUint16List[_create1](_checkLength(length));
    }
    fromList(list) {
      return NativeUint16List[_create1](_ensureNativeList(list));
    }
    view(buffer, offsetInBytes, length) {
      _checkViewArguments(buffer, offsetInBytes, length);
      return length == null ? NativeUint16List[_create2](buffer, offsetInBytes) : NativeUint16List[_create3](buffer, offsetInBytes, length);
    }
    get runtimeType() {
      return typed_data.Uint16List;
    }
    [core.$get](index) {
      this[_checkIndex](index, this[core.$length]);
      return dart.as(this[index], core.int);
    }
    [core.$sublist](start, end) {
      if (end === void 0)
        end = null;
      end = this[_checkSublistArguments](start, end, this[core.$length]);
      let source = this.subarray(start, end);
      return NativeUint16List[_create1](source);
    }
    static [_create1](arg) {
      return dart.as(new Uint16Array(arg), NativeUint16List);
    }
    static [_create2](arg1, arg2) {
      return dart.as(new Uint16Array(arg1, arg2), NativeUint16List);
    }
    static [_create3](arg1, arg2, arg3) {
      return dart.as(new Uint16Array(arg1, arg2, arg3), NativeUint16List);
    }
  }
  NativeUint16List[dart.implements] = () => [typed_data.Uint16List];
  dart.defineNamedConstructor(NativeUint16List, 'fromList');
  dart.defineNamedConstructor(NativeUint16List, 'view');
  class NativeUint32List extends NativeTypedArrayOfInt {
    NativeUint32List(length) {
      return NativeUint32List[_create1](_checkLength(length));
    }
    fromList(elements) {
      return NativeUint32List[_create1](_ensureNativeList(elements));
    }
    view(buffer, offsetInBytes, length) {
      _checkViewArguments(buffer, offsetInBytes, length);
      return length == null ? NativeUint32List[_create2](buffer, offsetInBytes) : NativeUint32List[_create3](buffer, offsetInBytes, length);
    }
    get runtimeType() {
      return typed_data.Uint32List;
    }
    [core.$get](index) {
      this[_checkIndex](index, this[core.$length]);
      return dart.as(this[index], core.int);
    }
    [core.$sublist](start, end) {
      if (end === void 0)
        end = null;
      end = this[_checkSublistArguments](start, end, this[core.$length]);
      let source = this.subarray(start, end);
      return NativeUint32List[_create1](source);
    }
    static [_create1](arg) {
      return dart.as(new Uint32Array(arg), NativeUint32List);
    }
    static [_create2](arg1, arg2) {
      return dart.as(new Uint32Array(arg1, arg2), NativeUint32List);
    }
    static [_create3](arg1, arg2, arg3) {
      return dart.as(new Uint32Array(arg1, arg2, arg3), NativeUint32List);
    }
  }
  NativeUint32List[dart.implements] = () => [typed_data.Uint32List];
  dart.defineNamedConstructor(NativeUint32List, 'fromList');
  dart.defineNamedConstructor(NativeUint32List, 'view');
  class NativeUint8ClampedList extends NativeTypedArrayOfInt {
    NativeUint8ClampedList(length) {
      return NativeUint8ClampedList[_create1](_checkLength(length));
    }
    fromList(elements) {
      return NativeUint8ClampedList[_create1](_ensureNativeList(elements));
    }
    view(buffer, offsetInBytes, length) {
      _checkViewArguments(buffer, offsetInBytes, length);
      return length == null ? NativeUint8ClampedList[_create2](buffer, offsetInBytes) : NativeUint8ClampedList[_create3](buffer, offsetInBytes, length);
    }
    get runtimeType() {
      return typed_data.Uint8ClampedList;
    }
    get [core.$length]() {
      return dart.as(this.length, core.int);
    }
    [core.$get](index) {
      this[_checkIndex](index, this[core.$length]);
      return dart.as(this[index], core.int);
    }
    [core.$sublist](start, end) {
      if (end === void 0)
        end = null;
      end = this[_checkSublistArguments](start, end, this[core.$length]);
      let source = this.subarray(start, end);
      return NativeUint8ClampedList[_create1](source);
    }
    static [_create1](arg) {
      return dart.as(new Uint8ClampedArray(arg), NativeUint8ClampedList);
    }
    static [_create2](arg1, arg2) {
      return dart.as(new Uint8ClampedArray(arg1, arg2), NativeUint8ClampedList);
    }
    static [_create3](arg1, arg2, arg3) {
      return dart.as(new Uint8ClampedArray(arg1, arg2, arg3), NativeUint8ClampedList);
    }
  }
  NativeUint8ClampedList[dart.implements] = () => [typed_data.Uint8ClampedList];
  dart.defineNamedConstructor(NativeUint8ClampedList, 'fromList');
  dart.defineNamedConstructor(NativeUint8ClampedList, 'view');
  class NativeUint8List extends NativeTypedArrayOfInt {
    NativeUint8List(length) {
      return NativeUint8List[_create1](_checkLength(length));
    }
    fromList(elements) {
      return NativeUint8List[_create1](_ensureNativeList(elements));
    }
    view(buffer, offsetInBytes, length) {
      _checkViewArguments(buffer, offsetInBytes, length);
      return length == null ? NativeUint8List[_create2](buffer, offsetInBytes) : NativeUint8List[_create3](buffer, offsetInBytes, length);
    }
    get runtimeType() {
      return typed_data.Uint8List;
    }
    get [core.$length]() {
      return dart.as(this.length, core.int);
    }
    [core.$get](index) {
      this[_checkIndex](index, this[core.$length]);
      return dart.as(this[index], core.int);
    }
    [core.$sublist](start, end) {
      if (end === void 0)
        end = null;
      end = this[_checkSublistArguments](start, end, this[core.$length]);
      let source = this.subarray(start, end);
      return NativeUint8List[_create1](source);
    }
    static [_create1](arg) {
      return dart.as(new Uint8Array(arg), NativeUint8List);
    }
    static [_create2](arg1, arg2) {
      return dart.as(new Uint8Array(arg1, arg2), NativeUint8List);
    }
    static [_create3](arg1, arg2, arg3) {
      return dart.as(new Uint8Array(arg1, arg2, arg3), NativeUint8List);
    }
  }
  NativeUint8List[dart.implements] = () => [typed_data.Uint8List];
  dart.defineNamedConstructor(NativeUint8List, 'fromList');
  dart.defineNamedConstructor(NativeUint8List, 'view');
  let _truncate = Symbol('_truncate');
  let _list = Symbol('_list');
  let _uint32view = Symbol('_uint32view');
  let _doubles = Symbol('_doubles');
  class NativeFloat32x4 extends core.Object {
    static [_truncate](x) {
      NativeFloat32x4[_list][core.$set](0, dart.as(x, core.num));
      return NativeFloat32x4[_list][core.$get](0);
    }
    NativeFloat32x4(x, y, z, w) {
      this.x = dart.as(NativeFloat32x4[_truncate](x), core.double);
      this.y = dart.as(NativeFloat32x4[_truncate](y), core.double);
      this.z = dart.as(NativeFloat32x4[_truncate](z), core.double);
      this.w = dart.as(NativeFloat32x4[_truncate](w), core.double);
      if (!dart.is(x, core.num))
        throw new core.ArgumentError(x);
      if (!dart.is(y, core.num))
        throw new core.ArgumentError(y);
      if (!dart.is(z, core.num))
        throw new core.ArgumentError(z);
      if (!dart.is(w, core.num))
        throw new core.ArgumentError(w);
    }
    splat(v) {
      this.NativeFloat32x4(v, v, v, v);
    }
    zero() {
      this[_truncated](0.0, 0.0, 0.0, 0.0);
    }
    fromInt32x4Bits(i) {
      NativeFloat32x4[_uint32view][core.$set](0, i.x);
      NativeFloat32x4[_uint32view][core.$set](1, i.y);
      NativeFloat32x4[_uint32view][core.$set](2, i.z);
      NativeFloat32x4[_uint32view][core.$set](3, i.w);
      return new NativeFloat32x4[_truncated](NativeFloat32x4[_list][core.$get](0), NativeFloat32x4[_list][core.$get](1), NativeFloat32x4[_list][core.$get](2), NativeFloat32x4[_list][core.$get](3));
    }
    fromFloat64x2(v) {
      this[_truncated](dart.as(NativeFloat32x4[_truncate](v.x), core.double), dart.as(NativeFloat32x4[_truncate](v.y), core.double), 0.0, 0.0);
    }
    [_doubles](x, y, z, w) {
      this.x = dart.as(NativeFloat32x4[_truncate](x), core.double);
      this.y = dart.as(NativeFloat32x4[_truncate](y), core.double);
      this.z = dart.as(NativeFloat32x4[_truncate](z), core.double);
      this.w = dart.as(NativeFloat32x4[_truncate](w), core.double);
    }
    [_truncated](x, y, z, w) {
      this.x = x;
      this.y = y;
      this.z = z;
      this.w = w;
    }
    toString() {
      return `[${this.x}, ${this.y}, ${this.z}, ${this.w}]`;
    }
    ['+'](other) {
      let _x = dart.notNull(this.x) + dart.notNull(other.x);
      let _y = dart.notNull(this.y) + dart.notNull(other.y);
      let _z = dart.notNull(this.z) + dart.notNull(other.z);
      let _w = dart.notNull(this.w) + dart.notNull(other.w);
      return new NativeFloat32x4[_doubles](_x, _y, _z, _w);
    }
    ['unary-']() {
      return new NativeFloat32x4[_truncated](-dart.notNull(this.x), -dart.notNull(this.y), -dart.notNull(this.z), -dart.notNull(this.w));
    }
    ['-'](other) {
      let _x = dart.notNull(this.x) - dart.notNull(other.x);
      let _y = dart.notNull(this.y) - dart.notNull(other.y);
      let _z = dart.notNull(this.z) - dart.notNull(other.z);
      let _w = dart.notNull(this.w) - dart.notNull(other.w);
      return new NativeFloat32x4[_doubles](_x, _y, _z, _w);
    }
    ['*'](other) {
      let _x = dart.notNull(this.x) * dart.notNull(other.x);
      let _y = dart.notNull(this.y) * dart.notNull(other.y);
      let _z = dart.notNull(this.z) * dart.notNull(other.z);
      let _w = dart.notNull(this.w) * dart.notNull(other.w);
      return new NativeFloat32x4[_doubles](_x, _y, _z, _w);
    }
    ['/'](other) {
      let _x = dart.notNull(this.x) / dart.notNull(other.x);
      let _y = dart.notNull(this.y) / dart.notNull(other.y);
      let _z = dart.notNull(this.z) / dart.notNull(other.z);
      let _w = dart.notNull(this.w) / dart.notNull(other.w);
      return new NativeFloat32x4[_doubles](_x, _y, _z, _w);
    }
    lessThan(other) {
      let _cx = dart.notNull(this.x) < dart.notNull(other.x);
      let _cy = dart.notNull(this.y) < dart.notNull(other.y);
      let _cz = dart.notNull(this.z) < dart.notNull(other.z);
      let _cw = dart.notNull(this.w) < dart.notNull(other.w);
      return new NativeInt32x4[_truncated](_cx ? -1 : 0, _cy ? -1 : 0, _cz ? -1 : 0, _cw ? -1 : 0);
    }
    lessThanOrEqual(other) {
      let _cx = dart.notNull(this.x) <= dart.notNull(other.x);
      let _cy = dart.notNull(this.y) <= dart.notNull(other.y);
      let _cz = dart.notNull(this.z) <= dart.notNull(other.z);
      let _cw = dart.notNull(this.w) <= dart.notNull(other.w);
      return new NativeInt32x4[_truncated](_cx ? -1 : 0, _cy ? -1 : 0, _cz ? -1 : 0, _cw ? -1 : 0);
    }
    greaterThan(other) {
      let _cx = dart.notNull(this.x) > dart.notNull(other.x);
      let _cy = dart.notNull(this.y) > dart.notNull(other.y);
      let _cz = dart.notNull(this.z) > dart.notNull(other.z);
      let _cw = dart.notNull(this.w) > dart.notNull(other.w);
      return new NativeInt32x4[_truncated](_cx ? -1 : 0, _cy ? -1 : 0, _cz ? -1 : 0, _cw ? -1 : 0);
    }
    greaterThanOrEqual(other) {
      let _cx = dart.notNull(this.x) >= dart.notNull(other.x);
      let _cy = dart.notNull(this.y) >= dart.notNull(other.y);
      let _cz = dart.notNull(this.z) >= dart.notNull(other.z);
      let _cw = dart.notNull(this.w) >= dart.notNull(other.w);
      return new NativeInt32x4[_truncated](_cx ? -1 : 0, _cy ? -1 : 0, _cz ? -1 : 0, _cw ? -1 : 0);
    }
    equal(other) {
      let _cx = this.x == other.x;
      let _cy = this.y == other.y;
      let _cz = this.z == other.z;
      let _cw = this.w == other.w;
      return new NativeInt32x4[_truncated](_cx ? -1 : 0, _cy ? -1 : 0, _cz ? -1 : 0, _cw ? -1 : 0);
    }
    notEqual(other) {
      let _cx = this.x != other.x;
      let _cy = this.y != other.y;
      let _cz = this.z != other.z;
      let _cw = this.w != other.w;
      return new NativeInt32x4[_truncated](_cx ? -1 : 0, _cy ? -1 : 0, _cz ? -1 : 0, _cw ? -1 : 0);
    }
    scale(s) {
      let _x = dart.notNull(s) * dart.notNull(this.x);
      let _y = dart.notNull(s) * dart.notNull(this.y);
      let _z = dart.notNull(s) * dart.notNull(this.z);
      let _w = dart.notNull(s) * dart.notNull(this.w);
      return new NativeFloat32x4[_doubles](_x, _y, _z, _w);
    }
    abs() {
      let _x = this.x.abs();
      let _y = this.y.abs();
      let _z = this.z.abs();
      let _w = this.w.abs();
      return new NativeFloat32x4[_truncated](_x, _y, _z, _w);
    }
    clamp(lowerLimit, upperLimit) {
      let _lx = lowerLimit.x;
      let _ly = lowerLimit.y;
      let _lz = lowerLimit.z;
      let _lw = lowerLimit.w;
      let _ux = upperLimit.x;
      let _uy = upperLimit.y;
      let _uz = upperLimit.z;
      let _uw = upperLimit.w;
      let _x = this.x;
      let _y = this.y;
      let _z = this.z;
      let _w = this.w;
      _x = dart.notNull(_x) > dart.notNull(_ux) ? _ux : _x;
      _y = dart.notNull(_y) > dart.notNull(_uy) ? _uy : _y;
      _z = dart.notNull(_z) > dart.notNull(_uz) ? _uz : _z;
      _w = dart.notNull(_w) > dart.notNull(_uw) ? _uw : _w;
      _x = dart.notNull(_x) < dart.notNull(_lx) ? _lx : _x;
      _y = dart.notNull(_y) < dart.notNull(_ly) ? _ly : _y;
      _z = dart.notNull(_z) < dart.notNull(_lz) ? _lz : _z;
      _w = dart.notNull(_w) < dart.notNull(_lw) ? _lw : _w;
      return new NativeFloat32x4[_truncated](_x, _y, _z, _w);
    }
    get signMask() {
      let view = NativeFloat32x4[_uint32view];
      let mx = null, my = null, mz = null, mw = null;
      NativeFloat32x4[_list][core.$set](0, this.x);
      NativeFloat32x4[_list][core.$set](1, this.y);
      NativeFloat32x4[_list][core.$set](2, this.z);
      NativeFloat32x4[_list][core.$set](3, this.w);
      mx = (dart.notNull(view[core.$get](0)) & 2147483648) >> 31;
      my = (dart.notNull(view[core.$get](1)) & 2147483648) >> 30;
      mz = (dart.notNull(view[core.$get](2)) & 2147483648) >> 29;
      mw = (dart.notNull(view[core.$get](3)) & 2147483648) >> 28;
      return dart.as(dart.dsend(dart.dsend(dart.dsend(mx, '|', my), '|', mz), '|', mw), core.int);
    }
    shuffle(m) {
      if (dart.notNull(m) < 0 || dart.notNull(m) > 255) {
        throw new core.RangeError(`mask ${m} must be in the range [0..256)`);
      }
      NativeFloat32x4[_list][core.$set](0, this.x);
      NativeFloat32x4[_list][core.$set](1, this.y);
      NativeFloat32x4[_list][core.$set](2, this.z);
      NativeFloat32x4[_list][core.$set](3, this.w);
      let _x = NativeFloat32x4[_list][core.$get](dart.notNull(m) & 3);
      let _y = NativeFloat32x4[_list][core.$get](dart.notNull(m) >> 2 & 3);
      let _z = NativeFloat32x4[_list][core.$get](dart.notNull(m) >> 4 & 3);
      let _w = NativeFloat32x4[_list][core.$get](dart.notNull(m) >> 6 & 3);
      return new NativeFloat32x4[_truncated](_x, _y, _z, _w);
    }
    shuffleMix(other, m) {
      if (dart.notNull(m) < 0 || dart.notNull(m) > 255) {
        throw new core.RangeError(`mask ${m} must be in the range [0..256)`);
      }
      NativeFloat32x4[_list][core.$set](0, this.x);
      NativeFloat32x4[_list][core.$set](1, this.y);
      NativeFloat32x4[_list][core.$set](2, this.z);
      NativeFloat32x4[_list][core.$set](3, this.w);
      let _x = NativeFloat32x4[_list][core.$get](dart.notNull(m) & 3);
      let _y = NativeFloat32x4[_list][core.$get](dart.notNull(m) >> 2 & 3);
      NativeFloat32x4[_list][core.$set](0, other.x);
      NativeFloat32x4[_list][core.$set](1, other.y);
      NativeFloat32x4[_list][core.$set](2, other.z);
      NativeFloat32x4[_list][core.$set](3, other.w);
      let _z = NativeFloat32x4[_list][core.$get](dart.notNull(m) >> 4 & 3);
      let _w = NativeFloat32x4[_list][core.$get](dart.notNull(m) >> 6 & 3);
      return new NativeFloat32x4[_truncated](_x, _y, _z, _w);
    }
    withX(newX) {
      return new NativeFloat32x4[_truncated](dart.as(NativeFloat32x4[_truncate](newX), core.double), this.y, this.z, this.w);
    }
    withY(newY) {
      return new NativeFloat32x4[_truncated](this.x, dart.as(NativeFloat32x4[_truncate](newY), core.double), this.z, this.w);
    }
    withZ(newZ) {
      return new NativeFloat32x4[_truncated](this.x, this.y, dart.as(NativeFloat32x4[_truncate](newZ), core.double), this.w);
    }
    withW(newW) {
      return new NativeFloat32x4[_truncated](this.x, this.y, this.z, dart.as(NativeFloat32x4[_truncate](newW), core.double));
    }
    min(other) {
      let _x = dart.notNull(this.x) < dart.notNull(other.x) ? this.x : other.x;
      let _y = dart.notNull(this.y) < dart.notNull(other.y) ? this.y : other.y;
      let _z = dart.notNull(this.z) < dart.notNull(other.z) ? this.z : other.z;
      let _w = dart.notNull(this.w) < dart.notNull(other.w) ? this.w : other.w;
      return new NativeFloat32x4[_truncated](_x, _y, _z, _w);
    }
    max(other) {
      let _x = dart.notNull(this.x) > dart.notNull(other.x) ? this.x : other.x;
      let _y = dart.notNull(this.y) > dart.notNull(other.y) ? this.y : other.y;
      let _z = dart.notNull(this.z) > dart.notNull(other.z) ? this.z : other.z;
      let _w = dart.notNull(this.w) > dart.notNull(other.w) ? this.w : other.w;
      return new NativeFloat32x4[_truncated](_x, _y, _z, _w);
    }
    sqrt() {
      let _x = math.sqrt(this.x);
      let _y = math.sqrt(this.y);
      let _z = math.sqrt(this.z);
      let _w = math.sqrt(this.w);
      return new NativeFloat32x4[_doubles](_x, _y, _z, _w);
    }
    reciprocal() {
      let _x = 1.0 / dart.notNull(this.x);
      let _y = 1.0 / dart.notNull(this.y);
      let _z = 1.0 / dart.notNull(this.z);
      let _w = 1.0 / dart.notNull(this.w);
      return new NativeFloat32x4[_doubles](_x, _y, _z, _w);
    }
    reciprocalSqrt() {
      let _x = math.sqrt(1.0 / dart.notNull(this.x));
      let _y = math.sqrt(1.0 / dart.notNull(this.y));
      let _z = math.sqrt(1.0 / dart.notNull(this.z));
      let _w = math.sqrt(1.0 / dart.notNull(this.w));
      return new NativeFloat32x4[_doubles](_x, _y, _z, _w);
    }
  }
  NativeFloat32x4[dart.implements] = () => [typed_data.Float32x4];
  dart.defineNamedConstructor(NativeFloat32x4, 'splat');
  dart.defineNamedConstructor(NativeFloat32x4, 'zero');
  dart.defineNamedConstructor(NativeFloat32x4, 'fromInt32x4Bits');
  dart.defineNamedConstructor(NativeFloat32x4, 'fromFloat64x2');
  dart.defineNamedConstructor(NativeFloat32x4, _doubles);
  dart.defineNamedConstructor(NativeFloat32x4, _truncated);
  dart.defineLazyProperties(NativeFloat32x4, {
    get _list() {
      return new NativeFloat32List(4);
    },
    get _uint32view() {
      return NativeFloat32x4[_list].buffer.asUint32List();
    }
  });
  class NativeInt32x4 extends core.Object {
    static [_truncate](x) {
      NativeInt32x4[_list][core.$set](0, dart.as(x, core.int));
      return NativeInt32x4[_list][core.$get](0);
    }
    NativeInt32x4(x, y, z, w) {
      this.x = dart.as(NativeInt32x4[_truncate](x), core.int);
      this.y = dart.as(NativeInt32x4[_truncate](y), core.int);
      this.z = dart.as(NativeInt32x4[_truncate](z), core.int);
      this.w = dart.as(NativeInt32x4[_truncate](w), core.int);
      if (x != this.x && !(typeof x == 'number'))
        throw new core.ArgumentError(x);
      if (y != this.y && !(typeof y == 'number'))
        throw new core.ArgumentError(y);
      if (z != this.z && !(typeof z == 'number'))
        throw new core.ArgumentError(z);
      if (w != this.w && !(typeof w == 'number'))
        throw new core.ArgumentError(w);
    }
    bool(x, y, z, w) {
      this.x = x ? -1 : 0;
      this.y = y ? -1 : 0;
      this.z = z ? -1 : 0;
      this.w = w ? -1 : 0;
    }
    fromFloat32x4Bits(f) {
      let floatList = NativeFloat32x4[_list];
      floatList[core.$set](0, f.x);
      floatList[core.$set](1, f.y);
      floatList[core.$set](2, f.z);
      floatList[core.$set](3, f.w);
      let view = dart.as(floatList.buffer.asInt32List(), NativeInt32List);
      return new NativeInt32x4[_truncated](view[core.$get](0), view[core.$get](1), view[core.$get](2), view[core.$get](3));
    }
    [_truncated](x, y, z, w) {
      this.x = x;
      this.y = y;
      this.z = z;
      this.w = w;
    }
    toString() {
      return `[${this.x}, ${this.y}, ${this.z}, ${this.w}]`;
    }
    ['|'](other) {
      return new NativeInt32x4[_truncated](this.x | other.x, this.y | other.y, this.z | other.z, this.w | other.w);
    }
    ['&'](other) {
      return new NativeInt32x4[_truncated](this.x & other.x, this.y & other.y, this.z & other.z, this.w & other.w);
    }
    ['^'](other) {
      return new NativeInt32x4[_truncated](this.x ^ other.x, this.y ^ other.y, this.z ^ other.z, this.w ^ other.w);
    }
    ['+'](other) {
      return new NativeInt32x4[_truncated](this.x + other.x | 0, this.y + other.y | 0, this.z + other.z | 0, this.w + other.w | 0);
    }
    ['-'](other) {
      return new NativeInt32x4[_truncated](this.x - other.x | 0, this.y - other.y | 0, this.z - other.z | 0, this.w - other.w | 0);
    }
    ['unary-']() {
      return new NativeInt32x4[_truncated](-this.x | 0, -this.y | 0, -this.z | 0, -this.w | 0);
    }
    get signMask() {
      let mx = (dart.notNull(this.x) & 2147483648) >> 31;
      let my = (dart.notNull(this.y) & 2147483648) >> 31;
      let mz = (dart.notNull(this.z) & 2147483648) >> 31;
      let mw = (dart.notNull(this.w) & 2147483648) >> 31;
      return dart.notNull(mx) | dart.notNull(my) << 1 | dart.notNull(mz) << 2 | dart.notNull(mw) << 3;
    }
    shuffle(mask) {
      if (dart.notNull(mask) < 0 || dart.notNull(mask) > 255) {
        throw new core.RangeError(`mask ${mask} must be in the range [0..256)`);
      }
      NativeInt32x4[_list][core.$set](0, this.x);
      NativeInt32x4[_list][core.$set](1, this.y);
      NativeInt32x4[_list][core.$set](2, this.z);
      NativeInt32x4[_list][core.$set](3, this.w);
      let _x = NativeInt32x4[_list][core.$get](dart.notNull(mask) & 3);
      let _y = NativeInt32x4[_list][core.$get](dart.notNull(mask) >> 2 & 3);
      let _z = NativeInt32x4[_list][core.$get](dart.notNull(mask) >> 4 & 3);
      let _w = NativeInt32x4[_list][core.$get](dart.notNull(mask) >> 6 & 3);
      return new NativeInt32x4[_truncated](_x, _y, _z, _w);
    }
    shuffleMix(other, mask) {
      if (dart.notNull(mask) < 0 || dart.notNull(mask) > 255) {
        throw new core.RangeError(`mask ${mask} must be in the range [0..256)`);
      }
      NativeInt32x4[_list][core.$set](0, this.x);
      NativeInt32x4[_list][core.$set](1, this.y);
      NativeInt32x4[_list][core.$set](2, this.z);
      NativeInt32x4[_list][core.$set](3, this.w);
      let _x = NativeInt32x4[_list][core.$get](dart.notNull(mask) & 3);
      let _y = NativeInt32x4[_list][core.$get](dart.notNull(mask) >> 2 & 3);
      NativeInt32x4[_list][core.$set](0, other.x);
      NativeInt32x4[_list][core.$set](1, other.y);
      NativeInt32x4[_list][core.$set](2, other.z);
      NativeInt32x4[_list][core.$set](3, other.w);
      let _z = NativeInt32x4[_list][core.$get](dart.notNull(mask) >> 4 & 3);
      let _w = NativeInt32x4[_list][core.$get](dart.notNull(mask) >> 6 & 3);
      return new NativeInt32x4[_truncated](_x, _y, _z, _w);
    }
    withX(x) {
      let _x = dart.as(NativeInt32x4[_truncate](x), core.int);
      return new NativeInt32x4[_truncated](_x, this.y, this.z, this.w);
    }
    withY(y) {
      let _y = dart.as(NativeInt32x4[_truncate](y), core.int);
      return new NativeInt32x4[_truncated](this.x, _y, this.z, this.w);
    }
    withZ(z) {
      let _z = dart.as(NativeInt32x4[_truncate](z), core.int);
      return new NativeInt32x4[_truncated](this.x, this.y, _z, this.w);
    }
    withW(w) {
      let _w = dart.as(NativeInt32x4[_truncate](w), core.int);
      return new NativeInt32x4[_truncated](this.x, this.y, this.z, _w);
    }
    get flagX() {
      return this.x != 0;
    }
    get flagY() {
      return this.y != 0;
    }
    get flagZ() {
      return this.z != 0;
    }
    get flagW() {
      return this.w != 0;
    }
    withFlagX(flagX) {
      let _x = flagX ? -1 : 0;
      return new NativeInt32x4[_truncated](_x, this.y, this.z, this.w);
    }
    withFlagY(flagY) {
      let _y = flagY ? -1 : 0;
      return new NativeInt32x4[_truncated](this.x, _y, this.z, this.w);
    }
    withFlagZ(flagZ) {
      let _z = flagZ ? -1 : 0;
      return new NativeInt32x4[_truncated](this.x, this.y, _z, this.w);
    }
    withFlagW(flagW) {
      let _w = flagW ? -1 : 0;
      return new NativeInt32x4[_truncated](this.x, this.y, this.z, _w);
    }
    select(trueValue, falseValue) {
      let floatList = NativeFloat32x4[_list];
      let intView = NativeFloat32x4[_uint32view];
      floatList[core.$set](0, trueValue.x);
      floatList[core.$set](1, trueValue.y);
      floatList[core.$set](2, trueValue.z);
      floatList[core.$set](3, trueValue.w);
      let stx = intView[core.$get](0);
      let sty = intView[core.$get](1);
      let stz = intView[core.$get](2);
      let stw = intView[core.$get](3);
      floatList[core.$set](0, falseValue.x);
      floatList[core.$set](1, falseValue.y);
      floatList[core.$set](2, falseValue.z);
      floatList[core.$set](3, falseValue.w);
      let sfx = intView[core.$get](0);
      let sfy = intView[core.$get](1);
      let sfz = intView[core.$get](2);
      let sfw = intView[core.$get](3);
      let _x = dart.notNull(this.x) & dart.notNull(stx) | ~dart.notNull(this.x) & dart.notNull(sfx);
      let _y = dart.notNull(this.y) & dart.notNull(sty) | ~dart.notNull(this.y) & dart.notNull(sfy);
      let _z = dart.notNull(this.z) & dart.notNull(stz) | ~dart.notNull(this.z) & dart.notNull(sfz);
      let _w = dart.notNull(this.w) & dart.notNull(stw) | ~dart.notNull(this.w) & dart.notNull(sfw);
      intView[core.$set](0, _x);
      intView[core.$set](1, _y);
      intView[core.$set](2, _z);
      intView[core.$set](3, _w);
      return new NativeFloat32x4[_truncated](floatList[core.$get](0), floatList[core.$get](1), floatList[core.$get](2), floatList[core.$get](3));
    }
  }
  NativeInt32x4[dart.implements] = () => [typed_data.Int32x4];
  dart.defineNamedConstructor(NativeInt32x4, 'bool');
  dart.defineNamedConstructor(NativeInt32x4, 'fromFloat32x4Bits');
  dart.defineNamedConstructor(NativeInt32x4, _truncated);
  dart.defineLazyProperties(NativeInt32x4, {
    get _list() {
      return new NativeInt32List(4);
    }
  });
  let _uint32View = Symbol('_uint32View');
  class NativeFloat64x2 extends core.Object {
    NativeFloat64x2(x, y) {
      this.x = x;
      this.y = y;
      if (!dart.is(this.x, core.num))
        throw new core.ArgumentError(this.x);
      if (!dart.is(this.y, core.num))
        throw new core.ArgumentError(this.y);
    }
    splat(v) {
      this.NativeFloat64x2(v, v);
    }
    zero() {
      this.splat(0.0);
    }
    fromFloat32x4(v) {
      this.NativeFloat64x2(v.x, v.y);
    }
    [_doubles](x, y) {
      this.x = x;
      this.y = y;
    }
    toString() {
      return `[${this.x}, ${this.y}]`;
    }
    ['+'](other) {
      return new NativeFloat64x2[_doubles](dart.notNull(this.x) + dart.notNull(other.x), dart.notNull(this.y) + dart.notNull(other.y));
    }
    ['unary-']() {
      return new NativeFloat64x2[_doubles](-dart.notNull(this.x), -dart.notNull(this.y));
    }
    ['-'](other) {
      return new NativeFloat64x2[_doubles](dart.notNull(this.x) - dart.notNull(other.x), dart.notNull(this.y) - dart.notNull(other.y));
    }
    ['*'](other) {
      return new NativeFloat64x2[_doubles](dart.notNull(this.x) * dart.notNull(other.x), dart.notNull(this.y) * dart.notNull(other.y));
    }
    ['/'](other) {
      return new NativeFloat64x2[_doubles](dart.notNull(this.x) / dart.notNull(other.x), dart.notNull(this.y) / dart.notNull(other.y));
    }
    scale(s) {
      return new NativeFloat64x2[_doubles](dart.notNull(this.x) * dart.notNull(s), dart.notNull(this.y) * dart.notNull(s));
    }
    abs() {
      return new NativeFloat64x2[_doubles](this.x.abs(), this.y.abs());
    }
    clamp(lowerLimit, upperLimit) {
      let _lx = lowerLimit.x;
      let _ly = lowerLimit.y;
      let _ux = upperLimit.x;
      let _uy = upperLimit.y;
      let _x = this.x;
      let _y = this.y;
      _x = dart.notNull(_x) > dart.notNull(_ux) ? _ux : _x;
      _y = dart.notNull(_y) > dart.notNull(_uy) ? _uy : _y;
      _x = dart.notNull(_x) < dart.notNull(_lx) ? _lx : _x;
      _y = dart.notNull(_y) < dart.notNull(_ly) ? _ly : _y;
      return new NativeFloat64x2[_doubles](_x, _y);
    }
    get signMask() {
      let view = NativeFloat64x2[_uint32View];
      NativeFloat64x2[_list][core.$set](0, this.x);
      NativeFloat64x2[_list][core.$set](1, this.y);
      let mx = (dart.notNull(view[core.$get](1)) & 2147483648) >> 31;
      let my = (dart.notNull(view[core.$get](3)) & 2147483648) >> 31;
      return dart.notNull(mx) | dart.notNull(my) << 1;
    }
    withX(x) {
      if (!dart.is(x, core.num))
        throw new core.ArgumentError(x);
      return new NativeFloat64x2[_doubles](x, this.y);
    }
    withY(y) {
      if (!dart.is(y, core.num))
        throw new core.ArgumentError(y);
      return new NativeFloat64x2[_doubles](this.x, y);
    }
    min(other) {
      return new NativeFloat64x2[_doubles](dart.notNull(this.x) < dart.notNull(other.x) ? this.x : other.x, dart.notNull(this.y) < dart.notNull(other.y) ? this.y : other.y);
    }
    max(other) {
      return new NativeFloat64x2[_doubles](dart.notNull(this.x) > dart.notNull(other.x) ? this.x : other.x, dart.notNull(this.y) > dart.notNull(other.y) ? this.y : other.y);
    }
    sqrt() {
      return new NativeFloat64x2[_doubles](math.sqrt(this.x), math.sqrt(this.y));
    }
  }
  NativeFloat64x2[dart.implements] = () => [typed_data.Float64x2];
  dart.defineNamedConstructor(NativeFloat64x2, 'splat');
  dart.defineNamedConstructor(NativeFloat64x2, 'zero');
  dart.defineNamedConstructor(NativeFloat64x2, 'fromFloat32x4');
  dart.defineNamedConstructor(NativeFloat64x2, _doubles);
  dart.defineLazyProperties(NativeFloat64x2, {
    get _list() {
      return new NativeFloat64List(2);
    },
    set _list(_) {},
    get _uint32View() {
      return dart.as(NativeFloat64x2[_list].buffer.asUint32List(), NativeUint32List);
    },
    set _uint32View(_) {}
  });
  // Exports:
  exports.NativeByteBuffer = NativeByteBuffer;
  exports.NativeFloat32x4List = NativeFloat32x4List;
  exports.NativeInt32x4List = NativeInt32x4List;
  exports.NativeFloat64x2List = NativeFloat64x2List;
  exports.NativeTypedData = NativeTypedData;
  exports.NativeByteData = NativeByteData;
  exports.NativeTypedArray = NativeTypedArray;
  exports.NativeTypedArrayOfDouble = NativeTypedArrayOfDouble;
  exports.NativeTypedArrayOfInt = NativeTypedArrayOfInt;
  exports.NativeFloat32List = NativeFloat32List;
  exports.NativeFloat64List = NativeFloat64List;
  exports.NativeInt16List = NativeInt16List;
  exports.NativeInt32List = NativeInt32List;
  exports.NativeInt8List = NativeInt8List;
  exports.NativeUint16List = NativeUint16List;
  exports.NativeUint32List = NativeUint32List;
  exports.NativeUint8ClampedList = NativeUint8ClampedList;
  exports.NativeUint8List = NativeUint8List;
  exports.NativeFloat32x4 = NativeFloat32x4;
  exports.NativeInt32x4 = NativeInt32x4;
  exports.NativeFloat64x2 = NativeFloat64x2;
})(_native_typed_data || (_native_typed_data = {}));
