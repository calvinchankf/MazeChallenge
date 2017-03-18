//
//  CanvaiOSChallengeTests.swift
//  CanvaiOSChallengeTests
//
//  Created by calvin on 17/3/2017.
//  Copyright © 2017年 me.calvinchankf. All rights reserved.
//

import XCTest
@testable import CanvaiOSChallenge

class CanvaiOSChallengeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // actaully in the mazeModel there is a dictinory of id:room
    // by using a set and iterating the dictionary we check if there is any duplicate keys
    func testFetchUniqueRoom() {
        
        let asyncExpectation = expectation(description: "mazeModelTest")
        
        let mm = MazeModel()
        mm.generate()
        mm.generateComplete = { (rooms, error) in
            
            if let error = error {
                XCTFail("ususally it is request error \(error)")
            } else {
                asyncExpectation.fulfill()
            }
        }
        
        self.waitForExpectations(timeout: 60) { (error) in
            
            if let error = error {
                XCTFail("i havn't catch this but it may occur if the maze is very big \(error)")
            } else {
                // Time Complexity: O(n), all the rooms
                // Space Complexity: O(n), the number of element in the set
                var set = Set<String>()
                for (key, _) in mm.roomCache {
                    if set.contains(key) {
                        XCTFail("omg \(key) just has been fetched twice")
                    } else {
                        set.insert(key)
                    }
                }
            }
            
        }
        
        XCTAssert(true);
    }
}
