//
//  Plist.swift
//  PropertyList
//
//  Created by Mark Onyschuk on 2015-07-18.
//  Copyright © 2015 Mark Onyschuk. All rights reserved.
//

import Foundation

/**
A Cocoa Property list.

See [About Property Lists](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/PropertyLists/AboutPropertyLists/AboutPropertyLists.html) on the Apple Developer website for details.
*/

public final class Plist {
    
    /**
    Property list compatible types.
    
    See [About Property Lists](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/PropertyLists/AboutPropertyLists/AboutPropertyLists.html) on the Apple Developer website for details.
    */
    
    private enum ValueType {
        case Date(NSDate)
        case Data(NSData)
        case Number(NSNumber)
        case String(Swift.String)
        
        case Array([Plist])
        case Dictionary([Swift.String:Plist])
    }
    
    /**
    Underlying Property list value.
    */
    private var value: ValueType
    
    /**
    Creates a Property list object.
    - parameter value: A property list compatible value type
    - returns: the created property list object
    */
    private init(value: ValueType) {
        self.value = value
    }
}

public extension Plist {
    /// Optional date value
    var date: NSDate? {
        switch value {
        case let .Date(value):
            return value
        default:
            return nil
        }
    }
    
    /// Optional data value
    var data: NSData? {
        switch value {
        case let .Data(value):
            return value
        default:
            return nil
        }
    }
    
    /// Optional number value
    var number: NSNumber? {
        switch value {
        case let .Number(value):
            return value
        default:
            return nil
        }
    }
    
    /// Optional string value
    var string: Swift.String? {
        switch value {
        case let .String(value):
            return value
        default:
            return nil
        }
    }

    /// Optional bool value, non-nil for numeric plist types
    var bool: Swift.Bool? {
        return number?.boolValue
    }
    
    /// Optional int value, non-nil for numeric plist types
    var int: Swift.Int? {
        return number?.integerValue
    }
    
    /// Optional float value, non-nil for numeric plist types
    var float: Swift.Float? {
        return number?.floatValue
    }
    
    /// Optional double value, non-nil for numeric plist types
    var double: Swift.Double? {
        return number?.doubleValue
    }
}

public extension Plist {
    /// True if the receiver is a plist date
    var isDate: Bool {
        switch value {
        case .Date(_):
            return true
        default:
            return false
        }
    }
    
    /// True if the receiver is a plist data
    var isData: Bool {
        switch value {
        case .Data(_):
            return true
        default:
            return false
        }
    }
    
    /// True if the receiver is a plist number
    var isNumber: Bool {
        switch value {
        case .Number(_):
            return true
        default:
            return false
        }
    }
    
    /// True if the receiver is a plist string
    var isString: Bool {
        switch value {
        case .String(_):
            return true
        default:
            return false
        }
    }
    
    /// True if the receiver is a plist array
    var isArray: Bool {
        switch value {
        case .Array(_):
            return true
        default:
            return false
        }
    }
    
    /// True if the receiver is a plist dictionary
    var isDictionary: Bool {
        switch value {
        case .Dictionary(_):
            return true
        default:
            return false
        }
    }
}

public extension Plist {
    /**
    Create a Property list from serialized data
    - parameter data: Serialized property list data
    - returns: the created property list object
    */
    class func propertyListWithData(data: NSData) throws -> Plist {
        return try Plist(rawValue: NSPropertyListSerialization.propertyListWithData(data, options: [], format: nil))!
    }
    
    /**
    Serialize a Property list to data
    - parameter plist: The property list to serialize
    - parameter format: The property list format to serialize to
    - returns: serialized data
    */
    class func dataWithPropertyList(plist: Plist, format: NSPropertyListFormat = .BinaryFormat_v1_0) throws -> NSData {
        return try NSPropertyListSerialization.dataWithPropertyList(plist.rawValue, format: format, options: 0)
    }
}

// allow both string and integer subscripts
public protocol PlistSubscript {}

extension Swift.Int: PlistSubscript {}
extension Swift.String: PlistSubscript {}

public extension Plist {
    
    subscript(key: PlistSubscript) -> Plist? {
        /// If the receiver is an array plist, returns the plist value at integer subscript `key`.
        /// If the receiver is a dictionary plist, returns the plist value at string subscript `key`.
        get {
            switch value {
            case let .Array(array):
                if let key = key as? Swift.Int where key >= 0 && key < array.count {
                    return array[key]
                } else {
                    return nil
                }
                
            case let .Dictionary(dict):
                if let key = key as? Swift.String {
                    return dict[key]
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
        /// If the receiver is an array plist, allows value replacement and removal at integer subscript `key`.
        /// If the receiver is a dictionary plist, allows value insertion, replacement, and removalat string subscript `key`.
        set(newValue) {
            switch value {
            case let .Array(array) where key is Swift.Int:
                let idx = key as! Swift.Int
                if idx >= 0 && idx < array.count {
                    var newArray = array
                    
                    if let plist = newValue {
                        // replace the element
                        newArray[idx] = plist
                    } else {
                        // remove the element if nil
                        newArray.removeAtIndex(idx)
                    }
                    
                    value = .Array(newArray)
                }
            case let .Dictionary(dict) where key is Swift.String:
                let subs = key as! Swift.String
                var newDict = dict
                
                if let plist = newValue {
                    // replace the element
                    newDict[subs] = plist
                } else {
                    // remove the element if nil
                    newDict.removeValueForKey(subs)
                }
                
                value = .Dictionary(newDict)
            default:
                break
            }
        }
    }
}

extension Plist: Swift.SequenceType {
    /// Returns `true` if the receiver is an empty array or dictionary plist type, false otherwise
    public var isEmpty: Bool {
        switch value {
        case let .Array(value):
            return value.isEmpty
        case let .Dictionary(value):
            return value.isEmpty
        default:
            return false
        }
    }
    
    /// Returns the number of elements in an array or dictionary plist type, `0` otherwise
    public var count: Int {
        switch value {
        case let .Array(value):
            return value.count
        case let .Dictionary(value):
            return value.count
        default:
            return 0
        }
    }
    
    /**
    If the receiver is an array or dictionary plist type, returns a generator over the receiver's elements,
    or an empty generator for other types. 
    
    - returns: Returns a *generator* over the reecivers contents
    */
    
    public func generate() -> AnyGenerator<(Swift.String, Plist)> {
        switch value {
        case let .Array(value):
            var idx = 0
            var gen = value.generate()
            
            return anyGenerator({
                if let elt = gen.next() {
                    return ("\(idx++)", elt)
                } else {
                    return nil
                }
            })
            
        case let .Dictionary(value):
            var gen = value.generate()
            
            return anyGenerator({
                return gen.next()
            })
        default:
            return anyGenerator({
                nil
            })
        }
    }
}

extension Plist: FloatLiteralConvertible {
    public convenience init(floatLiteral value: FloatLiteralType) {
        self.init(value: .Number(NSNumber(double: value)))
    }
}
extension Plist: IntegerLiteralConvertible {
    public convenience init(integerLiteral value: IntegerLiteralType) {
        self.init(value: .Number(NSNumber(integer: value)))
    }
}
extension Plist: BooleanLiteralConvertible {
    public convenience init(booleanLiteral value: BooleanLiteralType) {
        self.init(value: .Number(NSNumber(bool: value)))
    }
}

extension Plist: StringLiteralConvertible {
    public convenience init(stringLiteral value: StringLiteralType) {
        self.init(value: .String(value))
    }
    public convenience init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(value: .String(value))
    }
    public convenience init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(value: .String(value))
    }
}

extension Plist: DictionaryLiteralConvertible {
    public convenience init(dictionaryLiteral elements: (Swift.String, Plist)...) {
        var dict: [Swift.String:Plist] = [:]
        for (key, value) in elements {
            dict[key] = value
        }
        self.init(value: .Dictionary(dict))
    }
}

extension Plist: ArrayLiteralConvertible {
    public convenience init(arrayLiteral elements: Plist...) {
        self.init(value: .Array(elements))
    }
}

extension Plist: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
    public var description: String {
        switch value {
        case let .Date(value):
            return value.description
        case let .Data(value):
            return value.description
        case let .Number(value):
            return value.description
        case let .String(value):
            return value
        case let .Array(value):
            return value.description
        case let .Dictionary(value):
            return value.description
        }
    }
    public var debugDescription: String {
        return description
    }
}

extension Plist: RawRepresentable {
    public convenience init?(rawValue: AnyObject) {
        switch rawValue {
        case let value as NSDate:
            self.init(value: .Date(value))
        
        case let value as NSData:
            self.init(value: .Data(value))
        
        case let value as NSNumber:
            self.init(value: .Number(value))
        
        case let value as Swift.String:
            self.init(value: .String(value))
        
        case let value as [AnyObject]:
            var array: [Plist] = []
            for obj in value {
                if let plist = Plist(rawValue: obj) {
                    array.append(plist)
                } else {
                    print("value \(obj) is not a valid property list type")
                    return nil
                }
            }
            self.init(value: .Array(array))
        
        case let value as [Swift.String: AnyObject]:
            var dict: [Swift.String: Plist] = [:]
            for (k, v) in value {
                if let plist = Plist(rawValue: v) {
                    dict[k] = plist
                } else {
                    print("value \(v) is not a valid property list type")
                    return nil
                }
            }
            self.init(value: .Dictionary(dict))
        
        default:
            print("value \(rawValue) is not a valid property list type")
            return nil
        }
    }
    
    public var rawValue: AnyObject {
        switch value {
        case let .Date(value):
            return value
        
        case let .Data(value):
            return value
        
        case let .Number(value):
            return value
        
        case let .String(value):
            return value as NSString
        
        case let .Array(value):
            var array: [AnyObject] = []
            for plist in value {
                array.append(plist.rawValue)
            }
            return array
            
        case let .Dictionary(value):
            var dict: [Swift.String: AnyObject] = [:]
            for (k, v) in value {
                dict[k] = v.rawValue
            }
            return dict
        }
    }
}

extension Plist: Equatable {}
public func ==(lhs: Plist, rhs: Plist) -> Bool {
    return lhs.value == rhs.value
}

extension Plist.ValueType: Equatable {}
private func ==(lhs: Plist.ValueType, rhs: Plist.ValueType) -> Bool {
    switch (lhs, rhs) {
    case let (.Date(lhs), .Date(rhs)):
        return lhs.isEqualToDate(rhs)
    case let (.Data(lhs), .Data(rhs)):
        return lhs.isEqualToData(rhs)
    case let (.Number(lhs), .Number(rhs)):
        return lhs.isEqualToNumber(rhs)
    case let (.String(lhs), .String(rhs)):
        return lhs == rhs
    case let (.Array(lhs), .Array(rhs)):
        return lhs == rhs
    case let (.Dictionary(lhs), .Dictionary(rhs)):
        return lhs == rhs
    default:
        return false
    }
}
