//
//  Level.swift
//  2nLine
//
//  Created by Alexey Yurko on 29.03.16.
//  Copyright © 2016 Alexey Yurko. All rights reserved.
//

import SpriteKit

let TileColors: UInt32 = 6 // max = 6

// TileType class, block description - coordinates, colour, sprite
class TileType: Hashable {
    var column: Int
    var row: Int
    var tile: Int
    var sprite: SKSpriteNode?
    
    init(column: Int, row: Int, tile: Int) {
        self.column = column
        self.row = row
        self.tile = tile
    }
   
    var hashValue: Int {
        return row*10 + column
    }
    
}

func ==(lhs: TileType, rhs: TileType) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}

func randomForTile() -> Int {
    return Int(arc4random_uniform(TileColors))+1
}
