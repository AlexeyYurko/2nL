//
//  SquareShape.swift
//  
//
//  Created by Alexey Yurko on 03.03.16.
//  Copyright © 2016 Alexey Yurko. All rights reserved.
//

class SquareShape:Shape {
  
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero:       [(0, 0), (0, 1), (1, 1), (1, 0)],
            Orientation.OneEighty:  [(1, 1), (1, 0), (0, 0), (0, 1)],
            Orientation.Ninety:     [(0, 1), (1, 1), (1, 0), (0, 0)],
            Orientation.TwoSeventy: [(1, 0), (0, 0), (0, 1), (1, 1)]
        ]
    }
    
}

