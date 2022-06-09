//
//  Field.swift
//  2nLine
//
//  Created by Alexey Yurko on 30.03.16.
//  Copyright © 2016 Alexey Yurko. All rights reserved.
//

import SpriteKit

// class field, description of the block - coordinates, what is stored, whether it is a "spawn" field
class Field: Hashable {
    var column: Int
    var row: Int
    let tile: Int
    var isSpawn: Bool
    var sprite: SKSpriteNode?
    
    init(column: Int, row: Int, tile: Int, isSpawn: Bool) {
        self.column = column
        self.row = row
        self.tile = tile
        self.isSpawn = isSpawn
    }
    
    var hashValue: Int {
        return row*10 + column
    }
    
}

func ==(lhs: Field, rhs: Field) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}
