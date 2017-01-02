/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import XCTest
import MessagePack

class ExtendedTests: XCTestCase {
    func testSerializerFixExt1() {
        let raw = [UInt8](repeating: 0x45, count: 1)
        let expected: [UInt8] = [0xd4, 0x01] + raw
        let packed = MessagePack.serialize(.extended(MessagePack.Extended(type: 1, data: raw)))
        XCTAssertEqual(packed, expected)
    }

    func testDeserializerFixExt1() {
        let raw = [UInt8](repeating: 0x45, count: 1)
        let expected = MessagePack.extended(MessagePack.Extended(type: 1, data: raw))
        let unpacked = try? MessagePack.deserialize(bytes: [0xd4, 0x01] + raw)
        XCTAssertEqual(unpacked, expected)
    }

    func testSerializerFixExt2() {
        let raw = [UInt8](repeating: 0x45, count: 2)
        let expected: [UInt8] = [0xd5, 0x01] + raw
        let packed = MessagePack.serialize(.extended(MessagePack.Extended(type: 1, data: raw)))
        XCTAssertEqual(packed, expected)
    }

    func testDeserializerFixExt2() {
        let raw = [UInt8](repeating: 0x45, count: 2)
        let expected = MessagePack.extended(MessagePack.Extended(type: 1, data: raw))
        let unpacked = try? MessagePack.deserialize(bytes: [0xd5, 0x01] + raw)
        XCTAssertEqual(unpacked, expected)
    }

    func testSerializerFixExt4() {
        let raw = [UInt8](repeating: 0x45, count: 4)
        let expected: [UInt8] = [0xd6, 0x01] + raw
        let packed = MessagePack.serialize(.extended(MessagePack.Extended(type: 1, data: raw)))
        XCTAssertEqual(packed, expected)
    }

    func testDeserializerFixExt4() {
        let raw = [UInt8](repeating: 0x45, count: 4)
        let expected = MessagePack.extended(MessagePack.Extended(type: 1, data: raw))
        let unpacked = try? MessagePack.deserialize(bytes: [0xd6, 0x01] + raw)
        XCTAssertEqual(unpacked, expected)
    }

    func testSerializerFixExt8() {
        let raw = [UInt8](repeating: 0x45, count: 8)
        let expected: [UInt8] = [0xd7, 0x01] + raw
        let packed = MessagePack.serialize(.extended(MessagePack.Extended(type: 1, data: raw)))
        XCTAssertEqual(packed, expected)
    }

    func testDeserializerFixExt8() {
        let raw = [UInt8](repeating: 0x45, count: 8)
        let expected = MessagePack.extended(MessagePack.Extended(type: 1, data: raw))
        let unpacked = try? MessagePack.deserialize(bytes: [0xd7, 0x01] + raw)
        XCTAssertEqual(unpacked, expected)
    }

    func testSerializerFixExt16() {
        let raw = [UInt8](repeating: 0x45, count: 16)
        let expected: [UInt8] = [0xd8, 0x01] + raw
        let packed = MessagePack.serialize(.extended(MessagePack.Extended(type: 1, data: raw)))
        XCTAssertEqual(packed, expected)
    }

    func testDeserializerFixExt16() {
        let raw = [UInt8](repeating: 0x45, count: 16)
        let expected = MessagePack.extended(MessagePack.Extended(type: 1, data: raw))
        let unpacked = try? MessagePack.deserialize(bytes: [0xd8, 0x01] + raw)
        XCTAssertEqual(unpacked, expected)
    }

    func testSerializerExt8() {
        let raw = [UInt8](repeating: 0x45, count: Int(UInt8.max))
        let expected: [UInt8] = [0xc7, 0xff, 0x01] + raw
        let packed = MessagePack.serialize(.extended(MessagePack.Extended(type: 1, data: raw)))
        XCTAssertEqual(packed, expected)
    }

    func testDeserializerExt8() {
        let raw = [UInt8](repeating: 0x45, count: Int(UInt8.max))
        let expected = MessagePack.extended(MessagePack.Extended(type: 1, data: raw))
        let unpacked = try? MessagePack.deserialize(bytes: [0xc7, 0xff, 0x01] + raw)
        XCTAssertEqual(unpacked, expected)
    }

    func testSerializerExt16() {
        let raw = [UInt8](repeating: 0x45, count: Int(UInt16.max))
        let expected: [UInt8] = [0xc8, 0xff, 0xff, 0x01] + raw
        let packed = MessagePack.serialize(.extended(MessagePack.Extended(type: 1, data: raw)))
        XCTAssertEqual(packed, expected)
    }

    func testDeserializerExt16() {
        let raw = [UInt8](repeating: 0x45, count: Int(UInt16.max))
        let expected = MessagePack.extended(MessagePack.Extended(type: 1, data: raw))
        let unpacked = try? MessagePack.deserialize(bytes: [0xc8, 0xff, 0xff, 0x01] + raw)
        XCTAssertEqual(unpacked, expected)
    }

    func testSerializerExt32() {
        let raw = [UInt8](repeating: 0x45, count: Int(UInt16.max)+1)
        let expected: [UInt8] = [0xc9, 0x00, 0x01, 0x00, 0x00, 0x01] + raw
        let packed = MessagePack.serialize(.extended(MessagePack.Extended(type: 1, data: raw)))
        XCTAssertEqual(packed, expected)
    }

    func testDeserializerExt32() {
        let raw = [UInt8](repeating: 0x45, count: Int(UInt16.max)+1)
        let expected = MessagePack.extended(MessagePack.Extended(type: 1, data: raw))
        let unpacked = try? MessagePack.deserialize(bytes: [0xc9, 0x00, 0x01, 0x00, 0x00, 0x01] + raw)
        XCTAssertEqual(unpacked, expected)
    }

    static var allTests : [(String, (ExtendedTests) -> () throws -> Void)] {
        return [
            ("testSerializerFixExt1", testSerializerFixExt1),
            ("testDeserializerFixExt1", testDeserializerFixExt1),
            ("testSerializerFixExt2", testSerializerFixExt2),
            ("testDeserializerFixExt2", testDeserializerFixExt2),
            ("testSerializerFixExt4", testSerializerFixExt4),
            ("testDeserializerFixExt4", testDeserializerFixExt4),
            ("testSerializerFixExt8", testSerializerFixExt8),
            ("testDeserializerFixExt8", testDeserializerFixExt8),
            ("testSerializerFixExt16", testSerializerFixExt16),
            ("testDeserializerFixExt16", testDeserializerFixExt16),
            ("testSerializerExt8", testSerializerExt8),
            ("testDeserializerExt8", testDeserializerExt8),
            ("testSerializerExt16", testSerializerExt16),
            ("testDeserializerExt16", testDeserializerExt16),
            ("testSerializerExt32", testSerializerExt32),
            ("testDeserializerExt32", testDeserializerExt32),
        ]
    }
}