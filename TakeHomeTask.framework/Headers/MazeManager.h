//
//  MazeManager.h
//  MazeServer
//
//  Copyright © 2016 Canva. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A callback providing either a MazeRoom, or an error.

 @param data  A json encoded data object.
 @param error An error, if the call was unsucessful.
 */
typedef void(^MazeResponse)(NSData * _Nullable data, NSError * _Nullable error);

/**
 A Maze manager, able to create a new maze, and explore existing mazes.
 */
@interface MazeManager: NSObject

/**
 Instantiate a new MazeManager.

 @return a new maze manager.
 */
-(_Nonnull instancetype)init;

/**
 Generates a new maze providing a room identifier or error from the server.

 The response JSON has the following form:

    {
      // a room identifier
      "id":"R4b7f8b8bd464e959"
    }
 
 @param callback   Either a room, or an error.
 */
-(void) fetchStartRoomWithCallback: (MazeResponse _Nonnull)callback;

/**
 Fetches a room description from the server.

 The response JSON has the following form:
    {
      // the same room identifier that you requested
      "id":"R4b7f8b8bd464e959",
      // an image representing the room
      "tileUrl":"https://example.com/sometile.jpg",
      // any connected rooms: north, south, east, or west
      "rooms": { 
        "east": {
          // the room identifier of the connected room
          "room":"R4b7f8c8cd464ee5e"
        },
        "west": {
          // a lock identifier, that can be unlocked into a room identifier
          "lock":"onF1pXP9jUimx0v9+5oBcccqid=="
        }
      },
      // the room's type, for debugging
      "type":"EMPTY"
    }
 
 @param identifier A string identifying the room to be fetched, passing null will find a room in a new maze.
 @param callback   Either a room, or an error.
 */
-(void) fetchRoomWithIdentifier: (NSString * _Nonnull)identifier
                       callback: (MazeResponse _Nonnull)callback;

/**
 Unlock a room with the given lock, this is computationally expensive.

 @param lock An opaque string representing the lock
 
 @returns A room identifier
 */
-(NSString * _Nonnull) unlockRoomWithLock: (NSString * _Nonnull)lock;

@end
