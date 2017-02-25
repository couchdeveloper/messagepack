/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

import Serialization

extension MessagePack: Serializable {
    public var serializedSize: Int {
        switch self {
        case .nil:
            return 1
        case .bool:
            return 1
        case .uint(let value):
            return getPositiveIntegerSize(value)
        case .int(let value):
            return value < 0 ?
                getNegativeIntegerSize(value) :
                getPositiveIntegerSize(UInt(bitPattern: value))
        case .float:
            return 5
        case .double:
            return 9
        case .string(let string):
            let count = string.utf8.count
            switch count {
            case _ where count <= 0x19:
                return count + 1
            case _ where count <= 0xff:
                return count + 2
            case _ where count <= 0xffff:
                return count + 3
            case _ where count <= 0xffffffff:
                return count + 5
            default:
                return 0
            }
        case .binary(let bytes):
            let count = bytes.count
            switch count {
            case _ where count <= 0xff:
                return count + 2
            case _ where count <= 0xffff:
                return count + 3
            case _ where count <= 0xffffffff:
                return count + 5
            default:
                return 0
            }
        case .array(let items):
            var size = 0
            let count = items.count
            switch count {
            case _ where count <= 0xf:
                size = 1
            case _ where count <= 0xffff:
                size = 3
            case _ where count <= 0xffffffff:
                size = 5
            default:
                return 0
            }
            for item in items {
                size += item.serializedSize
            }
            return size
        case .map(let items):
            var size = 0
            let count = items.count
            switch count {
            case _ where count <= 0xf:
                size = 1
            case _ where count <= 0xffff:
                size = 3
            case _ where count <= 0xffffffff:
                size = 5
            default:
                return 0
            }
            for (key, value) in items {
                size += key.serializedSize
                size += value.serializedSize
            }
            return size
        case .extended(let extended):
            let count = extended.data.count
            switch count {
            case _ where count == 1:
                return 3
            case _ where count == 2:
                return 4
            case _ where count == 4:
                return 6
            case _ where count == 8:
                return 10
            case _ where count == 16:
                return 18
            case _ where count <= 0xff:
                return 3 + count
            case _ where count <= 0xffff:
                return 4 + count
            case _ where count <= 0xffffffff:
                return 6 + count
            default:
                return 0
            }
        }
    }

    @inline(__always)
    fileprivate func getNegativeIntegerSize(_ value: Int) -> Int {
        switch value {
        case _ where value >= -0x20:
            return 1
        case _ where value >= -0x7f:
            return 2
        case _ where value >= -0x7fff:
            return 3
        case _ where value >= -0x7fffffff:
            return 5
        default:
            return 9
        }
    }

    @inline(__always)
    fileprivate func getPositiveIntegerSize(_ value: UInt) -> Int {
        switch value {
        case _ where value <= 0x7f:
            return 1
        case _ where value <= 0xff:
            return 2
        case _ where value <= 0xffff:
            return 3
        case _ where value <= 0xffffffff:
            return 5
        default:
            return 9
        }
    }

    public func serialize(to buffer: UnsafeMutableRawPointer, count: Int) throws -> Int {
        var encoder = Encoder(start: buffer, count: count)
        try encoder.encode(self)
        return encoder.position
    }
}

extension MessagePack: Deserializable {
    public static func deserialize(from buffer: UnsafeRawPointer, count: Int) throws -> (MessagePack, Int) {
        var decoder = Decoder(bytes: buffer, count: count)
        let result = try decoder.decode() as MessagePack
        let count = decoder.position
        return (result, count)
    }
}
