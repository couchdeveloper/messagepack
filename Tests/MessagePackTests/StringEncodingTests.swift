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

class StringEncodingTests: TestCase {
    func testEnglishString() {
        let original = MessagePack.string("Hello, World!")
        let result = try? MessagePack.decode(bytes: MessagePack.encode(original))
        assertEqual(result, original)
    }

    func testSwedishString() {
        let original = MessagePack.string("Hellö, Wörld!")
        let result = try? MessagePack.decode(bytes: MessagePack.encode(original))
        assertEqual(result, original)
    }

    func testJapaneseString() {
        let original = MessagePack.string("こんにちは世界！")
        let result = try? MessagePack.decode(bytes: MessagePack.encode(original))
        assertEqual(result, original)
    }

    func testRussianString() {
        let original = MessagePack.string("Привет, Мир!")
        let result = try? MessagePack.decode(bytes: MessagePack.encode(original))
        assertEqual(result, original)
    }

    func testASCIIString() {
        let string = MessagePack.string("Hello, World!")
        let bytes: [UInt8] = [0xad, 0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x57, 0x6f, 0x72, 0x6c, 0x64, 0x21]

        let encoded = MessagePack.encode(string)
        assertEqual(encoded, bytes)

        let decoded = try? MessagePack.decode(bytes: bytes)
        assertEqual(decoded, string)
    }

    static var allTests = [
        ("testEnglishString", testEnglishString),
        ("testSwedishString", testSwedishString),
        ("testJapaneseString", testJapaneseString),
        ("testRussianString", testRussianString),
        ("testASCIIString", testASCIIString),
    ]
}
