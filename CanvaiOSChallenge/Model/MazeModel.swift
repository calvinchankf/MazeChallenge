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
    
    let mazeQueue = DispatchQueue(label: "maze.queue", qos: .userInitiated) // userInitiated: highest priority 
    // since the dfs is async, i need a dispatchGroup to get notofied after all calls are completed
//    var myGroup: DispatchGroup?
    var myGroup = DispatchGroup()
    
    private(set) var isGenerating = false
    
    var generatedComplete: ((_ data: [[Room]]?, _ error: Error?)  -> ())?
    
    init() {
        
    }
    
    // methods
    
    func generate() {
        
        print("start generate")
        
        self.coordinates = [String: RawRoom]()
        
        let startTime = Date().timeIntervalSince1970
//        self.myGroup = DispatchGroup()
        myGroup.enter()
        
        self.isGenerating = true
        
        self.mazeQueue.async {
            
            self.mazeManager.fetchStartRoom { [weak self] (data: Data?, error: Error?) in
                
                if let error = error {
                    print("fetchStartRoom error \(error)")
                    self?.generateError(error: error)
                    return
                }
                
                guard let data = data else {
                    print("no data")
                    self?.generateError(error: NSError(domain:"", code:0, userInfo:nil))
                    return
                }
                
                guard let firstRoomId = RawRoom(data: data).id else {
                    print("fetch first room error")
                    self?.generateError(error: NSError(domain:"", code:0, userInfo:nil))
                    return
                }
                
                self?.fetchRoom(identifier: firstRoomId, complete: { [weak self] (room: RawRoom) in
                    
                    // i suggest use Promise if i can use more dependencies
                    self?.dfs(room)
                    self?.myGroup.leave()
                })
            }
        }
        
        self.myGroup.notify(queue: .main) { [weak self] in
            
            guard let weakSelf = self else {
                return // if self is nil, the whole mazeModel has been deinit-ed, no need to callback
            }
            
            let duration = Date().timeIntervalSince1970 - startTime
            let result = MazeModel.convertCoordinatesToArray(coors: weakSelf.coordinates)
//            weakSelf.printRooms(rooms: result)
            print("Finished all requests \(weakSelf.coordinates.count) in \(duration) sec")
            weakSelf.isGenerating = false
//            complete(result)
            weakSelf.generatedComplete?(result, nil)
        }
    }
    
    // if error, call generateComplete error directly
    func fetchRoom(identifier: String, complete:@escaping (_ room : RawRoom) -> ()) {
        mazeManager.fetchRoom(withIdentifier: identifier) { [weak self] (data: Data?, error: Error?) in
            if let error = error {
                print("fetchRoom error \(error)")
                self?.generateError(error: error)
            } else if let data = data {
                let room = RawRoom(data: data)
                complete(room)
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
        
        self.myGroup.enter()
        
        var key = dir.room
        if let lock = dir.lock {
            key = self.unlockRoom(lock: lock)
        }
        if let finalKey = key {
            self.fetchRoom(identifier: finalKey, complete: { [weak self] (room) in
                var newRoom = room
                newRoom.x = x
                newRoom.y = y
                complete(newRoom)
                self?.myGroup.leave()
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
//        self.myGroup?.wait()
        self.coordinates.removeAll()
    }
    
    func generateError(error: Error) {
        self.isGenerating = false
        self.generatedComplete?(nil, error)
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
