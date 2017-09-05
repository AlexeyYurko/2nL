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


//достаточно неуместное творение, надо убирать, упрощать
//описание класса Уровень(хм), состоящего из массива 10*10 типа Tile
class Level {
    fileprivate var ground = Array2D<Field>(columns: NumColumns, rows: NumRows)
   
    //вызываем очистку поля
    func newField() -> Set<Field> {
        return createField()
    }
   
    //формируем поле
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
