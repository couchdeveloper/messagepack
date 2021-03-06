/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

public protocol MessagePackInitializable {
    init?(_ MessagePack: MessagePack)
}

extension Bool: MessagePackInitializable {
    public init?(_ MessagePack: MessagePack) {
        guard case let .bool(value) = MessagePack else {
            return nil
        }
        self.init(value)
    }
}

extension String: MessagePackInitializable {
    public init?(_ MessagePack: MessagePack) {
        guard case let .string(string) = MessagePack else {
            return nil
        }
        self.init(string)
    }
}

extension Float: MessagePackInitializable {
    public init?(_ MessagePack: MessagePack) {
        switch MessagePack {
        case let .float(value): self.init(value)
        default: return nil
        }
    }
}

extension Double: MessagePackInitializable {
    public init?(_ MessagePack: MessagePack) {
        switch MessagePack {
        case let .double(value): self.init(value)
        default: return nil
        }
    }
}

extension Int: MessagePackInitializable {
    public init?(_ MessagePack: MessagePack) {
        switch MessagePack {
        case let .int(value): self.init(value)
        case let .uint(value) where value <= UInt(Int.max): self.init(value)
        default: return nil
        }
    }
}

extension Int8: MessagePackInitializable {
    public init?(_ MessagePack: MessagePack) {
        switch MessagePack {
        case let .int(value) where value <= Int(Int8.max): self.init(value)
        case let .uint(value) where value <= UInt(Int8.max): self.init(value)
        default: return nil
        }
    }
}

extension Int16: MessagePackInitializable {
    public init?(_ MessagePack: MessagePack) {
        switch MessagePack {
        case let .int(value) where value <= Int(Int16.max): self.init(value)
        case let .uint(value) where value <= UInt(Int16.max): self.init(value)
        default: return nil
        }
    }
}

extension Int32: MessagePackInitializable {
    public init?(_ MessagePack: MessagePack) {
        switch MessagePack {
        case let .int(value) where value <= Int(Int32.max): self.init(value)
        case let .uint(value) where value <= UInt(Int32.max): self.init(value)
        default: return nil
        }
    }
}

extension Int64: MessagePackInitializable {
    public init?(_ MessagePack: MessagePack) {
        switch MessagePack {
        case let .int(value):
            self.init(value)
        case let .uint(value) where UInt64(value) <= UInt64(Int64.max):
           self.init(value)
        default: return nil
        }
    }
}

extension UInt: MessagePackInitializable {
    public init?(_ MessagePack: MessagePack) {
        switch MessagePack {
        case let .int(value) where value >= 0 : self.init(value)
        case let .uint(value): self.init(value)
        default: return nil
        }
    }
}

extension UInt8: MessagePackInitializable {
    public init?(_ MessagePack: MessagePack) {
        switch MessagePack {
        case let .int(value) where value >= 0 && UInt(value) <= UInt(UInt8.max):
            self.init(value)
        case let .uint(value) where value <= UInt(UInt8.max):
            self.init(value)
        default: return nil
        }
    }
}

extension UInt16: MessagePackInitializable {
    public init?(_ MessagePack: MessagePack) {
        switch MessagePack {
        case let .int(value)
            where value >= 0 && UInt(value) <= UInt(UInt16.max):
                self.init(value)
        case let .uint(value)
            where value <= UInt(UInt16.max):
                self.init(value)
        default: return nil
        }
    }
}

extension UInt32: MessagePackInitializable {
    public init?(_ MessagePack: MessagePack) {
        switch MessagePack {
        case let .int(value)
            where value >= 0 && UInt(value) <= UInt(UInt32.max):
                self.init(value)
        case let .uint(value)
            where value <= UInt(UInt32.max):
                self.init(value)
        default: return nil
        }
    }
}

extension UInt64: MessagePackInitializable {
    public init?(_ MessagePack: MessagePack) {
        switch MessagePack {
        case let .int(value) where value >= 0: self.init(value)
        case let .uint(value): self.init(value)
        default: return nil
        }
    }
}

extension MessagePack.Extended: MessagePackInitializable {
    public init?(_ value: MessagePack) {
        guard case let .extended(data) = value else {
            return nil
        }
        self = data
    }
}


extension Array where Element == UInt8 {
    public init?(_ value: MessagePack) {
        guard case let .binary(data) = value else {
            return nil
        }
        self = data
    }
}

extension Array where Element == MessagePack {
    public init?(_ value: MessagePack) {
        guard case let .array(items) = value else {
            return nil
        }
        self = items
    }
}

extension Dictionary where Key == MessagePack, Value == MessagePack {
    public init?(_ value: MessagePack) {
        guard case let .map(items) = value else {
            return nil
        }
        self = items
    }
}

// MARK: Optionals

extension MessagePackInitializable {
    public init?(_ optional: MessagePack?) {
        guard case let .some(some) = optional,
            let value = Self(some) else {
                return nil
        }
        self = value
    }
}

extension Array where Element == MessagePack {
    public init?(_ optional: MessagePack?) {
        guard case let .some(some) = optional,
            let value = Array(some) else {
                return nil
        }
        self = value
    }
}

extension Dictionary where Key == MessagePack, Value == MessagePack {
    public init?(_ optional: MessagePack?) {
        guard case let .some(some) = optional,
            let value = Dictionary(some) else {
                return nil
        }
        self = value
    }
}
