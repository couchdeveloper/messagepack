/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

public struct Encoder {
    public var buffer: UnsafeMutableRawBufferPointer
    internal private(set) var position: Int = 0

    public init(buffer: UnsafeMutableRawBufferPointer) {
        self.buffer = buffer
    }

    public init(start: UnsafeMutableRawPointer, count: Int) {
        self.buffer = UnsafeMutableRawBufferPointer(start: start, count: count)
    }

    public mutating func rewind() {
        position = 0
    }

    mutating func requestBuffer(size: Int) throws -> UnsafeMutableRawPointer {
        guard position + size <= buffer.count else {
            throw MessagePackError.notEnoughSpace
        }
        defer { position += size }
        return buffer.baseAddress! + position
    }

    mutating func write(_ value: UInt8) throws {
        let buffer = try requestBuffer(size: MemoryLayout<UInt8>.size)
        buffer.assumingMemoryBound(to: UInt8.self).pointee = value
    }

    mutating func write(_ value: UInt16) throws {
        let buffer = try requestBuffer(size: MemoryLayout<UInt16>.size)
        buffer.assumingMemoryBound(to: UInt16.self).pointee = value.byteSwapped
    }

    mutating func write(_ value: UInt32) throws {
        let buffer = try requestBuffer(size: MemoryLayout<UInt32>.size)
        buffer.assumingMemoryBound(to: UInt32.self).pointee = value.byteSwapped
    }

    mutating func write(_ value: UInt64) throws {
        let buffer = try requestBuffer(size: MemoryLayout<UInt64>.size)
        buffer.assumingMemoryBound(to: UInt64.self).pointee = value.byteSwapped
    }

    mutating func write(_ bytes: [UInt8]) throws {
        let buffer = try requestBuffer(size: bytes.count)
        buffer.copyBytes(from: bytes, count: bytes.count)
    }
}

extension Encoder {
    mutating func write(_ value: Int8) throws {
        try write(UInt8(bitPattern: value))
    }

    mutating func write(_ value: Int16) throws {
        try write(UInt16(bitPattern: value))
    }

    mutating func write(_ value: Int32) throws {
        try write(UInt32(bitPattern: value))
    }

    mutating func write(_ value: Int64) throws {
        try write(UInt64(bitPattern: value))
    }
}

extension Encoder {
    mutating func write(code value: UInt8) throws {
        try write(value)
    }
}
