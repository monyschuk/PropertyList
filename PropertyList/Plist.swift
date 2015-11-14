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

See [About Property Lists](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/PropertyLists/AboutPropertyLists/AboutPropertyLists.html) 
on the Apple Developer website for details.
*/

public enum Plist {
    case Date(NSDate)
    case Data(NSData)
    case Number(NSNumber)
    case String(Swift.String)
    
    case Array([Plist])
    case Dictionary([Swift.String:Plist])
    
    /// Creates a Property list object containing the value `date`.
    public init(date: NSDate) {
        self = .Date(date)
    }
    
    /// Creates a Property list object containing the value `data`.
    public init(data: NSData) {
        self = .Data(data)
    }
    
    /// Creates a Property list object containing the value `number`.
    public init(number: NSNumber) {
        self = .Number(number)
    }
    
    /// Creates a Property list object containing the value `string`.
    public init(string: Swift.String) {
        self = .String(string)
    }
    
    /// Creates a Property list object containing the array `array`.
    public init(array: [Plist]) {
        self = .Array(array)
    }
    
    /// Creates a Property list object containing the dictionary `dictionary`.
    public init(dictionary: [Swift.String:Plist]) {
        self = .Dictionary(dictionary)
    }
}

public extension Plist {
    /// Optional date value
    var date: NSDate? {
        switch self {
        case let .Date(value):      return value
        default:                    return nil
        }
    }
    
    /// Optional data value
    var data: NSData? {
        switch self {
        case let .Data(value):      return value
        default:                    return nil
        }
    }
    
    /// Optional number value
    var number: NSNumber? {
        switch self {
        case let .Number(value):    return value
        default:                    return nil
        }
    }
    
    /// Optional string value
    var string: Swift.String? {
        switch self {
        case let .String(value):    return value
        default:                    return nil
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

// MARK: -
// MARK: Value Types

public extension Plist {
    /// True if the receiver is a plist date
    var isDate: Bool {
        switch self {
        case .Date(_):          return true
        default:                return false
        }
    }
    
    /// True if the receiver is a plist data
    var isData: Bool {
        switch self {
        case .Data(_):          return true
        default:                return false
        }
    }
    
    /// True if the receiver is a plist number
    var isNumber: Bool {
        switch self {
        case .Number(_):        return true
        default:                return false
        }
    }
    
    /// True if the receiver is a plist string
    var isString: Bool {
        switch self {
        case .String(_):        return true
        default:                return false
        }
    }
    
    /// True if the receiver is a plist array
    var isArray: Bool {
        switch self {
        case .Array(_):         return true
        default:                return false
        }
    }
    
    /// True if the receiver is a plist dictionary
    var isDictionary: Bool {
        switch self {
        case .Dictionary(_):    return true
        default:                return false
        }
    }
}

// MARK: -
// MARK: Equatable

extension Plist: Equatable {}
public func ==(lhs: Plist, rhs: Plist) -> Bool {
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

// MARK: -
// MARK: SequenceType

extension Plist: Swift.SequenceType {
    /// Returns `true` if the receiver is an empty array or dictionary plist type, `false` otherwise
    public var isEmpty: Bool {
        switch self {
        case let .Array(value):         return value.isEmpty
        case let .Dictionary(value):    return value.isEmpty
        default:                        return false
        }
    }
    
    /// Returns the number of elements in an array or dictionary plist type, `0` otherwise
    public var count: Int {
        switch self {
        case let .Array(value):         return value.count
        case let .Dictionary(value):    return value.count
        default:                        return 0
        }
    }
    
    /**
    If the receiver is an array or dictionary plist type, returns a generator over the receiver's elements,
    or an empty generator for other types. 
    
    - returns: Returns a *generator* over the reecivers contents
    */
    public func generate() -> AnyGenerator<(Swift.String, Plist)> {
        switch self {
        case let .Array(value):
            var idx = 0
            var gen = value.generate()
            
            return anyGenerator {
                if let elt = gen.next() {
                    return ("\(idx++)", elt)
                } else {
                    return nil
                }
            }
            
        case let .Dictionary(value):
            var gen = value.generate()
            
            return anyGenerator {
                return gen.next()
            }
            
        default:
            return anyGenerator {
                nil
            }
        }
    }
}

// MARK: -
// MARK: Subscripts

// allow both string and integer subscripts
public protocol PlistSubscript {}

extension Swift.Int: PlistSubscript {}
extension Swift.String: PlistSubscript {}

public extension Plist {
    
    subscript(key: PlistSubscript) -> Plist? {
        
        /// If the receiver is an array plist, returns the plist value at integer subscript `key`.
        /// If the receiver is a dictionary plist, returns the plist value at string subscript `key`.
        get {
            switch self {
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
            switch self {
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
                    
                    self = .Array(newArray)
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
                
                self = .Dictionary(newDict)
                
            default:
                break
            }
        }
    }
}

// MARK: -
// MARK: Literal Convertibles

extension Plist: FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .Number(NSNumber(double: value))
    }
}
extension Plist: IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .Number(NSNumber(integer: value))
    }
}
extension Plist: BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .Number(NSNumber(bool: value))
    }
}

extension Plist: StringLiteralConvertible {
    public init(stringLiteral value: StringLiteralType) {
        self = .String(value)
    }
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self = .String(value)
    }
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = .String(value)
    }
}

extension Plist: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (Swift.String, Plist)...) {
        var dict: [Swift.String:Plist] = [:]
        for (key, value) in elements {
            dict[key] = value
        }
        self = .Dictionary(dict)
    }
}

extension Plist: ArrayLiteralConvertible {
    public  init(arrayLiteral elements: Plist...) {
        self = .Array(elements)
    }
}

extension Plist: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
    public var description: Swift.String {
        switch self {
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
    public var debugDescription: Swift.String {
        return description
    }
}

// MARK: -
// MARK: RawRepresentable

extension Plist: RawRepresentable {
    
    /**
     Create a Property list from a native cocoa property list.
     - parameter rawValue: A native cocoa property list
     - returns: the created property list
     */
    public init?(rawValue: AnyObject) {
        switch rawValue {
        case let value as NSURL:
            // NOTE: NSURL is not an actual property list type though it occurs in several property list
            // like values such as NSBundle.mainBundle().infoDictionary, so we add support for it here.
            
            self = .String(value.absoluteString)
            
        case let value as NSDate:
            self = .Date(value)
            
        case let value as NSData:
            self = .Data(value)
            
        case let value as NSNumber:
            self = .Number(value)
            
        case let value as Swift.String:
            self = .String(value)
            
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
            self = .Array(array)
            
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
            self = .Dictionary(dict)
            
        default:
            print("value \(rawValue) is not a valid property list type")
            return nil
        }
    }
    
    public var rawValue: AnyObject {
        switch self {
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
    
    /**
     Create a Property list from serialized data
     - parameter data: Serialized property list data
     - returns: the created property list object
     */
    static func propertyListWithData(data: NSData) throws -> Plist? {
        return try Plist(rawValue: NSPropertyListSerialization.propertyListWithData(data, options: [], format: nil))
    }
    
    /**
     Serialize a Property list to data
     - parameter plist: The property list to serialize
     - parameter format: The property list format to serialize to
     - returns: serialized data
     */
    static func dataWithPropertyList(plist: Plist, format: NSPropertyListFormat = .BinaryFormat_v1_0) -> NSData {
        return try! NSPropertyListSerialization.dataWithPropertyList(plist.rawValue, format: format, options: 0)
    }
    
    /**
     Create a Property list from a serialized property list stored in the file URL `url`.
     - parameter url: A file URL containing serialized plist data
     - parameter options: Options used to read data from `url`, defaults to none.
     - returns: the created property list object
     */
    static func propertyListWithContentsOfURL(url: NSURL, options: NSDataReadingOptions = []) throws -> Plist? {
        return try propertyListWithData(NSData(contentsOfURL: url, options: options))
    }
    
    /**
     Serialize a Property list to the filesystem at the file URL `url`.
     - parameter plist: The property list to serialize
     - parameter url: The file URL where the property list will be stored
     - parameter format: The property list format to serialize to
     - parameter options: Options used to write data to `url`.
     */
    static func writePropertyListToURL(plist: Plist, url: NSURL, format: NSPropertyListFormat = .BinaryFormat_v1_0, options writeOptionsMask: NSDataWritingOptions = []) throws {
        try dataWithPropertyList(plist, format: format).writeToURL(url, options: writeOptionsMask)
    }
}
