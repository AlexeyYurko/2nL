//
//  Line.swift
//  2nLine
//
//  Created by Alexey Yurko on 30.03.16.
//  Copyright © 2016 Alexey Yurko. All rights reserved.
//


//работа с поиском последовательностей
class Line: Hashable {
    var tiles = [TileType]()
    
    enum LineType: CustomStringConvertible {
        case Horizontal
        case Vertical
        case Diagonal
        
        var description: String {
            switch self {
            case .Horizontal: return "Horizontal"
            case .Vertical: return "Vertical"
            case .Diagonal: return "Diagonal"
            }
        }
    }
    
    var lineType: LineType
    
    init(lineType: LineType) {
        self.lineType = lineType
    }
    
    func addTile(tile: TileType) {
        tiles.append(tile)
    }
    
    func firstTile() -> TileType {
        return tiles[0]
    }
    
    func lastTile() -> TileType {
        return tiles[tiles.count - 1]
    }
    
    var length: Int {
        return tiles.count
    }
    
    var hashValue: Int {
        return tiles.reduce(0) { $0.hashValue ^ $1.hashValue }
    }
}

func ==(lhs: Line, rhs: Line) -> Bool {
    return lhs.tiles == rhs.tiles
}