//
//  RawRoom.swift
//  CanvaiOSChallenge
//
//  Created by calvin on 17/3/2017.
//  Copyright © 2017年 me.calvinchankf. All rights reserved.
//

import Foundation

import SwiftyJSON

struct RawRoom {
    var id: String? // is it possible to have nil from data?
    var north: Direction?
    var east: Direction?
    var south: Direction?
    var west: Direction?
    var tileUrl: URL?
    var type: String?
    
    var x: Int = 0
    var y: Int = 0
    
    init(data: Data) {
        let json = JSON(data: data)
        
        if let roomId = json["id"].string {
            self.id = roomId
        }
        
        if let north = json["rooms"]["north"].dictionaryObject as? [String : String] {
            self.north = Direction(data: north)
        }
        
        if let east = json["rooms"]["east"].dictionaryObject as? [String : String] {
            self.east = Direction(data: east)
        }
        
        if let south = json["rooms"]["south"].dictionaryObject as? [String : String] {
            self.south = Direction(data: south)
        }
        
        if let west = json["rooms"]["west"].dictionaryObject as? [String : String] {
            self.west = Direction(data: west)
        }
        
        if let tileUrl = json["tileUrl"].string {
            self.tileUrl = URL(string: tileUrl)
        }
        
        if let type = json["type"].string {
            self.type = type
        }
    }
}

struct Direction {
    var room: String?
    var lock: String?
    
    init(data: [String : String]) {
        
        if let room = data["room"] {
            self.room = room
        }
        if let lock = data["lock"] {
            self.lock = lock
        }
    }
}
