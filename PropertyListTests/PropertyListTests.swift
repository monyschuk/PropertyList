//
//  PropertyListTests.swift
//  PropertyListTests
//
//  Created by Mark Onyschuk on 2015-07-20.
//  Copyright © 2015 Mark Onyschuk. All rights reserved.
//

import XCTest
@testable import PropertyList

class PropertyListTests: XCTestCase {
    
    func testArrayIndexedAccessors() {
        func assertEqualToArrayUsingIndexedAccessors(plist: Plist, array: [String]) {
            XCTAssertTrue(plist.count == array.count)
            
            for idx in 0..<array.count {
                XCTAssertTrue(plist[idx]?.string == array[idx])
            }
        }
        
        // test indexed getters
        let p: Plist = ["Mammal", "Reptile", "Amphibian"]
        assertEqualToArrayUsingIndexedAccessors(p, array: ["Mammal", "Reptile", "Amphibian"])
        
        // test indexed getters for invalid indexes
        XCTAssertTrue(p["Fish"] == nil)
        XCTAssertTrue(p[-1] == nil)
        XCTAssertTrue(p[99] == nil)
        
        // test indexed setters for invalid indexes
        p["Fish"] = nil
        XCTAssertTrue(p.count == 3)
        
        p[-1] = "Bird"
        XCTAssertTrue(p.count == 3)
        
        p[99] = "Bird"
        XCTAssertTrue(p.count == 3)
        
        // test indexed setter value update
        p[0] = "Monkey"
        p[2] = "Salamander"
        assertEqualToArrayUsingIndexedAccessors(p, array: ["Monkey", "Reptile", "Salamander"])
        
        // test indexed setter value removal
        p[1] = nil
        assertEqualToArrayUsingIndexedAccessors(p, array: ["Monkey", "Salamander"])
    }
    
    func testDictionaryIndexedAccessors() {
        func assertEqualToDictionaryUsingIndexedAccessors(plist: Plist, dict: [String:String]) {
            XCTAssertTrue(plist.count == dict.count)
            for (k, v) in dict {
                XCTAssertTrue(plist[k]?.string == v)
            }
        }
        
        // test indexed getters
        let p: Plist = ["Mammal": "Monkey", "Reptile": "Aligator", "Amphibian": "Salamander"]
        assertEqualToDictionaryUsingIndexedAccessors(p, dict: ["Mammal": "Monkey", "Reptile": "Aligator", "Amphibian": "Salamander"])
        
        // test indexed getters for invalid indexes
        XCTAssertTrue(p["bird"] == nil)
        XCTAssertTrue(p[0] == nil)
        
        // test indexed setter value insertion and replacement
        p["Mammal"] = "Hamster"
        p["Bird"] = "Finch"
        assertEqualToDictionaryUsingIndexedAccessors(p, dict: ["Mammal": "Hamster", "Bird": "Finch", "Reptile": "Aligator", "Amphibian": "Salamander"])
        
        // test indexed setter value removal
        p["Amphibian"] = nil
        assertEqualToDictionaryUsingIndexedAccessors(p, dict: ["Mammal": "Hamster", "Bird": "Finch", "Reptile": "Aligator"])
    }
    
    
    func testSequenceType() {
        func assertEqualToSequenceKeysAndValues(plist: Plist, keys: Set<String>, values: Set<String>) {
            var plistKeys = Set<String>()
            var plistValues = Set<String>()
            
            for (k, v) in plist {
                plistKeys.insert(k)
                plistValues.insert(v.string!)
            }
            
            XCTAssertTrue(keys == plistKeys && values == plistValues)
        }
        
        let array: Plist = ["Mammal", "Reptile", "Amphibian"]
        assertEqualToSequenceKeysAndValues(array, keys: ["0", "1", "2"], values: ["Mammal", "Reptile", "Amphibian"])
        
        let dict: Plist = ["Mammal": "Monkey", "Reptile": "Aligator", "Amphibian": "Salamander"]
        assertEqualToSequenceKeysAndValues(dict, keys: ["Mammal", "Reptile", "Amphibian"], values: ["Monkey", "Aligator", "Salamander"])
    }
    
    func testRawRepresentable() {
        // basic valid dictionary
        let validDict = ["Name": "Mark", "Age": 47]
        let validDictPlist = Plist(rawValue: validDict)
        
        XCTAssertTrue(validDictPlist != nil && validDictPlist! == ["Name": "Mark", "Age": 47] as Plist)
        
        // basic invalid dictionary
        let invalidDict = ["Name": "Mark", "Age": 47, "Phone": NSNull()]
        let invalidDictPlist = Plist(rawValue: invalidDict)
        
        XCTAssertTrue(invalidDictPlist == nil)
        
        // basic valid array
        let validArray = [1, 2, 3]
        let validArrayPlist = Plist(rawValue: validArray)
        
        XCTAssertTrue(validArrayPlist != nil && validArrayPlist! == [1, 2, 3] as Plist)
        
        // basic invalid array
        let invalidArray = [1, 2, 3, NSValue(rect: CGRect.zeroRect)]
        let invalidArrayPlist = Plist(rawValue: invalidArray)
        
        XCTAssertTrue(invalidArrayPlist == nil)
        
        // nested structures
        let nested = [
            "Name":     "Mark",
            "Age":      47,
            "Children": [
                [
                    "Name": "Nadia",
                    "Age": 16,
                ]
            ]
        ]
        
        let nestedPlist = Plist(rawValue: nested)
        XCTAssertTrue(nestedPlist?["Children"]?.count == 1)
        XCTAssertTrue(nestedPlist?["Children"]?[0]?["Name"]?.string == "Nadia")
        
        let rawNestedPlist = nestedPlist!.rawValue
        XCTAssertTrue(rawNestedPlist.isEqual(nested))
    }
    
    func testSerialization() {
        var errorCount = 0
        var samplePlists = [Plist]()
        
        samplePlists.append([
            "Name":     "Mark",
            "Age":      47,
            "Children": [
                [
                    "Name": "Nadia",
                    "Age": 16,
                ]
            ]
            ])
        samplePlists.append(12)
        samplePlists.append(Plist(rawValue: NSData())!)
        samplePlists.append(Plist(rawValue: NSDate())!)
        
        
        for plist in samplePlists {
            let serializedData: NSData
            
            do {
                serializedData = try Plist.dataWithPropertyList(plist)
            } catch let err {
                errorCount += 1
                print("caught error \(err)")
                
                continue
            }

            let unserializedPlist: Plist

            do {
                unserializedPlist = try Plist.propertyListWithData(serializedData)

                if (plist != unserializedPlist) {
                    errorCount += 1
                    print("serialization round trip modified plists: orig = \(plist), reconstituted = \(unserializedPlist)")
                }
            
            } catch let err {
                errorCount += 1
                print("caught error \(err)")
            }
            
        }
        
        XCTAssertTrue(errorCount == 0)
    }
}
