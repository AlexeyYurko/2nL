//
//  Level.swift
//  2nLine
//
//  Created by Alexey Yurko on 29.03.16.
//  Copyright © 2016 Alexey Yurko. All rights reserved.
//

import Foundation

let NumColumns = 10
let NumRows = 10


// rather inappropriate creation, should be removed, simplify the description of the Level class, consisting of a 10*10 array of type Tile
class Level {
    fileprivate var ground = Array2D<Field>(columns: NumColumns, rows: NumRows)
   
    // call for clearing the field
    func newField() -> Set<Field> {
        return createField()
    }
   
    // generate a field
    fileprivate func createField() -> Set<Field> {
        var set = Set<Field>()
        var spawn: Bool
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                if (row>2&&row<7) && (column > 2 && column<7) {
                    spawn = true} else {
                    spawn = false}
                
            let field = Field(column: column, row: row, tile: 0, isSpawn: spawn)
                ground[column, row] = field
                set.insert(field)
            }
        }
        return set
    }
 
}
