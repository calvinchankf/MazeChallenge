//
//  MazeModel.swift
//  CanvaiOSChallenge
//
//  Created by calvin on 17/3/2017.
//  Copyright © 2017年 me.calvinchankf. All rights reserved.
//

import Foundation

class MazeModel {
    
    let mazeManager = MazeManager()
    
    var coordinates = [String: RawRoom]()
    
    // since the dfs is async, i need a dispatchGroup to get notofied after all calls are completed
    var myGroup: DispatchGroup?
    
    private(set) var isGenerating = false
    
    init() {
        
    }
    
    // methods
    
    func generate(complete:@escaping (_ data: [[Room]]) -> ()) {
        
        print("start generate")
        
        self.coordinates = [String: RawRoom]()
        
        let startTime = Date().timeIntervalSince1970
        self.myGroup = DispatchGroup()
        myGroup?.enter()
        
        self.isGenerating = true
        
        mazeManager.fetchStartRoom { [weak self] (data: Data?, error: Error?) in
            
            if let error = error {
                print("fetchStartRoom error \(error)")
                return
            }
            
            guard let data = data else {
                print("no data")
                return
            }
            
            guard let firstRoomId = RawRoom(data: data).id else {
                print("fetch first room error")
                return
            }
            
            self?.fetchRoom(identifier: firstRoomId, complete: { [weak self] (error: Error?, room: RawRoom?) in
                
                // i really suggest use Promise if i can use more dependencies
                
                if let error = error {
                    print("fetch room error \(error)")
                    return
                }
                
                guard let room = room else {
                    print("no such room by id")
                    return
                }
                self?.dfs(room)
                self?.myGroup?.leave()
            })
        }
        
        self.myGroup?.notify(queue: .main) { [weak self] in
            
            guard let weakSelf = self else {
                return // the whole mazeModel has been deinit-ed, no need to callback
            }
            
            let duration = Date().timeIntervalSince1970 - startTime
            let result = MazeModel.convertCoordinatesToArray(coors: weakSelf.coordinates)
//            weakSelf.printRooms(rooms: result)
            print("Finished all requests \(weakSelf.coordinates.count) in \(duration) sec")
            weakSelf.isGenerating = false
            complete(result)
        }
    }
    
    func fetchRoom(identifier: String, complete:@escaping (_ error: Error?, _ room : RawRoom?) -> ()) {
        mazeManager.fetchRoom(withIdentifier: identifier) { (data: Data?, error: Error?) in
            if let error = error {
                print("fetchRoom error \(error)")
                complete(error, nil)
            } else if let data = data {
                let room = RawRoom(data: data)
                complete(nil, room)
            }
        }
    }
    
    func unlockRoom(lock: String) -> String {
        return mazeManager.unlockRoom(withLock: lock)
    }
    
    // if room is locked, unlock it
    // if not return a room directly
    func giveMeARoomNoMatterHow(dir: Direction, x: Int, y: Int,
                                complete:@escaping (_ room: RawRoom) -> ()) {
        
        if !self.isGenerating { return }
        
        self.myGroup?.enter()
        // to reduce complexity
        // since there must be a room or a lock to a room
        // i am simply not using complete(nil) with complete:@escaping (_ room: RawRoom?)
        var key = dir.room
        if let lock = dir.lock {
            key = self.unlockRoom(lock: lock)
        }
        if let finalKey = key {
            self.fetchRoom(identifier: finalKey, complete: { [weak self] (error, room) in
                if let room = room {
                    // copy and mutate
                    // make used of swift 'copy on write'
                    var newRoom = room
                    newRoom.x = x
                    newRoom.y = y
                    complete(newRoom)
                    self?.myGroup?.leave()
                }
            })
        }
    }
    
    // Depth First Search, recursive and async
    // Hash table is used to avoid 2nd visit on each node
    // Time Complexity: O(n), n is the number of nodes
    // Space Complexity: O(n), a hash table of nodes is used
    func dfs(_ node: RawRoom?) {
        
        guard let node = node else { return }
        
        let hash = "\(node.x),\(node.y)"
        if self.coordinates[hash] != nil {
            // visited
//            print("\(hash) visited")
        } else{
            self.coordinates[hash] = node
            if let north = node.north {
                self.giveMeARoomNoMatterHow(dir: north, x: node.x, y: node.y + 1, complete: { (room) in
                    self.dfs(room)
                })
            }
            
            if let east = node.east {
                self.giveMeARoomNoMatterHow(dir: east, x: node.x + 1, y: node.y, complete: { (room) in
                    self.dfs(room)
                })
            }
            
            if let south = node.south {
                self.giveMeARoomNoMatterHow(dir: south, x: node.x, y: node.y - 1, complete: { (room) in
                    self.dfs(room)
                })
            }
            
            if let west = node.west {
                self.giveMeARoomNoMatterHow(dir: west, x: node.x - 1, y: node.y, complete: { (room) in
                    self.dfs(room)
                })
            }
        }
    }
    
    func stopGenerate() {
        print("stopGenerate")
        self.isGenerating = false
        self.myGroup?.wait()
        self.coordinates.removeAll()
    }
    
    // Time Complexity: O(n)
    // Space Complexity: O(1), only 6 variables are used except the result
    // pure function: input -> output only, avoid side effects so static function is used
    static func convertCoordinatesToArray(coors: [String: RawRoom]) -> [[Room]] {
        
        var minX = Int.max
        var maxX = Int.min
        var minY = Int.max
        var maxY = Int.min
        
        // O(N1), N1 is number of rooms
        for (_, room) in coors {
            minX = min(minX, room.x)
            maxX = max(maxX, room.x)
            minY = min(minY, room.y)
            maxY = max(maxY, room.y)
        }
        
        let width = maxX - minX + 1 // e.g. -2 -1 0 1 2 3 -> 6
        let height = maxY - minY + 1
        
        var result = [[Room]]()
        
        // O(N2), N2 = width * height of the result array
        for i in 0..<height {
            var row = [Room]()
            for j in 0..<width {
                let hash = "\(j + minX),\(i + minY)"
                if let existedRoom = coors[hash] {
                    row.append(Room(imageURL: existedRoom.tileUrl))
                } else {
                    row.append(Room(imageURL: nil))
                }
            }
            result.append(row)
        }
        
        return result
    }
    
    // debug
    static func printRooms(rooms: [[Room]]) {
        for i in 0..<rooms.count {
            var row = ""
            for j in 0..<rooms[0].count {
                if let _ = rooms[i][j].imageURL {
                    row += "⬜️"
                } else {
                    row += "⬛"
                }
            }
            print(row)
        }
    }
}
