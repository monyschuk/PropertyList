# PropertyList
Create and access property lists using Swift.

The Plist enumeration wraps valid property list types and provides creation and query APIs similar to those provided by the popular JSON serialization library SwiftyJSON. Plist is written using Swift 2.0 syntax and requires Xcode 7.0 or later to build.

See PropertyListTests.swift for sample usage including property list creation, queries and modification.

PropertyList is MIT licensed.

# Recent Changes
  - 2015/11/15: Plist is no longer a class, it's now an enum.

# TODO
  - Add simplified initializers for Swift Bool, Float, Double types since init(number:) is ugly in Swift code.
