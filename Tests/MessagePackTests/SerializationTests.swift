/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import MessagePack

class SerializationTests: TestCase {
    func testNilSize() {
        let value = MessagePack.nil
        assertEqual(value.serializedSize, 1)
        assertEqual(try! value.serialize().count, 1)
    }

    func testBoolSize() {
        let bool = MessagePack.bool(true)
        assertEqual(bool.serializedSize, 1)
        assertEqual(try! bool.serialize().count, 1)
    }

    func testUIntSize() {
        let fixnum = MessagePack.uint(0x7f)
        assertEqual(fixnum.serializedSize, 1)
        assertEqual(try! fixnum.serialize().count, 1)

        let uint8 = MessagePack.uint(0xff)
        assertEqual(uint8.serializedSize, 2)
        assertEqual(try! uint8.serialize().count, 2)

        let uint16 = MessagePack.uint(UInt(UInt8.max) + 1)
        assertEqual(uint16.serializedSize, 3)
        assertEqual(try! uint16.serialize().count, 3)

        let uint32 = MessagePack.uint(UInt(UInt16.max) + 1)
        assertEqual(uint32.serializedSize, 5)
        assertEqual(try! uint32.serialize().count, 5)

        let uint64 = MessagePack.uint(UInt(UInt32.max) + 1)
        assertEqual(uint64.serializedSize, 9)
        assertEqual(try! uint64.serialize().count, 9)
    }

    func testIntSize() {
        let fixnum = MessagePack.int(-0x20)
        assertEqual(fixnum.serializedSize, 1)
        assertEqual(try! fixnum.serialize().count, 1)

        let int8 = MessagePack.int(-0x7f)
        assertEqual(int8.serializedSize, 2)
        assertEqual(try! int8.serialize().count, 2)

        let int16 = MessagePack.int(Int(Int8.min) - 1)
        assertEqual(int16.serializedSize, 3)
        assertEqual(try! int16.serialize().count, 3)

        let int32 = MessagePack.int(Int(Int16.min) - 1)
        assertEqual(int32.serializedSize, 5)
        assertEqual(try! int32.serialize().count, 5)

        let int64 = MessagePack.int(Int(Int32.min) - 1)
        assertEqual(int64.serializedSize, 9)
        assertEqual(try! int64.serialize().count, 9)
    }

    func testFloatSize() {
        let float = MessagePack.float(3.14)
        assertEqual(float.serializedSize, 5)
        assertEqual(try! float.serialize().count, 5)
    }

    func testDoubleSize() {
        let double = MessagePack.double(3.14)
        assertEqual(double.serializedSize, 9)
        assertEqual(try! double.serialize().count, 9)
    }

    func testStringSize() {
        let fixstrCount = 0x19
        let fixstr = MessagePack.string(String(repeating: "X", count: fixstrCount))
        assertEqual(fixstr.serializedSize, fixstrCount + 1)
        assertEqual(try! fixstr.serialize().count, fixstrCount + 1)

        let str8Count = Int(UInt8.max)
        let str8 = MessagePack.string(String(repeating: "X", count: str8Count))
        assertEqual(str8.serializedSize, str8Count + 2)
        assertEqual(try! str8.serialize().count, str8Count + 2)

        let str16Count = Int(UInt8.max) + 1
        let str16 = MessagePack.string(String(repeating: "X", count: str16Count))
        assertEqual(str16.serializedSize, str16Count + 3)
        assertEqual(try! str16.serialize().count, str16Count + 3)

        let str32Count = Int(UInt16.max) + 1
        let str32 = MessagePack.string(String(repeating: "X", count: str32Count))
        assertEqual(str32.serializedSize, str32Count + 5)
        assertEqual(try! str32.serialize().count, str32Count + 5)
    }

    func testBinarySize() {
        let bin8Count = Int(UInt8.max)
        let bin8 = MessagePack.binary([UInt8](repeating: 7, count: bin8Count))
        assertEqual(bin8.serializedSize, bin8Count + 2)
        assertEqual(try! bin8.serialize().count, bin8Count + 2)

        let bin16Count = Int(UInt8.max) + 1
        let bin16 = MessagePack.binary([UInt8](repeating: 7, count: bin16Count))
        assertEqual(bin16.serializedSize, bin16Count + 3)
        assertEqual(try! bin16.serialize().count, bin16Count + 3)

        let bin32Count = Int(UInt16.max) + 1
        let bin32 = MessagePack.binary([UInt8](repeating: 7, count: bin32Count))
        assertEqual(bin32.serializedSize, bin32Count + 5)
        assertEqual(try! bin32.serialize().count, bin32Count + 5)
    }

    func testArraySize() {
        let arrayItem = MessagePack(1)
        let arrayItemSize = arrayItem.serializedSize

        let fixarrayCount = 15
        let fixarrayItems = [MessagePack](repeating: arrayItem, count: fixarrayCount)
        let fixarray = MessagePack.array(fixarrayItems)
        assertEqual(fixarray.serializedSize, arrayItemSize * fixarrayCount + 1)
        assertEqual(try! fixarray.serialize().count, arrayItemSize * fixarrayCount + 1)

        let array16Count = 15 + 1
        let array16Items = [MessagePack](repeating: arrayItem, count: array16Count)
        let array16 = MessagePack.array(array16Items)
        assertEqual(array16.serializedSize, arrayItemSize * array16Count + 3)
        assertEqual(try! array16.serialize().count, arrayItemSize * array16Count + 3)

        let array32Count = Int(UInt16.max) + 1
        let array32Items = [MessagePack](repeating: arrayItem, count: array32Count)
        let array32 = MessagePack.array(array32Items)
        assertEqual(array32.serializedSize, arrayItemSize * array32Count + 5)
        assertEqual(try! array32.serialize().count, arrayItemSize * array32Count + 5)
    }

    func testMapSize() {
        let fixmapCount = 15
        var fixmapItems = [MessagePack : MessagePack]()
        var fixmapItemSize = 0
        for i in 1...fixmapCount {
            let key = MessagePack.int(i)
            let value = MessagePack.int(i)
            fixmapItems[key] = value
            fixmapItemSize += key.serializedSize
            fixmapItemSize += value.serializedSize
        }
        let fixmap = MessagePack.map(fixmapItems)
        assertEqual(fixmap.serializedSize, fixmapItemSize + 1)
        assertEqual(try! fixmap.serialize().count, fixmapItemSize + 1)

        let map16Count = 15 + 1
        var map16Items = [MessagePack : MessagePack]()
        var map16ItemSize = 0
        for i in 1...map16Count {
            let key = MessagePack.int(i)
            let value = MessagePack.int(i)
            map16Items[key] = value
            map16ItemSize += key.serializedSize
            map16ItemSize += value.serializedSize
        }
        let map16 = MessagePack.map(map16Items)
        assertEqual(map16.serializedSize, map16ItemSize + 3)
        assertEqual(try! map16.serialize().count, map16ItemSize + 3)

        let map32Count = Int(UInt16.max) + 1
        var map32Items = [MessagePack : MessagePack]()
        var map32ItemSize = 0
        for i in 1...map32Count {
            let key = MessagePack.int(i)
            let value = MessagePack.int(i)
            map32Items[key] = value
            map32ItemSize += key.serializedSize
            map32ItemSize += value.serializedSize
        }
        let map32 = MessagePack.map(map32Items)
        assertEqual(map32.serializedSize, map32ItemSize + 5)
        assertEqual(try! map32.serialize().count, map32ItemSize + 5)
    }

    func testExtendedSize() {
        let fixext1Item = MessagePack.Extended(type: 1, data: [1])
        let fixext1 = MessagePack.extended(fixext1Item)
        assertEqual(fixext1.serializedSize, 3)
        assertEqual(try! fixext1.serialize().count, 3)

        let fixext2Item = MessagePack.Extended(type: 1, data: [1, 2])
        let fixext2 = MessagePack.extended(fixext2Item)
        assertEqual(fixext2.serializedSize, 4)
        assertEqual(try! fixext2.serialize().count, 4)

        let fixext4Item = MessagePack.Extended(type: 1, data: [1, 2, 3, 4])
        let fixext4 = MessagePack.extended(fixext4Item)
        assertEqual(fixext4.serializedSize, 6)
        assertEqual(try! fixext4.serialize().count, 6)

        let fixext8Data = [UInt8](repeating: 7, count: 8)
        let fixext8Item = MessagePack.Extended(type: 1, data: fixext8Data)
        let fixext8 = MessagePack.extended(fixext8Item)
        assertEqual(fixext8.serializedSize, 10)
        assertEqual(try! fixext8.serialize().count, 10)

        let fixext16Data = [UInt8](repeating: 7, count: 16)
        let fixext16Item = MessagePack.Extended(type: 1, data: fixext16Data)
        let fixext16 = MessagePack.extended(fixext16Item)
        assertEqual(fixext16.serializedSize, 18)
        assertEqual(try! fixext16.serialize().count, 18)

        let ext8Data = [UInt8](repeating: 7, count: Int(UInt8.max))
        let ext8Item = MessagePack.Extended(type: 1, data: ext8Data)
        let ext8 = MessagePack.extended(ext8Item)
        assertEqual(ext8.serializedSize, 3 + Int(UInt8.max))
        assertEqual(try! ext8.serialize().count, 3 + Int(UInt8.max))

        let ext16Data = [UInt8](repeating: 7, count: Int(UInt8.max) + 1)
        let ext16Item = MessagePack.Extended(type: 1, data: ext16Data)
        let ext16 = MessagePack.extended(ext16Item)
        assertEqual(ext16.serializedSize, 4 + Int(UInt8.max) + 1)
        assertEqual(try! ext16.serialize().count, 4 + Int(UInt8.max) + 1)

        let ext32Data = [UInt8](repeating: 7, count: Int(UInt16.max) + 1)
        let ext32Item = MessagePack.Extended(type: 1, data: ext32Data)
        let ext32 = MessagePack.extended(ext32Item)
        assertEqual(ext32.serializedSize, 6 + Int(UInt16.max) + 1)
        assertEqual(try! ext32.serialize().count, 6 + Int(UInt16.max) + 1)
    }

    func testSerialization() {
        let object = MessagePack("Hello, World!")
        let expected = MessagePack.encode(object)

        var buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: object.serializedSize)
        defer { buffer.deinitialize(count: object.serializedSize) }

        let written = try! object.serialize(to: buffer, count: object.serializedSize)
        let result = [UInt8](UnsafeBufferPointer(start: buffer, count: object.serializedSize))
        assertEqual(written, expected.count)
        assertEqual(result, expected)
    }

    func testDeserialization() {
        let expected = MessagePack("Hello, World!")
        let encoded = MessagePack.encode(expected)

        let (result, read) = try! MessagePack.deserialize(from: encoded, count: encoded.count)

        assertEqual(read, encoded.count)
        assertEqual(result, expected)
    }

    static var allTests = [
        ("testNilSize", testNilSize),
        ("testBoolSize", testBoolSize),
        ("testUIntSize", testUIntSize),
        ("testIntSize", testIntSize),
        ("testFloatSize", testFloatSize),
        ("testDoubleSize", testDoubleSize),
        ("testStringSize", testStringSize),
        ("testBinarySize", testBinarySize),
        ("testArraySize", testArraySize),
        ("testMapSize", testMapSize),
        ("testExtendedSize", testExtendedSize),
        ("testSerialization", testSerialization),
        ("testDeserialization", testDeserialization),
    ]
}
