/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

public struct MPDeserializer {
    private let bytes: [UInt8]!
    private let buffer: UnsafeBufferPointer<UInt8>
    private var position = 0

    public init(bytes: [UInt8]) {
        self.bytes = bytes
        self.buffer = UnsafeBufferPointer(start: self.bytes!, count: bytes.count)
    }

    public init(bytes: UnsafeBufferPointer<UInt8>) {
        let copiedBytes = [UInt8](bytes)
        self.init(bytes: copiedBytes)
    }

    public init(bytes: UnsafePointer<UInt8>, count: Int) {
        let copiedBytes = [UInt8](UnsafeBufferPointer(start: bytes, count: count))
        self.init(bytes: copiedBytes)
    }

    public init(bytesNoCopy buffer: UnsafeBufferPointer<UInt8>) {
        self.bytes = nil
        self.buffer = buffer
    }

    public init(bytesNoCopy pointer: UnsafePointer<UInt8>, count: Int) {
        self.bytes = nil
        self.buffer = UnsafeBufferPointer(start: pointer, count: count)
    }

    public mutating func rewind() {
        position = 0
    }

    mutating func requestBuffer(size: Int) throws -> UnsafeRawPointer {
        guard position + size <= buffer.count else {
            throw MessagePackError.insufficientData
        }
        defer { position += size }
        return UnsafeRawPointer(buffer.baseAddress! + position)
    }

    mutating func readUInt8() throws -> UInt8 {
        let buffer = try requestBuffer(size: MemoryLayout<UInt8>.size)
        return buffer.assumingMemoryBound(to: UInt8.self).pointee
    }

    mutating func readUInt16() throws -> UInt16 {
        let buffer = try requestBuffer(size: MemoryLayout<UInt16>.size)
        return buffer.assumingMemoryBound(to: UInt16.self).pointee.byteSwapped
    }

    mutating func readUInt32() throws -> UInt32 {
        let buffer = try requestBuffer(size: MemoryLayout<UInt32>.size)
        return buffer.assumingMemoryBound(to: UInt32.self).pointee.byteSwapped
    }

    mutating func readUInt64() throws -> UInt64 {
        let buffer = try requestBuffer(size: MemoryLayout<UInt64>.size)
        return buffer.assumingMemoryBound(to: UInt64.self).pointee.byteSwapped
    }

    mutating func read(count: Int) throws -> UnsafeBufferPointer<UInt8> {
        let buffer = try requestBuffer(size: count)
        return UnsafeBufferPointer(start: buffer.assumingMemoryBound(to: UInt8.self), count: count)
    }
}

extension MPDeserializer {
    mutating func readInt8() throws -> Int8 {
        return Int8(bitPattern: try readUInt8())
    }

    mutating func readInt16() throws -> Int16 {
        return Int16(bitPattern: try readUInt16())
    }

    mutating func readInt32() throws -> Int32 {
        return Int32(bitPattern: try readUInt32())
    }

    mutating func readInt64() throws -> Int64 {
        return Int64(bitPattern: try readUInt64())
    }
}

extension MPDeserializer {
    mutating func readCode() throws -> UInt8 {
        return try readUInt8()
    }
}

extension MPDeserializer {
    mutating func readInt(code: UInt8) throws -> Int {
        switch code {
        case 0xd0: return Int(try readInt8())
        case 0xd1: return Int(try readInt16())
        case 0xd2: return Int(try readInt32())
        case 0xd3: return Int(try readInt64())
        case 0xe0...0xff: return Int(Int8(numericCast(code) - 0x100))
        default: throw MessagePackError.invalidData
        }
    }

    mutating func readUInt(code: UInt8) throws -> UInt {
        switch code {
        case 0x00...0x7f: return UInt(code)
        case 0xcc: return UInt(try readUInt8())
        case 0xcd: return UInt(try readUInt16())
        case 0xce: return UInt(try readUInt32())
        case 0xcf: return UInt(try readUInt64())
        default: throw MessagePackError.invalidData
        }
    }

    mutating func readBool(code: UInt8) throws -> Bool {
        switch code {
        case 0xc2: return false
        case 0xc3: return true
        default: throw MessagePackError.invalidData
        }
    }

    mutating func readFloat() throws -> Float {
        let bytes = try readUInt32()
        return unsafeBitCast(bytes, to: Float.self)
    }

    mutating func readDouble() throws -> Double {
        let bytes = try readUInt64()
        return unsafeBitCast(bytes, to: Double.self)
    }

    mutating func readString(code: UInt8) throws -> String {
        let count = try readStringLength(code: code)

        // TODO: Optimize iterator
        // let buffer = try read(count: count)
        let data = Array(try read(count: count))

        var string = ""
        var decoder = UTF8()
        var iterator = data.makeIterator()

        decode: for _ in 0..<count {
            switch decoder.decode(&iterator) {
            case .scalarValue(let char): string.unicodeScalars.append(char)
            case .emptyInput: break decode
            case .error: throw MessagePackError.invalidData
            }
        }
        return string
    }

    mutating func readArray(code: UInt8) throws -> [MessagePack] {
        let count = try readArrayLength(code: code)
        var array = [MessagePack]()

        array.reserveCapacity(count)
        for _ in 0..<count {
            array.append(try unpack())
        }

        return array
    }

    mutating func readMap(code: UInt8) throws -> [MessagePack: MessagePack] {
        let count = try readMapLength(code: code)
        var dictionary = [MessagePack: MessagePack]()

        for _ in 0..<count {
            let key = try unpack() as MessagePack
            let value = try unpack() as MessagePack
            dictionary[key] = value
        }

        return dictionary
    }

    mutating func readBinary(code: UInt8) throws -> [UInt8] {
        let count = try readBinaryLength(code: code)
        return [UInt8](try read(count: count))
    }

    mutating func readExtended(code: UInt8) throws -> MessagePack.Extended {
        let count = try readExtendedLength(code: code)

        let type = try readInt8()
        let data = [UInt8](try read(count: count))

        return MessagePack.Extended(type: type, data: data)
    }
}
