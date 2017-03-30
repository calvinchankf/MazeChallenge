#### Just for record
2 weeks ago i was given a challenge to make a maze iOS app, I was just given one graph node, and display a maze by constructing a graph. It is quite interesting and I started to do it once I have received the challenge. Unfortunately....the recruitor replied me that `While the general consensus is that the challenge was good overall -- compared to some of the other reviews that have come in this week, it wasn't strong enough to progress to a technical interview at this point in time.`

Anyway, lesson learned.

#### Approach
Basically it is a graph problem. I do it by using a recursive depth first search. I use a hashTable to avoiding visiting a same room (acyclic graph, forever searching).

After searching, I end up use a coordinate system to store all the rooms (starting from 0,0)

Then the coordinate system will have some negative x and y, so I iterating the coordinate system to find the min and max and convert it to an 2D array.
i.e.
```
let width = maxX - minX + 1 // e.g. -2 -1 0 1 2 3 -> 6
let height = maxY - minY + 1
```

To ***speed up the loop up time*** of converting a coordinate system to an array, I basically use a ***hashTable*** to store the coordinate and the corresponding room e.g. `"x,y": rawroom`

#### Project Structure
Model
- MazeModel // magic happens here!!!

View
- RoomCell // CollectionView Cell

ViewController
- ViewController // the starting point

Unit
- RawRoom // parse all the data from framework
- Room // cell data

#### Lastly, there are some details


 1. It is not an easy depth first search, because the data come from callbacks, so i need a DispatchGroup to get notified when all async calls `fetchRoom` is done

 2. The requirements said `Each time the "Generate" button is pressed you must fetch a new starting room from the server`. It means that I have to cancel all sync calls `fetchRoom` and generate the maze again if 'generate button' is clicked. It can be done with a boolean flag and leverage the power of DispatchGroup

#### Dependencies
- SwiftyJSON // help parsing the raw json object, it is painful to do it because of long and messy optional chaining
- Kingfisher // fetch and cache images

please `pod install` and go :)
