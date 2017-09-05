//
//  nLine
//
//  Created by Alexey Yurko on 03.03.16.
//  Copyright © 2016 Alexey Yurko. All rights reserved.
//

import Foundation

/*let NumColumns = 10
let NumRows = 20
*/

let StartingColumn = 4
let StartingRow = 4

let spawnStart = 3
let spawnEnd = 6

let PreviewColumn = 4
let PreviewRow = 11

let PointsPerLine = 50
let LevelThreshold = 1000

protocol NLineDelegate {
    // Invoked when the current round ends
    func gameDidEnd(_ nLine: NLine)
    
    // Invoked after a new game has begun
    func gameDidBegin(_ nLine: NLine)
    
    // Invoked when the falling shape has become part of the game board
    func gameShapeDidLand(_ nLine: NLine)
    
    // Invoked when the falling shape has changed its location
    func gameShapeDidMove(_ nLine: NLine)
    
    // Invoked when the falling shape has changed its location after being dropped
    func gameShapeDidDrop(_ nLine: NLine)
    
    //color shift
    func colorShiftMake(_ nLine: NLine)
    
    // Invoked when the game has reached a new level
    func gameDidLevelUp(_ nLine: NLine)
}

class NLine {
    
    // игровое поле, tiles.
    var blockArray:Array2D<TileType>
    
    var nextShape:Shape?
    var fallingShape:Shape?
    var delegate:NLineDelegate?

    var score = 0
    var round = 1
    
    init() {
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<TileType>(columns: NumColumns, rows: NumRows)
    }
    
    func beginGame() {
        if (nextShape == nil) {
            nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        }
        delegate?.gameDidBegin(self)
    }
    
    func newShape() -> (fallingShape:Shape?, nextShape:Shape?) {
        fallingShape = nextShape
        nextShape = Shape.random(PreviewColumn, startingRow: PreviewRow)
        fallingShape?.moveTo(StartingColumn, row: StartingRow)
        
     // guard detectIllegalPlacement() == false else {
        
        if !detectPossibleSpawnPoint() {
            nextShape = fallingShape
            nextShape!.moveTo(PreviewColumn, row: PreviewRow)
            endGame()
            return (nil, nil)
            }
       // }
        return (fallingShape, nextShape)
    }
    
    
    //смотрим на возможность посадки фигуры на свободное поле в spawn zone
    func detectPossibleSpawnPoint() -> Bool {
        var diffsXY: [(X:Int, Y: Int)] = [(0, 0)]
        
        for diffY in -1...2 {
            for diffX in -1...2 {
                if detectPlacement(diffX, Y: diffY) {
                    diffsXY.append(X: diffX, Y: diffY)
                }
            }
        }
        
        if diffsXY.count > 1 {
            let variable = 1+random(diffsXY.count-1)
            
            let shape = fallingShape
            
            for block in shape!.blocks {
                block.column = block.column+diffsXY[variable].X
                block.row = block.row+diffsXY[variable].Y
            }
            shape!.column = shape!.column + diffsXY[variable].X
            shape!.row = shape!.row + diffsXY[variable].Y
            fallingShape = shape
            
            return true
        }
    return false
    }
    
    //проверка на возможность установки блока, применяется в процедуре detectPossibleSpawnPoint, для определения места установки в рамках spawn zone
    func detectPlacement(_ X: Int, Y: Int) -> Bool {

        guard let shape = fallingShape else {
            return false
        }

        for block in shape.blocks {
            if (block.column + X) < spawnStart {return false}
            if (block.column + X) > spawnEnd {return false}
            
            if (block.row + Y) < spawnStart {return false}
            if (block.row + Y) > spawnEnd {return false}
            
            if (blockArray[block.column + X, block.row + Y] != nil) {
                        return false
                    }
        }
            return true
    }
    
    
    // для detectPossibleSpawnPoint и вообще
    func random(_ max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
    }
    
    //проверка на возможность установки блока, применяется по всему телу
    func detectIllegalPlacement() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for block in shape.blocks {
            if block.column < 0 || block.column >= NumColumns
                || block.row < 0 || block.row >= NumRows {
                return true
            } else if blockArray[block.column, block.row] != nil {
                return true
            }
        }
        return false
    }

    func settleShape() {
        guard let shape = fallingShape else {
            return
        }
        for block in shape.blocks {
            blockArray[block.column, block.row] = block
        }
        fallingShape = nil
        delegate?.gameShapeDidLand(self)
    }
    
    func endGame() {
        score = 0
        round = 1
        delegate?.gameDidEnd(self)
    }
    
    func dropShape() {
      //  delegate?.gameShapeDidDrop(self)
             if !detectIllegalPlacement() {
            delegate?.gameShapeDidDrop(self)
            } else {
                endGame()
        }
    }
    
    func letShapeFall() {
         if detectIllegalPlacement() {
                endGame()
            } else {
                settleShape()
         }
    }
    
    func rotateShape() {
        guard let shape = fallingShape else {
            return
        }
        
        if shape.blocks.count == 1 {return}
        
        shape.rotateClockwise()
        guard detectIllegalPlacement() == false else {
            shape.rotateCounterClockwise()
            return
        }
        delegate?.gameShapeDidMove(self)
    }
    
    func moveShapeLeft() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftLeftByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftRightByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(self)
    }
    
    func moveShapeRight() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftRightByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftLeftByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(self)
}
    
    func moveShapeUp() {
        guard let shape = fallingShape else {
            return
        }
        shape.raiseShapeByOneRow()
        guard detectIllegalPlacement() == false else {
            shape.lowerShapeByOneRow()
            return
        }
        delegate?.gameShapeDidMove(self)
    }
    
    func moveShapeDown() {
        guard let shape = fallingShape else {
            return
        }
        shape.lowerShapeByOneRow()
        guard detectIllegalPlacement() == false else {
            shape.raiseShapeByOneRow()
            return
        }
        delegate?.gameShapeDidMove(self)
    }
    
    //сдвиг цвета
    func colorShift() {
        
        var tileArray: [Int] = []
        
        guard let shape = fallingShape else {
            return
        }
        
        let tiles = shape.blocks.count
        
        if tiles == 1 {return}
        
        for block in shape.blocks {
            tileArray.append(block.tile)
        }
        
        
        for index in 0...(tiles-2) {
            shape.blocks[index].tile = tileArray[index+1]
        }
        
        shape.blocks[tiles-1].tile = tileArray[0]
        
        delegate?.colorShiftMake(self)
    }
    
    // обнуление поля при нажатии Новая Игра
    func removeBlocksWhenNewGamePressed() -> Array<TileType> {
        var allBlocks = Array<TileType>()
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                allBlocks.append(block)
                blockArray[column, row] = nil
            }
        }
        
        for tile in (fallingShape?.blocks)! {
            allBlocks.append(tile)
        }
        
        return allBlocks
    }
    
    //обнуление поля в случае конца игры, когда некуда или не успел поставить фигуру
    func removeAllBlocks() -> Array<TileType> {
        var allBlocks = Array<TileType>()
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                allBlocks.append(block)
                blockArray[column, row] = nil
            }
        }
        return allBlocks
    }
    
//************************
    // обнуление ячеек из набора line
    fileprivate func removeTiles(_ lines: Set<Line>) {
        for blocks in lines {
            for block in blocks.tiles {
                scoreForRemove() //попутно считаем баллы
                blockArray[block.column, block.row] = nil
                }
            }
    }
    
    func scoreForRemove() {
        let points = PointsPerLine * round
        score += points
        if score >= round * LevelThreshold {
            round += 1
            roundShapeCap()
            delegate?.gameDidLevelUp(self)
        }
        
    }

    // определяем максимальное кол-во фигур
    func roundShapeCap() {
        switch round {
        case 1...2: NumShapeTypes = 4
        case 3...4: NumShapeTypes = 7
        case 5...10: NumShapeTypes = 11
        default: NumShapeTypes = 11
        }
    }
    
    //поиск линий - общий
    func removeMatches() -> Set<Line> {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        let diagonalChains = detectDiagonalMatches()
        var unitedChains = horizontalChains.union(verticalChains)
        unitedChains = diagonalChains.union(unitedChains)
        
        removeTiles(unitedChains)
        
        return unitedChains
    }
        
    //поиск диагональный линий
    fileprivate func detectDiagonalMatches() -> Set<Line> {
        var set = Set<Line>()
       
        //  /
        for var row in stride(from: 0, to: NumRows - 2, by: 1) {
            for var column in stride(from: 0, to: NumColumns - 2, by: 1) {
                if let tile = blockArray[column, row]
                {
                    let matchType = tile.tile
                    if blockArray[column + 1, row+1]?.tile == matchType &&
                        blockArray[column + 2, row+2]?.tile == matchType
                    {
                        let line = Line(lineType: .diagonal)
                        
                        var workColumn = column
                        var workRow = row

                        repeat {
                            line.addTile(blockArray[workColumn, workRow]!)
                            workColumn += 1
                            workRow += 1
                        }
                            while workRow < NumRows && workColumn < NumColumns && blockArray[workColumn, workRow]?.tile == matchType
                        set.insert(line)
                    }
                }
                column += 1
            }
            row += 1
        }
        
        //  \
        
        for var row in stride(from: 0, to: NumRows - 2, by: 1) {
            for var column in (2..<NumColumns).reversed() {
                if let tile = blockArray[column, row]
                {
                    let matchType = tile.tile
                    if blockArray[column - 1, row + 1]?.tile == matchType &&
                        blockArray[column - 2, row + 2]?.tile == matchType {
                        let line = Line(lineType: .diagonal)
                        
                        var workColumn = column
                        var workRow = row
                        
                        repeat {
                            line.addTile(blockArray[workColumn, workRow]!)
                            workColumn -= 1
                            workRow += 1
                        } while workRow < NumRows && workColumn > -1 && blockArray[workColumn, workRow]?.tile == matchType
                        
                        set.insert(line)
                    }
                }
                column -= 1
            }
            row += 1
        }
        
        return set
    }
    
    
    //поиск горизонтальных линий
    fileprivate func detectHorizontalMatches() -> Set<Line> {
        var set = Set<Line>()
        for row in 0..<NumRows {
            for var column in stride(from: 0, to: NumColumns - 2, by: 1) {
                if let tile = blockArray[column, row]
                 {
                    let matchType = tile.tile
                    if blockArray[column + 1, row]?.tile == matchType &&
                        blockArray[column + 2, row]?.tile == matchType {
                        let line = Line(lineType: .horizontal)
                        repeat {
                            line.addTile(blockArray[column, row]!)
                            column += 1
                        }
                            while column < NumColumns && blockArray[column, row]?.tile == matchType
                        set.insert(line)
                       continue
                    }
                }
                column += 1
            }
        }
        return set
    }
    
    //поиск вертикальных линий
    fileprivate func detectVerticalMatches() -> Set<Line> {
        var set = Set<Line>()
        for column in 0..<NumColumns {
            for var row in stride(from: 0, to: NumRows - 2, by: 1) {
                if let tile = blockArray[column, row]
                {
                    let matchType = tile.tile
                    if blockArray[column, row + 1]?.tile == matchType &&
                        blockArray[column, row + 2]?.tile == matchType {
                        let line = Line(lineType: .vertical)
                        repeat {
                            line.addTile(blockArray[column, row]!)
                            row += 1
                        }
                            while row < NumRows && blockArray[column, row]?.tile == matchType
                        set.insert(line)
                        continue
                    }
                }
                row += 1
            }
        }
        return set
    }
    
    
    
}
