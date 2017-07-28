//
//  tcl-object.swift
//  tcl-swift-bridge
//
//  Created by Peter da Silva on 5/17/16.
//  Copyright © 2016 FlightAware. All rights reserved.
//
// Free under the Berkeley license.
//

import Foundation
import Tcl8_6


// TclObj - Tcl object class

public class TclObj: Sequence {
    let obj: UnsafeMutablePointer<Tcl_Obj>
    let Interp: TclInterp
    let interp: UnsafeMutablePointer<Tcl_Interp>
    
    // various initializers to create a Tcl object from nothing, an int,
    // double, string, Tcl_Obj *, etc
    
    // init - Initialize from a Tcl_Obj *
    init(_ val: UnsafeMutablePointer<Tcl_Obj>, Interp: TclInterp) {
        self.Interp = Interp; self.interp = Interp.interp
        obj = val
        IncrRefCount(val)
    }
    
    // init - initialize from nothing, get an empty Tcl object
    public convenience init(Interp: TclInterp) {
        self.init(Tcl_NewObj(), Interp: Interp)
    }
    
    // init - initialize from a Swift Int
    public convenience init(_ val: Int, Interp: TclInterp) {
        self.init(Interp: Interp)
        self.set(val);
    }
    
    // init - initialize from a Swift String
    public convenience init(_ val: String, Interp: TclInterp) {
        self.init(Interp: Interp)
        self.set(val);
    }
    
    // init - initialize from a Swift Double
    public convenience init(_ val: Double, Interp: TclInterp) {
        self.init(Interp: Interp)
        self.set(val);
    }
    
    // init - initialize from a Swift Bool
    public convenience init(_ val: Bool, Interp: TclInterp) {
        self.init(Interp: Interp)
        self.set(val);
    }
    
    // init - init from a set of Strings to a list
    public convenience init(_ set: Set<String>, Interp: TclInterp) {
        self.init(Interp: Interp)
        self.set(set)
    }
    
    public func set(_ set: Set<String>) {
        for element in set {
            Tcl_ListObjAppendElement (interp, obj, Tcl_NewStringObj (element, -1))
        }
    }
    
    // init from a set of Ints to a list
    public convenience init(_ set: Set<Int>, Interp: TclInterp) {
        self.init(Interp: Interp)
        self.set(set)
    }
    
    public func set(_ set: Set<Int>) {
        for element in set {
            Tcl_ListObjAppendElement (interp, obj, Tcl_NewLongObj (element))
        }
    }
    
    // init from a Set of doubles to a list
    public convenience init(_ set: Set<Double>, Interp: TclInterp) {
        self.init(Interp: Interp)
        self.set(set)
    }
    
    public func set(_ set: Set<Double>) {
        for element in set {
            Tcl_ListObjAppendElement (interp, obj, Tcl_NewDoubleObj (element))
        }
    }
    
    // init from an Array of Strings to a Tcl list
    public convenience init(_ array: [String], Interp: TclInterp) {
        self.init(Interp: Interp)
        self.set(array)
    }
    
    public func set(_ array: [String]) {
        for element in array {
            Tcl_ListObjAppendElement (interp, obj, Tcl_NewStringObj (element, -1))
        }
    }
    
    // Init from an Array of Int to a Tcl list
    public convenience init (_ array: [Int], Interp: TclInterp) {
        self.init(Interp: Interp)
        self.set(array)
    }
    
    public func set(_ array: [Int]) {
        for element in array {
            Tcl_ListObjAppendElement (interp, obj, Tcl_NewLongObj(element))
        }
    }
    
    // Init from an Array of Double to a Tcl list
    public convenience init (_ array: [Double], Interp: TclInterp) {
        self.init(Interp: Interp)
        self.set(array)
    }
    
    public func set(_ array: [Double]) {
        for element in array {
            Tcl_ListObjAppendElement(interp, obj, Tcl_NewDoubleObj(element))
        }
    }
    
    // init from a String/String dictionary to a list
    public convenience init (_ dictionary: [String: String], Interp: TclInterp) {
        self.init(Interp: Interp)
        self.set(dictionary)
    }
    
    public func set(_ dictionary: [String: String]) {
        for (key, val) in dictionary {
            Tcl_ListObjAppendElement (interp, obj, Tcl_NewStringObj (key, -1))
            Tcl_ListObjAppendElement (interp, obj, Tcl_NewStringObj (val, -1))
        }
    }
    
    // init from a String/Int dictionary to a list
    public convenience init (_ dictionary: [String: Int], Interp: TclInterp) {
        self.init(Interp: Interp)
        self.set(dictionary)
    }

    public func set(_ dictionary: [String: Int]) {
        for (key, val) in dictionary {
            Tcl_ListObjAppendElement (interp, obj, Tcl_NewStringObj (key, -1))
            Tcl_ListObjAppendElement (interp, obj, Tcl_NewLongObj (val))
        }
    }
    
    // init from a String/Double dictionary to a list
    public convenience init (_ dictionary: [String: Double], Interp: TclInterp) {
        self.init(Interp: Interp)
        self.set(dictionary)
    }
    
    public func set(_ dictionary: [String: Double]) {
        for (key, val) in dictionary {
            Tcl_ListObjAppendElement (interp, obj, Tcl_NewStringObj (key, -1))
            Tcl_ListObjAppendElement (interp, obj, Tcl_NewDoubleObj (val))
        }
    }
    
    // deinit - decrement the object's reference count.  if it goes below one
    // the object will be freed.  if not then something else has it and it will
    // be freed after the last use
    deinit {
        DecrRefCount(obj)
    }
    
    // various set functions to set the Tcl object from a string, Int, Double, etc
    public var stringValue: String? {
        get {
            return try? get()
        }
        set {
            guard let val = newValue else {return}
            set(val)
        }
    }
    
    public func get() throws -> String {
        return try tclobjp_to_String(obj)
    }
    
    public func set(_ value: String) {
        Tcl_SetStringObj (obj, value, -1)
    }
    
    // getInt - return the Tcl object as an Int or nil
    // if in-object Tcl type conversion fails
    public var intValue: Int? {
        get {
            return try? get()
        }
        set {
            guard let val = newValue else {return}
            set(val)
        }
    }

    public func get() throws -> Int {
        return try tclobjp_to_Int(obj)
    }

    public func set(_ val: Int) {
        Tcl_SetLongObj (obj, val)
    }

    // getDouble - return the Tcl object as a Double or nil
    // if in-object Tcl type conversion fails
    public var doubleValue: Double? {
        get {
            return try? get()
        }
        set {
            guard let val = newValue else {return}
            set(val)
        }
    }
    
    public func get() throws -> Double {
        return try tclobjp_to_Double(obj)
    }
    
    public func set(_ val: Double) {
        Tcl_SetDoubleObj (obj, val)
    }
    
    // getBool - return the Tcl object as a Bool or nil
    public var boolValue: Bool? {
        get {
            return try? get()
        }
        set {
            guard let val = newValue else {return}
            set(val)
        }
    }

    public func get() throws -> Bool {
        return try tclobjp_to_Bool(obj)
    }

    public func set(_ val: Bool) {
        Tcl_SetBooleanObj (obj, val ? 1 : 0)
    }

    // getObj - return the Tcl object pointer (Tcl_Obj *)
    public func get() -> UnsafeMutablePointer<Tcl_Obj> {
        return obj
    }
    
    public func getAsArg(named varName: String) throws -> Int {
        do {
            return try tclobjp_to_Int(obj, interp: interp)
        } catch {
            Interp.addErrorInfo(" while converting \"\(varName)\" argument")
            throw TclError.error
        }
    }
    
    public func getAsArg(named varName: String) throws -> Double {
        do {
            return try tclobjp_to_Double(obj, interp: interp)
        } catch {
            Interp.addErrorInfo(" while converting \"\(varName)\" argument")
            throw TclError.error
        }
    }
    
    public func getAsArg(named varName: String) throws -> Bool {
        do {
            return try tclobjp_to_Bool(obj, interp: interp)
        } catch {
            Interp.addErrorInfo(" while converting \"\(varName)\" argument")
            throw TclError.error
        }
    }
    
    public func getAsArg(named varName: String) throws -> String {
        do {
            return try tclobjp_to_String(obj)
        } catch {
            Interp.addErrorInfo(" while converting \"\(varName)\" argument")
            throw TclError.error
        }
    }

    // lappend - append a Tcl_Obj * to the Tcl object list
    func lappend (_ value: UnsafeMutablePointer<Tcl_Obj>) throws {
        guard (Tcl_ListObjAppendElement (interp, obj, value) != TCL_ERROR) else {throw TclError.error}
    }
    
    // lappend - append an Int to the Tcl object list
    public func lappend (_ value: Int) throws {
        try self.lappend (Tcl_NewLongObj (value))
    }
    
    // lappend - append a Double to the Tcl object list
    public func lappend (_ value: Double) throws {
        try self.lappend (Tcl_NewDoubleObj (value))
    }
    
    // lappend - append a String to the Tcl object list
    public func lappend (_ value: String) throws {
        try self.lappend(Tcl_NewStringObj (value, -1))
    }
    
    // lappend - append a Bool to the Tcl object list
    public func lappend (_ value: Bool) throws {
        try self.lappend (Tcl_NewBooleanObj (value ? 1 : 0))
    }
    
    // lappend - append a tclObj to the Tcl object list
    public func lappend (_ value: TclObj) throws {
        try self.lappend(value)
    }
    
    // lappend - append an array of Int to the Tcl object list
    // (flattens them out)
    public func lappend (_ array: [Int]) throws {
        for element in array {
            try self.lappend(element)
        }
    }
    
    // lappend - append an array of Double to the Tcl object list
    // (flattens them out)
    public func lappend (_ array: [Double]) throws {
        for element in array {
            try self.lappend(element)
        }
    }
    
    // lappend - append an array of String to the Tcl object list
    // (flattens them out)
    public func lappend (_ array: [String]) throws {
        for element in array {
            try self.lappend(element)
        }
    }
    
    // llength - return the number of elements in the list if the contents of our obj can be interpreted as a list
    public func llength () throws -> Int {
        var count: Int32 = 0
        if (Tcl_ListObjLength(interp, obj, &count) == TCL_ERROR) {
            throw TclError.error
        }
        return Int(count)
    }
    
    // lindex - return the nth element treating obj as a list, if possible, and return a Tcl_Obj *
    func lindex (_ index: Int) throws -> UnsafeMutablePointer<Tcl_Obj>? {
        var tmpObj: UnsafeMutablePointer<Tcl_Obj>? = nil
        var index = index;
        if(index < 0) {
            if let count = try? self.llength() {
                index += count
            }
        }
        if Tcl_ListObjIndex(interp, obj, Int32(index), &tmpObj) == TCL_ERROR {
            throw TclError.error
        }
        return tmpObj
    }
    
    // lindex returning a TclObj object or nil
    public func lindex (_ index: Int) throws -> TclObj? {
        let tmpObj: UnsafeMutablePointer<Tcl_Obj>? = try self.lindex(index)
        return TclObj(tmpObj!, Interp: Interp)
    }
    
    // lindex returning an Int or nil
    public func lindex (_ index: Int) throws -> Int {
        let tmpObj: UnsafeMutablePointer<Tcl_Obj>? = try self.lindex(index)
        
        return try tclobjp_to_Int(tmpObj, interp: interp)
    }
    
    // lindex returning a Double or nil
    public func lindex (_ index: Int) throws -> Double {
        let tmpObj: UnsafeMutablePointer<Tcl_Obj>? = try self.lindex(index)
        
        return try tclobjp_to_Double(tmpObj, interp: interp)
    }
    
    // lindex returning a String or nil
    public func lindex (_ index: Int) throws -> String {
        let tmpObj: UnsafeMutablePointer<Tcl_Obj>? = try self.lindex(index)
        
        return try tclobjp_to_String(tmpObj)
    }
    
    // lindex returning a Bool or nil
    public func lindex (_ index: Int) throws -> Bool {
        let tmpObj: UnsafeMutablePointer<Tcl_Obj>? = try self.lindex(index)
        
        return try tclobjp_to_Bool(tmpObj, interp: interp)
    }
    
    // toDictionary - copy the tcl object as a list into a String/TclObj dictionary
    public func get() throws -> [String: TclObj] {
        var dictionary: [String: TclObj] = [:]
        
        var objc: Int32 = 0
        var objv: UnsafeMutablePointer<UnsafeMutablePointer<Tcl_Obj>?>? = nil
        
        if Tcl_ListObjGetElements(interp, obj, &objc, &objv) == TCL_ERROR {throw TclError.error}
        
        for i in stride(from: 0, to: Int(objc)-1, by: 2) {
            let keyString = try tclobjp_to_String(objv![i])
            dictionary[keyString] = TclObj(objv![i+1]!, Interp: Interp)
        }
        return dictionary
    }
    
    // toArray - create a String array from the tcl object as a list
    public func get() throws -> [String] {
        var array: [String] = []
        
        var objc: Int32 = 0
        var objv: UnsafeMutablePointer<UnsafeMutablePointer<Tcl_Obj>?>? = nil
        
        if Tcl_ListObjGetElements(interp, obj, &objc, &objv) == TCL_ERROR {throw TclError.error}
        
        for i in 0..<Int(objc) {
            try array.append(tclobjp_to_String(objv![i]))
        }
        
        return array
    }
    
    // toArray - create an Int array from the tcl object as a list
    public func get() throws -> [Int] {
        var array: [Int] = []
        
        var objc: Int32 = 0
        var objv: UnsafeMutablePointer<UnsafeMutablePointer<Tcl_Obj>?>? = nil
        
        if Tcl_ListObjGetElements(interp, obj, &objc, &objv) == TCL_ERROR {throw TclError.error}
        
        for i in 0..<Int(objc) {
            let longVal = try tclobjp_to_Int(objv![i], interp: interp)
            array.append(longVal)
        }
        
        return array
    }
    
    // toArray - create a Double array from the tcl object as a list
    public func get() throws ->  [Double] {
        var array: [Double] = []
        
        var objc: Int32 = 0
        var objv: UnsafeMutablePointer<UnsafeMutablePointer<Tcl_Obj>?>? = nil
        
        if Tcl_ListObjGetElements(interp, obj, &objc, &objv) == TCL_ERROR {throw TclError.error}
        
        for i in 0..<Int(objc) {
            let doubleVal = try tclobjp_to_Double(objv![i], interp: interp)
            array.append(doubleVal)
            
        }
        
        return array
    }
    
    // toArray - create a TclObj array from the tcl object as a list,
    // each element becomes its own TclObj
    
    public func get() throws -> [TclObj] {
        var array: [TclObj] = []
        
        var objc: Int32 = 0
        var objv: UnsafeMutablePointer<UnsafeMutablePointer<Tcl_Obj>?>? = nil
        
        if Tcl_ListObjGetElements(interp, obj, &objc, &objv) == TCL_ERROR {throw TclError.error}
        
        for i in 0..<Int(objc) {
            array.append(TclObj((objv?[i])!, Interp: Interp))
        }
        
        return array
    }
    
    // Utility function for lrange
    private func normalize_range(_ first: Int, _ last: Int, _ count: Int) -> ( Int, Int) {
        var start: Int = first
        var end: Int = last
        
        if start < 0 { start = Swift.max(0, count + start) }
        else if start >= count { start = count - 1 }
        
        if end < 0 { end = Swift.max(0, count + end) }
        else if end >= count { end = count  - 1}
        
        if end < start { end = start }
        
        return (start, end)
    }
    
    // lrange returning a TclObj array
    public func lrange (_ range: CountableClosedRange<Int>) throws -> [TclObj] {
        var array: [TclObj] = []
        
        var objc: Int32 = 0
        var objv: UnsafeMutablePointer<UnsafeMutablePointer<Tcl_Obj>?>? = nil
        
        if Tcl_ListObjGetElements(interp, obj, &objc, &objv) == TCL_ERROR {throw TclError.error}
        
        let (start, end) = normalize_range(range.lowerBound, range.upperBound-1, Int(objc))
        
        for i in start...end {
            array.append(TclObj((objv?[i])!, Interp: Interp))
        }
        
        return array
    }
    
    // lrange returning a string array
    public func lrange (_ range: CountableClosedRange<Int>) throws -> [String] {
        var array: [String] = []
        
        var objc: Int32 = 0
        var objv: UnsafeMutablePointer<UnsafeMutablePointer<Tcl_Obj>?>? = nil
        
        if Tcl_ListObjGetElements(interp, obj, &objc, &objv) == TCL_ERROR {throw TclError.error}
        
        let (start, end) = normalize_range(range.lowerBound, range.upperBound-1, Int(objc))
        
        for i in start...end {
            try array.append(tclobjp_to_String(objv![i]))
        }
        
        return array
    }
    
    // lrange returning an integer array
    public func lrange (_ range: CountableClosedRange<Int>) throws -> [Int] {
        var array: [Int] = []
        
        var objc: Int32 = 0
        var objv: UnsafeMutablePointer<UnsafeMutablePointer<Tcl_Obj>?>? = nil
        
        if Tcl_ListObjGetElements(interp, obj, &objc, &objv) == TCL_ERROR {throw TclError.error}
        
        let (start, end) = normalize_range(range.lowerBound, range.upperBound - 1, Int(objc))
        
        for i in start...end {
            let longVal = try tclobjp_to_Int(objv![i], interp: interp)
            array.append(longVal)
        }
        
        return array
    }
    
    // lrange returning a float array
    public func lrange (_ range: CountableClosedRange<Int>) throws -> [Double] {
        var array: [Double] = []
        
        var objc: Int32 = 0
        var objv: UnsafeMutablePointer<UnsafeMutablePointer<Tcl_Obj>?>? = nil
        
        if Tcl_ListObjGetElements(interp, obj, &objc, &objv) == TCL_ERROR {throw TclError.error}
        
        let (start, end) = normalize_range(range.lowerBound, range.upperBound - 1, Int(objc))
        
        for i in start...end {
            let doubleVal = try tclobjp_to_Double(objv![i], interp: interp)
            array.append(doubleVal)
        }
    
        return array
    }
    
    // lrange returning a boolean array
    public func lrange (_ range: CountableClosedRange<Int>) throws -> [Bool] {
        var array: [Bool] = []
        
        var objc: Int32 = 0
        var objv: UnsafeMutablePointer<UnsafeMutablePointer<Tcl_Obj>?>? = nil
        
        if Tcl_ListObjGetElements(interp, obj, &objc, &objv) == TCL_ERROR {throw TclError.error}
        
        let (start, end) = normalize_range(range.lowerBound, range.upperBound-1, Int(objc))
        
        for i in start...end {
            let boolVal = try tclobjp_to_Bool(objv![i], interp: interp)
            array.append(boolVal)
        }
        
        return array
    }

    // get - copy the tcl object as a list into a String/String dictionary
    public func get() throws -> [String: String] {
        var dictionary: [String: String] = [:]
        
        var objc: Int32 = 0
        var objv: UnsafeMutablePointer<UnsafeMutablePointer<Tcl_Obj>?>? = nil
        
        if Tcl_ListObjGetElements(interp, obj, &objc, &objv) == TCL_ERROR {throw TclError.error}
        
        for i in stride(from: 0, to: Int(objc-1), by: 2) {
            let keyString = try tclobjp_to_String(objv![i])
            let valueString = try tclobjp_to_String(objv![i+1])
            
            dictionary[keyString] = valueString
        }
        return dictionary
    }
    
    // get - copy the tcl object as a list into a String/Int dictionary
    public func get() throws -> [String: Int] {
        var dictionary: [String: Int] = [:]
        
        var objc: Int32 = 0
        var objv: UnsafeMutablePointer<UnsafeMutablePointer<Tcl_Obj>?>? = nil
        
        if Tcl_ListObjGetElements(interp, obj, &objc, &objv) == TCL_ERROR {throw TclError.error}
        
        for i in stride(from: 0, to: Int(objc-1), by: 2) {
            let keyString = try tclobjp_to_String(objv![i])
            let val = try tclobjp_to_Int(objv![i+1])
            dictionary[keyString] = val
        }
        return dictionary
    }
    
    // get - copy the tcl object as a list into a String/Double dictionary
    public func get() throws -> [String: Double] {
        var dictionary: [String: Double] = [:]
        
        var objc: Int32 = 0
        var objv: UnsafeMutablePointer<UnsafeMutablePointer<Tcl_Obj>?>? = nil
        
        if Tcl_ListObjGetElements(interp, obj, &objc, &objv) == TCL_ERROR {throw TclError.error}
        
        for i in stride(from: 0, to: Int(objc-1), by: 2) {
            let keyString = try tclobjp_to_String(objv![i])
            let val = try tclobjp_to_Double(objv![i+1])
            
            dictionary[keyString] = val
        }
        return dictionary
    }
    
    public subscript(index: Int) -> TclObj? {
        get {
            if let result : TclObj? = try? self.lindex(index) {
                return result
            } else {
                return nil
            }
        }
        set {
            var list: [TclObj]
            if let value = newValue {
                list = [value]
            } else {
                list = []
            }
            do { try lreplace(index...index, list: list) } catch { }
        }
    }
    
    public subscript(range: CountableClosedRange<Int>) -> [TclObj]? {
        get {
            if let result : [TclObj] = try? self.lrange(range) {
                return result
            } else {
                return nil
            }
        }
        set {
            var list: [TclObj]
            if let value = newValue {
                list = value
            } else {
                list = []
            }
            do { try lreplace(range, list: list) } catch { }
        }
    }
    
    public subscript(index: Int) -> String? {
        get {
            if let result : String = try? self.lindex(index) {
                return result
            } else {
                return nil
            }
        }
        set {
            var list: [String]
            if let value = newValue {
                list = [value]
            } else {
                list = []
            }
            do { try lreplace(index...index, list: list) } catch { }
        }
    }
  
    public subscript(range: CountableClosedRange<Int>) -> [String]? {
        get {
            if let result : [String] = try? self.lrange(range) {
                return result
            } else {
                return nil
            }
        }
        set {
            var list: [String]
            if let value = newValue {
                list = value
            } else {
                list = []
            }
            do { try lreplace(range, list: list) } catch { }
        }
    }
    
    public subscript(index: Int) -> Double? {
        get {
            if let result : Double = try? self.lindex(index) {
                return result
            } else {
                return nil
            }
        }
        set {
            var list: [Double]
            if let value = newValue {
                list = [value]
            } else {
                list = []
            }
            do { try lreplace(index...index, list: list) } catch { }
        }
    }
    
    public subscript(range: CountableClosedRange<Int>) -> [Double]? {
        get {
            if let result : [Double] = try? self.lrange(range) {
                return result
            } else {
                return nil
            }
        }
        set {
            var list: [Double]
            if let value = newValue {
                list = value
            } else {
                list = []
            }
            do { try lreplace(range, list: list) } catch { }
        }
    }
    
    public subscript(index: Int) -> Int? {
        get {
            if let result : Int = try? self.lindex(index) {
                return result
            } else {
                return nil
            }
        }
        set {
            var list: [Int]
            if let value = newValue {
                list = [value]
            } else {
                list = []
            }
            do { try lreplace(index...index, list: list) } catch { }
        }
    }
    
    public subscript(range: CountableClosedRange<Int>) -> [Int]? {
        get {
            if let result : [Int] = try? self.lrange(range) {
                return result
            } else {
                return nil
            }
        }
        set {
            var list: [Int]
            if let value = newValue {
                list = value
            } else {
                list = []
            }
            do { try lreplace(range, list: list) } catch { }
        }
    }

    public subscript(index: Int) -> Bool? {
        get {
            if let result : Bool = try? self.lindex(index) {
                return result
            } else {
                return nil
            }
        }
        set {
            var list: [Bool]
            if let value = newValue {
                list = [value]
            } else {
                list = []
            }
            do { try lreplace(index...index, list: list) } catch { }
        }
    }
    
    public subscript(range: CountableClosedRange<Int>) -> [Bool]? {
        get {
            if let result : [Bool] = try? self.lrange(range) {
                return result
            } else {
                return nil
            }
        }
        set {
            var list: [Bool]
            if let value = newValue {
                list = value
            } else {
                list = []
            }
            do { try lreplace(range, list: list) } catch { }
        }
    }
    
    // lreplace(range, list) and variants
    func lreplace (_ range: CountableClosedRange<Int>, objv: [UnsafeMutablePointer<Tcl_Obj>?]) throws {
        guard (Tcl_ListObjReplace (interp, obj, Int32(range.lowerBound), Int32(range.upperBound-range.lowerBound), Int32(objv.count), objv) != TCL_ERROR) else { throw TclError.error }
    }
    
    public func lreplace (_ range: CountableClosedRange<Int>, list: [TclObj]) throws {
        try self.lreplace(range, objv: list.map { $0.obj })
    }
    
    // IMPORTANT NOTE
    // Orginally used self.lreplace(range, objv: list.map { TclObj($0, Interp: Interp).obj } )
    // This allocated and deallocated the TclObj for each step of the map, so passing freed memory to Tcl_ListObjReplace above
    // Creating a [ TclObj ] meant that none of the TclObjs are deallocated until lreplace returns.
    public func lreplace (_ range: CountableClosedRange<Int>, list: [String]) throws {
        try self.lreplace(range, list: list.map { TclObj($0, Interp: Interp) })
    }
    
    public func lreplace (_ range: CountableClosedRange<Int>, list: [Int]) throws {
        try self.lreplace(range, list: list.map { TclObj($0, Interp: Interp) })
    }
    
    public func lreplace (_ range: CountableClosedRange<Int>, list: [Double]) throws {
        try self.lreplace(range, list: list.map { TclObj($0, Interp: Interp) })
    }
    
    public func lreplace (_ range: CountableClosedRange<Int>, list: [Bool]) throws {
        try self.lreplace(range, list: list.map { TclObj($0, Interp: Interp) })
    }
    
    func linsert (_ index: Int, objv: [UnsafeMutablePointer<Tcl_Obj>?]) throws {
        guard (Tcl_ListObjReplace (interp, obj, Int32(index), Int32(0), Int32(objv.count), objv) != TCL_ERROR) else {throw TclError.error}
    }
    
    public func linsert (_ index: Int, list: [TclObj]) throws {
        try self.linsert(index, objv: list.map { $0.obj })
    }
    
    public func linsert (_ index: Int, list: [String]) throws {
        try self.linsert(index, list: list.map { TclObj($0, Interp: Interp) })
    }
    
    public func linsert (_ index: Int, list: [Int]) throws {
        try self.linsert(index, list: list.map { TclObj($0, Interp: Interp) })
    }
    
    public func linsert (_ index: Int, list: [Double]) throws {
        try self.linsert(index, list: list.map { TclObj($0, Interp: Interp) })
    }
    
    public func linsert (_ index: Int, list: [Bool]) throws {
        try self.linsert(index, list: list.map { TclObj($0, Interp: Interp) })
    }
    
    public func makeIterator() -> AnyIterator<TclObj> {
        var next = 0
        return AnyIterator<TclObj> {
            guard let length = try? self.llength() else {
                return nil
            }
            if next >= length {
                return nil
            }
            guard let element: TclObj? = try? self.lindex(next) else {
                return nil
            }
            next += 1
            return element;
        }
    }
}
