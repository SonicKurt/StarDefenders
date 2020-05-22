/*
 Star Defenders
 PhysicsCategories.swift
 Created By: Kurt Campbell
 */

import SpriteKit
// Created physics categories structure to contain all sprites with a physics category
public struct PhysicsCategories: OptionSet {
    public let rawValue: UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    // Created physics categories for each sprite that contains a unique UInt32 raw value
    static let redAlien = PhysicsCategories(rawValue: 0b0001)
    static let blueAlien = PhysicsCategories(rawValue: 0b0010)
    static let bullet = PhysicsCategories(rawValue: 0b0100)
    static let player = PhysicsCategories(rawValue: 0b1000)
}
// Created extension for category within PhysicsCategories
public extension SKPhysicsBody {
    var category: PhysicsCategories {
        get {
            // Gets PhysicsCategories and returns raw value as a categoryBitMask for each sprite
            return PhysicsCategories(rawValue: self.categoryBitMask) 
        }
        set(newValue) {
            // Sets categoryBitMask raw value to a new value
            self.categoryBitMask = newValue.rawValue
        }
    }
}

