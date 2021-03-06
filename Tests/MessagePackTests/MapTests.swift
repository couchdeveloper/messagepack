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

func makeMap(repeating: MessagePack, count: Int) -> [MessagePack: MessagePack] {
    var map: [MessagePack: MessagePack] = [:]
    for i in 0..<count {
        map[.int(i)] = repeating
    }
    return map
}

func makeEncodedMapData(repeating: MessagePack, count: Int) -> [UInt8] {
    var bytes: [UInt8] = []
    for i in 0..<count {
        bytes.append(contentsOf: MessagePack.encode(.int(i)))
        bytes.append(contentsOf: MessagePack.encode(repeating))
    }
    return bytes
}

class MapTests: TestCase {
    func testEncodeFixMap() {
        let expected: [UInt8] = [0x81, 0xa5, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 0xa5, 0x77, 0x6f, 0x72, 0x6c, 0x64]
        let encoded = MessagePack.encode(.map([.string("hello"): .string("world")]))
        assertEqual(encoded, expected)
    }

    func testDecodeFixMap() {
        let expected = MessagePack.map([.string("hello"): .string("world")])
        let decoded = try? MessagePack.decode(bytes: [0x81, 0xa5, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 0xa5, 0x77, 0x6f, 0x72, 0x6c, 0x64])
        assertEqual(decoded, expected)
    }

    func testEncodeMap16() {
        let expected: [UInt8] = [0xde, 0x01, 0x00] + makeEncodedMapData(repeating: .nil, count: Int(UInt8.max)+1)
        let encoded = MessagePack.encode(.map(makeMap(repeating: nil, count: Int(UInt8.max)+1)))
        assertEqual(encoded.prefix(3), expected.prefix(3))
        assertEqual(encoded.sorted(), expected.sorted())
    }

    func testDecodeMap16() {
        let expected = MessagePack.map(makeMap(repeating: nil, count: Int(UInt8.max)+1))
        let decoded = try? MessagePack.decode(bytes: [0xde, 0x01, 0x00] + makeEncodedMapData(repeating: .nil, count: Int(UInt8.max)+1))
        assertEqual(decoded, expected)
    }

    func testEncodeMap32() {
        let expected: [UInt8] = [0xdf, 0x00, 0x01, 0x00, 0x00] + makeEncodedMapData(repeating: .nil, count: Int(UInt16.max)+1)
        let encoded = MessagePack.encode(.map(makeMap(repeating: nil, count: Int(UInt16.max)+1)))
        assertEqual(encoded.prefix(3), expected.prefix(3))
        assertEqual(encoded.sorted(), expected.sorted())
    }

    func testDecodeMap32() {
        let expected = MessagePack.map(makeMap(repeating: nil, count: Int(UInt16.max)+1))
        let decoded = try? MessagePack.decode(bytes: [0xdf, 0x00, 0x01, 0x00, 0x00] + makeEncodedMapData(repeating: .nil, count: Int(UInt16.max)+1))
        assertEqual(decoded, expected)
    }

    func testEmptyMap() {
        let mapArray: [[UInt8]] = [
            [0x80],
            [0xde, 0x00, 0x00],
            [0xdf, 0x00, 0x00, 0x00, 0x00]
        ]
        for bytes in mapArray {
            guard let object = try? MessagePack.decode(bytes: bytes),
                let map = [MessagePack : MessagePack](object) else {
                    fail()
                    return

            }
            assertEqual(map, [:])
        }
    }

    func testFixMapSize() {
        var items = [MessagePack : MessagePack]()
        for i in 1...15 {
            items[.int(i)] = .int(i)
        }
        let bytes = MessagePack.encode(.map(items))
        assertEqual(bytes.count, 31)
    }

    static var allTests = [
        ("testEncodeFixMap", testEncodeFixMap),
        ("testDecodeFixMap", testDecodeFixMap),
        ("testEncodeMap16", testEncodeMap16),
        ("testDecodeMap16", testDecodeMap16),
        ("testEncodeMap32", testEncodeMap32),
        ("testDecodeMap32", testDecodeMap32),
        ("testEmptyMap", testEmptyMap),
        ("testFixMapSize", testFixMapSize)
    ]
}
